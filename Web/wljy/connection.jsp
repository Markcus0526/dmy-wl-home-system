<%-- 
    Document   : connection
    Created on : Dec 24, 2013, 3:29:45 PM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page language="Java" import="java.sql.*" %>
<%@page import="java.awt.Graphics2D"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@page import="java.io.File"%>
<%@page import="javax.imageio.ImageIO"%>
<%@page import = "java.io.IOException" %>
<%@page import="java.util.Date"%>

<%
   Connection conn = null;
	try {
		 Class.forName("oracle.jdbc.driver.OracleDriver");
		 conn = DriverManager.getConnection("jdbc:oracle:thin:@192.168.1.79:1525:NewWoLong", "SYSTEM", "WoLong2014");
	}
	catch (SQLException e)
	{
	   System.out.println("ERROR: failed to connect!");
	   System.out.println("ERROR: " + e.getMessage());
	   e.printStackTrace();
	   return;
	}
	
%>

<%!
    public void imageresize(String src) {
        File src_file = new File(src);
        try {
            BufferedImage tmp_img = ImageIO.read(src_file);

            int width1 = 300;
            int height1 = 300;

            if (tmp_img.getWidth() > 300) {
                height1 = tmp_img.getHeight() * width1 / tmp_img.getWidth();
            } else {
                width1 = tmp_img.getWidth();
                height1 = tmp_img.getHeight();
            }

            BufferedImage dst1 = new BufferedImage(width1, height1, BufferedImage.TYPE_3BYTE_BGR);
            Graphics2D g1 = dst1.createGraphics();

            g1.drawImage(tmp_img, 0, 0, width1, height1, null);
            File dst_file1 = new File(phoneImageSrc(src));
            ImageIO.write(dst1, "jpg", dst_file1);
            
        } catch (IOException ex) {
        }

    }
    
    public String phoneImageSrc(String src) {
        if ( src == null || src.equals("")  )
            return src;
        int ind = src.lastIndexOf(".");
        String phoneSrc = src.substring(0, ind) +"_phone" +src.substring(ind);
        return phoneSrc;
    }
    
    public String makeUploadFileNamePrefix(String curFileName) {
        if ( curFileName.equals("") )
            return "";
        
        String retStr = "";
        
        Date today = new Date();
        String fileExt = curFileName.substring(curFileName.lastIndexOf("."));
        
        retStr = (String.format("%04d", today.getYear() + 1900) + String.format("%02d", today.getMonth() + 1)   +String.format("%02d", today.getDate()) ) + "_" + today.getTime() + fileExt;
        
        
        return retStr;
    }
    
    public String makeUploadDirName()
    {
         Date today = new Date();

         return (String.format("%04d", today.getYear() + 1900) + String.format("%02d", today.getMonth() + 1));
    }
/*
	public boolean IsActiveUser(int userID)
	{
		int nRet = 0;

		Statement u_stmt1 = conn.createStatement();
		String sql = "select firstlogin from memberinfo where id = " + userID;
		ResultSet rs1 = u_stmt1.executeQuery(sql);
		if (rs1.next()) {
			nRet = rs1.getInt("DEFAULTINTEGRAL");
		}
		rs1.close();
		u_stmt1.close();

		if (nRet == 1)
			return true;
		else
			return false;
	}
*/
%>