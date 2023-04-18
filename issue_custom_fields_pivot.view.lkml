view: issue_custom_fields_pivot {
  derived_table: {
    sql:

    with field_categories as (
        select
          id as field_id
          ,name as field_name
        from fivetran.jira.field
        where lower(name) in (
          'labels'
          ,'project start'
          ,'project complete'
          ,'project size'
          ,'v2mom method fy23'
          ,'v2mom method fy22'
          ,'stakeholders'
          ,'product stage'
          ,'b&mm product'
          ,'prodops category'
          ,'epic link'
          ,'incident-severity'
          ,'identification source'
          ,'incident-repeat outage'
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
            ,case when lower(fc.field_name) in ('labels', 'project start', 'project complete') then imh.value else fo.name end as field_value
          from fivetran.jira.issue issue
          join fivetran.jira.issue_multiselect_history imh
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
            ,case when lower(fc.field_name) in ('labels', 'project start', 'project complete') then ifh.value else fo.name end as field_value
          from fivetran.jira.issue issue
          join fivetran.jira.issue_field_history ifh
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
          left join fivetran.jira.epic epic
              on ifh.value = epic.id::varchar

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
                  ,incident_repeate_outage
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
  }

  dimension: incident_severity {
    type:  string
    sql: ${TABLE}.incident_severity ;;
  }

  dimension: identification_source {
    type:  string
    sql: ${TABLE}.identification_source ;;
  }

  dimension: incident_repeat_outage {
    type: string
    sql: ${TABLE}.incident_repeat_outage ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

}
