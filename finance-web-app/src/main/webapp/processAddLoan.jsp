<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    if (session.getAttribute("role") == null || !"Admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = request.getParameter("username");
    String amountStr = request.getParameter("amount");

    if (username == null || username.trim().isEmpty() || amountStr == null || amountStr.trim().isEmpty()) {
        response.sendRedirect("addLoan.jsp?loanError=empty_fields");
        return;
    }

    Connection conn = null;
    PreparedStatement delPst = null;
    PreparedStatement insPst = null;

    try {
        double amount = Double.parseDouble(amountStr);
        conn = DBConnection.getConnection();
        
        // Ensure AUTO_INCREMENT is set on loans table (fixes schema issues)
        try {
            conn.createStatement().execute("ALTER TABLE loans MODIFY id INT AUTO_INCREMENT");
        } catch (Exception ignore) {}
        
        // Erase any previous loan for this user
        String delSql = "DELETE FROM loans WHERE username = ?";
        delPst = conn.prepareStatement(delSql);
        delPst.setString(1, username.trim());
        delPst.executeUpdate();
        
        // Insert the new loan
        String insSql = "INSERT INTO loans (username, loan_amount, paid_amount, remaining_amount, date) VALUES (?, ?, 0.0, ?, ?)";
        insPst = conn.prepareStatement(insSql);
        insPst.setString(1, username.trim());
        insPst.setDouble(2, amount);
        insPst.setDouble(3, amount); // initial remaining amount is the full loan amount
        insPst.setDate(4, new java.sql.Date(System.currentTimeMillis()));
        
        int result = insPst.executeUpdate();
        if (result > 0) {
            response.sendRedirect("admin.jsp?loanSuccess=true");
        } else {
            response.sendRedirect("addLoan.jsp?loanError=insert_failed");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("addLoan.jsp?loanError=exception&msg=" + java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Unknown Error", "UTF-8"));
    } finally {
        if (delPst != null) try { delPst.close(); } catch(Exception e){}
        if (insPst != null) try { insPst.close(); } catch(Exception e){}
        if (conn != null) try { conn.close(); } catch(Exception e){}
    }
%>
