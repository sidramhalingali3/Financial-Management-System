package com.finance;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import java.sql.Driver;

public class DBConnection {

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Driver d = new com.mysql.cj.jdbc.Driver();
        DriverManager.registerDriver(d);
        String url = "jdbc:mysql://acela.proxy.rlwy.net:55794/railway";
        String user = "root";
        String password = "sTbzmPyVSRzYWMmkOkFfseQAuRgQOtry";

        return DriverManager.getConnection(url, user, password);
    }

    public static void main(String[] args) {
        try {
            Connection conn = getConnection();
            if (conn != null) {
                System.out.println("Successfully connected to the Railway MySQL Database!");
                conn.close();
            }
        } catch (Exception e) {
            System.err.println("Failed to connect to the database.");
            e.printStackTrace();
        }
    }
}
