<%-- 
    Document   : Answer
    Created on : 2014-2-5, 11:34:31
    Author     : Hercules
--%>

<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Date"%>
<%@ include file="../connection.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    JSONObject obj = new JSONObject();

    String userid = (request.getParameter("userid") == null) ? "0" : request.getParameter("userid");

    Statement stmt = conn.createStatement();
    String sql = "select * from MEMBERINFO where deleted = 0 and ID =" + Integer.parseInt(userid, 10);
    ResultSet rs = stmt.executeQuery(sql);

    if (!rs.next()) {
        obj.put("success", 0);
        rs.close();
        stmt.close();
    } else {
        obj.put("success", 1);
        rs.close();
        stmt.close();

        String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");
        int id = Integer.parseInt(request.getParameter("id") == null ? "0" : request.getParameter("id"), 10);
        int pagenum = Integer.parseInt(spage);

        int pagecount = 8;
        int total_count = 0, total_page = 0;

        stmt = conn.createStatement();
        sql = "select count(*) as COUNT from ACTIVITY_EVAL where AID = " + id + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR')";
        rs = stmt.executeQuery(sql);
        if (rs.next()) {
            total_count = rs.getInt("COUNT");
            if (total_count == 0) {
                obj.put("count", 0);
                out.println(obj.toJSONString());

                rs.close();
                stmt.close();
                conn.close();
                return;
            }

            total_page = (total_count - 1) / pagecount + 1;
            if (pagenum > total_page) {
                obj.put("count", 0);
                out.println(obj.toJSONString());

                rs.close();
                stmt.close();
                conn.close();
                return;
            }
            if (pagenum != 0) {
                pagenum = total_page - pagenum + 1;
            } else {
                pagenum = total_page;
            }
        }
        rs.close();
        stmt.close();

        int prev_page = 1, next_page = total_page;
        if (pagenum > 1) {
            prev_page = pagenum - 1;
        }
        if (pagenum < total_page) {
            next_page = pagenum + 1;
        }

        int last_index = total_count - (total_page - pagenum) * pagecount;
        int first_index = last_index - pagecount + 1;
        if (first_index <= 0) {
            first_index = 1;
        }
        pagecount = last_index - first_index + 1;

        stmt = conn.createStatement();
        sql = "select * from (select * from (select * from ACTIVITY_EVAL where AID = " + id + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by ID) where ID >= (select MAX(ID) from (select * from (select * from ACTIVITY_EVAL where AID = " + id + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by ID) where ROWNUM <= " + last_index + ") where ROWNUM <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
        rs = stmt.executeQuery(sql);

        String name = new String();
        Date postdate = new Date(1, 11, 1);
        String body = new String();
        String imagepath = new String();

        int mid = 0;
        int clob_length = 0;
        Clob clob = null;

        JSONArray obj1 = new JSONArray();
        JSONObject obj2[] = new JSONObject[pagecount];

        Statement u_stmt = conn.createStatement();
        ResultSet rs1 = null;
        int index = 0;
        while (rs.next()) {
            mid = rs.getInt("mid");

            sql = "Select * from MEMBERINFO where id = " + mid;
            rs1 = u_stmt.executeQuery(sql);
            name = "";
            imagepath = "";
            if (rs1.next()) {
                name = rs1.getString("NAME");
                imagepath = rs1.getString("PHOTO");
            }
            rs1.close();

            clob = rs.getClob("body");
            clob_length = (clob == null) ? -1 : (int) clob.length();
            if (clob_length < 0) {
                body = "";
            } else {
                body = clob.getSubString(1, clob_length);
            }

            postdate = rs.getDate("postdate");

            Date cur_date = new Date();
            long a = cur_date.getTime() - postdate.getTime();
            a = a / 1000 / 3600 / 24;

            obj2[index] = new JSONObject();
            obj2[index].put("name", name);
            obj2[index].put("body", body);
            obj2[index].put("postdate", a);
            obj2[index].put("imagepath", phoneImageSrc(imagepath));

            obj1.add(index, obj2[index]);
            index++;
        }
        obj.put("count", index);
        obj.put("data", obj1);
        rs1.close();
        u_stmt.close();
    }
    rs.close();
    stmt.close();

    conn.close();
    out.println(obj.toJSONString());
%>
