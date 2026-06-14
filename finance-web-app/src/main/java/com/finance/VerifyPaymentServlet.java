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

@WebServlet("/VerifyPaymentServlet")
public class VerifyPaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String role = (String) session.getAttribute("role");
        if (role == null || !"Collector".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        String action = request.getParameter("action");
        
        if (idStr == null || action == null) {
            response.sendRedirect("collector.jsp?error=invalid_request");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            int id = Integer.parseInt(idStr);
            String status = "Approved";
            if ("reject".equals(action)) {
                status = "Rejected";
            }
            
            String sql = "UPDATE finance SET status = ? WHERE id = ?";
            try (PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setString(1, status);
                pst.setInt(2, id);
                int updated = pst.executeUpdate();
                
                if (updated > 0 && "Approved".equals(status)) {
                    // Fetch amount and username
                    String fetchSql = "SELECT amount, username FROM finance WHERE id = ?";
                    try (PreparedStatement fetchPst = conn.prepareStatement(fetchSql)) {
                        fetchPst.setInt(1, id);
                        try (java.sql.ResultSet rs = fetchPst.executeQuery()) {
                            if (rs.next()) {
                                double amt = rs.getDouble("amount");
                                String user = rs.getString("username");
                                String updateLoanSql = "UPDATE loans SET paid_amount = COALESCE(paid_amount, 0) + ?, remaining_amount = COALESCE(remaining_amount, loan_amount) - ? WHERE username = ?";
                                try (PreparedStatement updatePst = conn.prepareStatement(updateLoanSql)) {
                                    updatePst.setDouble(1, amt);
                                    updatePst.setDouble(2, amt);
                                    updatePst.setString(3, user);
                                    updatePst.executeUpdate();
                                }
                                
                                // Fetch new balance and save to finance
                                String fetchBalSql = "SELECT paid_amount, remaining_amount FROM loans WHERE username = ?";
                                try (PreparedStatement fetchBalPst = conn.prepareStatement(fetchBalSql)) {
                                    fetchBalPst.setString(1, user);
                                    try (java.sql.ResultSet rsBal = fetchBalPst.executeQuery()) {
                                        if (rsBal.next()) {
                                            double pAmt = rsBal.getDouble("paid_amount");
                                            double rAmt = rsBal.getDouble("remaining_amount");
                                            String updateFinSql = "UPDATE finance SET current_paid_amount = ?, current_remaining_amount = ? WHERE id = ?";
                                            try (PreparedStatement ufinPst = conn.prepareStatement(updateFinSql)) {
                                                ufinPst.setDouble(1, pAmt);
                                                ufinPst.setDouble(2, rAmt);
                                                ufinPst.setInt(3, id);
                                                ufinPst.executeUpdate();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            response.sendRedirect("collector.jsp?success=verified");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("collector.jsp?error=exception");
        }
    }
}
