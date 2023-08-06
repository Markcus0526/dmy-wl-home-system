<%-- 
    Document   : myinfo
    Created on : 2014/1/23, 下午 04:39:39
    Author     : kimsui
--%>

<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    JSONObject obj = new JSONObject();

    String userid = (request.getParameter("userid") == null) ? "0" : request.getParameter("userid");

    Statement stmt = conn.createStatement();
    String sql = "select * from memberinfo where deleted = 0 and id=" + Integer.parseInt(userid, 10);
    ResultSet rs = stmt.executeQuery(sql), rs1;

    if (!rs.next()) {
        obj.put("success", 0);
    } else {

        rs.close();
        String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");

        int pagenum = Integer.parseInt(spage);
        int pagecount = 8;


        Statement u_stmt = conn.createStatement();

        sql = "select * from MEMBERINFO where ID = '" + userid + "'";
        rs = stmt.executeQuery(sql);
        if (rs.next()) {
            String mem_Name = rs.getString("NAME");
            String mem_OtherName = rs.getString("NICKNAME");
            String mem_Userid = rs.getString("USERID");
            String mem_Password = rs.getString("PASSWORD");
            String mem_Photo = rs.getString("PHOTO");
            int mem_Integral = rs.getInt("INTEGRAL");
            Date mem_lastlog = rs.getDate("LASTLOGINDATE");
            String mem_Phone = rs.getString("PHONENUM");
            rs.close();

            obj.put("name", mem_Name);
            obj.put("nickname", mem_OtherName);
            obj.put("phone", mem_Phone);
            obj.put("integral", mem_Integral);
            obj.put("success", 1);
        } else {
            obj.put("success", 0);
        }

        out.println(obj.toJSONString());
    }
    conn.close();
%>

