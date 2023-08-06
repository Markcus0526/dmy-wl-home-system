<%-- 
    Document   : faq
    Created on : 2014/1/17, 上午 09:48:59
    Author     : kimsui
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
    ResultSet rs = stmt.executeQuery(sql), rs1;

    if (!rs.next()) {
        obj.put("success", 0);
    } else {
        obj.put("success", 1);
        rs.close();
        String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");
        int type = Integer.parseInt(request.getParameter("type") == null ? "0" : request.getParameter("type"), 10);
        int pagenum = Integer.parseInt(spage);
        int pagecount = 8;

        Statement u_stmt = conn.createStatement();

        if (type > 0) {
            sql = "select count(*) as count from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and type =" + type + "and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
        } else {
            sql = "select count(*) as count from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
        }
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

            total_page = (total_count - 1) / pagecount + 1;
            if (pagenum > total_page) {
                obj.put("count", 0);
                out.println(obj.toJSONString());
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

        int prev_page = 1, next_page = total_page;
        if (pagenum > 1) {
            prev_page = pagenum - 1;
        }
        if (pagenum < total_page) {
            next_page = pagenum + 1;
        }

        rs1 = null;

        int last_index = total_count - (total_page - pagenum) * pagecount;
        int first_index = last_index - pagecount + 1;
        if (first_index <= 0) {
            first_index = 1;
        }
        pagecount = last_index - first_index + 1;

        if (type > 0) {
            sql = "select * from (select * from (select * from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and type = " + type + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC)  where ID >= (select MAX(ID) from (select * from  (select * from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and type = " + type + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ROWNUM <= " + last_index + "  ) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by id DESC";
        } else {
            sql = "select * from (select * from (select * from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ID >= (select MAX(ID) from (select * from (select * from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by id DESC";
        }
        rs = stmt.executeQuery(sql);

        String title = new String();
        Date postdate = new Date(1, 11, 1);

        String body = new String();
        String imagepath = new String();
        int img_index = 0;
        int id = 0, mid = 0, rewardintegral = 0;
        String username = new String();
        int clob_length = 0;
        Clob clob = null;
        JSONObject obj1[] = new JSONObject[pagecount];
        JSONArray obj2 = new JSONArray();
        int index = 0;
        int answernum = 0, readcount = 0;

        while (rs.next()) {
            id = rs.getInt("id");
            mid = rs.getInt("mid");

            sql = "Select * from memberinfo where id = " + mid;

            rs1 = u_stmt.executeQuery(sql);
            username = "";
            if (rs1.next()) {
                username = rs1.getString("name");
            }
            rs1.close();

            title = rs.getString("title");

            clob = rs.getClob("body");
            if (clob == null) {
                body = "";
            } else {
                clob_length = (int) clob.length();

                if (clob_length > 32) {
                    body = clob.getSubString(1, 32) + "...";
                } else {
                    body = clob.getSubString(1, clob_length);
                }
            }

            postdate = rs.getDate("postdate");
            rewardintegral = rs.getInt("rewardintegral");



            sql = " Select count(*) from PROBLEM_AINFO where deleted = 0 and pid = " + id;
            rs1 = u_stmt.executeQuery(sql);
            answernum = 0;
            while (rs1.next()) {
                answernum = rs1.getInt(1);
            }
            rs1.close();

            obj1[index] = new JSONObject();
            obj1[index].put("id", id);
            obj1[index].put("title", title);
            obj1[index].put("body", body);
            obj1[index].put("week", postdate.getDay());
            obj1[index].put("postdate", postdate.toString());
            obj1[index].put("rewardintegral", rewardintegral);
            obj1[index].put("answer_count", answernum);
            obj1[index].put("imagepath", phoneImageSrc(imagepath));
            obj2.add(index, obj1[index]);
            index++;
        }
         sql = "select * from integralreason where id = 14";
         rs = stmt.executeQuery(sql);
         int max_integral = 0;
         while (rs.next()) {
            max_integral = rs.getInt("DEFAULTINTEGRAL");
        }
        
        obj.put("max", max_integral);
        obj.put("count", index);
        obj.put("data", obj2);
        out.println(obj.toJSONString());
    }
    conn.close();
%>
