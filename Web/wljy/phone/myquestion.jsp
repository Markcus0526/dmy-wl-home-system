<%-- 
    Document   : myfaq
    Created on : 2014/1/23, 下午 04:03:55
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
        String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");

        int pagenum = Integer.parseInt(spage);
        int pagecount = 8;


        Statement u_stmt = conn.createStatement();

        sql = "select count(*) as count from problem_qinfo where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and mid = " + userid;
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

        sql = "select * from (select * from (select * from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and mid = '" + userid + "' order by id) where ID >= (select MAX(ID) from (select * from (select * from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and mid = '" + userid + "' order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
        rs = stmt.executeQuery(sql);

        String title = new String();
        //Date postdate = new Date(1,11,1);
        String postdate = new String();
        int readcount = 0;

        String imagepath = new String();

        String body = new String();

        int img_index = 0;
        int id = 0, mid = 0, eval_count = 0;
        String act_user = new String();
        int clob_length = 0;
        Clob clob = null;


        JSONArray obj1 = new JSONArray();
        JSONObject obj2[] = new JSONObject[pagecount];

        int index = 0, rewardintegral = 0, ans_count = 0;
        String ans_name = new String();

        while (rs.next()) {

            id = rs.getInt("id");
            title = rs.getString("title");
            rewardintegral = rs.getInt("rewardintegral");
            postdate = rs.getString("postdate");
            postdate = postdate.substring(5, 7) + ". " + postdate.substring(8, 10);
            readcount = rs.getInt("readcount");

            clob = rs.getClob("body");
            clob_length = (clob == null) ? -1 : (int) clob.length();
            if (clob_length < 0) {
                body = "";
            } else {
                body = clob.getSubString(1, clob_length);
            }

            sql = "select count(*) as count from problem_ainfo where deleted = 0 and pid = " + id;
            rs1 = u_stmt.executeQuery(sql);
            ans_count = 0;
            if (rs1.next()) {
                ans_count = rs1.getInt("count");
            }
            rs1.close();

            sql = "select MAX(id) from problem_ainfo where pid = " + id;
            rs1 = u_stmt.executeQuery(sql);
            int aid = 0;
            if (rs1.next()) {
                aid = rs1.getInt(1);
            }
            rs1.close();

            int auserid = 0;
            sql = "select mid from problem_ainfo where id = " + aid;
            rs1 = u_stmt.executeQuery(sql);
            if (rs1.next()) {
                auserid = rs1.getInt(1);
            }
            rs1.close();

            sql = "select name from memberinfo where id = " + auserid;
            rs1 = u_stmt.executeQuery(sql);
            ans_name = "";
            if (rs1.next()) {
                ans_name = rs1.getString("name");
            }
            rs1.close();


            obj2[index] = new JSONObject();
            obj2[index].put("id", id);
            obj2[index].put("title", title);
            obj2[index].put("postdate", postdate);
            obj2[index].put("read_count", readcount);
            obj2[index].put("answer_count", ans_count);
            obj2[index].put("answerer_name", ans_name);
            obj2[index].put("body", body);

            obj1.add(index, obj2[index]);
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
        obj.put("data", obj1);
        out.println(obj.toJSONString());
    }
    conn.close();
%>

