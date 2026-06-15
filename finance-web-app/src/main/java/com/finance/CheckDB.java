import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import com.finance.DBConnection;

public class CheckDB {
    public static void main(String[] args) {
        try {
            Connection conn = DBConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SHOW CREATE TABLE users");
            if (rs.next()) {
                System.out.println(rs.getString(2));
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
