package com.finance;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT id, role FROM users WHERE username = ? AND password = ?";
            try (PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setString(1, user);
                pst.setString(2, pass);
                
                try (ResultSet rs = pst.executeQuery()) {
                    if (rs.next()) {
                        String role = rs.getString("role");
                        
                        HttpSession session = request.getSession();
                        session.setAttribute("username", user);
                        session.setAttribute("role", role);
                        
                        if ("Admin".equals(role)) {
                            response.sendRedirect("admin.jsp");
                        } else if ("Collector".equals(role)) {
                            response.sendRedirect("collector.jsp");
                        } else if ("Customer".equals(role)) {
                            response.sendRedirect("customer.jsp");
                        } else {
                            response.sendRedirect("login.jsp?error=invalid_role");
                        }
                    } else {
                        response.sendRedirect("login.jsp?error=invalid_credentials");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=database_error");
        }
    }
}
