<%-- 
    Document   : faq_info_addans
    Created on : Dec 23, 2013, 3:56:56 PM
    Author     : Hercules
--%>

<%@page import="org.json.simple.JSONArray"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page language="Java" import="java.sql.*" %>
<%@page language="Java" import="java.util.Date"%>
<%@ include file="../connection.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    JSONObject obj = new JSONObject();

    String userid = (request.getParameter("userid") == null) ? "0" : request.getParameter("userid");

    Statement stmt = conn.createStatement();
    String sql = "select * from memberinfo where deleted = 0 and id=" + Integer.parseInt(userid, 10);
    ResultSet rs = stmt.executeQuery(sql);

    if (!rs.next()) {
        obj.put("success", 0);
        rs.close();
        stmt.close();
    } else {


        stmt = conn.createStatement();
        sql = null;
        rs = null;

        String id = request.getParameter("id") == null ? "0" : request.getParameter("id");
        String postdata = (request.getParameter("postdata") == null) ? "0" : request.getParameter("postdata");
        java.sql.NClob nclob = conn.createNClob();
        byte[] utf8bytes = postdata.getBytes("UTF8");
        nclob.setString(1, new String(utf8bytes, "UTF8"));

        sql = "select max(id) from problem_ainfo";
        rs = stmt.executeQuery(sql);
        int max_id = 1;
        if (rs.next()) {
            max_id = rs.getInt(1);
        }
        rs.close();
        stmt.close();

        sql = "Insert into problem_ainfo (ID, PID, MID, title, BODY, postdate, ENABLED) VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);

        pstmt.setInt(1, max_id + 1);
        pstmt.setInt(2, Integer.parseInt(id));
        pstmt.setInt(3, Integer.parseInt(userid));
        pstmt.setString(4, "TITLE");
        pstmt.setNClob(5, nclob);
        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
        pstmt.setTimestamp(6, d);
        pstmt.setInt(7, 1);

        pstmt.execute();
        pstmt.close();
        
        
        int reason_id = 14;
        int mid = 0, integral = 0;
        Statement u_stmt1 = conn.createStatement();
        sql = "select mid, rewardintegral from PROBLEM_QINFO where id = " + id;
        ResultSet rs1 = u_stmt1.executeQuery(sql);
        if(rs1 != null && rs1.next()) {
           mid = rs1.getInt("mid");
           integral = rs1.getInt("rewardintegral");
        }
        rs1.close();

        max_id = 0;
        sql = "select MAX(id) as maxid from INTEGRALLOG";
        rs1 = u_stmt1.executeQuery(sql);
        if(rs1.next())
           max_id = rs1.getInt("maxid");
        rs1.close();

        sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, max_id + 1);
        pstmt.setInt(2, Integer.parseInt(userid));
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
        pstmt.setInt(5, reason_id + 1);
        pstmt.setInt(6, 1);
        pstmt.execute();
        pstmt.close();
        
        sql = "update memberinfo set INTEGRAL = INTEGRAL + " + integral + " where ID = " + userid;
        u_stmt1.execute(sql);
        
        if ( mid > 0 )
        {
            sql = "update memberinfo set INTEGRAL = INTEGRAL - " + integral + " where ID = " + mid;
            u_stmt1.execute(sql);
        }

        obj.put("success", 1);

    }

    out.println(obj.toJSONString());
    conn.close();
%>