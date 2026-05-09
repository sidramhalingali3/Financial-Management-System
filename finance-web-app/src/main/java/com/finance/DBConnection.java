package com.finance;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

import java.sql.Driver;

public class DBConnection {

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Driver d = new com.mysql.cj.jdbc.Driver();
        DriverManager.registerDriver(d);
        String url = System.getenv("DB_URL") != null ? System.getenv("DB_URL") : "jdbc:mysql://localhost:3306/finance_db";
        String user = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
        String password = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "root";
        return DriverManager.getConnection(url, user, password);
    }
}
