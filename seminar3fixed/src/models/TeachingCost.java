package models;

public class TeachingCost {
    private int courseInstanceId;
    private String courseCode;
    private String studyPeriod;
    private int year;
    private double plannedHours;
    private double plannedCostSek;
    private double actualHours;
    private double actualCostSek;

    public TeachingCost(int courseInstanceId, String courseCode, String studyPeriod, int year,
                        double plannedHours, double plannedCostSek,
                        double actualHours, double actualCostSek) {
        this.courseInstanceId = courseInstanceId;
        this.courseCode = courseCode;
        this.studyPeriod = studyPeriod;
        this.year = year;
        this.plannedHours = plannedHours;
        this.plannedCostSek = plannedCostSek;
        this.actualHours = actualHours;
        this.actualCostSek = actualCostSek;
    }

    // ===== Getters =====
    public int getCourseInstanceId() { return courseInstanceId; }
    public String getCourseCode() { return courseCode; }
    public String getStudyPeriod() { return studyPeriod; }
    public int getYear() { return year; }
    public double getPlannedHours() { return plannedHours; }
    public double getPlannedCostSek() { return plannedCostSek; }
    public double getActualHours() { return actualHours; }
    public double getActualCostSek() { return actualCostSek; }
}
