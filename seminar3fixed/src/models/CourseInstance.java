package models;

public class CourseInstance {
    private int courseInstanceId;
    private String courseCode;
    private String courseName;
    private String studyPeriod;
    private int numStudents;
    private int year;

    public CourseInstance(int courseInstanceId, String courseCode, String courseName,
                          String studyPeriod, int numStudents, int year) {
        this.courseInstanceId = courseInstanceId;
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.studyPeriod = studyPeriod;
        this.numStudents = numStudents;
        this.year = year;
    }

    // ===== Getters =====
    public int getCourseInstanceId() { return courseInstanceId; }
    public String getCourseCode() { return courseCode; }
    public String getCourseName() { return courseName; }
    public String getStudyPeriod() { return studyPeriod; }
    public int getNumStudents() { return numStudents; }
    public int getYear() { return year; }

    // ===== Setters =====
    public void setNumStudents(int numStudents) { this.numStudents = numStudents; }
}
