package dao;

import java.sql.*;

public class ActivityDAO {

    // =============================
    // Get planned_activity_id for a course instance + activity type
    // =============================
    public int getPlannedActivityId(Connection c, int courseInstanceId, int activityTypeId) throws SQLException {
        String sql = "SELECT planned_activity_id FROM PlannedActivity WHERE courseinstance_id = ? AND activitytype_id = ?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, courseInstanceId);
            ps.setInt(2, activityTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("Planned activity not found for instance " + courseInstanceId + " and activity " + activityTypeId);
    }

    // =============================
    // Ensure activity type exists and return ID
    // =============================
    public int ensureActivity(Connection c, String activityName, double factor) throws SQLException {
        String selectSql = "SELECT activitytype_id FROM ActivityType WHERE activity_name = ?";
        try (PreparedStatement ps = c.prepareStatement(selectSql)) {
            ps.setString(1, activityName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }

        String insertSql = "INSERT INTO ActivityType(activity_name, factor) VALUES (?, ?) RETURNING activitytype_id";
        try (PreparedStatement ps = c.prepareStatement(insertSql)) {
            ps.setString(1, activityName);
            ps.setDouble(2, factor);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("Failed to insert or get activity type: " + activityName);
    }

    // =============================
    // Upsert planned activity (insert if not exists)
    // =============================
    public void upsertPlannedActivity(Connection c, int courseInstanceId, int activityTypeId, double plannedHours) throws SQLException {
        String selectSql = "SELECT planned_activity_id FROM PlannedActivity WHERE courseinstance_id = ? AND activitytype_id = ?";
        try (PreparedStatement ps = c.prepareStatement(selectSql)) {
            ps.setInt(1, courseInstanceId);
            ps.setInt(2, activityTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Update existing
                    int plannedActivityId = rs.getInt(1);
                    String updateSql = "UPDATE PlannedActivity SET planned_hours = ? WHERE planned_activity_id = ?";
                    try (PreparedStatement psUpdate = c.prepareStatement(updateSql)) {
                        psUpdate.setDouble(1, plannedHours);
                        psUpdate.setInt(2, plannedActivityId);
                        psUpdate.executeUpdate();
                    }
                    return;
                }
            }
        }

        // Insert new planned activity
        String insertSql = "INSERT INTO PlannedActivity(courseinstance_id, activitytype_id, planned_hours) VALUES (?, ?, ?)";
        try (PreparedStatement psInsert = c.prepareStatement(insertSql)) {
            psInsert.setInt(1, courseInstanceId);
            psInsert.setInt(2, activityTypeId);
            psInsert.setDouble(3, plannedHours);
            psInsert.executeUpdate();
        }
    }
}
