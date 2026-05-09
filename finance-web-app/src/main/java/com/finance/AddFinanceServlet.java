package com.finance;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AddFinanceServlet")
public class AddFinanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null || (!"Customer".equals(role) && !"Collector".equals(role))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String amountStr = request.getParameter("amount");
        String description = request.getParameter("description");
        String type = request.getParameter("type");
        String dateStr = request.getParameter("date");
        String username = (String) session.getAttribute("username");
        if ("Collector".equals(role)) {
            username = request.getParameter("customerUsername");
        }

        try (Connection conn = DBConnection.getConnection()) {
            double amount = Double.parseDouble(amountStr);
            Date sqlDate = Date.valueOf(dateStr);
            
            String sql = "INSERT INTO finance (username, type, amount, description, date) VALUES (?, ?, ?, ?, ?)";
            
            try (PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setString(1, username);
                pst.setString(2, type);
                pst.setDouble(3, amount);
                pst.setString(4, description);
                pst.setDate(5, sqlDate);
                
                int result = pst.executeUpdate();
                if (result > 0) {
                    if ("Collector".equals(role)) {
                        response.sendRedirect("collector.jsp?success=true");
                    } else {
                        response.sendRedirect("customer.jsp?success=true");
                    }
                } else {
                    response.sendRedirect("addFinance.jsp?error=insert_failed");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addFinance.jsp?error=exception");
        }
    }
}
