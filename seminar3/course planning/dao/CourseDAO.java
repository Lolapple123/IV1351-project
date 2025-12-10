package dao;
import model.CourseInstance;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
public class CourseDAO {
    public List<CourseInstance> getAllInstances() {
        List<CourseInstance> out = new ArrayList<>();
        String sql = "SELECT ci.instance_id, ci.period, ci.year, ci.num_students " +
                "FROM CourseInstance ci JOIN CourseLayout cl ON ci.layout_id = cl.layout_id " +
                "ORDER BY ci.year DESC, ci.period, ci.instance_id";
        try (Connection c = DATABASEconnect.getConnection();
                Statement s = c.createStatement();
                ResultSet rs = s.executeQuery(sql)) {
            while (rs.next()) {
                out.add(new CourseInstance(
                        rs.getInt("instance_id"),
                        rs.getString("period"),
                        rs.getInt("year"),
                        rs.getInt("num_students")));
            }
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
        return out;
    }
    public CourseInstance lockAndGetCourseInstance(int instanceId) throws SQLException {
        String sql = "SELECT ci.instance_id, ci.period, ci.year, ci.num_students " +
                "FROM CourseInstance ci JOIN CourseLayout cl ON ci.layout_id = cl.layout_id " +
                "WHERE ci.instance_id = ? FOR UPDATE";
        try (Connection c = DATABASEconnect.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, instanceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new CourseInstance(
                            rs.getInt("courseinstance_id"),
                            rs.getString("study_period"),
                            rs.getInt("year"),
                            rs.getInt("num_students"));
                } } }  return null; }
    public void increaseStudents(int instanceId, int delta) throws SQLException {
        String sql = "UPDATE CourseInstance SET num_students = num_students + ? WHERE instance_id = ?";
        try (Connection c = DATABASEconnect.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, delta);
            ps.setInt(2, instanceId);
            ps.executeUpdate();
        }  }
    public String[] getCourseCodeAndPeriod(int instanceId) throws SQLException {
        String sql = "SELECT ci.period FROM CourseInstance ci JOIN CourseLayout cl ON ci.layout_id = cl.layout_id WHERE ci.instance_id = ?";
        try (Connection c = DATABASEconnect.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, instanceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new String[] { rs.getString(1), rs.getString(2) };
                } } }
        return null; } }
