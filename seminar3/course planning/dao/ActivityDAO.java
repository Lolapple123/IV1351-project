package dao;
import java.sql.*;
public class ActivityDAO {

    public int ensureActivity(Connection co, String name, double factor) throws SQLException {
        String findSql = "SELECT activitytype_id FROM ActivityType WHERE activity_name = ?";
        try (PreparedStatement ps = co.prepareStatement(findSql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("activitytype_id");
            } }
        String insertSql = "INSERT INTO ActivityType(activity_name, factor) VALUES (?, ?) RETURNING activitytype_id";
        try (PreparedStatement ps = co.prepareStatement(insertSql)) {
            ps.setString(1, name);
            ps.setDouble(2, factor);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("activitytype_id");
            }}
        throw new SQLException("Failed to create or find activity");
    }

    public void upsertPlannedActivity(Connection co, int instanceId, int activityId, double hours) throws SQLException {
        String sql = "INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours) " +
                     "VALUES (?, ?, ?) " +
                     "ON CONFLICT (courseinstance_id, activitytype_id) DO UPDATE SET planned_hours = EXCLUDED.planned_hours";

        try (PreparedStatement ps = co.prepareStatement(sql)) {
            ps.setInt(1, instanceId);
            ps.setInt(2, activityId);
            ps.setDouble(3, hours);
            ps.executeUpdate();
        }}}
