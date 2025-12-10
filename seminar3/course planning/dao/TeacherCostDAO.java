package dao;
import model.TeachingCost;
import java.sql.*;

public class TeachingCostDAO {
    private static final double AVG_SALARY_PER_HOUR = 350.0;

    public TeachingCost getCostForInstance(int instanceId) {
        String sqlPlanned = """
            SELECT COALESCE(SUM(pa.planned_hours * at.factor), 0) AS planned
            FROM PlannedActivity pa
            JOIN ActivityType at ON pa.activity_id = at.activity_id
            WHERE pa.instance_id = ?
        """;

        String sqlActual = """
            SELECT COALESCE(SUM(a.allocated_hours * at.factor), 0) AS actual
            FROM Allocation a
            JOIN ActivityType at ON a.activity_id = at.activity_id
            WHERE a.instance_id = ?
        """;

        String infoSql = """
            SELECT cl.course_code, ci.period, ci.year
            FROM CourseInstance ci
            JOIN CourseLayout cl ON ci.layout_id = cl.layout_id
            WHERE ci.instance_id = ?
        """;

        try (Connection c = DATABASEconnect.getConnection()) {
            double planned = getSingleValue(c, sqlPlanned, instanceId, "planned");
            double actual = getSingleValue(c, sqlActual, instanceId, "actual");

            double plannedsek = planned * AVG_SALARY_PER_HOUR / 1000.0;
            double actualsek = actual * AVG_SALARY_PER_HOUR / 1000.0;

            try (PreparedStatement ps = c.prepareStatement(infoSql)) {
                ps.setInt(1, instanceId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String courseCode = rs.getString("course_code");
                        String period = rs.getString("period");
                        int year = rs.getInt("year");

                        return new TeachingCost(
                                instanceId,
                                courseCode,
                                period,
                                year,
                                planned,
                                actual,
                                plannedsek,
                                actualsek
                        );
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("TeachingCostDAO error: " + e.getMessage());
        }

        return null;
    }

    private double getSingleValue(Connection c, String sql, int instanceId, String columnLabel) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, instanceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(columnLabel);
                }
            }
        }
        return 0.0;
    }
}
