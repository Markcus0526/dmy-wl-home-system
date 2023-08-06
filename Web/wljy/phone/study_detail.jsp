<%-- 
    Document   : study_detail
    Created on : 2014/2/3, 下午 03:25:52
    Author     : kimsui
--%>

<%@page import="org.json.simple.JSONArray"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.util.Date"%>
<%@ include file="../connection.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    JSONObject obj = new JSONObject();

    String userid = (request.getParameter("userid") == null) ? "0" : request.getParameter("userid");

    Statement stmt = conn.createStatement();
    String sql = "select * from memberinfo where deleted = 0 and id=" + Integer.parseInt(userid, 10);
    ResultSet rs = stmt.executeQuery(sql), rs1, rs2;

    if (!rs.next()) {
        obj.put("success", 0);
    } else {
        obj.put("success", 1);
        rs.close();
        Statement u_stmt = conn.createStatement();
        Statement u_stmt1 = conn.createStatement();
        String id = request.getParameter("id") == null ? "0" : request.getParameter("id");
        int pagenum = Integer.parseInt(request.getParameter("page") == null ? "0" : request.getParameter("page"), 10);

        int readcount = 0;

        String title = new String();
        Date postdate = new Date(1, 11, 1);
        int rewardintegral = 0;
        String body = new String();
        int mid = 0;
        String username = new String();
        String type_name = new String();
        int type = 0;
        Clob clob = null;
        int clob_len = 0, answer_count = 0;

        sql = "select count(*) as count from STUDY_AINFO where sid = " + id;
        rs = stmt.executeQuery(sql);
        int total_count = 0;
        int pagecount = 8;
        if (rs.next()) {
            total_count = rs.getInt("count");
            int total_page = 0;
            int prev_page = 1, next_page = 1, first_index = 1, last_index = 1;

            if (total_count != 0) {
                total_page = (total_count - 1) / pagecount + 1;
                if (pagenum == 0) {
                    pagenum = total_page;
                }
                prev_page = 1;
                next_page = total_page;

                last_index = total_count - (pagenum - 1) * pagecount;
                first_index = last_index - pagecount + 1;
                if (first_index <= 0) {
                    first_index = 1;
                }
                if (first_index == 1) {
                    pagecount = last_index;
                }

                sql = "select * from (select * from  (select * from STUDY_AINFO where sid = '" + id + "' order by id ASC) where ID >= (select MAX(ID) from (select * from STUDY_AINFO where sid = '" + id + "' and ROWNUM <= " + last_index + " order by id) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
                rs = stmt.executeQuery(sql);
                mid = 0;
                String user_image = null, answer_name = null, answer_body = null;



                int clob_length = 0;
                JSONArray obj2 = new JSONArray();
                int index = 0;
                while (rs.next()) {
                    JSONObject obj3 = new JSONObject();
                    mid = rs.getInt("mid");

                    sql = "select name, photo from memberinfo where id = " + mid;
                    rs1 = u_stmt.executeQuery(sql);
                    answer_name = "";
                    user_image = "";
                    if (rs1.next()) {
                        answer_name = rs1.getString("name");
                        user_image = rs1.getString("photo");
                    }
                    rs1.close();

                    clob = rs.getClob("BODY");
                    clob_length = (clob == null) ? -1 : (int) clob.length();
                    if (clob_length < 0) {
                        body = "";
                    } else {
                        answer_body = clob.getSubString(1, clob_length);
                    }

                    postdate = rs.getDate("postdate");

                    Date cur_date = new Date();
                    long a = cur_date.getTime() - postdate.getTime();
                    a = a / 1000 / 3600 / 24;

                    obj3.put("name", answer_name);
                    obj3.put("body", answer_body);
                    obj3.put("imagepath", phoneImageSrc(user_image));
                    obj3.put("postdate", a);

                    obj2.add(index, obj3);
                    index++;

                }
                obj.put("data", obj2);
                obj.put("count", index);
            }
        }

        out.println(obj.toJSONString());
    }
    conn.close();
%>


