<%-- 
    Document   : faq_info_addans
    Created on : Dec 23, 2013, 3:56:56 PM
    Author     : Hercules
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@page language="Java" import="java.util.Date"%>
<%@ include file="connection.jsp" %>
<%    
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyid")) {
             tmp_str=name.substring(pos+1);
             break;
       }
       }
    }
    
    int UserId = Integer.parseInt(tmp_str, 10);
    
    request.setCharacterEncoding("UTF-8");
    
    String id = request.getParameter("id");
    if(id != null) {
		Statement mystmt = conn.createStatement(); 
		String query = "select * from PROBLEM_QINFO where id = " + Integer.parseInt(id);
        ResultSet myrs = mystmt.executeQuery(query);
        int sharedUserID = 1;
        if (myrs.next()) 
            sharedUserID = myrs.getInt("MID");
        myrs.close();
        mystmt.close();
		/*
		if (UserId == sharedUserID)
		{
			out.println("<script>alert(\"现在问题是您提出的问题。\");</script>");
			out.println("<script>window.location.href='faq_info.jsp?id=" + id + "';</script>");
		}
		else
		*/
		{	
			Statement stmt = conn.createStatement();

			String sql = new String();
			ResultSet rs = null;
			String postdata = (request.getParameter("postdata")== null)?"0":request.getParameter("postdata");
			java.sql.NClob nclob = conn.createNClob();
			byte[] utf8bytes = postdata.getBytes("UTF8");
			nclob.setString(1, new String(utf8bytes, "UTF8"));        
			
			sql = "select max(id) from problem_ainfo";
			rs = stmt.executeQuery(sql);
			int max_id = 1;
			if (rs.next()) 
				max_id = rs.getInt(1);
			rs.close();
			stmt.close();
			
			sql = "Insert into problem_ainfo (ID, PID, MID, title, BODY, postdate, ENABLED) VALUES (?, ?, ?, ?, ?, ?, ?)";
			PreparedStatement pstmt = conn.prepareStatement(sql); 
			
			pstmt.setInt(1, max_id + 1);
			pstmt.setInt(2, Integer.parseInt(id));
			pstmt.setInt(3, UserId);
			pstmt.setString(4, "TITLE");
			pstmt.setNClob(5, nclob);
			Date tmp = new Date();
			java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
			pstmt.setTimestamp(6, d);
			pstmt.setInt(7, 1);

			pstmt.execute();        
			pstmt.close();
		}
        
        conn.close();
    }
      
    out.println("<script>window.location.href='faq_info.jsp?id=" + id + "';</script>");
%>