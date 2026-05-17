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
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <div>
                <div class="welcome-text">Welcome back, <%= session.getAttribute("username") %></div>
                <h2>Admin Dashboard</h2>
            </div>
            <a href="login.jsp?logout=true" class="btn btn-outline">Logout</a>
        </div>

        <% 
            if ("true".equals(request.getParameter("userSuccess"))) {
                out.println("<div class='alert alert-success'>User added successfully!</div>");
            }
            if (request.getParameter("userError") != null) {
                out.println("<div class='alert alert-error'>Failed to add user.</div>");
            }
            if ("true".equals(request.getParameter("loanSuccess"))) {
                out.println("<div class='alert alert-success'>Loan assigned successfully!</div>");
            }
            if (request.getParameter("loanError") != null) {
                out.println("<div class='alert alert-error'>Failed to assign loan.</div>");
            }
        %>

        <div style="display: flex; gap: 20px; flex-wrap: wrap; margin-bottom: 30px;">
            <div class="card" style="flex: 1; min-width: 300px; padding: 20px; background: rgba(255, 255, 255, 0.05); border-radius: 12px;">
                <h3 style="margin-top: 0;">Add New User</h3>
                <form action="AddUserServlet" method="post" style="display: flex; flex-direction: column; gap: 15px;">
                    <input type="text" name="username" placeholder="Username" required style="padding: 10px; border-radius: 6px; border: 1px solid #4b5563; background: #1f2937; color: white;">
                    <input type="password" name="password" placeholder="Password" required style="padding: 10px; border-radius: 6px; border: 1px solid #4b5563; background: #1f2937; color: white;">
                    <select name="role" style="padding: 10px; border-radius: 6px; border: 1px solid #4b5563; background: #1f2937; color: white;">
                        <option value="Collector">Collector</option>
                        <option value="Customer">Customer</option>
                    </select>
                    <button type="submit" class="btn" style="width: 100%;">Add User</button>
                </form>
            </div>

            <div class="card" style="flex: 1; min-width: 300px; padding: 20px; background: rgba(255, 255, 255, 0.05); border-radius: 12px;">
                <h3 style="margin-top: 0;">Provide Loan</h3>
                <form action="AddLoanServlet" method="post" style="display: flex; flex-direction: column; gap: 15px;">
                    <input type="text" name="username" placeholder="Customer Username" required style="padding: 10px; border-radius: 6px; border: 1px solid #4b5563; background: #1f2937; color: white;">
                    <input type="number" name="amount" placeholder="Loan Amount (₹)" required style="padding: 10px; border-radius: 6px; border: 1px solid #4b5563; background: #1f2937; color: white;">
                    <button type="submit" class="btn" style="width: 100%;">Assign Loan</button>
                </form>
            </div>
            
            <div class="card" style="flex: 2; min-width: 300px; padding: 20px; background: rgba(255, 255, 255, 0.05); border-radius: 12px; max-height: 400px; overflow-y: auto;">
                <h3 style="margin-top: 0;">System Users</h3>
                <table style="width: 100%; border-collapse: collapse;">
                    <thead>
                        <tr style="text-align: left; border-bottom: 1px solid #374151;">
                            <th style="padding: 10px;">ID</th>
                            <th style="padding: 10px;">Username</th>
                            <th style="padding: 10px;">Role</th>
                            <th style="padding: 10px;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Connection uConn = null;
                            PreparedStatement uPst = null;
                            ResultSet uRs = null;
                            try {
                                uConn = DBConnection.getConnection();
                                String uSql = "SELECT id, username, role FROM users ORDER BY id DESC";
                                uPst = uConn.prepareStatement(uSql);
                                uRs = uPst.executeQuery();
                                while(uRs.next()) {
                        %>
                                    <tr style="border-bottom: 1px solid #374151;">
                                        <td data-label="ID" style="padding: 10px;"><%= uRs.getInt("id") %></td>
                                        <td data-label="Username" style="padding: 10px;"><%= uRs.getString("username") %></td>
                                        <td data-label="Role" style="padding: 10px;">
                                            <span style="padding: 4px 8px; border-radius: 12px; font-size: 0.8rem; background: <%= "Admin".equals(uRs.getString("role")) ? "#3b82f6" : ("Collector".equals(uRs.getString("role")) ? "#8b5cf6" : "#10b981") %>;">
                                                <%= uRs.getString("role") %>
                                            </span>
                                        </td>
                                        <td data-label="Action" style="padding: 10px;">
                                            <% if (!uRs.getString("username").equals(session.getAttribute("username"))) { %>
                                                <a href="DeleteUserServlet?id=<%= uRs.getInt("id") %>" style="color: #ef4444; text-decoration: none; font-size: 0.875rem;" onclick="return confirm('Delete this user?');">Delete</a>
                                            <% } else { %>
                                                <span style="color: #6b7280; font-size: 0.875rem;">You</span>
                                            <% } %>
                                        </td>
                                    </tr>
                        <%
                                }
                            } catch (Exception e) {
                                out.println("<tr><td colspan='3'>Error: " + e.getMessage() + "</td></tr>");
                            } finally {
                                if(uRs != null) try { uRs.close(); } catch(Exception e){}
                                if(uPst != null) try { uPst.close(); } catch(Exception e){}
                                if(uConn != null) try { uConn.close(); } catch(Exception e){}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <h3>Customer Loan Details</h3>
        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>Customer Name</th>
                        <th>Loan Amount</th>
                        <th>Paid Amount</th>
                        <th>Remaining Amount</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Connection conn = null;
                        PreparedStatement pst = null;
                        ResultSet rs = null;
                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT u.username, IFNULL(l.loan_amount, 0) as loan_amount, IFNULL(SUM(f.amount), 0) as paid_amount " +
                                         "FROM users u " +
                                         "LEFT JOIN (SELECT username, MAX(loan_amount) as loan_amount FROM loans GROUP BY username) l ON u.username = l.username " +
                                         "LEFT JOIN finance f ON u.username = f.username " +
                                         "WHERE u.role = 'Customer' " +
                                         "GROUP BY u.username, l.loan_amount " +
                                         "HAVING IFNULL(l.loan_amount, 0) > 0 OR IFNULL(SUM(f.amount), 0) > 0 " +
                                         "ORDER BY u.username";
                            pst = conn.prepareStatement(sql);
                            rs = pst.executeQuery();
                                
                            boolean hasRecords = false;
                            while (rs.next()) {
                                hasRecords = true;
                                double loanAmount = rs.getDouble("loan_amount");
                                double paidAmount = rs.getDouble("paid_amount");
                                double remainingAmount = loanAmount - paidAmount;
                    %>
                                    <tr>
                                        <td data-label="Customer Name"><%= rs.getString("username") %></td>
                                        <td data-label="Loan Amount" style="font-weight: 500;">&#8377;<%= String.format("%,.0f", loanAmount) %></td>
                                        <td data-label="Paid Amount" style="color: #10b981; font-weight: 500;">&#8377;<%= String.format("%,.0f", paidAmount) %></td>
                                        <td data-label="Remaining Amount" style="color: <%= remainingAmount > 0 ? "#ef4444" : "#10b981" %>; font-weight: 500;">&#8377;<%= String.format("%,.0f", remainingAmount) %></td>
                                    </tr>
                    <%
                            }
                            if (!hasRecords) {
                                out.println("<tr><td colspan='4' style='text-align:center;'>No active loans found.</td></tr>");
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='4' style='text-align:center; color:#ef4444;'>Error loading records: " + e.getMessage() + "</td></tr>");
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
