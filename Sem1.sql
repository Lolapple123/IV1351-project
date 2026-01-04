-- ==========================================================
--  FULL DATABASE SCRIPT FOR THE 3.1 DATA MODEL (CORRECTED)
-- ==========================================================

-- Drop tables if they exist (cascade for dependencies)
DROP TABLE IF EXISTS Allocation CASCADE;
DROP TABLE IF EXISTS PlannedActivity CASCADE;
DROP TABLE IF EXISTS ActivityType CASCADE;
DROP TABLE IF EXISTS CourseInstance CASCADE;
DROP TABLE IF EXISTS CourseLayout CASCADE;
DROP TABLE IF EXISTS Employee_Salary CASCADE;
DROP TABLE IF EXISTS JobTitle CASCADE;
DROP TABLE IF EXISTS Employee CASCADE;
DROP TABLE IF EXISTS Person CASCADE;
DROP TABLE IF EXISTS Department CASCADE;

-- ==========================================================
-- Department
-- ==========================================================
CREATE TABLE Department (
    dept_identifier SERIAL PRIMARY KEY,
    dept_name       VARCHAR(50) NOT NULL UNIQUE,
    manager_id      INT REFERENCES Employee(employee_id)
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
-- JobTitle
-- ==========================================================
CREATE TABLE JobTitle (
    job_title_id SERIAL PRIMARY KEY,
    title_name   VARCHAR(50) NOT NULL UNIQUE
);

-- ==========================================================
-- Employee
-- ==========================================================
CREATE TABLE Employee (
    employee_id     SERIAL PRIMARY KEY,
    email           VARCHAR(50) NOT NULL UNIQUE,
    dept_identifier INT REFERENCES Department(dept_identifier),
    personal_number VARCHAR(20) NOT NULL UNIQUE,
    job_title_id    INT REFERENCES JobTitle(job_title_id)
);

-- ==========================================================
-- Employee_Salary
-- ==========================================================
CREATE TABLE Employee_Salary (
    salary_id     SERIAL PRIMARY KEY,
    employee_id   INT NOT NULL REFERENCES Employee(employee_id),
    salary_amount NUMERIC(10,2) NOT NULL CHECK (salary_amount > 0),
    valid_from    DATE NOT NULL,
    valid_to      DATE
);

-- ==========================================================
-- CourseLayout (VERSIONED)
-- ==========================================================
CREATE TABLE CourseLayout (
    courselayout_id SERIAL PRIMARY KEY,
    course_code     VARCHAR(7) NOT NULL,
    version_number  INT NOT NULL DEFAULT 1,
    course_name     VARCHAR(50) NOT NULL,
    min_students    INT CHECK (min_students >= 0),
    max_students    INT CHECK (max_students >= min_students),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    hp              NUMERIC(4,1) CHECK (hp > 0),
    UNIQUE(course_code, version_number)
);

-- ==========================================================
-- CourseInstance
-- ==========================================================
CREATE TABLE CourseInstance (
    courseinstance_id SERIAL PRIMARY KEY,
    courselayout_id   INT NOT NULL REFERENCES CourseLayout(courselayout_id),
    study_period      VARCHAR(2) CHECK (study_period IN ('P1','P2','P3','P4')),
    year              INT NOT NULL,
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
    activitytype_id     INT NOT NULL REFERENCES ActivityType(activitytype_id),
    planned_hours       INT CHECK (planned_hours >= 0)
);

-- ==========================================================
-- Allocation
-- ==========================================================
CREATE TABLE Allocation (
    allocation_id       SERIAL PRIMARY KEY,
    employee_id         INT NOT NULL REFERENCES Employee(employee_id),
    planned_activity_id INT NOT NULL REFERENCES PlannedActivity(planned_activity_id),
    hoursallocated      NUMERIC(10,2) CHECK (hoursallocated >= 0)
);

-- ==========================================================
-- Insert sample data
-- ==========================================================

-- Departments
INSERT INTO Department (dept_name) VALUES
('Mechanical Engineering'),
('Chemical Engineering');

-- Persons
INSERT INTO Person(first_name, last_name, phone_number, address, personal_number)
VALUES
('Paris', 'Carbone', '070-1000001', 'KTH Campus', '900101-0001'),
('Leif', 'Lindbäck', '070-1000002', 'KTH Campus', '900101-0002'),
('Niharika', 'Gauraha', '070-1000003', 'KTH Campus', '900101-0003'),
('Brian', 'Karlsson', '070-1000004', 'KTH Campus', '900101-0004'),
('Adam',  'West',     '070-1000005', 'KTH Campus', '900101-0005');

-- Job Titles
INSERT INTO JobTitle(title_name) VALUES
('Professor'),
('Senior Lecturer'),
('Lecturer'),
('Assistant');

-- Employees
INSERT INTO Employee(email, dept_identifier, personal_number, job_title_id)
VALUES
('paris@kth.se', 1, '900101-0001', 1),
('leif@kth.se',  1, '900101-0002', 2),
('nih@kth.se',   1, '900101-0003', 3),
('brian@kth.se', 1, '900101-0004', 4),
('adam@kth.se',  1, '900101-0005', 4);

-- Assign Department Managers (after employees exist)
UPDATE Department SET manager_id = 1 WHERE dept_identifier = 1;
UPDATE Department SET manager_id = 2 WHERE dept_identifier = 2;

-- Employee Salaries
INSERT INTO Employee_Salary(employee_id, salary_amount, valid_from, valid_to)
VALUES
(1, 55000, '2024-01-01', NULL),
(2, 42000, '2024-01-01', NULL),
(3, 42000, '2024-01-01', NULL),
(4, 30000, '2024-01-01', NULL),
(5, 25000, '2024-01-01', NULL);

-- CourseLayout (VERSIONED)
INSERT INTO CourseLayout(course_code, version_number, course_name, min_students, max_students, start_date, end_date, hp)
VALUES
('IV1351', 1, 'Data Storage Paradigms', 50, 250, '2024-01-01', '2024-06-01', 7.5),
('IV1351', 2, 'Data Storage Paradigms', 50, 250, '2024-01-01', '2024-06-01', 15.0),
('IX1500', 1, 'Discrete Mathematics',    50, 150, '2024-01-01', '2024-06-01', 7.5);

-- CourseInstance
INSERT INTO CourseInstance(courselayout_id, study_period, year, num_students)
VALUES
(1, 'P1', 2025, 200),
(2, 'P2', 2025, 220),
(3, 'P1', 2025, 150);

-- ActivityType
INSERT INTO ActivityType(activity_name, factor)
VALUES
('Lecture', 1.0),
('Tutorial', 1.0),
('Lab', 1.0),
('Seminar', 1.0),
('Overhead', 1.0),
('Admin', 1.0),
('Exam', 1.0);

-- PlannedActivity
INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours)
VALUES
-- Instance 1: IV1351 (P1)
(1, 1, 72),
(1, 2, 192),
(1, 3, 96),
(1, 4, 144),
(1, 5, 650),
(1, 6, 177),
(1, 7, 83),
-- Instance 2: IV1351 (P2)
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

-- Allocation (linked to PlannedActivity)
INSERT INTO Allocation(employee_id, planned_activity_id, hoursallocated)
VALUES
-- Paris
(1, 1, 72),
(1, 5, 100),
(1, 6, 43),
(1, 7, 61),
-- Leif
(2, 4, 64),
(2, 5, 100),
(2, 7, 62),
-- Niharika
(3, 4, 64),
(3, 5, 100),
(3, 6, 43),
(3, 7, 61),
(3, 15, 159),
(3, 19, 100),
(3, 20, 141),
(3, 21, 73),
-- Brian
(4, 3, 50),
(4, 5, 100),
-- Adam
(5, 3, 50),
(5, 4, 50);

-- ==========================================================
-- Config table for dynamic limits
-- ==========================================================
CREATE TABLE Config (
    config_key   VARCHAR(50) PRIMARY KEY,
    config_value INT NOT NULL
);

-- Insert max courses per period
INSERT INTO Config(config_key, config_value) VALUES ('max_courses_per_period', 4);

-- ==========================================================
-- Query to check employees exceeding max courses per period
-- ==========================================================
SELECT a.employee_id,
       ci.study_period,
       COUNT(DISTINCT a.courseinstance_id) AS course_count
FROM Allocation a
JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id
GROUP BY a.employee_id, ci.study_period
HAVING COUNT(DISTINCT a.courseinstance_id) >
       (SELECT config_value FROM Config WHERE config_key = 'max_courses_per_period');
