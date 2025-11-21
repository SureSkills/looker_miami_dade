connection: "bigquery_public_data_looker"

include: "views/*.view.lkml"                # include all views in the views/ folder in this project

explore: student_master {
  from:  performance

  join: demographics {
    type: left_outer
    relationship: many_to_many
    sql_on: ${performance.student_id} = ${demographics.student_id};;
  }
  join: attendance{
    type: left_outer
    relationship: many_to_many
    sql_on: ${performance.student_id} = ${attendance.student_id};;
  }
}

## 1. student_performance Explore (KPIs: Proficiency, Equity, Instructional Capacity)

# Primary focus: Student assessment results and linking to demographics/staff.
explore: performance {
  label: "Student Performance & Teacher Analysis"
  description: "Assessment results linked to demographics, teacher, and course for proficiency and equity metrics."
  # Base view: performance contains most dimensions needed (teacher_id, student_id, course_id, flags)
  from: performance

  # --- Joins for Proficiency & Equity ---

  # 1. Link to Student Demographic Data (for ESE/ELL flags and Gain Flag)
  join: demographics {
    type: left_outer
    # Joining on Student ID and School Year for precision
    sql_on: ${performance.student_id} = ${demographics.student_id}
      AND ${performance.school_year} = ${demographics.school_year} ;;
    relationship: many_to_one
  }

  # 2. Link to Teacher/Staffing Data (for Years Experience and Avg Growth Index)
  join: staffing {
    type: left_outer
    sql_on: ${performance.teacher_id} = ${staffing.teacher_id} ;;
    relationship: many_to_one
  }

  # 3. Link to Course Reference (optional, performance has course_name/id/grade, but included for complete reference details)
  join: course_reference {
    type: left_outer
    # Joining on Course ID and School Year
    sql_on: ${performance.course_id} = ${course_reference.course_id}
      AND ${performance.school_year} = ${course_reference.school_year} ;;
    relationship: many_to_one
  }

  # NOTE: The 'roster' view is not strictly required here as performance already contains teacher_id/course_id/student_id.
}

## 2. course_attendance Explore (KPI: Operational Health / Chronic Absences)

# Primary focus: Chronic Absences per Course and Grade Level.
explore: course_attendance {
  label: "Chronic Absence Rates by Course"
  description: "Leverages pre-calculated chronic flags and aggregates by course and grade."
  # Base view: attendance already contains the ChronicFlag, CourseID, and GradeLevel
  from: attendance

  # --- Joins for Context ---

  # 1. Link to Teacher/Staffing Data (to disaggregate by teacher, if needed)
  join: staffing {
    type: left_outer
    sql_on: ${course_attendance.teacher_id} = ${staffing.teacher_id} ;;
    relationship: many_to_one
  }

  # 2. Link to Course Reference (for course/department detail, if needed)
  join: course_reference {
    type: left_outer
    # Joining on Course ID and School Year
    sql_on: ${course_attendance.course_id} = ${course_reference.course_id}
      AND ${course_attendance.school_year}attendance.school_year} = ${course_reference.school_year} ;;
    relationship: many_to_one
  }
}

## 3. staff_capacity Explore (KPI: Instructional Capacity / Growth vs. Experience)

# Primary focus: Comparing teacher metrics directly.
explore: staff_capacity {
  label: "Instructional Capacity (Staffing)"
  description: "Analyze teacher experience (YearsExperience) against average student growth (AvgGrowthIndex)."
  # Base view: staffing contains both key dimensions (YearsExperience and AvgGrowthIndex)
  from: staffing

  # --- Joins for Student/Course Context ---

  # 1. Link to Roster (to see which courses the staff member teaches, if needed for filtering)
  join: roster {
    type: left_outer
    sql_on: ${staff_capacity.teacher_id} = ${roster.teacher_id} ;;
    relationship: one_to_many
  }

  # NOTE: Since staffing.AvgGrowthIndex already exists, you don't need to join performance and calculate the average here,
  # making this Explore very efficient for the Instructional Capacity KPI.
}
