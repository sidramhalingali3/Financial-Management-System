<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% 
    String role=(String) session.getAttribute("role"); 
    if (role==null || !"Customer".equals(role)) { 
        response.sendRedirect("login.jsp"); 
        return; 
    } 
%>
<%@ page import="java.sql.*" %>
<%@ page import="com.finance.DBConnection" %>
<%
    Connection _conn = null;
    Statement _stmt = null;
    try {
        _conn = DBConnection.getConnection();
        _stmt = _conn.createStatement();
        try { _stmt.executeUpdate("ALTER TABLE finance MODIFY id INT AUTO_INCREMENT"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE finance ADD COLUMN current_paid_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE finance ADD COLUMN current_remaining_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE loans ADD COLUMN paid_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE loans ADD COLUMN remaining_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
        try { _stmt.executeUpdate("ALTER TABLE loans ADD COLUMN loan_amount DECIMAL(10,2)"); } catch (Exception ignore) {}
    } catch (Exception ignore) {
    } finally {
        if (_stmt != null) try { _stmt.close(); } catch(Exception e) {}
        if (_conn != null) try { _conn.close(); } catch(Exception e) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pay via UPI - Finance Management</title>
    <link rel="stylesheet" href="style.css">
    <script>
        function openUpi() {
            const amount = document.getElementById('upiAmount').value;
            if (!amount || amount <= 0) {
                alert("Please enter a valid amount first.");
                return;
            }
            const upiId = "6363882198@sbi";
            const upiName = "Admin";
            // Create intent URL
            const intentUrl = `upi://pay?pa=${upiId}&pn=${upiName}&am=${amount}&cu=INR`;
            
            // Open the Intent
            window.location.href = intentUrl;
            
            // Show the next step (Enter UTR and submit)
            document.getElementById('step1').style.display = 'none';
            document.getElementById('step2').style.display = 'block';
            
            // Pre-fill the form amount
            document.getElementById('amount').value = amount;
            
        }

        async function validateUtr(event) {
            event.preventDefault(); // Stop normal form submission
            
            const utr = document.getElementById('description').value;
            const btn = document.getElementById('submitBtn');
            const errorMsg = document.getElementById('utrError');
            
            btn.innerText = "Verifying...";
            btn.disabled = true;
            
            try {
                const response = await fetch('check_utr.jsp?utr=' + encodeURIComponent(utr));
                const text = await response.text();
                
                if (text.trim() === 'true') {
                    // UTR already exists!
                    errorMsg.style.display = 'block';
                    btn.innerText = "Confirm Payment";
                    btn.disabled = false;
                    return false;
                } else {
                    // Unique, go ahead
                    errorMsg.style.display = 'none';
                    document.getElementById('paymentForm').submit();
                }
            } catch(e) {
                // If network fails, just submit normally
                document.getElementById('paymentForm').submit();
            }
            return false;
        }
    </script>
</head>
<body>
    <div class="container login-container" style="max-width: 500px;">
        <div class="header-actions" style="margin-bottom: 1.5rem; padding-bottom: 0.5rem; border-bottom: 1px solid rgba(255,255,255,0.1);">
            <h2 style="margin-bottom: 0; color: #a855f7;">Make a Payment</h2>
            <a href="customer.jsp" class="btn btn-outline" style="padding: 0.5rem 1rem; font-size: 0.875rem;">&larr; Back</a>
        </div>

        <div id="step1" style="text-align: center;">
            <p style="color: #ccc; margin-bottom: 20px;">Enter the amount you wish to pay, then click below to open your UPI app (PhonePe, GPay, Paytm).</p>
            
            <div class="form-group" style="text-align: left;">
                <label for="upiAmount">Amount (₹)</label>
                <input type="number" id="upiAmount" step="0.01" min="1" placeholder="0.00" required>
            </div>
            
            <button onclick="openUpi()" class="btn" style="background-color: #5f259f; font-size: 1.1rem; padding: 12px; display: flex; align-items: center; justify-content: center; gap: 10px; width: 100%;">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                Pay via UPI App
            </button>
            
            <div style="margin-top: 30px; padding: 15px; background: rgba(255,255,255,0.05); border-radius: 8px;">
                <p style="font-size: 0.9rem; color: #999; margin:0 0 10px 0;">Or scan to pay (Laptop Users):</p>
                <img src="Admin.jpeg?v=2" alt="Scan QR" style="max-width: 150px; border-radius: 8px; border: 2px solid #5f259f;">
                <p style="font-size: 0.85rem; color: #666; margin: 10px 0 0 0;">UPI ID: <strong>6363882198@sbi</strong></p>
                <button onclick="document.getElementById('step1').style.display='none'; document.getElementById('step2').style.display='block'; document.getElementById('amount').value=document.getElementById('upiAmount').value;" class="btn btn-outline" style="margin-top: 15px; width: 100%;">I have already paid</button>
            </div>
        </div>

        <div id="step2" style="display: none;">
            <div style="background: rgba(16, 185, 129, 0.1); border: 1px solid #10b981; padding: 15px; border-radius: 8px; margin-bottom: 20px; text-align: center;">
                <h4 style="color: #10b981; margin: 0 0 5px 0;">Great! Payment Initiated.</h4>
                <p style="font-size: 0.9rem; margin: 0; color: #ddd;">After successfully paying in your app, please enter the 12-digit UTR/Transaction ID below to confirm your payment.</p>
            </div>
            
            <form action="AddFinanceServlet" method="post" id="paymentForm" onsubmit="return validateUtr(event)">
                <input type="hidden" name="type" value="Payment">
                
                <div class="form-group">
                    <label for="amount">Amount Paid (₹)</label>
                    <input type="number" id="amount" name="amount" step="0.01" min="0" required readonly style="background: rgba(0,0,0,0.2); cursor: not-allowed; opacity: 0.7;">
                </div>
                
                <div class="form-group">
                    <label for="description">12-digit UTR / Transaction ID</label>
                    <input type="text" id="description" name="description" required placeholder="e.g. 312345678901" pattern="\d{12}" title="Please enter exactly 12 digits for the UTR">
                    <div id="utrError" style="display:none; color: #ef4444; font-size: 0.85rem; margin-top: 5px; background: rgba(239, 68, 68, 0.1); padding: 5px; border-radius: 4px;">
                        This UTR number already exists. Please enter a unique 12-digit UTR.
                    </div>
                </div>
                
                <div class="form-group" style="display:none;">
                    <label for="date">Date</label>
                    <%
                        java.time.LocalDate istDate = java.time.LocalDate.now(java.time.ZoneId.of("Asia/Kolkata")).plusDays(1);
                    %>
                    <input type="date" id="date" name="date" value="<%= istDate.toString() %>" required>
                </div>
                
                <button type="submit" id="submitBtn" class="btn" style="background-color: #10b981;">Confirm Payment</button>
            </form>
        </div>
    </div>
</body>
</html>
