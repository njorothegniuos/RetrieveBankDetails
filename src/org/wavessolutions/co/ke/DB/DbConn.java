package org.wavessolutions.co.ke.DB;
import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import org.wavessolutions.co.ke.LogError;
public class DbConn {
	Connection conn = null;
	private PreparedStatement preparedStatement = null;
	public DbConn() throws SQLException{
		   try {
		String connectionUrl = "jdbc:sqlserver://DESKTOP-HRDVLSE:1433;databaseName=bankDetails;user=sa;password=Password123!";
        conn = DriverManager.getConnection(connectionUrl);
		   } catch (SQLException ex) {
		    	le.Log_Error("DbConn", ex);
		    }
	}
	LogError le = new LogError();
	public String  insertdata(String Bezeichnung,String Bic,String Ort,String Plz ) {

    try {
    	//String sql = "INSERT INTO bank (bankname, BICNumber, City, ZipCode) VALUES (?, ?, ?, ?)";
    	String sql = "sp_InsertBankDetails ?, ?, ?, ?";
    	if (conn != null) {
        	 System.out.println("connected!");
        	preparedStatement = conn.prepareStatement(sql);
        	 preparedStatement.setString(1, Bezeichnung);
             preparedStatement.setString(2, Bic);
             preparedStatement.setString(3, Ort);
             preparedStatement.setString(4, Plz);
             int rowsInserted= preparedStatement.executeUpdate();
             if (rowsInserted > 0) {
            	    //System.out.println("Bank detials inserted successfully!");
            	    return "Bank detials inserted successfully!"; 
            	}
        }else{
        	 System.out.println("No connection!");
        }
    } catch (SQLException ex) {
    	le.Log_Error("DbConn", ex);
    } finally {
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException ex) {
        	le.Log_Error("DbConn", ex);
        }
    }
    return "no response";
    }
	}
	
	

