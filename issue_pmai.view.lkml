view: issue_pmai {
  derived_table: {
    sql:

        with inci_issues as (
          select
              issue.id
          from fivetran.jira.issue
          left join fivetran.jira.status --status for pmai tickets
              on issue.status = status.id
          left join fivetran.jira.priority --priority for pmai tickets
              on issue.priority = priority.id
          left join fivetran.jira.user
              on issue.assignee = user.id
          where key like 'INCI-%' and summary not ilike 'pmai tracker%'
      )

      ,pmai as (
          select
              ii.id as inci_id
              ,link.related_issue_id as pmai_tracker_epic_id
              ,issue.key as pmai_tracker_epic_key
          from inci_issues ii
          join fivetran.jira.issue_link link
              on ii.id = link.issue_id
          join fivetran.jira.issue
              on link.related_issue_id = issue.id
          where link.relationship = 'causes' --getting all linked tickets to original incident
          and issue.summary ilike 'pmai tracker%' --limiting to only pmai tracker epic
      )

      select
          pm.inci_id
          ,pm.pmai_tracker_epic_id
          ,pm.pmai_tracker_epic_key
          ,issue.id as pmai_issue_id
          ,issue.key as pmai_issue_key
          ,issue.created as pmai_created
          ,issue.summary as pmai_summary
          ,issue.description as pmai_description
          ,status.name as pmai_status
          ,priority.name as pmai_priority
          ,user.name as pmai_assignee
      from fivetran.jira.issue
      join pmai pm
          on issue.parent_id = pm.pmai_tracker_epic_id --get all tickets in the pmai tracker epic; these are pmai tickets
      left join fivetran.jira.status --status for pmai tickets
          on issue.status = status.id
      left join fivetran.jira.priority --priority for pmai tickets
          on issue.priority = priority.id
      left join fivetran.jira.user
          on issue.assignee = user.id
      where issue.summary not ilike 'PLACEHOLDER | Delete after adding PMAIs%'
      ;;

  }


  dimension: inci_id {
    type: string
    sql: ${TABLE}.inci_id ;;
  }

  dimension: pmai_tracker_epic_id {
    type:  string
    sql: ${TABLE}.pmai_tracker_epic_id ;;
  }

  dimension: pmai_tracker_epic_key {
    type:  string
    sql: ${TABLE}.pmai_tracker_epic_key ;;
  }

  dimension: pmai_issue_id {
    type:  string
    sql: ${TABLE}.pmai_issue_id ;;
  }

  dimension: pmai_issue_key {
    type:  string
    sql: ${TABLE}.pmai_issue_key ;;
    primary_key: yes
  }

  dimension_group: pmai_created {
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
    sql: ${TABLE}.pmai_created ;;
  }

  dimension: pmai_summary {
    type:  string
    sql: ${TABLE}.pmai_summary ;;
  }

  dimension: pmai_description {
    type:  string
    sql: ${TABLE}.pmai_description ;;
  }

  dimension: pmai_status {
    type:  string
    sql: ${TABLE}.pmai_status ;;
  }

  dimension: pmai_priority {
    type:  string
    sql: ${TABLE}.pmai_priority ;;
  }

  dimension: pmai_assignee {
    type:  string
    sql: ${TABLE}.pmai_assignee ;;
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
