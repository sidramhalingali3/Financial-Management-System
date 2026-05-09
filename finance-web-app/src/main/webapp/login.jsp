<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Finance Management System</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container login-container">
        <h1>Finance System</h1>
        
        <% 
            if ("true".equals(request.getParameter("logout"))) {
                session.invalidate();
                out.println("<div class='alert alert-success'>Successfully logged out.</div>");
            }
            String error = request.getParameter("error");
            if (error != null) {
                String msg = "";
                if (error.equals("invalid_credentials")) msg = "Invalid username or password.";
                else if (error.equals("invalid_role")) msg = "Invalid user role.";
                else if (error.equals("database_error")) msg = "Database connection error.";
                out.println("<div class='alert alert-error'>" + msg + "</div>");
            }
        %>

        <form action="LoginServlet" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required placeholder="Enter your username">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required placeholder="Enter your password">
            </div>
            <button type="submit" class="btn">Sign In</button>
        </form>
    </div>
</body>
</html>
