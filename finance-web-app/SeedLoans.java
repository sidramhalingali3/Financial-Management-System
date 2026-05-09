import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Date;

public class SeedLoans {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/finance_db?useSSL=false", "root", "root");
            
            // Create table if not exists
            conn.createStatement().executeUpdate("CREATE TABLE IF NOT EXISTS loans (id INT PRIMARY KEY AUTO_INCREMENT, username VARCHAR(50), loan_amount DOUBLE, date DATE)");
            
            // Delete old data for these 3 users
            conn.createStatement().executeUpdate("DELETE FROM loans WHERE username IN ('Ravi Kumar', 'Suresh Patil', 'Mahesh Reddy')");
            conn.createStatement().executeUpdate("DELETE FROM finance WHERE username IN ('Ravi Kumar', 'Suresh Patil', 'Mahesh Reddy')");
            
            String[][] loans = {
                {"Ravi Kumar", "50000"},
                {"Suresh Patil", "80000"},
                {"Mahesh Reddy", "40000"}
            };
            
            String[][] payments = {
                {"Ravi Kumar", "20000"},
                {"Suresh Patil", "35000"},
                {"Mahesh Reddy", "15000"}
            };
            
            Date today = new Date(System.currentTimeMillis());
            
            PreparedStatement lpst = conn.prepareStatement("INSERT INTO loans (username, loan_amount, date) VALUES (?, ?, ?)");
            for (String[] l : loans) {
                lpst.setString(1, l[0]);
                lpst.setDouble(2, Double.parseDouble(l[1]));
                lpst.setDate(3, today);
                lpst.addBatch();
            }
            lpst.executeBatch();
            lpst.close();
            
            PreparedStatement fpst = conn.prepareStatement("INSERT INTO finance (username, type, amount, description, date) VALUES (?, ?, ?, ?, ?)");
            for (String[] p : payments) {
                fpst.setString(1, p[0]);
                fpst.setString(2, "Payment");
                fpst.setDouble(3, Double.parseDouble(p[1]));
                fpst.setString(4, "Initial Collected EMI");
                fpst.setDate(5, today);
                fpst.addBatch();
            }
            fpst.executeBatch();
            fpst.close();
            
            System.out.println("Successfully seeded exact loan data.");
            
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
