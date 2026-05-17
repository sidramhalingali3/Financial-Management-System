<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    if (session.getAttribute("role") == null || !"User".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard - Finance Management</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <div>
                <div class="welcome-text">Welcome back, <%= session.getAttribute("username") %></div>
                <h2>Customer Dashboard</h2>
            </div>
            <div>
                <a href="addFinance.jsp" class="btn" style="margin-right: 10px; width: auto;">+ Add Record</a>
                <a href="login.jsp?logout=true" class="btn btn-outline">Logout</a>
            </div>
        </div>

        <% 
            if ("true".equals(request.getParameter("success"))) {
                out.println("<div class='alert alert-success'>Finance record added successfully!</div>");
            }
            
            String currentUsername = (String) session.getAttribute("username");
            double myLoanAmount = 0;
            double myPaidAmount = 0;
            try (Connection conn = DBConnection.getConnection()) {
                String lSql = "SELECT MAX(loan_amount) as la FROM loans WHERE username = ?";
                try(PreparedStatement lpst = conn.prepareStatement(lSql)){
                    lpst.setString(1, currentUsername);
                    ResultSet lrs = lpst.executeQuery();
                    if(lrs.next()) myLoanAmount = lrs.getDouble("la");
                }
                String pSql = "SELECT SUM(amount) as pa FROM finance WHERE username = ?";
                try(PreparedStatement ppst = conn.prepareStatement(pSql)){
                    ppst.setString(1, currentUsername);
                    ResultSet prs = ppst.executeQuery();
                    if(prs.next()) myPaidAmount = prs.getDouble("pa");
                }
            } catch (Exception e) {}
            double myRemaining = myLoanAmount - myPaidAmount;
        %>
        
        <div style="display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 30px;">
            <div class="card" style="flex: 1; padding: 20px; background: rgba(59, 130, 246, 0.1); border-radius: 12px; border-left: 4px solid #3b82f6;">
                <h4 style="margin: 0; color: #9ca3af; font-weight: normal;">Total Loan Amount</h4>
                <div style="font-size: 1.5rem; font-weight: bold; margin-top: 5px;">&#8377;<%= String.format("%,.0f", myLoanAmount) %></div>
            </div>
            <div class="card" style="flex: 1; padding: 20px; background: rgba(16, 185, 129, 0.1); border-radius: 12px; border-left: 4px solid #10b981;">
                <h4 style="margin: 0; color: #9ca3af; font-weight: normal;">Paid Amount</h4>
                <div style="font-size: 1.5rem; font-weight: bold; margin-top: 5px; color: #10b981;">&#8377;<%= String.format("%,.0f", myPaidAmount) %></div>
            </div>
            <div class="card" style="flex: 1; padding: 20px; background: rgba(239, 68, 68, 0.1); border-radius: 12px; border-left: 4px solid #ef4444;">
                <h4 style="margin: 0; color: #9ca3af; font-weight: normal;">Remaining Balance</h4>
                <div style="font-size: 1.5rem; font-weight: bold; margin-top: 5px; color: <%= myRemaining > 0 ? "#ef4444" : "#10b981" %>;">&#8377;<%= String.format("%,.0f", myRemaining) %></div>
            </div>
        </div>

        <h3>Your Payment History</h3>
        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Description</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String currentUsername = (String) session.getAttribute("username");
                        Connection conn = null;
                        PreparedStatement pst = null;
                        ResultSet rs = null;
                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT id, type, amount, description, date FROM finance WHERE username = ? ORDER BY date DESC";
                            pst = conn.prepareStatement(sql);
                            pst.setString(1, currentUsername);
                            rs = pst.executeQuery();
                            boolean hasRecords = false;
                            while (rs.next()) {
                                hasRecords = true;
                    %>
                                        <tr>
                                            <td data-label="ID"><%= rs.getInt("id") %></td>
                                            <td data-label="Type"><%= rs.getString("type") %></td>
                                            <td data-label="Amount" style="color: #10b981; font-weight: 500;">&#8377;<%= String.format("%,.0f", rs.getDouble("amount")) %></td>
                                            <td data-label="Description"><%= rs.getString("description") %></td>
                                            <td data-label="Date"><%= rs.getDate("date") %></td>
                                        </tr>
                    <%
                            }
                            if (!hasRecords) {
                                out.println("<tr><td colspan='5' style='text-align:center;'>You haven't added any records yet.</td></tr>");
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' style='text-align:center; color:#ef4444;'>Error loading records: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if(rs != null) try { rs.close(); } catch(Exception e){}
                            if(pst != null) try { pst.close(); } catch(Exception e){}
                            if(conn != null) try { conn.close(); } catch(Exception e){}
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
