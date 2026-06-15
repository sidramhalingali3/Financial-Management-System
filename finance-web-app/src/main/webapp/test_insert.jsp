<%@ page import="java.sql.*, com.finance.DBConnection" %>
<%
    try {
        Connection conn = DBConnection.getConnection();
        String sql = "INSERT INTO finance (username, type, amount, description, date, time, collector, status) VALUES ('testuser', 'Payment', 100, 'test desc', '2023-01-01', CURRENT_TIME, 'collector1', 'Approved')";
        PreparedStatement pst = conn.prepareStatement(sql);
        pst.executeUpdate();
        out.println("Success!");
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace(new java.io.PrintWriter(out));
    }
%>
