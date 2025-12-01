-- =========================
-- Departments
-- =========================
INSERT INTO Department(dept_name) VALUES ('Computer Science'), ('Mathematics');

-- =========================
-- Persons
-- =========================
INSERT INTO Person(person_id, first_name, last_name, phone_number, personal_number) VALUES
(900001,'Paris','Carbone','070-111','PN900001'),
(900004,'Leif','Lindbäck','070-222','PN900004'),
(900009,'Niharika','Gauraha','070-333','PN900009'),
(900010,'Brian','Karlsson','070-444','PN900010'),
(900011,'Adam','West','070-555','PN900011'),
(900100,'Test','TeacherOverload','070-999','PN901000');

-- =========================
-- Job Titles
-- =========================
INSERT INTO job_title(job_title_id, job_title) VALUES
(1,'Ass. Professor'),
(2,'Lecturer'),
(3,'PhD Student'),
(4,'TA');

-- =========================
-- Employees
-- =========================
INSERT INTO Employee(employee_id, personal_number, job_title_id, salary, dept_identifier) VALUES
(500001,'PN900001',1,550000,1),
(500004,'PN900004',2,480000,1),
(500009,'PN900009',2,440000,1),
(500010,'PN900010',3,240000,1),
(500011,'PN900011',4,200000,1),
(500100,'PN901000',2,420000,1);

-- =========================
-- Update Department Managers
-- =========================
UPDATE Department SET manager_id = 500001 WHERE dept_identifier = 1;
UPDATE Department SET manager_id = 500004 WHERE dept_identifier = 2;

-- =========================
-- Course Layouts
-- =========================
INSERT INTO CourseLayout(course_code, hp, course_name, min_students, max_students, start_date, end_date) VALUES
('IV1351', 7.5, 'Data Storage Paradigms', 50, 250, '2023-01-01', '2026-12-31'),
('IX1500', 7.5, 'Discrete Mathematics', 50, 150, '2023-01-01', '2026-12-31');

-- =========================
-- Course Instances
-- =========================
INSERT INTO CourseInstance(courselayout_id, study_period, year, num_students) VALUES
((SELECT courselayout_id FROM CourseLayout WHERE course_code='IV1351'),'P2',2025,200),
((SELECT courselayout_id FROM CourseLayout WHERE course_code='IX1500'),'P1',2025,150),
((SELECT courselayout_id FROM CourseLayout WHERE course_code='IV1351'),'P1',2025,50),
((SELECT courselayout_id FROM CourseLayout WHERE course_code='IX1500'),'P2',2025,40);

-- =========================
-- Activity Types
-- =========================
INSERT INTO ActivityType(activitytype_id, activity_name, factor) VALUES
(1,'Lecture',3.6),
(2,'Lab',2.4),
(3,'Tutorial',2.4),
(4,'Seminar',1.8),
(5,'Overhead',1.0),
(6,'Admin',1.0),
(7,'Exam',1.0);

-- =========================
-- Planned Activities
-- =========================
-- IV1351 P2
INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours, activity_name)
SELECT ci.courseinstance_id, at.activitytype_id, vals.h, vals.name
FROM CourseInstance ci
JOIN (VALUES
('Lecture',20.0),
('Lab',80.0),
('Tutorial',40.0),
('Seminar',80.0),
('Overhead',650.0)
) AS vals(name,h) ON TRUE
JOIN ActivityType at ON vals.name = at.activity_name
WHERE ci.study_period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT courselayout_id FROM CourseLayout WHERE course_code='IV1351');

-- IX1500 P1
INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours, activity_name)
SELECT ci.courseinstance_id, at.activitytype_id, vals.h, vals.name
FROM CourseInstance ci
JOIN (VALUES
('Lecture',44.0),
('Seminar',64.0),
('Overhead',200.0)
) AS vals(name,h) ON TRUE
JOIN ActivityType at ON vals.name = at.activity_name
WHERE ci.study_period='P1' AND ci.year=2025 AND ci.courselayout_id = (SELECT courselayout_id FROM CourseLayout WHERE course_code='IX1500');

-- =========================
-- Allocations
-- =========================
-- IV1351 P2 Lecture
INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hoursallocated)
SELECT 500001, ci.courseinstance_id, at.activitytype_id, 20
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Lecture'
WHERE ci.study_period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT courselayout_id FROM CourseLayout WHERE course_code='IV1351')
LIMIT 1;

-- IV1351 P2 Seminar
INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hoursallocated)
SELECT e_id, ci.courseinstance_id, at.activitytype_id, 64
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Seminar'
JOIN (VALUES (500004), (500009)) AS emp(e_id) ON TRUE
WHERE ci.study_period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT courselayout_id FROM CourseLayout WHERE course_code='IV1351');

-- IV1351 P2 Lab
INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hoursallocated)
SELECT 500010, ci.courseinstance_id, at.activitytype_id, 50
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Lab'
WHERE ci.study_period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT courselayout_id FROM CourseLayout WHERE course_code='IV1351');

-- IV1351 P2 Tutorial
INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hoursallocated)
SELECT 500011, ci.courseinstance_id, at.activitytype_id, 50
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Tutorial'
WHERE ci.study_period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT courselayout_id FROM CourseLayout WHERE course_code='IV1351');

-- IX1500 P1 Lecture
INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hoursallocated)
SELECT 500009, ci.courseinstance_id, at.activitytype_id, 44
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Lecture'
WHERE ci.study_period='P1' AND ci.year=2025 AND ci.courselayout_id = (SELECT courselayout_id FROM CourseLayout WHERE course_code='IX1500');

-- Dummy allocations for testing overload
INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hoursallocated)
SELECT 500100, ci.courseinstance_id, at.activitytype_id, 10
FROM CourseInstance ci
WHERE ci.year=2025
ORDER BY ci.courseinstance_id
LIMIT 4;

-- =========================
-- Materialized Views
-- =========================
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_teacher_yearly_load AS
SELECT
e.employee_id,
p.first_name || ' ' || p.last_name AS teacher_name,
ci.year,
SUM(a.hoursallocated * at.factor) AS total_weighted_hours
FROM Allocation a
JOIN Employee e ON a.employee_id = e.employee_id
JOIN Person p ON e.personal_number = p.personal_number
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN ActivityType at ON a.activitytype_id = at.activitytype_id
GROUP BY e.employee_id, teacher_name, ci.year;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_course_cost AS
SELECT
ci.courseinstance_id,
cl.course_code,
ci.study_period,
ci.year,
ROUND(SUM((e.salary / 160.0) * (a.hoursallocated * at.factor)), 2) AS total_cost_sek
FROM Allocation a
JOIN Employee e ON a.employee_id = e.employee_id
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
JOIN CourseLayout cl ON ci.courselayout_id = cl.courselayout_id
JOIN ActivityType at ON a.activitytype_id = at.activitytype_id
GROUP BY ci.courseinstance_id, cl.course_code, ci.study_period, ci.year;
