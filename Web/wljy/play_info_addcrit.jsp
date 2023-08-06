<%-- 
    Document   : play_info_addcrit
    Created on : Dec 23, 2013, 3:27:39 PM
    Author     : Hercules
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@page language="Java" import="java.sql.*" %>
<%@page language="Java" import="java.util.Date"%>
<%@ include file="connection.jsp" %>
<%
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
    
    String id = request.getParameter("id");
    if(id != null)
    {
        Statement stmt = conn.createStatement();
        String sql = null;
        ResultSet rs = null;
        String postdata = (request.getParameter("postdata")== null)?"0":request.getParameter("postdata");
        java.sql.NClob nclob = conn.createNClob();
        byte[] utf8bytes = postdata.getBytes("UTF8");
        nclob.setString(1, new String(utf8bytes, "UTF8"));   
        
        sql = "select max(id) from activity_eval";
        rs = stmt.executeQuery(sql);
        int max_id = 1;
        if (rs.next()) 
            max_id = rs.getInt(1);
        rs.close();
        stmt.close();
        
        sql = "Insert into ACTIVITY_EVAL (ID, AID, MID, POSTDATE, BODY, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql); 
        
        pstmt.setInt(1, max_id + 1);
        pstmt.setInt(2, Integer.parseInt(id));
        pstmt.setInt(3, UserId);
        
        Date tmp = new Date();
java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
        
		pstmt.setTimestamp(4, d);
        pstmt.setNClob(5, nclob);
        pstmt.setInt(6, 1);

        pstmt.execute();        
        pstmt.close();
        
               int reason_id = 3;
               int def_reason = 1;
               Statement u_stmt1 = conn.createStatement();
               sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = "+reason_id;
               ResultSet rs1 = u_stmt1.executeQuery(sql);
               if(rs1.next())
                   def_reason = rs1.getInt("DEFAULTINTEGRAL");
               rs1.close();
               u_stmt1.close();
               
               max_id = 0;
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
               pstmt.setInt(2, UserId);
               pstmt.setTimestamp(3, d);
               pstmt.setInt(4, def_reason);
               pstmt.setInt(5, reason_id);
               pstmt.setInt(6, 1);
               pstmt.execute();
               pstmt.close();
        
               u_stmt1 = conn.createStatement();
               sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + def_reason + " WHERE ID = " + UserId;
               u_stmt1.execute(sql);
               u_stmt1.close();
        
        conn.close();
    }
         
    out.println("<script>window.location.href='play_info.jsp?id=" + id + "';</script>");
%>