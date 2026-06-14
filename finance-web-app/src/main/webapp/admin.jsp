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
    <title>Admin Dashboard - Finance Management</title>
    <link rel="stylesheet" href="style.css?v=3">
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <div>
                <div class="welcome-text">Welcome back, <%= session.getAttribute("username") %> (Admin)</div>
                <h2>Admin Dashboard</h2>
            </div>
            <div>
                <a href="users.jsp" class="btn" style="margin-right: 20px; background-color: #6366f1;">View Users</a>
                <a href="login.jsp?logout=true" class="btn btn-outline">Logout</a>
            </div>
        </div>

        <% 
            if ("true".equals(request.getParameter("success"))) {
                out.println("<div class='alert alert-success'>Action completed successfully!</div>");
            }
            if ("true".equals(request.getParameter("userSuccess"))) {
                out.println("<div class='alert alert-success'>User created successfully!</div>");
            }
            if ("true".equals(request.getParameter("loanSuccess"))) {
                out.println("<div class='alert alert-success'>Loan added successfully!</div>");
            }
        %>
        
        <%
            double totalLoans = 0;
            double totalCollected = 0;
            Connection statConn = null;
            Statement s1 = null;
            ResultSet r1 = null;
            Statement s2 = null;
            ResultSet r2 = null;
            try {
                statConn = DBConnection.getConnection();
                s1 = statConn.createStatement();
                r1 = s1.executeQuery("SELECT SUM(loan_amount) FROM loans");
                if (r1.next()) totalLoans = r1.getDouble(1);
                
                s2 = statConn.createStatement();
                r2 = s2.executeQuery("SELECT SUM(amount) FROM finance WHERE status = 'Approved' OR status IS NULL");
                if (r2.next()) totalCollected = r2.getDouble(1);
            } catch (Exception e) {
            } finally {
                if (r2 != null) try { r2.close(); } catch(Exception e){}
                if (s2 != null) try { s2.close(); } catch(Exception e){}
                if (r1 != null) try { r1.close(); } catch(Exception e){}
                if (s1 != null) try { s1.close(); } catch(Exception e){}
                if (statConn != null) try { statConn.close(); } catch(Exception e){}
            }
        %>
        <div style="display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 30px;">
            <a href="loans.jsp" class="card" style="flex: 1; padding: 20px; background: rgba(59, 130, 246, 0.1); border-radius: 12px; border-left: 4px solid #3b82f6; text-decoration: none; display: block; transition: transform 0.2s, background 0.2s;" onmouseover="this.style.transform='scale(1.02)'; this.style.background='rgba(59, 130, 246, 0.15)';" onmouseout="this.style.transform='scale(1)'; this.style.background='rgba(59, 130, 246, 0.1)';">
                <h4 style="margin: 0; color: #9ca3af; font-weight: normal;">Total System Loans <span style="font-size: 0.8rem; color: #3b82f6;">(Click to view details &rarr;)</span></h4>
                <div style="font-size: 1.5rem; font-weight: bold; margin-top: 5px; color: #f3f4f6;">&#8377;<%= String.format("%,.0f", totalLoans) %></div>
            </a>
            <div class="card" style="flex: 1; padding: 20px; background: rgba(16, 185, 129, 0.1); border-radius: 12px; border-left: 4px solid #10b981;">
                <h4 style="margin: 0; color: #9ca3af; font-weight: normal;">Total Collected (Approved)</h4>
                <div style="font-size: 1.5rem; font-weight: bold; margin-top: 5px; color: #10b981;">&#8377;<%= String.format("%,.0f", totalCollected) %></div>
            </div>
        </div>

        <h3>Platform Wide Collections</h3>
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
                            String sql = "SELECT id, username, type, amount, description, date, time, collector, status, current_paid_amount, current_remaining_amount FROM finance ORDER BY status DESC, date DESC, time DESC, id DESC";
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
                                            <a href="DeleteFinanceServlet?id=<%= rs.getInt("id") %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this record as Admin?');">Delete</a>
                                        </td>
                                    </tr>
                    <%
                            }
                            if (!hasRecords) {
                                out.println("<tr><td colspan='9' style='text-align:center;'>No collections found.</td></tr>");
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='9' style='text-align:center; color:#ef4444;'>Error loading collections: " + e.getMessage() + "</td></tr>");
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
