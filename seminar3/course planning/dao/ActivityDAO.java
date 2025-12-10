package dao;
import java.sql.*;
public class ActivityDAO {
  
    public int ensureActivity(Connection co, String name, double factor) throws SQLException {
        String find = "SELECT activitytype_id FROM ActivityType WHERE activity_name = ?";
        try (PreparedStatement ps = co.prepareStatement(find)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }  }
        String ins = "INSERT INTO ActivityType(activity_name, factor) VALUES (?,?) RETURNING activitytype_id";
        try (PreparedStatement ps = conn.prepareStatement(ins)) {
            ps.setString(1, name);
            ps.setDouble(2, factor);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }}}
    public void upsertPlannedActivity(Connection co, int instanceId, int activityId, double hours)
            throws SQLException {
        String sql = "INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours) VALUES (?,?,?) ON CONFLICT (courseinstance_id, activitytype_id) DO UPDATE SET planned_hours = EXCLUDED.planned_hours";
        try (PreparedStatement ps = co.prepareStatement(sql)) {
            ps.setInt(1, instanceId);
            ps.setInt(2, activityId);
            ps.setDouble(3, hours);
            ps.executeUpdate();
        } } }
