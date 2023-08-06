<%-- 
    Document   : mycartee
    Created on : 2014/2/11, 上午 09:22:31
    Author     : kimsui
--%>

<%@page import="org.json.simple.JSONArray"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="org.json.simple.JSONObject"%>
<%@ include file="../connection.jsp" %>
<%@page import="java.util.Date"%>
<%
    request.setCharacterEncoding("UTF-8");

    JSONObject obj = new JSONObject();

    String userid = (request.getParameter("userid") == null) ? "0" : request.getParameter("userid");

    Statement stmt = conn.createStatement();
    String sql = "select * from memberinfo where id=" + Integer.parseInt(userid, 10);
    ResultSet rs = stmt.executeQuery(sql), rs1, rs2;

    if (!rs.next()) {
        obj.put("success", 0);
    } else {
        obj.put("success", 1);
        int cart_id = Integer.parseInt(request.getParameter("cart_id") == null ? "0" : request.getParameter("cart_id"));

        sql = "select PID, COUNT from ORDER_PRODUCT where id = " + cart_id;
        rs = stmt.executeQuery(sql);
        if (rs.next()) {
            int cnt = rs.getInt("COUNT");
            int pid = rs.getInt("PID");
            sql = "UPDATE PRODUCT_INFO SET TOTAL_SECURE = TOTAL_SECURE + " + cnt + " where id = " + pid;
            stmt.executeQuery(sql);
        }

        sql = "delete from ORDER_PRODUCT where id = " + cart_id;
        stmt.executeQuery(sql);

    }
    out.println(obj.toJSONString());
    conn.close();
%>