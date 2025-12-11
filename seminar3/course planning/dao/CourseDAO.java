package dao;
import model.CourseInstance;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CourseDAO {

    public List<CourseInstance> getAllInstances() {
        List<CourseInstance> list = new ArrayList<>();
        String sql = "SELECT ci.courseinstance_id, cl.course_code, cl.course_name, ci.study_period, ci.year, ci.num_students " +
                     "FROM CourseInstance ci " +
                     "JOIN CourseLayout cl ON ci.courselayout_id = cl.courselayout_id " +
                     "ORDER BY ci.year DESC, ci.study_period, ci.courseinstance_id";

        try (Connection c = DATABASEconnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(new CourseInstance(
                        rs.getInt("courseinstance_id"),
                        rs.getString("course_code"),
                        rs.getString("course_name"),
                        rs.getString("study_period"),
                        rs.getInt("year"),
                        rs.getInt("num_students")
                )); }
        } catch (SQLException e) {
            System.out.println("Error fetching course instances: " + e.getMessage());
        }
        return list;
    }
    public CourseInstance lockAndGetCourseInstance(int instanceId) {
        String sql = "SELECT ci.courseinstance_id, cl.course_code, cl.course_name, ci.study_period, ci.year, ci.num_students " +
                     "FROM CourseInstance ci " +
                     "JOIN CourseLayout cl ON ci.courselayout_id = cl.courselayout_id " +
                     "WHERE ci.courseinstance_id = ? FOR UPDATE";

        try (Connection c = DATABASEconnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, instanceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new CourseInstance(
                            rs.getInt("courseinstance_id"),
                            rs.getString("course_code"),
                            rs.getString("course_name"),
                            rs.getString("study_period"),
                            rs.getInt("year"),
                            rs.getInt("num_students")
                    );}}
        } catch (SQLException e) {
            System.out.println("Error locking/getting course instance: " + e.getMessage());
        }
        return null;
    }

    public void increaseStudents(int instanceId, int delta) {
        String sql = "UPDATE CourseInstance SET num_students = num_students + ? WHERE courseinstance_id = ?";
        try (Connection c = DATABASEconnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, delta);
            ps.setInt(2, instanceId);
            ps.executeUpdate();

        } catch (SQLException e) {
            System.out.println("Error increasing students: " + e.getMessage());
        }}}
