<%-- 
    Document   : myphoto_info
    Created on : 2014/2/10, 下午 06:17:27
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
        obj.put("success", 1);
        rs.close();
        int id = Integer.parseInt(request.getParameter("id") == null ? "0" : request.getParameter("id"), 10);


        sql = "select * from member_data where deleted = 0 and id=" + id;
        rs = stmt.executeQuery(sql);
        String title = new String();
        Date postdate = new Date(1, 11, 1);
        int readcount = 0;

        String imagepath = new String();
        String body = new String();

        int index = 0;

        while (rs.next()) {
            imagepath = rs.getString("datapath");
            id = rs.getInt("id");
            title = rs.getString("title");
            body = rs.getString("body");

        }

        obj.put("id", id);
        obj.put("imagepath", phoneImageSrc(imagepath));
        obj.put("title", title);
        obj.put("body", body);
        out.println(obj.toJSONString());
    }
    conn.close();
%>


