view: issue_timestamp_pivot {
  derived_table: {
    sql:

   with field_categories as (
        select
          id as field_id
          ,name as field_name
        from fivetran.jira.field
        where lower(name) in (
          'impact start time'
          ,'stable time'
        )
        group by 1,2
        )

        select
          *
        from (
          select
            issue.key
            ,issue.id as issue_id
            ,fc.field_name
            ,case when lower(fc.field_name) in ('impact start time', 'stable time') then imh.value::timestamp_ntz else fo.name::timestamp_ntz end as field_value
          from fivetran.jira.issue issue
          join fivetran.jira.issue_multiselect_history imh -- For fields with multiple options
              on issue.id = imh.issue_id
              and imh.is_active = 'TRUE'
          join field_categories fc
              on imh.field_id = fc.field_id
              and fc.field_name not in ('Partner', 'Epic Link')
          left join fivetran.jira.field_option fo
              on imh.value = fo.id::varchar

          UNION ALL

          select
            issue.key
            ,issue.id as issue_id
            ,fc.field_name
            ,case when lower(fc.field_name) in ('impact start time', 'stable time') then ifh.value::timestamp_ntz else fo.name::timestamp_ntz end as field_value
          from fivetran.jira.issue issue
          join fivetran.jira.issue_field_history ifh -- for fields with only 1 option
              on issue.id = ifh.issue_id
              and ifh.is_active = 'TRUE'
          join field_categories fc
              on ifh.field_id = fc.field_id
              and fc.field_name not in ('Epic Link')
          left join fivetran.jira.field_option fo
              on ifh.value = fo.id::varchar

          UNION ALL

          select
            issue.key
            ,issue.id as issue_id
            ,fc.field_name
            ,name as field_value --epic name
          from fivetran.jira.issue issue
          join fivetran.jira.issue_field_history ifh
              on issue.id = ifh.issue_id
              and ifh.is_active = 'TRUE'
          join field_categories fc
              on ifh.field_id = fc.field_id
              and fc.field_name in ('Epic Link')
          left join fivetran.jira.epic epic  -- specifically just for the Epic Link/Name
              on ifh.value = epic.id::varchar

        )
        --pivot results of above sub-query union to create columns for each field_name; can take max(field_value) since there's 1:1 relationship
        pivot (max(field_value) for field_name in (
          'Impact Start Time'
          ,'Stable Time'
          )) as p(
                  key
                  ,issue_id
                  ,impact_start_time
                  ,stable_time
                  )
      ;;

  }


  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
    primary_key: yes
  }

  dimension: issue_id {
    type: string
    sql: ${TABLE}.issue_id ;;
    primary_key: yes
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
    sql: ${TABLE}.impact_start_time ;;
  }

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
    sql: to_timestamp(${TABLE}.stable_time) ;;
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


  measure: count {
    type: count
    drill_fields: []
  }
  measure: percent_of_total {
    type: percent_of_total
    sql: ${count} ;;
  }

}
