explore: issue_core {
  extension: required
  join: project {
    type: left_outer
    sql_on: ${project.id} = ${issue.project} ;;
    relationship: one_to_many
  }
  join:  issue_type {
    type:  left_outer
    sql_on: ${issue.issue_type} = ${issue_type.id} ;;
    relationship: many_to_one
  }
  join:  priority {
    type:  left_outer
    sql_on: ${issue.priority} = ${priority.id} ;;
    relationship: many_to_one
  }
  join:  status {
    type:  left_outer
    sql_on: ${issue.status} = ${status.id} ;;
    relationship: many_to_one
  }
  join:  status_category {
    type:  left_outer
    sql_on: ${status.status_category_id} = ${status_category.id} ;;
    relationship: many_to_one
  }
  join: user {
    type: left_outer
    sql_on: ${issue.assignee} = ${user.id} ;;
    relationship: many_to_one
  }
  join: comment {
    type: left_outer
    sql_on: ${issue.id} = ${comment.issue_id} ;;
    relationship: one_to_many
  }
  join: epic {
    type:  left_outer
    sql_on:  ${issue.summary} = ${epic.name} ;;
    relationship: one_to_many
  }
  join: issue_custom_fields_pivot {
    type:  left_outer
    sql_on: ${issue.id} = ${issue_custom_fields_pivot.issue_id} ;;
    relationship:  one_to_many
  }
  join: issue_pmai {
    type:  left_outer
    sql_on: ${issue.id} = ${issue_pmai.inci_id} ;;
    relationship:  one_to_many
  }


}
