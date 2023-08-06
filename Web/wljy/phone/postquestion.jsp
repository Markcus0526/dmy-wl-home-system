<%-- 
    Document   : myfaq_add
    Created on : 2014/2/3, 下午 03:37:07
    Author     : kimsui
--%>

<%@page import="org.json.simple.JSONObject"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page import="java.util.Date"%>
<%@ include file="../connection.jsp" %>

<%

    request.setCharacterEncoding("UTF-8");
    String userid = (request.getParameter("userid") == null) ? "0" : request.getParameter("userid");

    Statement stmt = conn.createStatement();
    String sql = "select * from memberinfo where deleted = 0 and id=" + Integer.parseInt(userid, 10);
    ResultSet rs = stmt.executeQuery(sql), rs1, rs2;
    JSONObject obj = new JSONObject();
    if (!rs.next()) {
        obj.put("success", 0);
    } else {
        obj.put("success", 1);
        rs.close();


        sql = "select MAX(ID) from PROBLEM_QINFO";
        rs = stmt.executeQuery(sql);

        int newID = 0;

        if (rs.next()) {
            newID = rs.getInt(1);
        }
        newID++;

        rs.close();


        String ques_title = (request.getParameter("ques_title") == null) ? "" : request.getParameter("ques_title");
        String ques_typestr = (request.getParameter("ques_type") == null) ? "1" : request.getParameter("ques_type");
        String ques_integral = (request.getParameter("ques_integral") == null) ? "0" : request.getParameter("ques_integral");
        if (ques_integral.equals("")) {
            ques_integral = "0";
        }
        String ques_body = (request.getParameter("ques_body") == null) ? "" : request.getParameter("ques_body");
        java.sql.NClob nclob_body = conn.createNClob();
        byte[] utf8bytes = ques_body.getBytes("UTF-8");
        nclob_body.setString(1, new String(utf8bytes, "UTF8"));

        int ques_type = Integer.parseInt(ques_typestr, 10);

        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        sql = "Insert into PROBLEM_QINFO (ID, MID, TITLE, TYPE, BODY, REWARDINTEGRAL, POSTDATE) VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, Integer.parseInt(userid, 10));
        pstmt.setString(3, ques_title);
        pstmt.setInt(4, ques_type);
        //pstmt.setString(5, ques_body);
        pstmt.setNClob(5, nclob_body);
        pstmt.setInt(6, Integer.parseInt(ques_integral));
        pstmt.setTimestamp(7, d);
        pstmt.execute();
        pstmt.close();
        obj.put("success", 1);
    }

    conn.close();

    out.println(obj.toJSONString());
%>

