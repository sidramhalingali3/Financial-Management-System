<%@ page import="java.sql.*, com.finance.DBConnection" %>
<%
    out.println("Testing DB Insert...<br/>");
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
            out.println("Insert result: " + result + "<br/>");
        }
    } catch (Exception e) {
        out.println("Exception: " + e.getMessage() + "<br/>");
        for(StackTraceElement el : e.getStackTrace()) {
            out.println(el.toString() + "<br/>");
        }
    }
%>
