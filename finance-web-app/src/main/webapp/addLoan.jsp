<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 
    String role=(String) session.getAttribute("role"); 
    if (role==null || !"Admin".equals(role)) { 
        response.sendRedirect("login.jsp"); 
        return; 
    } 
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assign New Loan - Finance Management</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container login-container" style="max-width: 500px;">
        <div class="header-actions" style="margin-bottom: 1.5rem; padding-bottom: 0.5rem;">
            <h2 style="margin-bottom: 0;">Assign New Loan</h2>
            <a href="loans.jsp" class="btn btn-outline" style="padding: 0.5rem 1rem; font-size: 0.875rem;">&larr; Back</a>
        </div>

        <% 
            String error = request.getParameter("loanError"); 
            if (error != null) { 
                String msg = ""; 
                if (error.equals("empty_fields")) {
                    msg = "Please fill all fields."; 
                } else if (error.equals("insert_failed")) {
                    msg = "Failed to assign loan to the customer."; 
                } else if (error.equals("exception")) {
                    String detail = request.getParameter("msg");
                    msg = "System error occurred." + (detail != null ? " Details: " + detail : ""); 
                }
                out.println("<div class='alert alert-error'>" + msg + "</div>");
            }
        %>

        <form action="processAddLoan.jsp" method="post">
            <div class="form-group">
                <label for="username">Customer Username</label>
                <input type="text" id="username" name="username" required placeholder="Enter customer's exact username">
            </div>
            
            <div class="form-group">
                <label for="principal">Base Loan Amount (₹)</label>
                <input type="number" id="principal" required min="1" step="0.01" placeholder="e.g. 10000" oninput="calculateInterest()">
            </div>
            
            <div class="form-group" style="padding: 15px; background: rgba(16, 185, 129, 0.1); border-left: 4px solid #10b981; border-radius: 8px; margin-bottom: 20px;">
                <label style="color: #10b981; font-weight: bold; margin-bottom: 5px; display: block;">Total with 10% Interest (₹)</label>
                <input type="number" id="amount" name="amount" readonly required style="background: transparent; border: none; font-size: 1.5rem; color: #10b981; font-weight: bold; padding: 0; pointer-events: none;" placeholder="0.00">
            </div>

            <script>
                function calculateInterest() {
                    const principal = parseFloat(document.getElementById('principal').value) || 0;
                    const total = principal + (principal * 0.10);
                    if (total > 0) {
                        document.getElementById('amount').value = total.toFixed(2);
                    } else {
                        document.getElementById('amount').value = "";
                    }
                }
            </script>
            
            <button type="submit" class="btn" style="background-color: #3b82f6; width: 100%; margin-top: 10px;">Assign Loan</button>
        </form>
    </div>
</body>
</html>
