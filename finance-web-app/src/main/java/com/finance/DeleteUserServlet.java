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

@WebServlet("/DeleteUserServlet")
public class DeleteUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"Admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try (Connection conn = DBConnection.getConnection()) {
                int id = Integer.parseInt(idStr);
                
                String currentUsername = (String) session.getAttribute("username");
                String checkSql = "SELECT username FROM users WHERE id = ?";
                try (PreparedStatement checkPst = conn.prepareStatement(checkSql)) {
                    checkPst.setInt(1, id);
                    ResultSet rs = checkPst.executeQuery();
                    if (rs.next()) {
                        String targetUsername = rs.getString("username");
                        if (targetUsername.equals(currentUsername)) {
                            response.sendRedirect("admin.jsp?userError=cannot_delete_self");
                            return;
                        }
                    }
                }
                
                String sql = "DELETE FROM users WHERE id = ?";
                try (PreparedStatement pst = conn.prepareStatement(sql)) {
                    pst.setInt(1, id);
                    int res = pst.executeUpdate();
                    if(res > 0) {
                        response.sendRedirect("admin.jsp?userSuccess=deleted");
                        return;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect("admin.jsp?userError=delete_failed");
    }
}
