-- ==========================================================
--  Insert sample data for the updated database schema
-- ==========================================================

-- Clean tables
TRUNCATE Allocation RESTART IDENTITY CASCADE;
TRUNCATE PlannedActivity RESTART IDENTITY CASCADE;
TRUNCATE ActivityType RESTART IDENTITY CASCADE;
TRUNCATE CourseInstance RESTART IDENTITY CASCADE;
TRUNCATE CourseLayout RESTART IDENTITY CASCADE;
TRUNCATE Employee RESTART IDENTITY CASCADE;
TRUNCATE Person RESTART IDENTITY CASCADE;
TRUNCATE Department RESTART IDENTITY CASCADE;

-- ==========================================================
-- Departments
-- ==========================================================
INSERT INTO Department (dept_name)
VALUES
('Mechanical Engineering'),
('Chemical Engineering');

-- ==========================================================
-- Persons
-- ==========================================================
INSERT INTO Person(first_name, last_name, phone_number, address, personal_number)
VALUES
('Paris', 'Carbone', '070-1000001', 'KTH Campus', '900101-0001'),
('Leif', 'Lindbäck', '070-1000002', 'KTH Campus', '900101-0002'),
('Niharika', 'Gauraha', '070-1000003', 'KTH Campus', '900101-0003'),
('Brian', 'Karlsson', '070-1000004', 'KTH Campus', '900101-0004'),
('Adam',  'West',     '070-1000005', 'KTH Campus', '900101-0005');

-- ==========================================================
-- Employees
-- ==========================================================
INSERT INTO Employee(email, salary, dept_identifier, job_title, personal_number)
VALUES
('paris@kth.se', 55000, 1, 'Professor',        '900101-0001'),
('leif@kth.se',  42000, 1, 'Senior Lecturer',  '900101-0002'),
('nih@kth.se',   42000, 1, 'Lecturer',         '900101-0003'),
('brian@kth.se', 30000, 1, 'Assistant',        '900101-0004'),
('adam@kth.se',  25000, 1, 'Assistant',        '900101-0005');

-- Assign department managers AFTER Employee creation
UPDATE Department SET manager_id = 1 WHERE dept_identifier = 1;
UPDATE Department SET manager_id = 2 WHERE dept_identifier = 2;

-- ==========================================================
-- CourseLayout (VERSIONED)
-- ==========================================================
INSERT INTO CourseLayout(course_code, version_number, course_name,
                         min_students, max_students, start_date, end_date, hp)
VALUES
('IV1351', 1, 'Data Storage Paradigms', 50, 250, '2024-01-01', '2024-06-01', 7.5),
('IV1351', 2, 'Data Storage Paradigms', 50, 250, '2024-01-01', '2024-06-01', 15.0),
('IX1500', 1, 'Discrete Mathematics',    50, 150, '2024-01-01', '2024-06-01', 7.5);

-- ==========================================================
-- CourseInstance
-- ==========================================================
INSERT INTO CourseInstance(courselayout_id, study_period, year,
                           version_number, course_code, period, num_students)
VALUES
(1, 'P1', 2025, 1, 'IV1351', 'P1', 200),
(2, 'P2', 2025, 2, 'IV1351', 'P2', 220),
(3, 'P1', 2025, 1, 'IX1500', 'P1', 150);

-- ==========================================================
-- ActivityType
-- ==========================================================
INSERT INTO ActivityType(activity_name, factor)
VALUES
('Lecture', 1.0),
('Tutorial', 1.0),
('Lab', 1.0),
('Seminar', 1.0),
('Overhead', 1.0),
('Admin', 1.0),
('Exam', 1.0);

-- ==========================================================
-- PlannedActivity
-- ==========================================================
INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours)
VALUES
-- Instance 1: IV1351 (P1, version 1)
(1, 1, 72),
(1, 2, 192),
(1, 3, 96),
(1, 4, 144),
(1, 5, 650),
(1, 6, 177),
(1, 7, 83),

-- Instance 2: IV1351 (P2, version 2)
(2, 1, 100),
(2, 2, 250),
(2, 3, 140),
(2, 4, 200),
(2, 5, 750),
(2, 6, 190),
(2, 7, 90),

-- Instance 3: IX1500
(3, 1, 159),
(3, 2, 0),
(3, 3, 0),
(3, 4, 116),
(3, 5, 270),
(3, 6, 141),
(3, 7, 73);

-- ==========================================================
-- Allocation
-- ==========================================================
INSERT INTO Allocation (employee_id, courseinstance_id, activitytype_id, hoursallocated)
VALUES
    -- Paris
    (1, 1, 1, 72),
    (1, 1, 5, 100),
    (1, 1, 6, 43),
    (1, 1, 7, 61),

    -- Leif
    (2, 1, 4, 64),
    (2, 1, 5, 100),
    (2, 1, 7, 62),

    -- Niharika
    (3, 1, 4, 64),
    (3, 1, 5, 100),
    (3, 1, 6, 43),
    (3, 1, 7, 61),
    (3, 3, 1, 159),
    (3, 3, 5, 100),
    (3, 3, 6, 141),
    (3, 3, 7, 73),

    -- Brian
    (4, 1, 3, 50),
    (4, 1, 5, 100),

    -- Adam
    (5, 1, 3, 50),
    (5, 1, 4, 50);

