package org.wavessolutions.co.ke;

import org.wavessolutions.co.ke.DB.DbConn;

import com.thomas_bayer.blz.BLZService;
import com.thomas_bayer.blz.BLZServicePortType;
import com.thomas_bayer.blz.DetailsType;

public class BankDetailsRetrival {

	public static void main(String[] args) {
		LogError le = new LogError();
		try{
		if(args.length !=1){
			System.out.println("Please provide a bank code!!!");
		}else{
			String bankcode = args[0];
			BLZService bl = new BLZService();
			BLZServicePortType bptyp = bl.getBLZServiceSOAP11PortHttp();
			DetailsType dt = bptyp.getBank(bankcode);
			//log this details to log files or persist to database
			DbConn d = new DbConn();
			String resp = d.insertdata(dt.getBezeichnung(),dt.getBic(),dt.getOrt(),dt.getPlz());
			le.Log_Error("BankDetailsRetrival", new Exception(resp));
			System.out.println(resp);

		}
		}catch(Exception ex){
			//log the error to log file
			le.Log_Error("BankDetailsRetrival", ex);
		}
	}
}
