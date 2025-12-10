package dao;
import model.Teacher;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TeacherDAO {
    public List<Teacher> getAllTeachers() {
        List<Teacher> list = new ArrayList<>();
        String sql = "SELECT emp_id, first_name, last_name";
        try (Connection c = DATABASEconnect.getConnection();
                Statement statement = c.createStatement();
                ResultSet result = statement.executeQuery(sql)) {
            while (result.next()) {
                list.add(new Teacher(
                        result.getInt("emp_id"),
                        result.getString("first_name"),
                        result.getString("last_name"),
                        result.getString("designation")));
            } } catch (Exception e) {
            System.out.println("Error loading teachers: " + e.getMessage()); }
        return list;
    } }
