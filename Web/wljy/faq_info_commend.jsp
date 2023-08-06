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
    
    String id = request.getParameter("queryid");
	String answerid = request.getParameter("answerid");
    if(id != null) 
	{
		Statement mystmt = conn.createStatement(); 
		String query = "update PROBLEM_QINFO set COMMENDNO = " + Integer.parseInt(answerid, 10) + " where id = " + Integer.parseInt(id);
        mystmt.execute(query);
        mystmt.close();
		
		String sql = new String();		
		
		int reason_id = 16;
	   int mid = 0, integral = 0;
	   Statement u_stmt1 = conn.createStatement();
	   sql = "select mid, rewardintegral from PROBLEM_QINFO where id = " + Integer.parseInt(id);
	   ResultSet rs1 = u_stmt1.executeQuery(sql);
	   if(rs1 != null && rs1.next()) {
		   mid = rs1.getInt("mid");
		   integral = rs1.getInt("rewardintegral");
	   }
	   rs1.close();

		int answeredUserID = 0;
	   sql = "select mid from PROBLEM_AINFO where id = " + Integer.parseInt(answerid);
	   rs1 = u_stmt1.executeQuery(sql);
	   if(rs1 != null && rs1.next()) {
		   answeredUserID = rs1.getInt("mid");
	   }
	   rs1.close();

	   int max_id = 0;
	   sql = "select MAX(id) as maxid from INTEGRALLOG";
	   rs1 = u_stmt1.executeQuery(sql);
	   if(rs1.next())
		   max_id = rs1.getInt("maxid");
	   rs1.close();

	   Date tmp = new Date();
		java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

	   sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
	   PreparedStatement pstmt = conn.prepareStatement(sql);
	   pstmt.setInt(1, max_id + 1);
	   pstmt.setInt(2, answeredUserID);
		pstmt.setTimestamp(3, d);
	   pstmt.setInt(4, integral);
	   pstmt.setInt(5, reason_id);
		pstmt.setInt(6, 1);
	   pstmt.execute();
	   pstmt.close(); 
	   
	   sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
	   pstmt = conn.prepareStatement(sql);
	   pstmt.setInt(1, max_id + 2);
	   pstmt.setInt(2, mid);
		pstmt.setTimestamp(3, d);
	   pstmt.setInt(4, -integral);
	   pstmt.setInt(5, reason_id);
		pstmt.setInt(6, 1);
	   pstmt.execute();
	   pstmt.close();

		sql = "update memberinfo set INTEGRAL = INTEGRAL + " + integral + " where deleted = 0 and ID = " + answeredUserID;
		u_stmt1.execute(sql);
		
		if ( mid > 0 )
		{
			sql = "update memberinfo set INTEGRAL = INTEGRAL - " + integral + " where deleted = 0 and ID = " + mid;
			u_stmt1.execute(sql);
		}
        
        conn.close();
    }
      
    out.println("<script>window.location.href='faq_info.jsp?id=" + id + "';</script>");
%>