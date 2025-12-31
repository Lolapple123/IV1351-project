-- ==========================================================
--  FULL DATABASE SCRIPT FOR THE 3.1 DATA MODEL
-- ==========================================================

-- Drop tables if they exist
DROP TABLE IF EXISTS Allocation CASCADE;
DROP TABLE IF EXISTS PlannedActivity CASCADE;
DROP TABLE IF EXISTS ActivityType CASCADE;
DROP TABLE IF EXISTS CourseInstance CASCADE;
DROP TABLE IF EXISTS CourseLayout CASCADE;
DROP TABLE IF EXISTS Employee CASCADE;
DROP TABLE IF EXISTS Person CASCADE;
DROP TABLE IF EXISTS Department CASCADE;

-- ==========================================================
-- Department
-- ==========================================================
CREATE TABLE Department (
    dept_identifier SERIAL PRIMARY KEY,
    dept_name       VARCHAR(15) NOT NULL UNIQUE,
   manager_id       INT PRIMARY KEY,
);
-- ==========================================================
-- Person
-- ==========================================================
CREATE TABLE Person (
    person_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(20) NOT NULL,
    last_name       VARCHAR(20) NOT NULL,
    phone_number    VARCHAR(12),
    address         VARCHAR(50),
    personal_number VARCHAR(20) NOT NULL UNIQUE
);
-- ==========================================================
-- Employee
-- ==========================================================
CREATE TABLE Employee (
    employ_id        SERIAL PRIMARY KEY,
    email            VARCHAR(30) NOT NULL,
    salary           NUMERIC(50,2) CHECK (salary > 0),
    manager_id       INT, REFERENCES Department(manager_id),
    dept_identifier  INT REFERENCES Department(dept_identifier),
    job_title        VARCHAR(50),
    personal_number  INT REFERENCES Person(personal_number)
);

-- Add manager_id foreign key now that Employee exists
ALTER TABLE Department
ADD COLUMN manager_id INT REFERENCES Employee(employ_id);
-- ==========================================================
-- CourseLayout
-- ==========================================================
CREATE TABLE CourseLayout (
    courselayout_id SERIAL PRIMARY KEY,
    version_number  INT NOT NULL DEFAULT 1,
    course_code     VARCHAR(7) NOT NULL UNIQUE,
    course_name     VARCHAR(20) NOT NULL,
    min_students    INT CHECK (min_students >= 0),
    max_students    INT CHECK (max_students >= min_students),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    hp              NUMERIC(4,1) CHECK (hp > 0)
    employee_id  INT REFERENCES employee(employee_id)
);
-- ==========================================================
-- CourseInstance
-- ==========================================================
CREATE TABLE CourseInstance (
    courseinstance_id SERIAL PRIMARY KEY,
    courselayout_id   INT REFERENCES CourseLayout(courselayout_id),
    study_period      VARCHAR(2) CHECK (study_period IN ('P1','P2','P3','P4')),
    year              INT NOT NULL,
    version_number INT REFERENCES CourseLayout(version_number),
    course_code     VARCHAR(10) REFERENCES CourseLayout(course_code),
    period               VARCHAR(10) CHECK (study_period IN ('P1','P2','P3','P4')),
num_students      INT CHECK (num_students >= 0)
);
-- ==========================================================
-- ActivityType
-- ==========================================================
CREATE TABLE ActivityType (
    activitytype_id SERIAL PRIMARY KEY,
    activity_name   VARCHAR(100) NOT NULL UNIQUE,
    factor          NUMERIC(4,2) CHECK (factor > 0)
);
-- ==========================================================
-- PlannedActivity
-- ==========================================================
CREATE TABLE PlannedActivity (
    planned_activity_id SERIAL PRIMARY KEY,
    courseinstance_id   INT NOT NULL REFERENCES CourseInstance(courseinstance_id),
    planned_hours       INT CHECK (planned_hours >= 0),
    activitytype_id     INT NOT NULL REFERENCES ActivityType(activitytype_id)
    activity_name      VARCHAR(100)  NOT NULL
);
-- ==========================================================
-- Allocation
-- ==========================================================
CREATE TABLE Allocation (
    allocation_id     SERIAL PRIMARY KEY,
    employee_id       INT REFERENCES Employee(employ_id),
    hoursallocated    NUMERIC(10,2) CHECK (hoursallocated >= 0),
    courseinstance_id INT REFERENCES CourseInstance(courseinstance_id),
    activitytype_id   INT REFERENCES ActivityType(activitytype_id)
);
-- ==========================================================
-- END OF SCRIPT
-- ==========================================================
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






-- Check teacher for more than 4 courses per period
SELECT a.employee_id,
       ci.study_period,
       COUNT(DISTINCT a.courseinstance_id) AS course_count
FROM Allocation a
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
GROUP BY a.employee_id, ci.study_period
HAVING COUNT(DISTINCT a.courseinstance_id) > 4;
