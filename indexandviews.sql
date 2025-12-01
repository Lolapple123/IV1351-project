-- ==========================================================
-- VIEWS
-- ==========================================================
-- 1. Planned breakdown per course instance
CREATE OR REPLACE VIEW v_planned_breakdown AS
SELECT
ci.courseinstance_id,
cl.course_code,
cl.hp,
ci.study_period,
ci.year,
ci.num_students,
COALESCE(SUM(CASE WHEN pa.activity_name = 'Lecture' THEN pa.planned_hours END), 0) AS lecture_hours,
COALESCE(SUM(CASE WHEN pa.activity_name = 'Tutorial' THEN pa.planned_hours END), 0) AS tutorial_hours,
COALESCE(SUM(CASE WHEN pa.activity_name = 'Lab' THEN pa.planned_hours END), 0) AS lab_hours,
COALESCE(SUM(CASE WHEN pa.activity_name = 'Seminar' THEN pa.planned_hours END), 0) AS seminar_hours,
COALESCE(SUM(CASE WHEN pa.activity_name = 'Overhead' THEN pa.planned_hours END), 0) AS overhead_hours,
COALESCE(SUM(CASE WHEN pa.activity_name = 'Admin' THEN pa.planned_hours END), 0) AS admin_hours,
COALESCE(SUM(CASE WHEN pa.activity_name = 'Exam' THEN pa.planned_hours END), 0) AS exam_hours,
COALESCE(SUM(pa.planned_hours), 0) AS total_planned_hours
FROM CourseInstance ci
JOIN CourseLayout cl ON ci.courselayout_id = cl.courselayout_id
LEFT JOIN PlannedActivity pa ON pa.courseinstance_id = ci.courseinstance_id
GROUP BY ci.courseinstance_id, cl.course_code, cl.hp, ci.study_period, ci.year, ci.num_students;

-- 2. Actual allocated hours per teacher per course instance
CREATE OR REPLACE VIEW v_actual_breakdown AS
SELECT
a.courseinstance_id,
cl.course_code,
cl.hp,
ci.study_period,
ci.year,
a.employee_id,
CONCAT(p.first_name,' ',p.last_name) AS teacher_name,
jt.job_title,
COALESCE(SUM(a.hoursallocated), 0) AS total_allocated_hours
FROM Allocation a
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN CourseLayout cl ON ci.courselayout_id = cl.courselayout_id
JOIN Employee e ON a.employee_id = e.employee_id
JOIN Person p ON e.personal_number = p.personal_number
JOIN job_title jt ON e.job_title_id = jt.job_title_id
GROUP BY a.courseinstance_id, cl.course_code, cl.hp, ci.study_period, ci.year, a.employee_id, teacher_name, jt.job_title;

-- 3. Count of course instances per teacher per year/period
CREATE OR REPLACE VIEW v_teacher_instance_count AS
SELECT
a.employee_id,
CONCAT(p.first_name,' ',p.last_name) AS teacher_name,
ci.year,
ci.study_period,
COUNT(DISTINCT a.courseinstance_id) AS num_instances
FROM Allocation a
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN Employee e ON a.employee_id = e.employee_id
JOIN Person p ON e.personal_number = p.personal_number
GROUP BY a.employee_id, teacher_name, ci.year, ci.study_period;

-- 4. Planned vs actual comparison per course instance
CREATE OR REPLACE VIEW v_plan_vs_actual AS
SELECT
pb.courseinstance_id,
pb.course_code,
pb.hp,
pb.study_period,
pb.year,
pb.num_students,
pb.total_planned_hours,
COALESCE(SUM(ab.total_allocated_hours), 0) AS total_actual_allocated_hours,
CASE
WHEN pb.total_planned_hours = 0 THEN NULL
ELSE ROUND((COALESCE(SUM(ab.total_allocated_hours), 0) - pb.total_planned_hours) / pb.total_planned_hours * 100, 2)
END AS variance_percent
FROM v_planned_breakdown pb
LEFT JOIN v_actual_breakdown ab ON pb.courseinstance_id = ab.courseinstance_id
GROUP BY pb.courseinstance_id, pb.course_code, pb.hp, pb.study_period, pb.year, pb.num_students, pb.total_planned_hours;

-- ==========================================================
-- MATERIALIZED VIEWS
-- ==========================================================
-- 1. Teacher yearly load
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_teacher_yearly_load AS
SELECT
e.employee_id,
CONCAT(p.first_name,' ',p.last_name) AS teacher_name,
ci.year,
SUM(a.hoursallocated) AS total_hours
FROM Allocation a
JOIN Employee e ON a.employee_id = e.employee_id
JOIN Person p ON e.personal_number = p.personal_number
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
GROUP BY e.employee_id, teacher_name, ci.year;

-- 2. Estimated course cost per course instance
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_course_cost AS
SELECT
ci.courseinstance_id,
cl.course_code,
ci.study_period,
ci.year,
ROUND(SUM((e.salary / 160.0) * a.hoursallocated), 2) AS total_cost_sek
FROM Allocation a
JOIN Employee e ON a.employee_id = e.employee_id
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN CourseLayout cl ON ci.courselayout_id = cl.courselayout_id
GROUP BY ci.courseinstance_id, cl.course_code, ci.study_period, ci.year;
