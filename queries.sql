SELECT
pb.course_code              AS "Course Code",
pb.courseinstance_id        AS "Course Instance ID",
pb.hp                       AS "HP",
pb.period                   AS "Period",
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

SELECT
ab.course_code              AS "Course Code",
ab.courseinstance_id        AS "Course Instance ID",
ab.hp                       AS "HP",
ab.teacher_name             AS "Teacher's Name",
ab.job_title                AS "Designation",
ab.lecture_hours            AS "Lecture Hours",
ab.tutorial_hours           AS "Tutorial Hours",
ab.lab_hours                AS "Lab Hours",
ab.seminar_hours            AS "Seminar Hours",
ab.overhead_hours           AS "Other Overhead Hours",
ab.admin_hours              AS "Admin",
ab.exam_hours               AS "Exam",
ab.total_allocated_hours    AS "Total"
FROM v_actual_breakdown ab
WHERE ab.year = 2025
ORDER BY ab.course_code, ab.courseinstance_id, ab.teacher_name;

SELECT
ab.course_code              AS "Course Code",
ab.courseinstance_id        AS "Course Instance ID",
ab.hp                       AS "HP",
ab.period                   AS "Period",
ab.teacher_name             AS "Teacher's Name",
ab.lecture_hours            AS "Lecture Hours",
ab.tutorial_hours           AS "Tutorial Hours",
ab.lab_hours                AS "Lab Hours",
ab.seminar_hours            AS "Seminar Hours",
ab.overhead_hours           AS "Other Overhead Hours",
ab.admin_hours              AS "Admin",
ab.exam_hours               AS "Exam",
ab.total_allocated_hours    AS "Total"
FROM v_actual_breakdown ab
WHERE ab.year = 2025
AND ab.employee_id = 500001
ORDER BY ab.period, ab.course_code;

SELECT
tic.employee_id        AS "Employment ID",
tic.teacher_name       AS "Teacher's Name",
tic.period             AS "Period",
tic.num_instances      AS "No of courses"
FROM v_teacher_instance_count tic
WHERE tic.year = 2025
AND tic.num_instances = 1
ORDER BY tic.num_instances DESC, tic.teacher_name;
