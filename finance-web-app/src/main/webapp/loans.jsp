<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    if (session.getAttribute("role") == null || !"Admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Loans - Finance Management</title>
    <link rel="stylesheet" href="style.css?v=3">
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <div>
                <h2>System Loans</h2>
                <div class="welcome-text">Overview of all customer loans in the system.</div>
            </div>
            <div>
                <a href="addLoan.jsp" class="btn" style="margin-right: 10px; background-color: #3b82f6;">+ Assign Loan</a>
                <a href="admin.jsp" class="btn btn-outline" style="margin-right: 10px;">&larr; Back to Dashboard</a>
            </div>
        </div>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Loan Amount</th>
                        <th>Paid Amount</th>
                        <th>Remaining Balance</th>
                        <th>Date Assigned</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection conn = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        try {
                            conn = DBConnection.getConnection();
                            stmt = conn.createStatement();
                            String query = "SELECT id, username, loan_amount, date, paid_amount, remaining_amount FROM loans ORDER BY date DESC, id DESC";
                            rs = stmt.executeQuery(query);
                             
                            boolean hasRecords = false;
                            while (rs.next()) {
                                hasRecords = true;
                                double loanAmount = rs.getDouble("loan_amount");
                                double paidAmount = rs.getDouble("paid_amount");
                                double remainingAmount = rs.getDouble("remaining_amount");
                    %>
                        <tr>
                            <td data-label="ID"><%= rs.getInt("id") %></td>
                            <td data-label="Username"><strong><%= rs.getString("username") %></strong></td>
                            <td data-label="Loan Amount" style="color: #3b82f6; font-weight: bold;">&#8377;<%= String.format("%,.0f", loanAmount) %></td>
                            <td data-label="Paid Amount" style="color: #10b981; font-weight: bold;">&#8377;<%= String.format("%,.0f", paidAmount) %></td>
                            <td data-label="Remaining Balance" style="color: <%= remainingAmount > 0 ? "#ef4444" : "#10b981" %>; font-weight: bold;">&#8377;<%= String.format("%,.0f", remainingAmount) %></td>
                            <td data-label="Date Assigned"><%= rs.getDate("date") != null ? rs.getDate("date") : "N/A" %></td>
                        </tr>
                    <%
                            }
                            if (!hasRecords) {
                                out.println("<tr><td colspan='6' style='text-align:center;'>No loans found in the system.</td></tr>");
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6' style='color:#ef4444; text-align:center;'>Error loading loans: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch(Exception e){}
                            if (stmt != null) try { stmt.close(); } catch(Exception e){}
                            if (conn != null) try { conn.close(); } catch(Exception e){}
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
