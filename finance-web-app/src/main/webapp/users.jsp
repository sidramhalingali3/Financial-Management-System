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
    <title>System Users - Finance Management</title>
    <link rel="stylesheet" href="style.css?v=3">
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <div>
                <h2>System Users</h2>
                <div class="welcome-text">Manage all platform users below.</div>
            </div>
            <div>
                <a href="addUser.jsp" class="btn" style="margin-right: 10px; background-color: #3b82f6;">+ Create User</a>
                <a href="admin.jsp" class="btn btn-outline" style="margin-right: 10px;">&larr; Back to Dashboard</a>
            </div>
        </div>

        <% 
            if ("true".equals(request.getParameter("deleted"))) {
                out.println("<div class='alert alert-success'>User deleted successfully!</div>");
            }
            if ("error".equals(request.getParameter("error"))) {
                out.println("<div class='alert alert-error'>Failed to delete user. They might have dependent records.</div>");
            }
            if ("true".equals(request.getParameter("userSuccess"))) {
                out.println("<div class='alert alert-success'>User created successfully!</div>");
            }
        %>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Password</th>
                        <th>Role</th>
                        <th>Action</th>
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
                            rs = stmt.executeQuery("SELECT id, username, password, role FROM users ORDER BY role, username");
                             
                            while (rs.next()) {
                                String userRole = rs.getString("role");
                                String rowColor = "";
                                if ("Admin".equals(userRole)) rowColor = "color: #a855f7;";
                                else if ("Collector".equals(userRole)) rowColor = "color: #3b82f6;";
                                else rowColor = "color: #10b981;";
                    %>
                        <tr>
                            <td data-label="ID"><%= rs.getInt("id") %></td>
                            <td data-label="Username"><strong><%= rs.getString("username") %></strong></td>
                            <td data-label="Password"><span style="filter: blur(3px); transition: filter 0.3s;" onmouseover="this.style.filter='none'" onmouseout="this.style.filter='blur(3px)'"><%= rs.getString("password") %></span></td>
                            <td data-label="Role" style="<%= rowColor %> font-weight: bold;"><%= userRole %></td>
                            <td data-label="Action">
                                <% if (!"Admin".equals(userRole)) { %>
                                    <a href="DeleteUserServlet?id=<%= rs.getInt("id") %>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this user?');">Delete</a>
                                <% } else { %>
                                    <span style="color: #666; font-size: 0.8rem;">Cannot Delete</span>
                                <% } %>
                            </td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' style='color:#ef4444; text-align:center;'>Error: " + e.getMessage() + "</td></tr>");
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
