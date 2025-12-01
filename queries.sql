
--first
SELECT
pb.course_code              AS "Course Code",
pb.courseinstance_id        AS "Course Instance ID",
pb.hp                       AS "HP",
pb.study_period             AS "Period",
pb.num_students             AS "# Students",
pb.lecture_hours            AS "Lecture Hours",
pb.tutorial_hours           AS "Tutorial Hours",
pb.lab_hours                AS "Lab Hours",
pb.seminar_hours            AS "Seminar Hours",
pb.overhead_hours           AS "Other Overhead Hours",
pb.admin_hours              AS "Admin",
pb.exam_hours               AS "Exam",
pb.total_planned_hours      AS "Total Hours"
FROM v_planned_breakdown pb
WHERE pb.year = 2025
ORDER BY pb.course_code, pb.courseinstance_id;


--second
SELECT
cl.course_code AS "Course Code",
ci.courseinstance_id AS "Course Instance ID",
cl.hp AS "HP",
CONCAT(p.first_name, ' ', p.last_name) AS "Teacher's Name",
jt.job_title AS "Designation",

SUM(CASE WHEN at.activity_name = 'Lecture' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Lecture Hours",
SUM(CASE WHEN at.activity_name = 'Tutorial' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Tutorial Hours",
SUM(CASE WHEN at.activity_name = 'Lab' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Lab Hours",
SUM(CASE WHEN at.activity_name = 'Seminar' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Seminar Hours",
SUM(CASE WHEN at.activity_name = 'Overhead' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Other Overhead Hours",
SUM(CASE WHEN at.activity_name = 'Admin' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Admin",
SUM(CASE WHEN at.activity_name = 'Exam' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Exam",
SUM(al.hoursallocated * at.factor) AS "Total"
FROM Allocation al
JOIN PlannedActivity pa ON al.courseinstance_id = pa.courseinstance_id
JOIN ActivityType at ON pa.activitytype_id = at.activitytype_id
JOIN CourseInstance ci ON al.courseinstance_id = ci.courseinstance_id
JOIN CourseLayout cl ON ci.courselayout_id = cl.courselayout_id
JOIN Employee e ON al.employee_id = e.employee_id
JOIN Person p ON e.personal_number = p.personal_number
JOIN Job_Title jt ON e.job_title_id = jt.job_title_id
WHERE ci.year = 2025


GROUP BY cl.course_code, ci.courseinstance_id, cl.hp, p.first_name, p.last_name, jt.job_title
ORDER BY cl.course_code, ci.courseinstance_id, "Teacher's Name";


--third

SELECT
CONCAT(p.first_name, ' ', p.last_name) AS "Teacher's Name",
jt.job_title AS "Designation",
-- Sum of hours by activity type across all course instances for this teacher
SUM(CASE WHEN at.activity_name = 'Lecture' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Lecture Hours",
SUM(CASE WHEN at.activity_name = 'Tutorial' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Tutorial Hours",
SUM(CASE WHEN at.activity_name = 'Lab' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Lab Hours",
SUM(CASE WHEN at.activity_name = 'Seminar' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Seminar Hours",
SUM(CASE WHEN at.activity_name = 'Overhead' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Other Overhead Hours",
SUM(CASE WHEN at.activity_name = 'Admin' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Admin",
SUM(CASE WHEN at.activity_name = 'Exam' THEN al.hoursallocated * at.factor ELSE 0 END) AS "Exam",
SUM(al.hoursallocated * at.factor) AS "Total Hours"
FROM Allocation al
JOIN PlannedActivity pa ON al.courseinstance_id = pa.courseinstance_id
JOIN ActivityType at ON pa.activitytype_id = at.activitytype_id
JOIN Employee e ON al.employee_id = e.employee_id
JOIN Person p ON e.personal_number = p.personal_number
JOIN Job_Title jt ON e.job_title_id = jt.job_title_id
JOIN CourseInstance ci ON al.courseinstance_id = ci.courseinstance_id
WHERE ci.year = 2025
GROUP BY p.first_name, p.last_name, jt.job_title
ORDER BY "Total Hours" DESC, "Teacher's Name";


--fourth

SELECT
e.employee_id AS "Employment ID",
CONCAT(p.first_name, ' ', p.last_name) AS "Teacher's Name",
ci.study_period AS "Period",
COUNT(DISTINCT ci.courseinstance_id) AS "No of courses"
FROM Allocation al
JOIN Employee e ON al.employee_id = e.employee_id
JOIN Person p ON e.personal_number = p.personal_number
JOIN CourseInstance ci ON al.courseinstance_id = ci.courseinstance_id
WHERE ci.year = 2025
GROUP BY e.employee_id, p.first_name, p.last_name, ci.study_period
HAVING COUNT(DISTINCT ci.courseinstance_id) > 1   -- replace 1 with the threshold you want
ORDER BY "No of courses" DESC, "Teacher's Name";




