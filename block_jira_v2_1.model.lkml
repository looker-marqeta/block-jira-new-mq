include: "/dashboards/*.dashboard"
include: "*.explore"
include: "*.view"
include: "*.model"

persist_with: fivetran_datagroup

explore: sprint {
  extends: [sprint_config]
}

explore: version {
  extends: [version_config]
}

explore: issue {
  extends: [issue_config]
}

explore: project {
  extends: [project_config]
}

explore: epic {
  extends: [epic_config]
}
