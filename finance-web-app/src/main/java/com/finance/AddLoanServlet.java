package com.finance;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AddLoanServlet")
public class AddLoanServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"Admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = request.getParameter("username");
        String amountStr = request.getParameter("amount");

        if (username == null || username.trim().isEmpty() || amountStr == null || amountStr.trim().isEmpty()) {
            response.sendRedirect("admin.jsp?loanError=empty_fields");
            return;
        }

        try {
            double amount = Double.parseDouble(amountStr);
            Connection conn = DBConnection.getConnection();
            
            // Delete existing loan if any, or just update. Let's just update the amount or insert new.
            // For simplicity, we'll just insert and the query will pick the latest using MAX(id)
            String sql = "INSERT INTO loans (username, loan_amount, date) VALUES (?, ?, ?)";
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, username.trim());
            pst.setDouble(2, amount);
            pst.setDate(3, new Date(System.currentTimeMillis()));
            
            int result = pst.executeUpdate();
            if (result > 0) {
                response.sendRedirect("admin.jsp?loanSuccess=true");
            } else {
                response.sendRedirect("admin.jsp?loanError=insert_failed");
            }
            
            pst.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?loanError=exception");
        }
    }
}
