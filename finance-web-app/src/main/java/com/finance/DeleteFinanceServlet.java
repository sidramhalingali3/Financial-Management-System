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

@WebServlet("/DeleteFinanceServlet")
public class DeleteFinanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null || (!"Admin".equals(role) && !"Collector".equals(role))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try (Connection conn = DBConnection.getConnection()) {
                int id = Integer.parseInt(idStr);
                String sql = "DELETE FROM finance WHERE id = ?";
                
                try (PreparedStatement pst = conn.prepareStatement(sql)) {
                    pst.setInt(1, id);
                    pst.executeUpdate();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        if ("Collector".equals(role)) {
            response.sendRedirect("collector.jsp");
        } else {
            response.sendRedirect("admin.jsp");
        }
    }
}
