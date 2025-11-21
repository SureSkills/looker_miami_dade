view: performance {
  sql_table_name: cloud-training-demos.k12_nwhs.performance
    ;;

  dimension: achievement_label {
    type: string
    sql: ${TABLE}.AchievementLabel ;;
  }

  dimension: achievement_level {
    type: number
    sql: ${TABLE}.AchievementLevel ;;
  }

  dimension_group: assessment {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.AssessmentDate ;;
  }

  dimension: benchmark {
    type: string
    sql: ${TABLE}.Benchmark ;;
  }

  dimension: course_id {
    type: string
    sql: ${TABLE}.CourseID ;;
  }

  dimension: course_name {
    type: string
    sql: ${TABLE}.CourseName ;;
  }

  dimension: grade_level {
    type: number
    sql: ${TABLE}.GradeLevel ;;
  }

  dimension: growth_index {
    type: number
    sql: ${TABLE}.GrowthIndex ;;
  }

  dimension: proficient_flag {
    type: number
    sql: ${TABLE}.ProficientFlag ;;
  }

  dimension: school_year {
    type: string
    sql: ${TABLE}.SchoolYear ;;
  }

  dimension: score {
    type: number
    sql: ${TABLE}.Score ;;
  }

  dimension: section_id {
    type: string
    sql: ${TABLE}.SectionID ;;
  }

  dimension: student_id {
    type: string
    sql: ${TABLE}.StudentID ;;
  }

  dimension: teacher_email {
    type: string
    sql: ${TABLE}.TeacherEmail ;;
  }

  dimension: teacher_id {
    type: string
    sql: ${TABLE}.TeacherID ;;
  }

  dimension: term {
    type: string
    sql: ${TABLE}.Term ;;
  }

  measure: students_proficient {
    label: "Students Proficient (Latest Benchmark)"
    type: sum
    # Summing the flag counts students who are proficient
    sql: ${proficient_flag} ;;
    drill_fields: [student_id, teacher_id]
  }

  measure: distinct_students_tested {
    label: "Distinct Students Tested"
    type: count_distinct
    sql: ${student_id} ;;
    drill_fields: [student_id, teacher_id]
  }

  measure: proficiency_rate {
    label: "Proficiency Rate (%)"
    type: number
    value_format: "0.00%"
    # Formula: (Count of Proficient Students) / (Count of Students Tested)
    sql: ${students_proficient} / NULLIF(${distinct_students_tested}, 0) ;;
  }
}
