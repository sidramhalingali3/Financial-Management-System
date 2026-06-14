<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    String utr = request.getParameter("utr");
    if (utr == null || utr.trim().isEmpty()) {
        out.print("false");
        return;
    }
    
    boolean exists = false;
    try {
        Connection conn = DBConnection.getConnection();
        PreparedStatement pst = conn.prepareStatement("SELECT 1 FROM finance WHERE description = ?");
        pst.setString(1, utr.trim());
        ResultSet rs = pst.executeQuery();
        if (rs.next()) {
            exists = true;
        }
        rs.close();
        pst.close();
        conn.close();
    } catch (Exception e) {
        // In case of DB error, assume it doesn't exist to not block unnecessarily, or block.
    }
    out.print(exists ? "true" : "false");
%>
