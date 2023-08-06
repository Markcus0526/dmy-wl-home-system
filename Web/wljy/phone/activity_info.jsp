<%-- 
    Document   : activity_info
    Created on : 2014-2-5, 9:55:25
    Author     : Hercules
--%>

<%@page import="org.json.simple.JSONArray"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="org.json.simple.JSONObject"%>
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
        obj.put("success", 1);
        rs.close();
        stmt.close();

        stmt = conn.createStatement();
        String id = request.getParameter("id") == null ? "0" : request.getParameter("id");

        sql = "update activity_info set readcount = readcount + 1 where id = " + id;
        stmt.executeUpdate(sql);
        rs.close();

        String title = new String();
        Date postdate = new Date(1, 11, 1);
        String body = new String();
        String imagepath = new String();

        int eval_count = 0;
        Clob clob = null;
        int clob_length = 0;

        sql = "select * from ACTIVITY_INFO where ID = " + id;
        rs = stmt.executeQuery(sql);
        if (rs.next()) {
            title = rs.getString("TITLE");
            postdate = rs.getDate("POSTDATE");


            clob = rs.getClob("BODY");
            clob_length = (clob == null) ? -1 : (int) clob.length();
            if (clob_length < 0) {
                body = "";
            } else {
                body = clob.getSubString(1, clob_length);
            }

            rs.close();
            stmt.close();

            stmt = conn.createStatement();
            sql = "select * from ACTIVITY_IMAGE where AID = " + id;
            rs = stmt.executeQuery(sql);
            imagepath = "";
            if (rs.next()) {
                imagepath = rs.getString("DATAPATH");
            }
            rs.close();
            stmt.close();

            stmt = conn.createStatement();
            sql = "select count(*) as COUNT from ACTIVITY_EVAL where AID = " + id;
            rs = stmt.executeQuery(sql);
            eval_count = 0;
            if (rs.next()) {
                eval_count = rs.getInt("COUNT");
            }
            rs.close();
            stmt.close();

            obj.put("title", title);
            obj.put("postdate", postdate.toString());
            obj.put("body", body);
            obj.put("eval_count", eval_count);
            obj.put("imagepath", phoneImageSrc(imagepath));
        }
    }

    conn.close();
    out.println(obj.toJSONString());
%>
