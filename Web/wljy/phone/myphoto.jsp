<%-- 
    Document   : myphoto
    Created on : 2014/1/23, 下午 03:50:40
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

        sql = "select count(*) as count from member_data where deleted = 0 and type = 0 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and mid = " + userid;
        rs = stmt.executeQuery(sql);

        int total_count = 0, total_page = 0;

        if (rs.next()) {
            total_count = rs.getInt("count");

            if (total_count == 0) {
                obj.put("count", 0);
                out.println(obj.toJSONString());
                conn.close();
                return;
            }

        }

        rs.close();


        rs1 = null;

        sql = "select * from member_data where deleted = 0 and type = 0 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and mid = '" + userid + "' order by id DESC";
        rs = stmt.executeQuery(sql);

        String imagepath = new String();

        int id = 0;

        JSONArray obj1 = new JSONArray();
        JSONObject obj2[] = new JSONObject[total_count];

        int index = 0;

        while (rs.next()) {
            imagepath = rs.getString("datapath");
            id = rs.getInt("id");
            
            obj2[index] = new JSONObject();
            obj2[index].put("id", id);
            obj2[index].put("imagepath", phoneImageSrc(imagepath));
            obj1.add(index, obj2[index]);
            index++;
        }
        obj.put("count", index);
        obj.put("data", obj1);
        out.println(obj.toJSONString());
    }
    conn.close();
%>

