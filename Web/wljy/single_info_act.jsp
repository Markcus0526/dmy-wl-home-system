<%-- 
    Document   : single_info_act
    Created on : Dec 23, 2013, 3:24:17 PM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<%@page import="java.util.Date"%>

<%@ include file="connection.jsp" %>
<%
    String id = (request.getParameter("act_id")== null)?"":request.getParameter("act_id");
    String act = (request.getParameter("act")== null)?"":request.getParameter("act");
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyid"))
           {
                 tmp_str=name.substring(pos+1);
                 break;
           }
       }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
    
    request.setCharacterEncoding("UTF-8");
    
    Statement stmt = conn.createStatement();
    if (act.equals("add")) {
        String sql = "select max(id) from activity_entry";
        ResultSet rs = stmt.executeQuery(sql);

        int maxid = 0;
        if (rs.next()) {
            maxid = rs.getInt(1);
        }

        Date tmp = new Date();
		java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        sql = "Insert into ACTIVITY_ENTRY (ID, AID, MID, ENTRYDATE, ENABLED) VALUES (?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql); 
        pstmt.setInt(1, maxid + 1);
        pstmt.setInt(2, Integer.parseInt(id, 10));
        pstmt.setInt(3, UserId);
		pstmt.setTimestamp(4, d);
        pstmt.setInt(5, 1);

        pstmt.execute();
        pstmt.close(); 
                   
           int partcount = 0;
           Statement u_stmt1 = conn.createStatement();
           sql = "select count(*) as count from ACTIVITY_ENTRY where aid = " + Integer.parseInt(id, 10);
           ResultSet rs1 = u_stmt1.executeQuery(sql);
           if(rs1 != null && rs1.next())
               partcount = rs1.getInt("count");
           rs1.close();
           u_stmt1.close();
        
           if(partcount < 5) {     
               int mid = 0;
               u_stmt1 = conn.createStatement();
               sql = "select mid from ACTIVITY_INFO where id = " + id;
               rs1 = u_stmt1.executeQuery(sql);
               if(rs1 != null && rs1.next())
                   mid = rs1.getInt("mid");
               rs1.close();
               u_stmt1.close();
               
                int reason_id = 13;
               int def_reason = 1;
			   
               u_stmt1 = conn.createStatement();
               sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = "+reason_id;
               rs1 = u_stmt1.executeQuery(sql);
               if(rs1.next())
                   def_reason = rs1.getInt("DEFAULTINTEGRAL");
               rs1.close();
               u_stmt1.close();
			   
               
               int max_id = 0;
               u_stmt1 = conn.createStatement();
               sql = "select MAX(id) as maxid from INTEGRALLOG";
               rs1 = u_stmt1.executeQuery(sql);
               if(rs1.next())
                   max_id = rs1.getInt("maxid");
               rs1.close();
               u_stmt1.close();

               sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
               pstmt = conn.prepareStatement(sql);
               pstmt.setInt(1, max_id + 1);
               pstmt.setInt(2, mid);
               pstmt.setTimestamp(3, d);
               pstmt.setInt(4, def_reason);
               pstmt.setInt(5, reason_id);
               pstmt.setInt(6, 1);
               pstmt.execute();
               pstmt.close();
               
               u_stmt1 = conn.createStatement();
               sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + def_reason + " WHERE ID = " + mid;
               u_stmt1.execute(sql);
               u_stmt1.close();

           }
    }
    else if (act.equals("delete"))
    {
        //String sql = "delete from activity_entry where aid =" + id + " and mid = " + UserId;
		String sql = "update activity_entry set deleted = 1 where aid =" + id + " and mid = " + UserId;
        stmt.execute(sql);

        int mid = 0;
        Statement u_stmt1 = conn.createStatement();
        sql = "select mid from ACTIVITY_INFO where id = " + id;
        ResultSet rs1 = u_stmt1.executeQuery(sql);
        if(rs1 != null && rs1.next())
            mid = rs1.getInt("mid");
               rs1.close();
               u_stmt1.close();
               
        //sql = "delete from integrallog where mid = " + mid + " and reason = 13 and enabled = 1";
        //stmt.execute(sql);
               
        int reason_id = 13;
        int def_reason = 1;
               u_stmt1 = conn.createStatement();
        sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = "+reason_id;
               rs1 = u_stmt1.executeQuery(sql);
               if(rs1.next())
            def_reason = rs1.getInt("DEFAULTINTEGRAL");
               rs1.close();
               u_stmt1.close();

	    Statement u_stmt2 = conn.createStatement();
		ResultSet rs2;
	   int max_id = 0;
	   u_stmt2 = conn.createStatement();
	   sql = "select MAX(id) as maxid from INTEGRALLOG";
	   rs2 = u_stmt2.executeQuery(sql);
	   if(rs2.next())
		   max_id = rs2.getInt("maxid");
	   rs2.close();
	   u_stmt2.close();
	   
	   Date tmp = new Date();
		java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
	   sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
	   PreparedStatement pstmt = conn.prepareStatement(sql); 
	   pstmt.setInt(1, max_id + 1);
	   pstmt.setInt(2, mid);
	   pstmt.setTimestamp(3, d);
	   pstmt.setInt(4, def_reason*(-1));
	   pstmt.setInt(5, reason_id);
	   pstmt.setInt(6, 1);
	   pstmt.execute();
	   pstmt.close();
               
        u_stmt2 = conn.createStatement();
        sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL - " + def_reason + " WHERE ID = " + mid;
        u_stmt2.execute(sql);
        u_stmt2.close();
       
        stmt.close();
    }
  
    conn.close();   
    
    out.println("<script>window.location.href='single_info.jsp?id=" + id + "';</script>");
%>
