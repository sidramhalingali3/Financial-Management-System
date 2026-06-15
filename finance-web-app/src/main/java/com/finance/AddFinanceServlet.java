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
            if (username != null) username = username.trim();
        }

        try (Connection conn = DBConnection.getConnection()) {
            double amount = Double.parseDouble(amountStr);
            if (dateStr == null || dateStr.trim().isEmpty()) {
                dateStr = java.time.LocalDate.now(java.time.ZoneId.of("Asia/Kolkata")).toString();
            }
            
            // Auto-migrate database: safely add the status column if it doesn't exist
            java.sql.Statement migStmt = null;
            try {
                migStmt = conn.createStatement();
                try { migStmt.executeUpdate("ALTER TABLE finance ADD COLUMN status VARCHAR(20) DEFAULT 'Approved'"); } catch (Exception ignore) {}
                try { migStmt.executeUpdate("ALTER TABLE finance ADD COLUMN time TIME"); } catch (Exception ignore) {}
                try { migStmt.executeUpdate("ALTER TABLE finance MODIFY COLUMN time TIME DEFAULT CURRENT_TIME"); } catch (Exception ignore) {}
                try { migStmt.executeUpdate("ALTER TABLE finance ADD COLUMN current_paid_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
                try { migStmt.executeUpdate("ALTER TABLE finance ADD COLUMN current_remaining_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
                try { migStmt.executeUpdate("ALTER TABLE loans ADD COLUMN paid_amount DOUBLE DEFAULT 0"); } catch (Exception ignore) {}
                try { migStmt.executeUpdate("ALTER TABLE loans ADD COLUMN remaining_amount DOUBLE"); } catch (Exception ignore) {}
            } catch (Exception ignore) {
            } finally {
                if (migStmt != null) try { migStmt.close(); } catch(Exception e){}
            }
            
            String collectorName = "Self (UPI)";
            String paymentStatus = "Pending";
            
            if ("Collector".equals(role)) {
                collectorName = (String) session.getAttribute("username"); // The logged in collector
                paymentStatus = "Approved";
            } else {
                // Verify UTR is unique for customers
                String checkSql = "SELECT id FROM finance WHERE description = ?";
                try (PreparedStatement checkPst = conn.prepareStatement(checkSql)) {
                    checkPst.setString(1, description);
                    try (java.sql.ResultSet checkRs = checkPst.executeQuery()) {
                        if (checkRs.next()) {
                            response.sendRedirect("customer.jsp?error=duplicate_utr");
                            return;
                        }
                    }
                }
            }
            
            String sql = "INSERT INTO finance (username, type, amount, description, date, time, collector, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement pst = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                pst.setString(1, username);
                pst.setString(2, type);
                pst.setDouble(3, amount);
                pst.setString(4, description);
                pst.setString(5, dateStr);
                
                // Set time exactly to Indian Standard Time (IST)
                java.time.LocalTime now = java.time.LocalTime.now(java.time.ZoneId.of("Asia/Kolkata"));
                pst.setTime(6, java.sql.Time.valueOf(now));
                pst.setString(7, collectorName);
                pst.setString(8, paymentStatus);
                
                int result = pst.executeUpdate();
                if (result > 0) {
                    int generatedId = -1;
                    try (java.sql.ResultSet rsKeys = pst.getGeneratedKeys()) {
                        if (rsKeys.next()) generatedId = rsKeys.getInt(1);
                    }
                    
                    if ("Collector".equals(role)) {
                        String updateLoanSql = "UPDATE loans SET paid_amount = COALESCE(paid_amount, 0) + ?, remaining_amount = COALESCE(remaining_amount, loan_amount) - ? WHERE username = ?";
                        try (PreparedStatement updatePst = conn.prepareStatement(updateLoanSql)) {
                            updatePst.setDouble(1, amount);
                            updatePst.setDouble(2, amount);
                            updatePst.setString(3, username);
                            updatePst.executeUpdate();
                        }
                        
                        // Fetch new balance and save to finance
                        if (generatedId != -1) {
                            String fetchSql = "SELECT paid_amount, remaining_amount FROM loans WHERE username = ?";
                            try (PreparedStatement fetchPst = conn.prepareStatement(fetchSql)) {
                                fetchPst.setString(1, username);
                                try (java.sql.ResultSet rs = fetchPst.executeQuery()) {
                                    if (rs.next()) {
                                        double pAmt = rs.getDouble("paid_amount");
                                        double rAmt = rs.getDouble("remaining_amount");
                                        String updateFinSql = "UPDATE finance SET current_paid_amount = ?, current_remaining_amount = ? WHERE id = ?";
                                        try (PreparedStatement ufinPst = conn.prepareStatement(updateFinSql)) {
                                            ufinPst.setDouble(1, pAmt);
                                            ufinPst.setDouble(2, rAmt);
                                            ufinPst.setInt(3, generatedId);
                                            ufinPst.executeUpdate();
                                        }
                                    }
                                }
                            }
                        }
                        
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
