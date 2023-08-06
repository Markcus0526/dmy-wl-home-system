<%-- 
    Document   : single_info
    Created on : 2014-2-5, 11:12:17
    Author     : Hercules
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

        sql = "select * from ACTIVITY_INFO where deleted = 0 and ID = " + id;
        rs = stmt.executeQuery(sql);

        String title = new String();
        String body = new String();
        int eval_upcount = 0;
        int eval_downcount = 0;

        String answerer_name = new String();
        Date answer_date = new Date(1, 11, 1);
        long answer_datebefore = 0;
        String answer_body = new String();
        String imagepath = new String();
        int good_cnt = 0;
        int bad_cnt = 0;

        Clob clob = null;
        int clob_length = 0;
        int mid = 0;

        if (rs.next()) {
            title = rs.getString("TITLE");
            good_cnt = rs.getInt("GOOD");
            bad_cnt = rs.getInt("BAD");

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
            sql = "select * from ACTIVITY_EVAL where AID = " + id + " order by ID DESC";
            rs = stmt.executeQuery(sql);

            int haveEval = 0;

            if (rs.next()) {
                mid = rs.getInt("MID");
                Statement u_stmt = conn.createStatement();
                sql = "select * from MEMBERINFO where id = " + mid;
                ResultSet rs1 = u_stmt.executeQuery(sql);
                if (rs1.next()) {
                    answerer_name = rs1.getString("NAME");
                    imagepath = rs1.getString("PHOTO");
                }
                u_stmt.close();

                answer_date = rs.getDate("POSTDATE");

                Date cur_date = new Date();
                long a = cur_date.getTime() - answer_date.getTime();
                answer_datebefore = a / 1000 / 3600 / 24;

                clob = rs.getClob("BODY");
                clob_length = (clob == null) ? -1 : (int) clob.length();
                if (clob_length < 0) {
                    answer_body = "";
                } else {
                    answer_body = clob.getSubString(1, clob_length);
                }

                haveEval = 1;
            }
            rs.close();
            stmt.close();

            obj.put("title", title);
            obj.put("body", body);
            obj.put("evalup_count", good_cnt);
            obj.put("evaldown_count", bad_cnt);
            obj.put("have_answer", haveEval);
            obj.put("answerer_name", answerer_name);
            obj.put("answer_date", answer_datebefore);
            obj.put("answer_body", answer_body);
            obj.put("imagepath", phoneImageSrc(imagepath));
        }
    }

    conn.close();
    out.println(obj.toJSONString());
%>
