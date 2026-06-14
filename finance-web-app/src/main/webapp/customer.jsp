<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    if (session.getAttribute("role") == null || !"Customer".equals(session.getAttribute("role"))) {
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
    <link rel="stylesheet" href="style.css?v=3">
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <div>
                <div class="welcome-text">Welcome back, <%= session.getAttribute("username") %></div>
                <h2>Customer Dashboard</h2>
            </div>
            <div>
                <a href="phonepe_payment.jsp" class="btn" style="margin-right: 20px; width: auto; background-color: #5f259f;">Pay via PhonePe / UPI</a>
                <a href="login.jsp?logout=true" class="btn btn-outline">Logout</a>
            </div>
        </div>

        <% 
            if ("true".equals(request.getParameter("success"))) {
                out.println("<div class='alert alert-success'>Finance record added successfully!</div>");
            }
            if ("duplicate_utr".equals(request.getParameter("error"))) {
                out.println("<div class='alert alert-error' style='background: rgba(239, 68, 68, 0.1); border: 1px solid #ef4444; color: #ef4444; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>This UTR number has already been used. Please enter a valid, unique 12-digit UTR.</div>");
            }
            
            String currentUsername = (String) session.getAttribute("username");
            double myLoanAmount = 0;
            double myPaidAmount = 0;
            double myRemaining = 0;
            Connection connSummary = null;
            PreparedStatement lpst = null;
            ResultSet lrs = null;
            try {
                connSummary = DBConnection.getConnection();
                String lSql = "SELECT loan_amount, paid_amount, remaining_amount FROM loans WHERE username = ?";
                lpst = connSummary.prepareStatement(lSql);
                lpst.setString(1, currentUsername);
                lrs = lpst.executeQuery();
                if(lrs.next()) {
                    myLoanAmount = lrs.getDouble("loan_amount");
                    myPaidAmount = lrs.getDouble("paid_amount");
                    myRemaining = lrs.getDouble("remaining_amount");
                }
            } catch (Exception e) {
            } finally {
                if(lrs != null) try { lrs.close(); } catch(Exception e){}
                if(lpst != null) try { lpst.close(); } catch(Exception e){}
                if(connSummary != null) try { connSummary.close(); } catch(Exception e){}
            }
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

        <%
            // Check if the user has any pending payments to show a helpful message
            boolean hasPending = false;
            Connection checkConn = null;
            PreparedStatement checkPst = null;
            ResultSet checkRs = null;
            try {
                checkConn = DBConnection.getConnection();
                checkPst = checkConn.prepareStatement("SELECT 1 FROM finance WHERE username = ? AND status = 'Pending' LIMIT 1");
                checkPst.setString(1, (String) session.getAttribute("username"));
                checkRs = checkPst.executeQuery();
                if (checkRs.next()) {
                    hasPending = true;
                }
            } catch (Exception e) {
            } finally {
                if (checkRs != null) try { checkRs.close(); } catch(Exception e){}
                if (checkPst != null) try { checkPst.close(); } catch(Exception e){}
                if (checkConn != null) try { checkConn.close(); } catch(Exception e){}
            }
            
            if (hasPending) {
        %>
            <div style="background: rgba(245, 158, 11, 0.1); border: 1px solid #f59e0b; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                <h4 style="color: #f59e0b; margin: 0 0 5px 0;">Pending Verification</h4>
                <p style="font-size: 0.9rem; margin: 0; color: #ddd;">You have recently submitted a payment that is currently waiting for Collector verification. It will appear in your history below once approved.</p>
            </div>
        <%
            }
        %>

        <h3>Your Payment History</h3>
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
                        <th>Collector</th>
                        <th>Status</th>
                        <th>Running Paid</th>
                        <th>Running Balance</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        currentUsername = (String) session.getAttribute("username");
                        Connection conn = null;
                        PreparedStatement pst = null;
                        ResultSet rs = null;
                        try {
                            conn = DBConnection.getConnection();
                            
                            // Auto-migrate database: safely add the collector and status columns if they don't exist
                            java.sql.Statement migStmt = null;
                            try {
                                migStmt = conn.createStatement();
                                migStmt.executeUpdate("ALTER TABLE finance ADD COLUMN collector VARCHAR(100) DEFAULT 'Self/Unknown'");
                            } catch (Exception ignore) {}
                            try {
                                if (migStmt == null) migStmt = conn.createStatement();
                                migStmt.executeUpdate("ALTER TABLE finance ADD COLUMN status VARCHAR(20) DEFAULT 'Approved'");
                            } catch (Exception ignore) {}
                            try {
                                if (migStmt == null) migStmt = conn.createStatement();
                                migStmt.executeUpdate("ALTER TABLE finance ADD COLUMN payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
                            } catch (Exception ignore) {}
                            finally {
                                if (migStmt != null) try { migStmt.close(); } catch(Exception e){}
                            }
                            
                            String sql = "SELECT id, type, amount, description, date, time, collector, status, current_paid_amount, current_remaining_amount, payment_time FROM finance WHERE username = ? ORDER BY date DESC, time DESC, id DESC";
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
                                            <td data-label="Date"><%= rs.getTimestamp("payment_time") != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(rs.getTimestamp("payment_time")) : rs.getDate("date") %></td>
                                            <td data-label="Time"><%= rs.getTime("time") != null ? new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("time")) : "-" %></td>
                                            <td data-label="Collector"><%= rs.getString("collector") != null ? rs.getString("collector") : "N/A" %></td>
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
                                        </tr>
                    <%
                            }
                            if (!hasRecords) {
                                out.println("<tr><td colspan='7' style='text-align:center;'>You haven't added any records yet.</td></tr>");
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
