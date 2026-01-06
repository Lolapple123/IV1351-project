package dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import models.Teacher;

public class TeacherDAO {

    public List<Teacher> getAllTeachers() {
        List<Teacher> list = new ArrayList<>();
        String sql = "SELECT e.employee_id, p.first_name, p.last_name, jt.job_title AS designation " +
                     "FROM Employee e " +
                     "JOIN Person p ON e.personal_number = p.personal_number " +
                     "JOIN Job_Title jt ON e.job_title_id = jt.job_title_id";
        try (Connection c = DATABASEconnect.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Teacher(
                        rs.getInt("employee_id"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getString("designation")
                ));
            }
        } catch (SQLException e) {
            System.out.println("Error loading teachers: " + e.getMessage());
        }
        return list;
    }
}
