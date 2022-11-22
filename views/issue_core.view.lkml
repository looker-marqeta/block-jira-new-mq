include: "issue.view"

view: issue {
  extends: [issue_config]
}

view: issue_core {
  extension: required
  sql_table_name: @{SCHEMA_NAME}.issue ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}._FIVETRAN_SYNCED ;;
  }

  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
    link: {
    url:"http://@{COMPANY_DOMAIN}.atlassian.net/browse/{{ value }}"
    label: "View in Jira"
    }
  }

  dimension: epic_link {
    type: string
    sql: ${TABLE}.epic_link ;;
    description: "Epic ID Link"
    hidden: yes
  }

  dimension: priority {
    type: number
    hidden: yes
    sql: ${TABLE}.priority ;;
  }

  dimension: resolution {
    group_label: "Resolution"
    hidden: yes
    type: number
    sql: ${TABLE}.resolution ;;
  }

  dimension: status {
    #hidden: yes
    type: number
    sql: ${TABLE}.status ;;
  }

  dimension: self {
    type: string
    sql: ${TABLE}.self ;;
  }

  dimension: change_log {
    type: string
    sql: ${TABLE}.change_log ;;
  }

  dimension: parent_id {
    type: number
    sql: ${TABLE}.parent_id ;;
  }

  dimension: needs_triage {
    type: yesno
    description: "By default, issues with no priority will be labeled as needing triage. This defaul can by modified in the config project. "
    sql: CASE WHEN ${priority.name} IS NULL THEN true ELSE false END ;;
  }

  dimension: is_approaching_sla {
    description: "Wheather the SLA is less than 30 days away."
    type: yesno
    sql: CASE WHEN (${sla.remaining_time_dim}/ (1000 * 60 * 60 * 24)) < 30 THEN true ELSE false END ;;
  }

  measure: count {
    type: count
  }

  measure: number_of_open_issues {
    type: count

    filters: {
      field: status_category.name
      value: "-Done"
    }
  }

  measure: number_of_closed_issues {
    type: count

    filters: {
      field: status_category.name
      value: "Closed"
    }
  }

# Additional field for a simple way to determine
  # if an issue is resolved
  dimension: is_issue_resolved {
    group_label: "Resolution"
    type: yesno
    sql: ${resolved_date} IS NOT NULL ;;
  }

  dimension: external_issue_id {
    type: string
    sql: ${TABLE}.external_issue_id ;;
  }
  dimension: _original_estimate {
    type: number
    sql: ${TABLE}._original_estimate ;;
  }
  dimension: _remaining_estimate {
    type: number
    sql: ${TABLE}._remaining_estimate ;;
  }
  dimension: _time_spent {
    type: number
    sql: ${TABLE}._time_spent ;;
  }
  dimension: assignee {
    type: string
    sql: ${TABLE}.assignee ;;
  }
  dimension_group: created {
    group_label: "Dates"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created ;;
  }
  dimension: department {
    hidden: yes
    type: number
    sql: ${TABLE}.op_department ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }
  dimension_group: due {
    group_label: "Dates"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.due_date ;;
  }
  dimension: environment {
    type: string
    sql: ${TABLE}.environment ;;
  }
  dimension: epic_name {
    type: string
    sql: ${TABLE}.epic_name ;;
  }
  dimension: issue_type {
    hidden: yes
    type: number
    sql: ${TABLE}.issue_type ;;
  }
  dimension: original_estimate {
    type: number
    sql: ${TABLE}.original_estimate ;;
  }

  dimension: project {
    label: "Current Project"
    hidden: yes
    type: number
    sql: ${TABLE}.project ;;
  }

  dimension_group: resolved {
    group_label: "Resolution"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.resolved ;;
  }
  # Custom dimensions for time to resolve issue
  dimension: hours_to_resolve_issue {
    group_label: "Resolution"
    label: "Time to Resolve (Hours)"
    type: number
    sql: timestamp_diff(${resolved_raw}, ${created_raw}, hour) ;;
    value_format_name: decimal_0
  }
  dimension: minutes_to_resolve_issue {
    group_label: "Resolution"
    label: "Time to Resolve (Minutes)"
    type: number
    sql: timestamp_diff(${resolved_raw}, ${created_raw}, minute) ;;
    value_format_name: decimal_0
  }
  dimension: days_to_resolve_issue {
    group_label: "Resolution"
    label: "Time to Resolve (Days)"
    type: number
    sql: timestamp_diff(${resolved_raw}, ${created_raw}, day) ;;
    value_format_name: decimal_0
  }
  measure: total_days_to_resolve_issues_hours {
    group_label: "Resolution"
    label: "Total Days to Resolve Issues"
    description: "The total hours required to resolve all issues in the chosen dimension grouping"
    type: sum
    sql: ${days_to_resolve_issue} ;;
    value_format_name: decimal_0
  }
  measure: avg_days_to_resolve_issues_hours {
    group_label: "Resolution"
    label: "Avg Number of Days to Resolve Issues"
    description: "The average hours required to resolve all issues in the chosen dimension grouping"
    type: average
    sql: ${days_to_resolve_issue} ;;
    value_format_name: decimal_0
  }
  dimension: story_points {
    type: number
    sql: ${TABLE}.story_points ;;
  }
  dimension: summary {
    type: string
    sql: ${TABLE}.summary ;;
  }
  measure: total_story_points {
    type: sum
    sql: ${story_points} ;;
  }
  dimension_group: updated {
    group_label: "Dates"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.updated ;;
  }
  measure: number_of_open_issues_this_month {
    type: count
    filters: {
      field: status_category.name
      value: "-Done"
    }
    filters: {
      field: issue.created_date
      value: "this month"
    }
    drill_fields: [issue_open_drill_set*]
  }
  measure: number_of_resolved_issues {
    type: count
    filters: {
      field: issue.resolved_date
      value: "-NULL"
    }
    drill_fields: [issue_open_drill_set*]
  }
  measure: number_of_issues_resolved_this_month {
    type: count
    filters: {
      field: issue.resolved_date
      value: "this month"
    }
    drill_fields: [issue_closed_drill_set*]
  }
  measure: number_of_issues_resolved_last_month {
    type: count
    filters: {
      field: issue.resolved_date
      value: "last month"
    }
    drill_fields: [issue_closed_drill_set*]
  }
  # ----- Sets of fields for drilling ------
  #set: detail {
  #  fields: [
  #    external_issue_id,
  #  ]
  #}
  set: issue_open_drill_set {
    fields: [key, created_date, status_category.name, assignee]
  }
  set: issue_closed_drill_set {
    fields: [key, resolved_date, assignee]
  }
  set: issue_exclusion_set {
    fields: [number_of_open_issues, number_of_open_issues_this_month, number_of_issues_closed_this_month, number_of_issues_closed_last_month]
  }

}
