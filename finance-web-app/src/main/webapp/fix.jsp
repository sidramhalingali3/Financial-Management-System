<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<!DOCTYPE html>
<html>
<head><title>Database Fix</title></head>
<body>
    <h1>Running Database Fixes...</h1>
    <ul>
    <%
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        PreparedStatement pst = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            
            // 1. Get all users from loans
            rs = stmt.executeQuery("SELECT username, loan_amount FROM loans");
            java.util.List<String> users = new java.util.ArrayList<String>();
            java.util.List<Double> loanAmts = new java.util.ArrayList<Double>();
            while (rs.next()) {
                users.add(rs.getString("username"));
                loanAmts.add(rs.getDouble("loan_amount"));
            }
            rs.close();
            
            // 2. For each user, calculate paid amount from finance and update loans
            pst = conn.prepareStatement("UPDATE loans SET paid_amount = ?, remaining_amount = ? WHERE username = ?");
            PreparedStatement getPaidPst = conn.prepareStatement("SELECT SUM(amount) FROM finance WHERE username = ? AND (status = 'Approved' OR status IS NULL)");
            
            for (int i = 0; i < users.size(); i++) {
                String u = users.get(i);
                double loanAmt = loanAmts.get(i);
                
                getPaidPst.setString(1, u);
                ResultSet prs = getPaidPst.executeQuery();
                double paidAmt = 0;
                if (prs.next()) {
                    paidAmt = prs.getDouble(1);
                }
                prs.close();
                
                double remaining = loanAmt - paidAmt;
                
                pst.setDouble(1, paidAmt);
                pst.setDouble(2, remaining);
                pst.setString(3, u);
                pst.executeUpdate();
                
                out.println("<li>Updated Loan for " + u + ": Paid=" + paidAmt + ", Remaining=" + remaining + "</li>");
            }
            
            // 3. Backfill finance table
            PreparedStatement updateFin = conn.prepareStatement("UPDATE finance SET current_paid_amount = ?, current_remaining_amount = ? WHERE username = ? AND (current_paid_amount = 0 OR current_paid_amount IS NULL)");
            for (int i = 0; i < users.size(); i++) {
                String u = users.get(i);
                getPaidPst.setString(1, u);
                ResultSet prs = getPaidPst.executeQuery();
                double paidAmt = 0;
                if (prs.next()) {
                    paidAmt = prs.getDouble(1);
                }
                prs.close();
                double remaining = loanAmts.get(i) - paidAmt;
                
                updateFin.setDouble(1, paidAmt);
                updateFin.setDouble(2, remaining);
                updateFin.setString(3, u);
                int updated = updateFin.executeUpdate();
                out.println("<li>Updated " + updated + " finance records for " + u + "</li>");
            }

        } catch (Exception e) {
            out.println("<li style='color:red;'>Error: " + e.getMessage() + "</li>");
        } finally {
            if (pst != null) try{pst.close();}catch(Exception e){}
            if (rs != null) try{rs.close();}catch(Exception e){}
            if (stmt != null) try{stmt.close();}catch(Exception e){}
            if (conn != null) try{conn.close();}catch(Exception e){}
        }
    %>
    </ul>
</body>
</html>
