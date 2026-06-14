package com.finance;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class TestInsert {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO finance (username, type, amount, description, date, time, collector, status) VALUES (?, ?, ?, ?, ?, CURRENT_TIME, ?, ?)";
            try (PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setString(1, "testuser");
                pst.setString(2, "Payment");
                pst.setDouble(3, 100.0);
                pst.setString(4, "Test");
                pst.setDate(5, new java.sql.Date(System.currentTimeMillis()));
                pst.setString(6, "Self");
                pst.setString(7, "Approved");
                
                int result = pst.executeUpdate();
                System.out.println("Insert result: " + result);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
