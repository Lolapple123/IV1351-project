CREATE INDEX IF NOT EXISTS idx_employee_dept ON Employee(dept_identifier);
CREATE INDEX IF NOT EXISTS idx_employee_email ON Employee(email);
CREATE INDEX IF NOT EXISTS idx_ci_layout ON CourseInstance(courselayout_id);
CREATE INDEX IF NOT EXISTS idx_ci_year_period ON CourseInstance(year, period);
CREATE INDEX IF NOT EXISTS idx_pa_instance ON PlannedActivity(courseinstance_id);
CREATE INDEX IF NOT EXISTS idx_pa_activity ON PlannedActivity(activitytype_id);
CREATE INDEX IF NOT EXISTS idx_alloc_instance ON Allocation(courseinstance_id);
CREATE INDEX IF NOT EXISTS idx_alloc_emp ON Allocation(employee_id);
CREATE INDEX IF NOT EXISTS idx_alloc_activity ON Allocation(activitytype_id);


CREATE OR REPLACE VIEW v_planned_breakdown AS
SELECT
 ci.courseinstance_id,
 cl.course_code,
 cl.hp,
 ci.period,
 ci.year,
 ci.num_students,


 COALESCE(SUM(CASE WHEN at.activity_name = 'Lecture'
                   THEN pa.planned_hours * at.factor END), 0) AS lecture_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Tutorial'
                   THEN pa.planned_hours * at.factor END), 0) AS tutorial_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Lab'
                   THEN pa.planned_hours * at.factor END), 0) AS lab_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Seminar'
                   THEN pa.planned_hours * at.factor END), 0) AS seminar_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Overhead'
                   THEN pa.planned_hours * at.factor END), 0) AS overhead_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Admin'
                   THEN pa.planned_hours * at.factor END), 0) AS admin_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Exam'
                   THEN pa.planned_hours * at.factor END), 0) AS exam_hours,


 COALESCE(SUM(pa.planned_hours * at.factor), 0) AS total_planned_hours


FROM CourseInstance ci
JOIN CourseLayout cl ON ci.courselayout_id = cl.course_layout_id
LEFT JOIN PlannedActivity pa ON pa.courseinstance_id = ci.courseinstance_id
LEFT JOIN ActivityType at ON pa.activitytype_id = at.activitytype_id
GROUP BY ci.courseinstance_id, cl.course_code, cl.hp, ci.period, ci.year, ci.num_students;


CREATE OR REPLACE VIEW v_actual_breakdown AS
SELECT
 a.courseinstance_id,
 cl.course_code,
 cl.hp,
 ci.period,
 ci.year,
 a.employee_id,


 p.first_name || ' ' || p.last_name AS teacher_name,
 e.job_title,


 COALESCE(SUM(CASE WHEN at.activity_name = 'Lecture'
                   THEN a.hours_allocated * at.factor END), 0) AS lecture_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Tutorial'
                   THEN a.hours_allocated * at.factor END), 0) AS tutorial_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Lab'
                   THEN a.hours_allocated * at.factor END), 0) AS lab_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Seminar'
                   THEN a.hours_allocated * at.factor END), 0) AS seminar_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Overhead'
                   THEN a.hours_allocated * at.factor END), 0) AS overhead_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Admin'
                   THEN a.hours_allocated * at.factor END), 0) AS admin_hours,
 COALESCE(SUM(CASE WHEN at.activity_name = 'Exam'
                   THEN a.hours_allocated * at.factor END), 0) AS exam_hours,


 COALESCE(SUM(a.hours_allocated * at.factor), 0) AS total_allocated_hours


FROM Allocation a
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN CourseLayout cl ON ci.courselayout_id = cl.course_layout_id
JOIN Employee e ON a.employee_id = e.employ_id
JOIN Person p ON e.personal_id = p.person_id
JOIN ActivityType at ON a.activitytype_id = at.activitytype_id
GROUP BY
 a.courseinstance_id, cl.course_code, cl.hp, ci.period, ci.year,
 a.employee_id, teacher_name, e.job_title;


CREATE OR REPLACE VIEW v_teacher_instance_count AS
SELECT
 a.employee_id,
 p.first_name || ' ' || p.last_name AS teacher_name,
 ci.year,
 ci.period,
 COUNT(DISTINCT a.courseinstance_id) AS num_instances
FROM Allocation a
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN Employee e ON a.employee_id = e.employ_id
JOIN Person p ON e.personal_id = p.person_id
GROUP BY a.employee_id, teacher_name, ci.year, ci.period;


CREATE OR REPLACE VIEW v_plan_vs_actual AS
SELECT
 pb.courseinstance_id,
 pb.course_code,
 pb.hp,
 pb.period,
 pb.year,
 pb.num_students,
 pb.total_planned_hours,


 COALESCE(SUM(ab.total_allocated_hours), 0) AS total_actual_allocated_hours,


 CASE
   WHEN pb.total_planned_hours = 0 THEN NULL
   ELSE ROUND(
        (COALESCE(SUM(ab.total_allocated_hours), 0) - pb.total_planned_hours)
        / pb.total_planned_hours * 100, 2
   )
 END AS variance_percent


FROM v_planned_breakdown pb
LEFT JOIN v_actual_breakdown ab
 ON pb.courseinstance_id = ab.courseinstance_id
GROUP BY pb.courseinstance_id, pb.course_code, pb.hp,
        pb.period, pb.year, pb.num_students, pb.total_planned_hours;


CREATE MATERIALIZED VIEW IF NOT EXISTS mv_teacher_yearly_load AS
SELECT
 e.employ_id AS employee_id,
 p.first_name || ' ' || p.last_name AS teacher_name,
 ci.year,
 SUM(a.hours_allocated * at.factor) AS total_weighted_hours
FROM Allocation a
JOIN Employee e ON a.employee_id = e.employ_id
JOIN Person p ON e.personal_id = p.person_id
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN ActivityType at ON a.activitytype_id = at.activitytype_id
GROUP BY e.employ_id, teacher_name, ci.year;


CREATE MATERIALIZED VIEW IF NOT EXISTS mv_course_cost AS
SELECT
 ci.courseinstance_id,
 cl.course_code,
 ci.period,
 ci.year,
 ROUND(SUM((e.salary / 160.0) * (a.hours_allocated * at.factor)), 2) AS total_cost_sek
FROM Allocation a
JOIN Employee e ON a.employee_id = e.employ_id
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN CourseLayout cl ON ci.courselayout_id = cl.course_layout_id
JOIN ActivityType at ON a.activitytype_id = at.activitytype_id
GROUP BY ci.courseinstance_id, cl.course_code, ci.period, ci.year;
