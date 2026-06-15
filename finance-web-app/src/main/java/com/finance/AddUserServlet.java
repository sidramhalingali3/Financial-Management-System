package com.finance;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AddUserServlet")
public class AddUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"Admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect("admin.jsp?userError=empty_fields");
            return;
        }

        try {
            Connection conn = DBConnection.getConnection();
            
            // Ensure AUTO_INCREMENT is set on users table (fixes potential schema issues)
            try {
                conn.createStatement().execute("ALTER TABLE users MODIFY id INT AUTO_INCREMENT");
            } catch (Exception ignore) {}
            
            String sql = "INSERT INTO users (username, password, role) VALUES (?, ?, ?)";
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, username.trim());
            pst.setString(2, password);
            pst.setString(3, role);
            
            int result = pst.executeUpdate();
            if (result > 0) {
                response.sendRedirect("users.jsp?userSuccess=true");
            } else {
                response.sendRedirect("addUser.jsp?userError=insert_failed");
            }
            
            pst.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addUser.jsp?userError=exception&msg=" + java.net.URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Unknown Error", "UTF-8"));
        }
    }
}
