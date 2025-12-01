-- Ta bort tabeller (om de finns) i rätt ordning
DROP TABLE IF EXISTS Allocation CASCADE;
DROP TABLE IF EXISTS PlannedActivity CASCADE;
DROP TABLE IF EXISTS ActivityType CASCADE;
DROP TABLE IF EXISTS CourseInstance CASCADE;
DROP TABLE IF EXISTS CourseLayout CASCADE;
DROP TABLE IF EXISTS Employee CASCADE;
DROP TABLE IF EXISTS job_title CASCADE;
DROP TABLE IF EXISTS Person CASCADE;
DROP TABLE IF EXISTS Department CASCADE;


-- ==========================================================
-- Department
-- ==========================================================
CREATE TABLE Department (
    dept_identifier SERIAL PRIMARY KEY,
    dept_name       VARCHAR(50) NOT NULL UNIQUE
    -- manager_id läggs till senare när Employee-tabellen finns (för att undvika cirkulära FK)
);

-- ==========================================================
-- Person
-- ==========================================================
CREATE TABLE Person (
    person_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(20) NOT NULL,
    last_name       VARCHAR(20) NOT NULL,
    phone_number    VARCHAR(20),
    address         VARCHAR(100),
    personal_number VARCHAR(20) NOT NULL UNIQUE
);

-- ==========================================================
-- job_title
-- ==========================================================
CREATE TABLE job_title (
    job_title_id    SERIAL PRIMARY KEY,
    job_title       VARCHAR(30) NOT NULL UNIQUE
);

-- ==========================================================
-- Employee
-- ==========================================================
CREATE TABLE Employee (
    employee_id      SERIAL PRIMARY KEY,
    email            VARCHAR(255) NOT NULL,
    salary           NUMERIC(10,2) CHECK (salary > 0),
    manager_id       INT REFERENCES Employee(employee_id), -- själv-referens för chef
    dept_identifier  INT REFERENCES Department(dept_identifier),
    job_title_id     INT REFERENCES job_title(job_title_id),
    personal_number  VARCHAR(20) REFERENCES Person(personal_number)
);

-- Lägg till manager_id i Department nu när Employee finns (valfritt, NULL tillåts)
ALTER TABLE Department
ADD COLUMN manager_id INT REFERENCES Employee(employee_id);

-- ==========================================================
-- CourseLayout
-- ==========================================================
CREATE TABLE CourseLayout (
    courselayout_id SERIAL PRIMARY KEY,
    version_number  INT NOT NULL DEFAULT 1,
    course_code     VARCHAR(7) NOT NULL,
    course_name     VARCHAR(100) NOT NULL,
    min_students    INT CHECK (min_students >= 0),
    max_students    INT CHECK (max_students >= min_students),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    hp              NUMERIC(4,1) CHECK (hp > 0),
    employee_id     INT REFERENCES Employee(employee_id) -- ansvarig lärare/anställd
);

-- ==========================================================
-- CourseInstance
-- ==========================================================
CREATE TABLE CourseInstance (
    courseinstance_id SERIAL PRIMARY KEY,
    courselayout_id   INT NOT NULL REFERENCES CourseLayout(courselayout_id),
    study_period      VARCHAR(2) CHECK (study_period IN ('P1','P2','P3','P4')),
    year              INT NOT NULL,
    version_number    INT NOT NULL, -- versionsnumret för den här instansen (kan valideras i appnivå)
    course_code       VARCHAR(7) NOT NULL REFERENCES CourseLayout(course_code),
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
    activitytype_id     INT NOT NULL REFERENCES ActivityType(activitytype_id),
    activity_name       VARCHAR(100) NOT NULL
);

-- ==========================================================
-- Allocation
-- ==========================================================
CREATE TABLE Allocation (
    allocation_id     SERIAL PRIMARY KEY,
    employee_id       INT REFERENCES Employee(employee_id),
    hoursallocated    NUMERIC(10,2) CHECK (hoursallocated >= 0),
    courseinstance_id INT REFERENCES CourseInstance(courseinstance_id)
);

-- ==========================================================
-- END OF SCRIPT
-- ==========================================================
