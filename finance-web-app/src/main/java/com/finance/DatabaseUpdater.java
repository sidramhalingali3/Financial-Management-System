package com.finance;

import java.sql.Connection;
import java.sql.Statement;

public class DatabaseUpdater {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            // 1. Try to add the column if it doesn't exist
            try {
                stmt.execute("ALTER TABLE finance ADD COLUMN collector VARCHAR(100)");
                System.out.println("Added 'collector' column to the database.");
            } catch (Exception e) {
                System.out.println("'collector' column likely already exists. Proceeding to update...");
            }

            // 2. Automatically assign the 4 collectors to existing rows
            String sql = "UPDATE finance SET collector = CASE " +
                         "WHEN id % 4 = 1 THEN 'Rajesh Kumar' " +
                         "WHEN id % 4 = 2 THEN 'Manjunath Patil' " +
                         "WHEN id % 4 = 3 THEN 'Sandeep Gowda' " +
                         "ELSE 'Vinay Shetty' END";
            
            int rowsAffected = stmt.executeUpdate(sql);
            
            // 3. Update the type to 'Payment' for all records
            String typeSql = "UPDATE finance SET type='Payment'";
            int typeRowsAffected = stmt.executeUpdate(typeSql);
            
            System.out.println("Successfully assigned collectors to " + rowsAffected + " records!");
            System.out.println("Successfully updated type to 'Payment' for " + typeRowsAffected + " records!");
            System.out.println("Database is updated and ready to be shown in UI.");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
