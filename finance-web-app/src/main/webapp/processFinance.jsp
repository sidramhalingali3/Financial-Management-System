<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || (!"Customer".equals(role) && !"Collector".equals(role))) {
        response.sendRedirect("login.jsp");
        return;
    }

    String amountStr = request.getParameter("amount");
    String description = request.getParameter("description");
    String type = request.getParameter("type");
    String dateStr = request.getParameter("date");
    String username = (String) session.getAttribute("username");
    
    if ("Collector".equals(role)) {
        username = request.getParameter("customerUsername");
        if (username != null) username = username.trim();
    }

    try (Connection conn = DBConnection.getConnection()) {
        double amount = Double.parseDouble(amountStr);
        Date sqlDate;
        if (dateStr != null && !dateStr.trim().isEmpty()) {
            sqlDate = Date.valueOf(dateStr);
        } else {
            sqlDate = new Date(System.currentTimeMillis());
        }
        
        String collectorName = "Self (UPI)";
        String paymentStatus = "Pending";
        
        if ("Collector".equals(role)) {
            collectorName = (String) session.getAttribute("username");
            paymentStatus = "Approved";
        } else {
            String checkSql = "SELECT id FROM finance WHERE description = ?";
            try (PreparedStatement checkPst = conn.prepareStatement(checkSql)) {
                checkPst.setString(1, description);
                try (ResultSet checkRs = checkPst.executeQuery()) {
                    if (checkRs.next()) {
                        response.sendRedirect("customer.jsp?error=duplicate_utr");
                        return;
                    }
                }
            }
        }
        
        String sql = "INSERT INTO finance (username, type, amount, description, date, time, collector, status) VALUES (?, ?, ?, ?, ?, CURRENT_TIME, ?, ?)";
        
        try (PreparedStatement pst = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pst.setString(1, username);
            pst.setString(2, type);
            pst.setDouble(3, amount);
            pst.setString(4, description);
            pst.setDate(5, sqlDate);
            pst.setString(6, collectorName);
            pst.setString(7, paymentStatus);
            
            int result = pst.executeUpdate();
            if (result > 0) {
                int generatedId = -1;
                try (ResultSet rsKeys = pst.getGeneratedKeys()) {
                    if (rsKeys.next()) generatedId = rsKeys.getInt(1);
                }
                
                if ("Collector".equals(role)) {
                    String updateLoanSql = "UPDATE loans SET paid_amount = COALESCE(paid_amount, 0) + ?, remaining_amount = COALESCE(remaining_amount, loan_amount) - ? WHERE username = ?";
                    try (PreparedStatement updatePst = conn.prepareStatement(updateLoanSql)) {
                        updatePst.setDouble(1, amount);
                        updatePst.setDouble(2, amount);
                        updatePst.setString(3, username);
                        updatePst.executeUpdate();
                    }
                    
                    if (generatedId != -1) {
                        String fetchSql = "SELECT paid_amount, remaining_amount FROM loans WHERE username = ?";
                        try (PreparedStatement fetchPst = conn.prepareStatement(fetchSql)) {
                            fetchPst.setString(1, username);
                            try (ResultSet rs = fetchPst.executeQuery()) {
                                if (rs.next()) {
                                    double pAmt = rs.getDouble("paid_amount");
                                    double rAmt = rs.getDouble("remaining_amount");
                                    String updateFinSql = "UPDATE finance SET current_paid_amount = ?, current_remaining_amount = ? WHERE id = ?";
                                    try (PreparedStatement ufinPst = conn.prepareStatement(updateFinSql)) {
                                        ufinPst.setDouble(1, pAmt);
                                        ufinPst.setDouble(2, rAmt);
                                        ufinPst.setInt(3, generatedId);
                                        ufinPst.executeUpdate();
                                    }
                                }
                            }
                        }
                    }
                    
                    response.sendRedirect("collector.jsp?success=true");
                } else {
                    response.sendRedirect("customer.jsp?success=true");
                }
            } else {
                response.sendRedirect("addFinance.jsp?error=insert_failed");
            }
        }
    } catch (Exception e) {
        out.println("<h2>EXCEPTION OCCURRED:</h2><pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
        out.println("<p><b>Please copy the above text and send it to me.</b></p>");
        out.println("<a href='addFinance.jsp'>Go Back</a>");
    }
%>
