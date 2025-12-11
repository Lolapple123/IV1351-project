package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DATABASEconnect {

    private static final String URL = "jdbc:postgresql://localhost:5432/yourdbname"; 
    private static final String USER = "yourusername";
    private static final String PASSWORD = "yourpassword"; 

    static {
        try {
            Class.forName("org.postgresql.Driver"); 
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }}
