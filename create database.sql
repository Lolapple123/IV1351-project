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
