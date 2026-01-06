package dao;

import models.CostTeaching;
import java.sql.*;

public class TeachingCostDAO {
    private static final double AVG_SALARY_PER_HOUR = 350.0;

    public CostTeaching getCostForInstance(int instanceId) {
        String sqlPlanned = "SELECT COALESCE(SUM(pa.planned_hours * at.factor), 0) AS planned " +
                            "FROM PlannedActivity pa " +
                            "JOIN ActivityType at ON pa.activitytype_id = at.activitytype_id " +
                            "WHERE pa.courseinstance_id = ?";

        String sqlActual = "SELECT COALESCE(SUM(a.hoursallocated * at.factor), 0) AS actual " +
                           "FROM Allocation a " +
                           "JOIN ActivityType at ON a.activitytype_id = at.activitytype_id " +
                           "WHERE a.courseinstance_id = ?";

        String infoSql = "SELECT cl.course_code, ci.study_period, ci.year " +
                         "FROM CourseInstance ci " +
                         "JOIN CourseLayout cl ON ci.courselayout_id = cl.courselayout_id " +
                         "WHERE ci.courseinstance_id = ?";

        try (Connection c = DATABASEconnect.getConnection()) {
            double planned = getSingleValue(c, sqlPlanned, instanceId, "planned");
            double actual = getSingleValue(c, sqlActual, instanceId, "actual");

            double plannedKsek = planned * AVG_SALARY_PER_HOUR / 1000.0;
            double actualKsek = actual * AVG_SALARY_PER_HOUR / 1000.0;

            try (PreparedStatement ps = c.prepareStatement(infoSql)) {
                ps.setInt(1, instanceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return new CostTeaching(
                                instanceId,
                                rs.getString("course_code"),
                                rs.getString("study_period"),
                                rs.getInt("year"),
                                planned,
                                actual,
                                plannedKsek,
                                actualKsek
                        );
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("TeachingCostDAO error: " + e.getMessage());
        }
        return null;
    }

    private double getSingleValue(Connection c, String sql, int instanceId, String columnLabel) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, instanceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(columnLabel);
            }
        }
        return 0.0;
    }
}
