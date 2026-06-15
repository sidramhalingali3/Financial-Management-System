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
    <title>Create New User - Finance Management</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container login-container" style="max-width: 500px;">
        <div class="header-actions" style="margin-bottom: 1.5rem; padding-bottom: 0.5rem;">
            <h2 style="margin-bottom: 0;">Create New User</h2>
            <a href="users.jsp" class="btn btn-outline" style="padding: 0.5rem 1rem; font-size: 0.875rem;">&larr; Back</a>
        </div>

        <% 
            String error = request.getParameter("userError"); 
            if (error != null) { 
                String msg = ""; 
                if (error.equals("empty_fields")) {
                    msg = "Please fill all fields."; 
                } else if (error.equals("insert_failed")) {
                    msg = "Failed to create user. Username might already exist."; 
                } else if (error.equals("exception")) {
                    String detail = request.getParameter("msg");
                    msg = "System error occurred." + (detail != null ? " Details: " + detail : ""); 
                }
                out.println("<div class='alert alert-error'>" + msg + "</div>");
            }
        %>

        <form action="AddUserServlet" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required placeholder="Enter username">
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="text" id="password" name="password" required placeholder="Enter temporary password">
            </div>
            
            <div class="form-group">
                <label for="role">Role</label>
                <select id="role" name="role" required style="width: 100%; padding: 12px; border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; background-color: rgba(255,255,255,0.05); color: #fff; font-size: 1rem;">
                    <option value="Customer" style="color: #000;">Customer</option>
                    <option value="Collector" style="color: #000;">Collector</option>
                    <option value="Admin" style="color: #000;">Admin</option>
                </select>
            </div>
            
            <button type="submit" class="btn" style="background-color: #3b82f6; width: 100%; margin-top: 10px;">Create User</button>
        </form>
    </div>
</body>
</html>
