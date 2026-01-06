package dao;

import java.sql.*;

public class AllocationDAO {

    // =============================
    // Insert allocation into database
    // =============================
    public void insertAllocation(Connection c, int empId, int plannedActivityId, double hours)
            throws SQLException {
        String sql = "INSERT INTO Allocation(employee_id, planned_activity_id, hoursallocated) VALUES (?, ?, ?)";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, empId);
            ps.setInt(2, plannedActivityId);
            ps.setDouble(3, hours);
            ps.executeUpdate();
        }
    }

    // =============================
    // Count distinct course instances a teacher has in a period
    // =============================
    public int countDistinctInstancesForTeacherInPeriod(Connection c, int empId, int year, String studyPeriod) 
            throws SQLException {
        String sql = "SELECT COUNT(DISTINCT pa.courseinstance_id) " +
                     "FROM Allocation a " +
                     "JOIN PlannedActivity pa ON a.planned_activity_id = pa.planned_activity_id " +
                     "JOIN CourseInstance ci ON pa.courseinstance_id = ci.courseinstance_id " +
                     "WHERE a.employee_id = ? AND ci.year = ? AND ci.study_period = ?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, empId);
            ps.setInt(2, year);
            ps.setString(3, studyPeriod);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // =============================
    // Check if teacher already has allocation
    // =============================
    public boolean isTeacherAllocated(Connection c, int empId, int plannedActivityId) throws SQLException {
    String sql = "SELECT 1 FROM Allocation WHERE employee_id = ? AND planned_activity_id = ?";
    try (PreparedStatement ps = c.prepareStatement(sql)) {
        ps.setInt(1, empId);
        ps.setInt(2, plannedActivityId);
        try (ResultSet rs = ps.executeQuery()) {
            return rs.next();
        }
    }
}

    // =============================
    // Delete allocation
    // =============================
    public boolean deleteAllocation(Connection c, int empId, int plannedActivityId) throws SQLException {
        String sql = "DELETE FROM Allocation WHERE employee_id = ? AND planned_activity_id = ?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, empId);
            ps.setInt(2, plannedActivityId);
            return ps.executeUpdate() > 0;
        }
    }
}
