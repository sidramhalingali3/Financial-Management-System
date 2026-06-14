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
        String password = "sTbzmPyVSRzYWMmkOkFfseQAuRgQ0try";
        
        return DriverManager.getConnection(url, user, password);
    }
}
