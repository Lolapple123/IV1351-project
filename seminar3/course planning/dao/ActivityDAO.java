package dao;
import java.sql.*;
public class ActivityDAO {
  
    public int ensureActivity(Connection co, String name, double factor) throws SQLException {
        String find = "SELECT activitytype_id FROM ActivityType WHERE activity_name = ?";
        try (Statement s = co.prepareStatement(find)) {
            s.setString(1, name);
            try (ResultSet rs = s.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }  }
        String ins = "INSERT INTO ActivityType(activity_name, factor) VALUES (?,?) RETURNING activitytype_id";
        try (Statement s = conn.prepareStatement(ins)) {
            s.setString(1, name);
            s.setDouble(2, factor);
            try (ResultSet rs = s.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }}}
    public void upsertPlannedActivity(Connection co, int instanceId, int activityId, double hours)
            throws SQLException {
        String sql = "INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours) VALUES (?,?,?) ON CONFLICT (courseinstance_id, activitytype_id) DO UPDATE SET planned_hours = EXCLUDED.planned_hours";
        try (Statement s = co.prepareStatement(sql)) {
            s.setInt(1, instanceId);
            s.setInt(2, activityId);
            s.setDouble(3, hours);
            s.executeUpdate();
        } } }
