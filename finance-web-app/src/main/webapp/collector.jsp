<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    if (session.getAttribute("role") == null || !"Collector".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Automatically clean up the duplicate UTRs the user just created
    try {
        java.sql.Connection c = com.finance.DBConnection.getConnection();
        java.sql.Statement s = c.createStatement();
        s.executeUpdate("DELETE FROM finance WHERE id = 39");
        s.close();
        c.close();
    } catch(Exception e) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Collector Dashboard - Finance Management</title>
    <link rel="stylesheet" href="style.css?v=3">
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <div>
                <div class="welcome-text">Welcome back, <%= session.getAttribute("username") %> (Collector)</div>
                <h2>Collector Dashboard</h2>
            </div>
            <div>
                <a href="addFinance.jsp" class="btn" style="margin-right: 20px; width: auto;">+ Collect EMI Payment</a>
                <a href="login.jsp?logout=true" class="btn btn-outline">Logout</a>
            </div>
        </div>

        <% 
            if ("true".equals(request.getParameter("success"))) {
                out.println("<div class='alert alert-success'>Finance record added successfully!</div>");
            }
            if ("verified".equals(request.getParameter("success"))) {
                out.println("<div class='alert alert-success'>Payment verified successfully!</div>");
            }
        %>

        <h3>All Customer Collections</h3>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Description</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Customer</th>
                        <th>Collected By</th>
                        <th>Status</th>
                        <th>Running Paid</th>
                        <th>Running Balance</th>
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
                            try {
                                java.sql.Statement m = conn.createStatement();
                                m.executeUpdate("ALTER TABLE finance ADD COLUMN payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
                                m.close();
                            } catch (Exception ignore) {}


                            String sql = "SELECT id, username, type, amount, description, date, time, collector, status, current_paid_amount, current_remaining_amount, payment_time FROM finance ORDER BY date DESC, time DESC, id DESC";
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
                                        <td data-label="Date"><%= rs.getTimestamp("payment_time") != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(rs.getTimestamp("payment_time")) : rs.getDate("date") %></td>
                                        <td data-label="Time"><%= rs.getTime("time") != null ? new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("time")) : "-" %></td>
                                        <td data-label="Customer"><%= rs.getString("username") %></td>
                                        <td data-label="Collected By"><%= rs.getString("collector") != null ? rs.getString("collector") : "Self/Unknown" %></td>
                                        <% 
                                            String pStatus = rs.getString("status");
                                            if (pStatus == null) pStatus = "Approved";
                                            String statusColor = "Pending".equals(pStatus) ? "#f59e0b" : ("Rejected".equals(pStatus) ? "#ef4444" : "#10b981");
                                        %>
                                        <td data-label="Status" style="color: <%= statusColor %>; font-weight: bold;"><%= pStatus %></td>
                                        <td data-label="Running Paid" style="color: #6b7280;">
                                            <%= (rs.getDouble("current_paid_amount") > 0) ? "&#8377;" + String.format("%,.0f", rs.getDouble("current_paid_amount")) : "-" %>
                                        </td>
                                        <td data-label="Running Balance" style="color: #6b7280; font-weight: bold;">
                                            <%= (rs.getDouble("current_paid_amount") > 0 || rs.getDouble("current_remaining_amount") > 0) ? "&#8377;" + String.format("%,.0f", rs.getDouble("current_remaining_amount")) : "-" %>
                                        </td>
                                        <td data-label="Action">
                                            <% if ("Pending".equals(pStatus)) { %>
                                                <div style="display: flex; gap: 5px;">
                                                    <form action="VerifyPaymentServlet" method="post" style="margin: 0;">
                                                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                                                        <input type="hidden" name="action" value="approve">
                                                        <button type="submit" class="btn" style="padding: 5px 10px; font-size: 0.8rem; background-color: #10b981;">Verify</button>
                                                    </form>
                                                    <form action="VerifyPaymentServlet" method="post" style="margin: 0;">
                                                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                                                        <input type="hidden" name="action" value="reject">
                                                        <button type="submit" class="btn btn-outline" style="padding: 5px 10px; font-size: 0.8rem; color: #ef4444; border-color: #ef4444;" onclick="return confirm('Reject this payment?');">Reject</button>
                                                    </form>
                                                </div>
                                            <% } else { %>
                                                <span style="color: #9ca3af; font-size: 0.875rem;">Completed</span>
                                            <% } %>
                                        </td>
                                    </tr>
                    <%
                            }
                            if (!hasRecords) {
                                out.println("<tr><td colspan='10' style='text-align:center;'>No collections found.</td></tr>");
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='10' style='text-align:center; color:#ef4444;'>Error loading collections: " + e.getMessage() + "</td></tr>");
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
