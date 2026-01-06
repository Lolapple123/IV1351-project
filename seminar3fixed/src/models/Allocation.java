package models;

public class Allocation {
    private int courseInstanceId;  // corresponds to courseinstance_id
    private int teacherId;         // corresponds to employee_id
    private int activityTypeId;    // corresponds to activitytype_id
    private double hoursAllocated; // corresponds to hoursallocated in DB

    public Allocation(int courseInstanceId, int teacherId, int activityTypeId, double hoursAllocated) {
        this.courseInstanceId = courseInstanceId;
        this.teacherId = teacherId;
        this.activityTypeId = activityTypeId;
        this.hoursAllocated = hoursAllocated;
    }

    // ===== Getters =====
    public int getCourseInstanceId() { return courseInstanceId; }
    public int getTeacherId() { return teacherId; }
    public int getActivityTypeId() { return activityTypeId; }
    public double getHoursAllocated() { return hoursAllocated; }

    // ===== Setters =====
    public void setCourseInstanceId(int courseInstanceId) { this.courseInstanceId = courseInstanceId; }
    public void setTeacherId(int teacherId) { this.teacherId = teacherId; }
    public void setActivityTypeId(int activityTypeId) { this.activityTypeId = activityTypeId; }
    public void setHoursAllocated(double hoursAllocated) { this.hoursAllocated = hoursAllocated; }
}
