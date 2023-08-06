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

        String old_pass = (request.getParameter("old_pass") == null) ? "" : request.getParameter("old_pass");
        String new_pass = (request.getParameter("new_pass") == null) ? "1" : request.getParameter("new_pass");

        String cur_pass = rs.getString("PASSWORD");

        if (cur_pass.equals(old_pass)) {
            sql = "UPDATE MEMBERINFO SET PASSWORD='" + new_pass + "' where ID=" + Integer.parseInt(userid, 10);
            stmt = conn.createStatement();
            stmt.executeQuery(sql);

            stmt.close();
            obj.put("success", 1);
        } else {
            obj.put("success", 2);
        }
    }

    conn.close();

    out.println(obj.toJSONString());
%>

