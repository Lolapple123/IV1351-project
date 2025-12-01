INSERT INTO Department(dept_name) VALUES ('Computer Science'), ('Mathematics');
UPDATE Department SET manager_id = 500001 WHERE dept_identifier = 1;
UPDATE Department SET manager_id = 500004 WHERE dept_identifier = 2;

INSERT INTO Person(person_id, first_name, last_name, email, phone) VALUES
(900001,'Paris','Carbone','[paris.carbone@uni.se](mailto:paris.carbone@uni.se)','070-111'),
(900004,'Leif','Lindbäck','[leif.linback@uni.se](mailto:leif.linback@uni.se)','070-222'),
(900009,'Niharika','Gauraha','[niharika.g@uni.se](mailto:niharika.g@uni.se)','070-333'),
(900010,'Brian','Karlsson','[brian.k@uni.se](mailto:brian.k@uni.se)','070-444'),
(900011,'Adam','West','[adam.w@uni.se](mailto:adam.w@uni.se)','070-555'),
(900100,'Test','TeacherOverload','[test.overload@uni.se](mailto:test.overload@uni.se)','070-999');

INSERT INTO Employee(employ_id, personal_id, job_title, salary, dept_identifier) VALUES
(500001,900001,'Ass. Professor',550000,1),
(500004,900004,'Lecturer',480000,1),
(500009,900009,'Lecturer',440000,1),
(500010,900010,'PhD Student',240000,1),
(500011,900011,'TA',200000,1),
(500100,900100,'Lecturer',420000,1);

INSERT INTO CourseLayout(course_code, hp, course_name, min_students, max_students, valid_from) VALUES
('IV1351', 7.5, 'Data Storage Paradigms', 50, 250, '2023-01-01'),
('IX1500', 7.5, 'Discrete Mathematics', 50, 150, '2023-01-01');

INSERT INTO CourseInstance(courselayout_id, period, year, num_students) VALUES
((SELECT course_layout_id FROM CourseLayout WHERE course_code='IV1351'),'P2',2025,200),
((SELECT course_layout_id FROM CourseLayout WHERE course_code='IX1500'),'P1',2025,150),
((SELECT course_layout_id FROM CourseLayout WHERE course_code='IV1351'),'P1',2025,50),
((SELECT course_layout_id FROM CourseLayout WHERE course_code='IX1500'),'P2',2025,40);

INSERT INTO ActivityType(activity_name, factor) VALUES
('Lecture', 3.6),
('Lab', 2.4),
('Tutorial', 2.4),
('Seminar', 1.8),
('Overhead', 1.0),
('Admin', 1.0),
('Exam', 1.0);

INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours)
SELECT ci.courseinstance_id, at.activitytype_id, vals.h
FROM CourseInstance ci
JOIN (VALUES
('Lecture',20.0),
('Lab',80.0),
('Tutorial',40.0),
('Seminar',80.0),
('Overhead',650.0)
) AS vals(name,h) ON TRUE
JOIN ActivityType at ON vals.name = at.activity_name
WHERE ci.period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT course_layout_id FROM CourseLayout WHERE course_code='IV1351');

INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours)
SELECT ci.courseinstance_id, at.activitytype_id, vals.h
FROM CourseInstance ci
JOIN (VALUES
('Lecture',44.0),
('Seminar',64.0),
('Overhead',200.0)
) AS vals(name,h) ON TRUE
JOIN ActivityType at ON vals.name = at.activity_name
WHERE ci.period='P1' AND ci.year=2025 AND ci.courselayout_id = (SELECT course_layout_id FROM CourseLayout WHERE course_code='IX1500');

INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hours_allocated)
SELECT 500001, ci.courseinstance_id, at.activitytype_id, 20
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Lecture'
WHERE ci.period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT course_layout_id FROM CourseLayout WHERE course_code='IV1351')
LIMIT 1;

INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hours_allocated)
SELECT e_id, ci.courseinstance_id, at.activitytype_id, 64
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Seminar'
JOIN (VALUES (500004), (500009)) AS emp(e_id) ON TRUE
WHERE ci.period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT course_layout_id FROM CourseLayout WHERE course_code='IV1351');

INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hours_allocated)
SELECT 500010, ci.courseinstance_id, at.activitytype_id, 50
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Lab'
WHERE ci.period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT course_layout_id FROM CourseLayout WHERE course_code='IV1351');

INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hours_allocated)
SELECT 500011, ci.courseinstance_id, at.activitytype_id, 50
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Tutorial'
WHERE ci.period='P2' AND ci.year=2025 AND ci.courselayout_id = (SELECT course_layout_id FROM CourseLayout WHERE course_code='IV1351');

INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hours_allocated)
SELECT 500009, ci.courseinstance_id, at.activitytype_id, 44
FROM CourseInstance ci
JOIN ActivityType at ON at.activity_name='Lecture'
WHERE ci.period='P1' AND ci.year=2025 AND ci.courselayout_id = (SELECT course_layout_id FROM CourseLayout WHERE course_code='IX1500');

INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hours_allocated)
SELECT 500100, ci.courseinstance_id, at.activitytype_id, 10
FROM CourseInstance ci
WHERE ci.year=2025
ORDER BY ci.courseinstance_id
LIMIT 4;
