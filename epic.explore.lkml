explore: epic_core {
  extension: required
  join: issue_custom_fields_pivot {
    type: left_outer
    sql_on: ${epic.name} = ${issue_custom_fields_pivot.epic_link} ;;
    relationship: one_to_many
  }
  join: issue {
    type: left_outer
    sql_on: ${issue_custom_fields_pivot.issue_id} = ${issue.id} ;;
    relationship: one_to_many
  }
  join:  issue_type {
    type:  left_outer
    sql_on: ${issue.issue_type} = ${issue_type.id} ;;
    relationship: many_to_one
  }
  join: issue_board {
    type: left_outer
    sql_on: ${issue_board.issue_id} = ${issue.id} ;;
    relationship: many_to_one
  }
  join: board {
    type: left_outer
    sql_on: ${issue_board.board_id} = ${board.id} ;;
    relationship: many_to_one
  }
  join: sprint {
    type: left_outer
    sql_on: ${sprint.board_id} = ${board.id} ;;
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
}
