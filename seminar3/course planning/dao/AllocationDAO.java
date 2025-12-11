package dao;

import java.sql.*;

public class AllocationDAO {

    public int countDistinctInstancesForTeacherInPeriod(int empId, int year, String period) {
        String sql = "SELECT COUNT(DISTINCT a.courseinstance_id) AS cnt " +
                     "FROM Allocation a " +
                     "JOIN CourseInstance ci ON a.courseinstance_id = ci.courseinstance_id " +
                     "WHERE a.employee_id = ? AND ci.year = ? AND ci.study_period = ?";

        try (Connection c = DATABASEconnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, empId);
            ps.setInt(2, year);
            ps.setString(3, period);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt");
            }

        } catch (SQLException e) {
            System.out.println("Error counting allocations: " + e.getMessage());
        }
        return 0;
    }

    public void insertAllocation(Connection co, int empId, int instanceId, int activityId, double hours) throws SQLException {
        String sql = "INSERT INTO Allocation(employee_id, courseinstance_id, activitytype_id, hoursallocated) VALUES (?,?,?,?)";
        try (PreparedStatement ps = co.prepareStatement(sql)) {
            ps.setInt(1, empId);
            ps.setInt(2, instanceId);
            ps.setInt(3, activityId);
            ps.setDouble(4, hours);
            ps.executeUpdate();
        }
    }

    public boolean deleteAllocation(int empId, int instanceId, int activityId) {
        String sql = "DELETE FROM Allocation WHERE employee_id = ? AND courseinstance_id = ? AND activitytype_id = ?";
        try (Connection c = DATABASEconnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, empId);
            ps.setInt(2, instanceId);
            ps.setInt(3, activityId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error deleting allocation: " + e.getMessage());
            return false;
        }
    }
}
