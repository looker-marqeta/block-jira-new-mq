include: "issue_type.view"

view: issue_type {
  extends: [issue_type_config]
}

view: issue_type_core {
  extension: required
  sql_table_name: @{SCHEMA_NAME}.issue_type ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.ID ;;
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

  dimension: description {
    type: string
    sql: ${TABLE}.DESCRIPTION ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: subtask {
    type: yesno
    sql: ${TABLE}.SUBTASK ;;
  }

  dimension: is_bug {
    type: yesno
    sql: ${name} = 'Bug' ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name]
  }
}
