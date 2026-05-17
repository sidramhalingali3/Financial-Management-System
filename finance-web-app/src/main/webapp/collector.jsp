<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    if (session.getAttribute("role") == null || !"Collector".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Collector Dashboard - Finance Management</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <div>
                <div class="welcome-text">Welcome back, <%= session.getAttribute("username") %> (Collector)</div>
                <h2>Collector Dashboard</h2>
            </div>
            <div>
                <a href="addFinance.jsp" class="btn" style="margin-right: 10px; width: auto;">+ Collect EMI Payment</a>
                <a href="login.jsp?logout=true" class="btn btn-outline">Logout</a>
            </div>
        </div>

        <% 
            if ("true".equals(request.getParameter("success"))) {
                out.println("<div class='alert alert-success'>Finance record added successfully!</div>");
            }
        %>

        <h3>All Customer Collections</h3>
        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Description</th>
                        <th>Date</th>
                        <th>Customer</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection conn = null;
                        PreparedStatement pst = null;
                        ResultSet rs = null;
                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT id, username, type, amount, description, date FROM finance ORDER BY date DESC";
                            pst = conn.prepareStatement(sql);
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
                                        <td data-label="Customer"><%= rs.getString("username") %></td>
                                        <td data-label="Action">
                                            <a href="DeleteFinanceServlet?id=<%= rs.getInt("id") %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this record?');">Delete</a>
                                        </td>
                                    </tr>
                    <%
                            }
                            if (!hasRecords) {
                                out.println("<tr><td colspan='7' style='text-align:center;'>No collections found.</td></tr>");
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='7' style='text-align:center; color:#ef4444;'>Error loading collections: " + e.getMessage() + "</td></tr>");
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
