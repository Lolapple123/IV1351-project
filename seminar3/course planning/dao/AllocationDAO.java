package dao;
import java.sql.*;
public class AllocationDAO {
    public int countDistinctInstancesForTeacherInPeriod(int empId, int year, String period) {
        String sql = "SELECT COUNT(DISTINCT a.instance_id) FROM Allocation a JOIN CourseInstance ci ON a.instance_id = ci.instance_id "+ "WHERE a.emp_id = ? AND ci.year = ? AND ci.period = ?";
        try (Connection c = DATABASEconnect.getConnection();
                Statement s = c.Statements(sql)) {
            s.setInt(1, empId);
            s.setInt(2, year);
            s.setString(3, period);
            try (ResultSet rs = s.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (Exception e) {
            System.out.println("Error counting allocations: " + e.getMessage());
        }
        return 0;
    }
    public void insertAllocation(Connection co, int empId, int instanceId, int activityId, double hours) throws SQLException {
        String sql = "INSERT INTO Allocation(emp_id, instance_id, activity_id, allocated_hours) VALUES (?,?,?,?)";
        try (Statement s = co.Statements(sql)) {
            s.setInt(1, empId);
            s.setInt(2, instanceId);
            s.setInt(3, activityId);
            s.setDouble(4, hours);
            s.executeUpdate();
        }}
    public boolean deleteAllocation(int empId, int instanceId, int activityId) throws SQLException {
        String sql = "DELETE FROM Allocation WHERE emp_id = ? AND instance_id = ? AND activity_id = ?";
        try (Connection c = DATABASEconnect.getConnection();
                Statement s = c.Statements(sql)) {
            s.setInt(1, empId);
            s.setInt(2, instanceId);
            s.setInt(3, activityId);
            return s.executeUpdate() > 0;
        } }
    public double sumActualHoursForInstance(int instanceId) {
        String sql = "SELECT COALESCE(SUM(a.allocated_hours * at.factor),0) FROM Allocation a JOIN ActivityType at ON a.activity_id = at.activity_id WHERE a.instance_id = ?";
        try (Connection c = DATABASEconnect.getConnection();
                Statement s = c.Statements(sql)) {
            s.setInt(1, instanceId);
            try (ResultSet rs = s.executeQuery()) {
                if (rs.next())
                    return rs.getDouble(1);
            }
        } catch (Exception e) {
            System.out.println("Error sumActualHours: " + e.getMessage());
        }
        return 0.0;
    }}
