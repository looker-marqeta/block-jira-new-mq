### CURRENT OVERVIEW OF STATUS OF PROJECTS, ISSUES, AND ISSUE FACTS (E.G. # OF COMMENTS)

explore: project_core {
  extension: required
  join: issue {
    type:  left_outer
    sql_on: ${project.id} = ${issue.project} ;;
    relationship: many_to_one
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
    sql_on: ${board.id} = ${issue_board.board_id} ;;
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
  join: issue_custom_fields_pivot {
    type:  left_outer
    sql_on: ${issue.id} = ${issue_custom_fields_pivot.issue_id} ;;
    relationship:  one_to_many
  }
}
