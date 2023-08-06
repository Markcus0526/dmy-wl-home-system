<%-- 
    Document   : play_info_addcrit
    Created on : Dec 23, 2013, 3:27:39 PM
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

        rs.close();
        stmt.close();

        stmt = conn.createStatement();
        String id = request.getParameter("id") == null ? "0" : request.getParameter("id");
        String type = (request.getParameter("type") == null) ? "0" : request.getParameter("type");

        sql = "select count(*) as cnt from study_comment where mid = " + userid + " and sid = " + id;
        rs = stmt.executeQuery(sql);
        if (rs.next()) {
            if (rs.getInt("cnt") > 0) {
                obj.put("success", 2);
            } else {
                rs.close();
                stmt.close();
                stmt = conn.createStatement();

                sql = "select max(id) from study_comment";
                rs = stmt.executeQuery(sql);
                int max_id = 1;
                if (rs.next()) {
                    max_id = rs.getInt(1);
                }
                rs.close();
                stmt.close();

                sql = "Insert into study_comment (ID, SID, MID, TYPE) VALUES (?, ?, ?, ?)";
                PreparedStatement pstmt = conn.prepareStatement(sql);

                pstmt.setInt(1, max_id + 1);
                pstmt.setInt(2, Integer.parseInt(id));
                pstmt.setInt(3, Integer.parseInt(userid));
                pstmt.setInt(4, Integer.parseInt(type));
                pstmt.execute();
                pstmt.close();

                rs.close();
                stmt.close();
                stmt = conn.createStatement();
                if (Integer.parseInt(type) == 1) {
                    sql = "UPDATE STUDY_QINFO SET GOOD=GOOD+1 where ID=" + id;
                } else {
                    sql = "UPDATE STUDY_QINFO SET BAD=BAD+1 where ID=" + id;
                }
                stmt.executeQuery(sql);


                obj.put("success", 1);
            }
        }
    }

    out.println(obj.toJSONString());
    conn.close();

%>