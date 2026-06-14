<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <% String role=(String) session.getAttribute("role"); if (role==null || !"Collector".equals(role)) { response.sendRedirect("login.jsp"); return; } String backLink="collector.jsp" ; %>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    Connection _conn = null;
    Statement _stmt = null;
    try {
        _conn = DBConnection.getConnection();
        _stmt = _conn.createStatement();
        try { _stmt.executeUpdate("ALTER TABLE finance MODIFY id INT AUTO_INCREMENT"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE finance ADD COLUMN current_paid_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE finance ADD COLUMN current_remaining_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE loans ADD COLUMN paid_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE loans ADD COLUMN remaining_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE loans ADD COLUMN loan_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
    } catch (Exception ignore) {
    } finally {
        if (_stmt != null) try { _stmt.close(); } catch(Exception e) {}
        if (_conn != null) try { _conn.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Finance - Finance Management</title>
    <link rel="stylesheet" href="style.css">
</head>

        <body>
            <div class="container login-container" style="max-width: 500px;">
                <div class="header-actions" style="margin-bottom: 1.5rem; padding-bottom: 0.5rem;">
                    <h2 style="margin-bottom: 0;">
                        Collect EMI Payment
                    </h2>
                    <a href="<%= backLink %>" class="btn btn-outline"
                        style="padding: 0.5rem 1rem; font-size: 0.875rem;">&larr; Back</a>
                </div>

                <% 
                    String error = request.getParameter("error"); 
                    if (error != null) { 
                        String msg = ""; 
                        if (error.equals("insert_failed")) {
                            msg = "Failed to add record. Please try again."; 
                        } else if (error.equals("exception")) {
                            msg = "System error occurred."; 
                        }
                        out.println("<div class='alert alert-error'>" + msg + "</div>");
                    }
                %>

            <form action="AddFinanceServlet" method="post">
                    <div class="form-group">
                        <label for="customerUsername">Customer Username</label>
                        <input type="text" id="customerUsername" name="customerUsername" required
                            placeholder="Enter customer's username">
                    </div>
                        <input type="hidden" name="type" value="Payment">

                        <div class="form-group">
                            <label for="amount">Amount (₹)</label>
                            <input type="number" step="0.01" min="0" id="amount" name="amount" required
                                placeholder="0.00">
                        </div>
                        <div class="form-group">
                            <label for="description">Description</label>
                            <input type="text" id="description" name="description" required
                                placeholder="e.g. Office Supplies, Travel Expense">
                        </div>

                        <% String todayDate = new java.sql.Date(System.currentTimeMillis()).toString(); %>
                        <div class="form-group" style="padding: 10px; background: rgba(255,255,255,0.05); border-radius: 5px; margin-bottom: 15px;">
                            <span style="color: #aaa; font-size: 0.9rem;">Date (Auto-filled): </span>
                            <strong style="color: #10b981;"><%= todayDate %></strong>
                        </div>

                        <input type="hidden" name="date" value="<%= todayDate %>">
                        <button type="submit" class="btn">Submit Record</button>
            </form>
            </div>
        </body>

        </html>