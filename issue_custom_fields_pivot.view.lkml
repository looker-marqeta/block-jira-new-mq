view: issue_custom_fields_pivot {
  derived_table: {
    sql:

        select
          *
        from (
          --pulls all array field values
          select
            issue.key
            ,issue.id as issue_id
            ,field.name as field_name
            ,array_agg(
              case when user.name is not null then user.name --first see if field_name maps to a user
                when sprint.name is not null then sprint.name --next see if there is a match for sprints
                when field_option.name is not null then field_option.name --next see if field_name maps to a field option
                else imh.value end --default to multiselect history value
                )
                within group (order by value)::varchar as field_value
          from fivetran.jira.issue issue
          join fivetran.jira.issue_multiselect_history imh -- For fields with multiple options
              on issue.id = imh.issue_id
              and imh.is_active = 'TRUE'
          join fivetran.jira.field
              on imh.field_id = field.id
              and field.is_array = 'TRUE'
          left join fivetran.jira.field_option field_option
              on imh.value = field_option.id::varchar
          left join fivetran.jira.user user
              on imh.value = user.id
          left join fivetran.jira.sprint sprint
              on imh.value = sprint.id::varchar
        group by 1,2,3


          UNION ALL

          --pull all non-array field values
          select
            issue.key
            ,issue.id as issue_id
            ,case when field.name = 'Start Date' and field_id = 'customfield_15995' then 'Start Date Timestamp' --multiple Start Date fields; this one is the ts version
                else field.name
                end as field_name
             ,case when field.name = 'Epic Link' then epic.name
                 when user.name is not null then user.name
                 when field_option.name is not null then field_option.name
                 else ifh.value
                end as field_value
          from fivetran.jira.issue issue
          join fivetran.jira.issue_field_history ifh -- for fields with only 1 option
              on issue.id = ifh.issue_id
              and ifh.is_active = 'TRUE'
          join fivetran.jira.field
              on ifh.field_id = field.id
              and field.is_array = 'FALSE'
          left join fivetran.jira.field_option field_option
              on ifh.value = field_option.id::varchar
          left join fivetran.jira.user user
              on ifh.value = user.id
          left join fivetran.jira.epic epic  -- specifically just for the Epic Link/Name
              on ifh.value = epic.id::varchar
          where field_id not in ('customfield_15076', 'customfield_15230') -- Start Date fields that should be inactive


        )
        --pivot results of above sub-query union to create columns for each field_name; can take max(field_value) since there's 1:1 relationship
        pivot (max(field_value) for field_name in (
          'Labels'
          ,'Project Start'
          ,'Project Complete'
          ,'Project Size'
          ,'V2MOM Method FY22'
          ,'V2MOM Method FY23'
          ,'Stakeholders'
          ,'Product Stage'
          ,'ProdOps Category'
          ,'B&MM product'
          ,'Epic Link'
          ,'Incident-Severity'
          ,'Identification Source'
          ,'Incident-Repeat Outage'
          ,'Incident-Type'
          ,'VP Responsible'
          ,'Partner'
          ,'Impact Start Time'
          ,'Detection Time'
          ,'Stable Time'
          ,'Authorization Impacted'
          ,'Due Date (Risk)'
          ,'Sprint'
          ,'Start Date'
          ,'Start Date Timestamp'
          ,'End Date'
          ,'Involved Teams'
          ,'Team Owning Incident'
          ,'Story Points (Estimate)'
          )) as p(
                  key
                  ,issue_id
                  ,labels
                  ,project_start
                  ,project_complete
                  ,project_size
                  ,v2mom_method_fy22
                  ,v2mom_method_fy23
                  ,stakeholders
                  ,product_stage
                  ,prodops_category
                  ,bmm_product
                  ,epic_link
                  ,incident_severity
                  ,identification_source
                  ,incident_repeat_outage
                  ,incident_type
                  ,vp_responsible
                  ,partner
                  ,impact_start_time
                  ,detection_time
                  ,stable_time
                  ,authorization_impacted
                  ,due_date_risk
                  ,sprint
                  ,start_date
                  ,start_date_timestamp
                  ,end_date
                  ,involved_teams
                  ,team_owning_incident
                  ,story_points_estimate
                  )
;;

  }


  dimension: key {
     type: string
     sql: ${TABLE}.key ;;
   }

  dimension: issue_id {
    type: string
    sql: ${TABLE}.issue_id ;;
    primary_key: yes
  }

  dimension: labels {
    type:  string
    sql: ${TABLE}.labels ;;
  }

  dimension: project_start {
    type:  date
    sql: ${TABLE}.project_start ;;
  }

  dimension: project_complete {
    type:  date
    sql: ${TABLE}.project_complete ;;
  }

  dimension: project_size {
    type:  string
    sql: ${TABLE}.project_size ;;
  }

  dimension: v2mom_method_fy22 {
    type:  string
    sql: ${TABLE}.v2mom_method_fy22 ;;
  }

  dimension: v2mom_method_fy23 {
    type:  string
    sql: ${TABLE}.v2mom_method_fy23 ;;
  }

  dimension: stakeholders {
    type:  string
    sql: ${TABLE}.stakeholders ;;
  }

  dimension: product_stage {
    type:  string
    sql: ${TABLE}.product_stage ;;
  }

  dimension: prodops_category {
    type:  string
    sql: ${TABLE}.prodops_category ;;
  }

  dimension: bmm_product {
    type:  string
    sql: ${TABLE}.bmm_product ;;
  }

  dimension: epic_link {
    type:  string
    sql: ${TABLE}.epic_link ;;
    label: "Epic Link"
  }

  dimension: incident_severity {
    type:  string
    sql: ${TABLE}.incident_severity ;;
  }

  dimension: severity_level {
    type:  string
    case: {
      when: {
        sql: ${TABLE}.incident_severity in ('SEV3', 'SEV4', 'SEV5') ;;
        label: "SEV3+"
      }
      when: {
        sql: ${TABLE}.incident_severity = 'SEV2' ;;
        label: "SEV2"
      }
      when: {
        sql: ${TABLE}.incident_severity in ('SEV1', 'SEV0') ;;
        label: "SEV0 or 1"
      }
      # Possibly more when statements
      else: "Null"
    }
}

  dimension: identification_source {
    type:  string
    sql: ${TABLE}.identification_source ;;
  }

  dimension: incident_repeat_outage {
    type: string
    sql: ${TABLE}.incident_repeat_outage ;;
  }

  dimension: incident_type {
    type: string
    sql: ${TABLE}.incident_type ;;
  }

  dimension: vp_responsible {
    type: string
    sql: ${TABLE}.vp_responsible ;;
    label: "VP Responsible"
  }

  dimension: partner {
    type: string
    sql: ${TABLE}.partner ;;
    label: "Partner"
  }

  dimension_group: impact_start_time {
    group_label: "Impact Start Time"
    type: time
    # convert_tz: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: to_timestamp_ntz(${TABLE}.impact_start_time) ;;
  }

  #dimension: impact_start_time {
  #  type: string
  #  sql: ${TABLE}.impact_start_time ;;
  #  label: "Impact Start Time"
  #}

  dimension_group: detection_time {
    group_label: "Detection Time"
    type: time
    # convert_tz: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: to_timestamp_ntz(${TABLE}.detection_time) ;;
  }

 # dimension: detection_time {
 #   type: string
 #   sql: ${TABLE}.detection_time ;;
 #   label: "Detection Time"
 # }

  dimension_group: stable_time {
    group_label: "Stable Time"
    type: time
    # convert_tz: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: to_timestamp_ntz(${TABLE}.stable_time) ;;
  }

  #dimension: stable_time {
   # type: string
   # sql: ${TABLE}.stable_time ;;
   # label: "Stable Time"
  #}

  dimension: authorization_impacted {
    type: string
    sql: ${TABLE}.authorization_impacted ;;
    label: "Authorization Impacted"
  }

  dimension_group: due_date_risk {
    group_label: "Due Date (Risk)"
    type: time
    # convert_tz: yes
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: to_date(${TABLE}.due_date_risk) ;;
  }

  dimension: sprint {
    type:  string
    sql: ${TABLE}.sprint ;;
    label: "Sprint"
  }

  dimension_group: start_date {
    group_label: "Start Date"
    type: time
    # convert_tz: yes
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: to_date(${TABLE}.start_date) ;;
  }

  dimension_group: start_date_timestamp {
    group_label: "Start Date Timestamp"
    type: time
    # convert_tz: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: to_timestamp_ntz(${TABLE}.start_date_timestamp) ;;
  }

  dimension_group: end_date {
    group_label: "End Date"
    type: time
    # convert_tz: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: to_timestamp_ntz(${TABLE}.end_date) ;;
  }

  dimension: story_points_estimate {
    type: number
    sql:  ${TABLE}.story_points_estimate ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
  measure: percent_of_total {
    type: percent_of_total
    sql: ${count} ;;
  }

  measure: repeated_inci_count {
    type: count
    hidden: yes
    filters: [incident_repeat_outage: "Yes"]
  }

  measure: repeated_perc {
    type: number
    sql: ${repeated_inci_count} / ${count};;
    value_format_name: percent_0
  }

  measure: story_points_estimate_sum {
    type: sum
    sql: ${story_points_estimate} ;;
  }

  measure: detected_with_monitor_count {
    type: count
    hidden: yes
    filters: [identification_source: "Detected with Monitoring"]
  }

  dimension: detected_with_monitoring {
    type: yesno
    sql: ${identification_source} = 'Detected with Monitoring' ;;
  }

  measure: detected_with_monitoring_perc {
    type: number
    sql: ${detected_with_monitor_count}/${count} ;;
    value_format_name: percent_0
  }

dimension_group: customer_impact {
  type: duration
  intervals: [hour, minute,day]
  sql_start: ${impact_start_time_time} ;;
  sql_end: ${stable_time_time} ;;
}

measure: days_of_impact {
  type: sum
  sql: round(${hours_customer_impact} / 24,0);;
}

  dimension: involved_teams {
    type: string
    sql: ${TABLE}.involved_teams ;;
    label: "Involved Teams"
  }

  dimension: team_owning_incident {
    type: string
    sql: ${TABLE}.team_owning_incident ;;
    label: "Team Owning Incident"
  }

}
