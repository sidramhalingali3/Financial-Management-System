<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || (!"Customer".equals(role) && !"Collector".equals(role))) {
        response.sendRedirect("login.jsp");
        return;
    }
    String backLink = "Collector".equals(role) ? "collector.jsp" : "customer.jsp";
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
            <h2 style="margin-bottom: 0;">Collect EMI Payment</h2>
            <a href="<%= backLink %>" class="btn btn-outline" style="padding: 0.5rem 1rem; font-size: 0.875rem;">&larr; Back</a>
        </div>

        <% 
            String error = request.getParameter("error");
            if (error != null) {
                String msg = "";
                if (error.equals("insert_failed")) msg = "Failed to add record. Please try again.";
                else if (error.equals("exception")) msg = "System error occurred.";
                out.println("<div class='alert alert-error'>" + msg + "</div>");
            }
        %>

        <form action="AddFinanceServlet" method="post">
            <% if ("Collector".equals(role)) { %>
            <div class="form-group">
                <label for="customerUsername">Customer Username</label>
                <input type="text" id="customerUsername" name="customerUsername" required placeholder="Enter customer's username">
            </div>
            <% } %>
            <input type="hidden" name="type" value="Payment">
            <div class="form-group">
                <label for="amount">Amount (₹)</label>
                <input type="number" step="0.01" min="0" id="amount" name="amount" required placeholder="0.00">
            </div>
            <div class="form-group">
                <label for="description">Description</label>
                <input type="text" id="description" name="description" required placeholder="e.g. Office Supplies, Travel Expense">
            </div>
            <div class="form-group">
                <label for="date">Date</label>
                <input type="date" id="date" name="date" required>
            </div>
            <button type="submit" class="btn">Submit Record</button>
        </form>
    </div>
</body>
</html>
