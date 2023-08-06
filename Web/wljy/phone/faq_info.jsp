<%-- 
    Document   : faq_info
    Created on : 2014/1/25, 下午 02:45:35
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
    String sql = "select * from MEMBERINFO where deleted = 0 and ID =" + Integer.parseInt(userid, 10);
    ResultSet rs = stmt.executeQuery(sql), rs1, rs2;

    if (!rs.next()) {
        obj.put("success", 0);
    } else {
        obj.put("success", 1);
        rs.close();
        Statement u_stmt = conn.createStatement();
        Statement u_stmt1 = conn.createStatement();
        String id = request.getParameter("id") == null ? "0" : request.getParameter("id");

        String title = new String();
        String provider_name = new String();
        int rewardintegral = 0;
        String body = new String();
        Date postdate = new Date(1, 11, 1);
        int answer_count = 0;
        String type = new String();
        int read_count = 0;

        String answerer_name = new String();
        Date answer_date = new Date(1, 11, 1);
        String answer_body = new String();
        String imagepath = new String();

        int good_cnt = 0;
        int bad_cnt = 0;

        int mid = 0;
        int itype = 0;
        Clob clob = null;
        int clob_len = 0;

        sql = "Select * from PROBLEM_QINFO where deleted = 0 and ID =" + id;
        rs = stmt.executeQuery(sql);
        if (rs.next()) {
            read_count = rs.getInt("readcount") + 1;
        }
        rs.close();

        sql = "update PROBLEM_QINFO set readcount = readcount + 1 where ID = " + id;
        stmt.executeUpdate(sql);

        sql = "select * from PROBLEM_QINFO where ID = " + id;
        rs = stmt.executeQuery(sql);

        while (rs.next()) {
            title = rs.getString("TITLE");
            good_cnt = rs.getInt("GOOD");
            bad_cnt = rs.getInt("BAD");

            mid = rs.getInt("MID");
            if (mid != 0) {
                sql = "Select * from MEMBERINFO where ID = " + mid;
                rs1 = u_stmt.executeQuery(sql);
                provider_name = "";
                if (rs1.next()) {
                    provider_name = rs1.getString("NAME");
                }
                rs1.close();
            } else {
                provider_name = "管理者";
            }

            itype = rs.getInt("TYPE");
            sql = "select * from PROBLEM_TYPE where ID = " + itype;
            rs1 = u_stmt.executeQuery(sql);
            type = "";
            while (rs1.next()) {
                type = rs1.getString("NAME");
            }
            rs1.close();

            clob = rs.getClob("BODY");
            clob_len = (clob == null) ? -1 : (int) clob.length();
            if (clob_len < 0) {
                body = "";
            } else {
                body = clob.getSubString(1, clob_len);
            }

            rewardintegral = rs.getInt("REWARDINTEGRAL");
            postdate = rs.getDate("POSTDATE");
            read_count = rs.getInt("READCOUNT");

            sql = "select count(*) as COUNT from PROBLEM_AINFO where PID = " + id;
            rs1 = u_stmt.executeQuery(sql);
            answer_count = 0;
            if (rs1.next()) {
                answer_count = rs1.getInt("COUNT");
            }

            obj.put("title", title);
            obj.put("provider_name", provider_name);
            obj.put("rewardintegral", rewardintegral);
            obj.put("body", body);
            obj.put("postdate", postdate.toString());
            obj.put("answer_count", answer_count);
            obj.put("type", type);
            obj.put("read_count", read_count);
            obj.put("good_cnt", good_cnt);
            obj.put("bad_cnt", bad_cnt);
        }
        rs.close();

        sql = "select * from PROBLEM_AINFO where deleted = 0 and PID = " + id + " order by ID DESC";
        rs1 = u_stmt.executeQuery(sql);
        if (rs1.next()) {
            mid = rs1.getInt("MID");
            sql = "select NAME, PHOTO from MEMBERINFO where ID = " + mid;
            rs2 = u_stmt1.executeQuery(sql);
            answerer_name = "";
            imagepath = "";
            if (rs2.next()) {
                answerer_name = rs2.getString("NAME");
                imagepath = rs2.getString("PHOTO");
            }
            rs2.close();

            clob = rs1.getClob("BODY");
            clob_len = (clob == null) ? -1 : (int) clob.length();
            if (clob_len < 0) {
                body = "";
            } else {
                answer_body = clob.getSubString(1, clob_len);
            }

            answer_date = rs1.getDate("POSTDATE");
            Date cur_date = new Date();
            long a = cur_date.getTime() - answer_date.getTime();
            a = a / 1000 / 3600 / 24;

            obj.put("answerer_name", answerer_name);
            obj.put("imagepath", phoneImageSrc(imagepath));
            obj.put("answer_body", answer_body);
            obj.put("answer_date", a);
        }
        u_stmt.close();
    }

    rs.close();
    stmt.close();
    conn.close();
    out.println(obj.toJSONString());
%>

