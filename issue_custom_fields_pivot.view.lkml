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
              and fc.field_name <> 'Partner'
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
          left join fivetran.jira.field_option fo
              on ifh.value = fo.id::varchar
        )
        --pivot results of above sub-query union to create columns for each field_name; can take max(field_value) since there's 1:1 relationship
        pivot (max(field_value) for field_name in (
          'Labels'
          ,'Project Start'
          ,'Project Complete'
          ,'Project Size'
          ,'V2MOM Method FY22'
          ,'V2MOM Method FY23'
            )) as p(key, issue_id, labels, project_start, project_complete, project_size, v2mom_method_fy22, v2mom_method_fy23)

  ;;

  }


  dimension: key {
     type: string
     sql: ${TABLE}.key ;;
   }

  dimension: issue_id {
    type: string
    sql: ${TABLE}.issue_id ;;
  }

  dimension: labels {
    type:  string
    sql: ${TABLE}.labels ;;
  }

  dimension: project_start {
    type:  string
    sql: ${TABLE}.project_start ;;
  }

  dimension: project_complete {
    type:  string
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

  measure: count {
    type: count
    drill_fields: []
  }

}
