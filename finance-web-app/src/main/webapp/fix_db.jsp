<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<!DOCTYPE html>
<html>
<body>
<h3>Database Fix and Test Insert Log</h3>
<pre>
<%
    out.println("Starting diagnosis...");
    try (Connection conn = DBConnection.getConnection()) {
        out.println("1. Connection successful.");
        
        // Fix missing columns
        try (Statement stmt = conn.createStatement()) {
            try { stmt.executeUpdate("ALTER TABLE finance ADD COLUMN current_paid_amount DECIMAL(10,2)"); out.println("Added current_paid_amount"); } catch (Exception e) { out.println("current_paid_amount exists or error: " + e.getMessage()); }
            try { stmt.executeUpdate("ALTER TABLE finance ADD COLUMN current_remaining_amount DECIMAL(10,2)"); out.println("Added current_remaining_amount"); } catch (Exception e) { out.println("current_remaining_amount exists or error: " + e.getMessage()); }
            try { stmt.executeUpdate("ALTER TABLE loans ADD COLUMN paid_amount DECIMAL(10,2)"); out.println("Added paid_amount to loans"); } catch (Exception e) { out.println("paid_amount in loans exists or error: " + e.getMessage()); }
            try { stmt.executeUpdate("ALTER TABLE loans ADD COLUMN remaining_amount DECIMAL(10,2)"); out.println("Added remaining_amount to loans"); } catch (Exception e) { out.println("remaining_amount in loans exists or error: " + e.getMessage()); }
            try { stmt.executeUpdate("ALTER TABLE loans ADD COLUMN loan_amount DECIMAL(10,2)"); out.println("Added loan_amount to loans"); } catch (Exception e) { out.println("loan_amount in loans exists or error: " + e.getMessage()); }
        }

        out.println("\n2. Attempting test insert...");
        
        String sql = "INSERT INTO finance (username, type, amount, description, date, time, collector, status) VALUES (?, ?, ?, ?, ?, CURRENT_TIME, ?, ?)";
        try (PreparedStatement pst = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pst.setString(1, "testuser_debug");
            pst.setString(2, "Payment");
            pst.setDouble(3, 10.0);
            pst.setString(4, "Debug Test");
            pst.setDate(5, new java.sql.Date(System.currentTimeMillis()));
            pst.setString(6, "Self");
            pst.setString(7, "Approved");
            
            int result = pst.executeUpdate();
            out.println("Insert into finance result: " + result);

            if (result > 0) {
                int generatedId = -1;
                try (ResultSet rsKeys = pst.getGeneratedKeys()) {
                    if (rsKeys.next()) generatedId = rsKeys.getInt(1);
                }
                out.println("Generated ID: " + generatedId);
                
                String updateLoanSql = "UPDATE loans SET paid_amount = COALESCE(paid_amount, 0) + ?, remaining_amount = COALESCE(remaining_amount, loan_amount) - ? WHERE username = ?";
                try (PreparedStatement updatePst = conn.prepareStatement(updateLoanSql)) {
                    updatePst.setDouble(1, 10.0);
                    updatePst.setDouble(2, 10.0);
                    updatePst.setString(3, "testuser_debug");
                    int loanUpd = updatePst.executeUpdate();
                    out.println("Loan update result: " + loanUpd);
                }

                if (generatedId != -1) {
                    String updateFinSql = "UPDATE finance SET current_paid_amount = ?, current_remaining_amount = ? WHERE id = ?";
                    try (PreparedStatement ufinPst = conn.prepareStatement(updateFinSql)) {
                        ufinPst.setDouble(1, 10.0);
                        ufinPst.setDouble(2, 90.0);
                        ufinPst.setInt(3, generatedId);
                        int finUpd = ufinPst.executeUpdate();
                        out.println("Finance current_amount update result: " + finUpd);
                    }
                }
            }
        }
        
        out.println("\nSUCCESS: No exceptions thrown during simulation!");
    } catch (Exception e) {
        out.println("\nEXCEPTION CAUGHT:");
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
</pre>
</body>
</html>
