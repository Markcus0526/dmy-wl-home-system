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

        sql = "select count(*) as count from collection_info where TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR')";
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

        sql = "select * from (select * from (select * from collection_info where TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by id) where ID >= (select MAX(ID) from (select * from (select * from collection_info where TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
        rs = stmt.executeQuery(sql);

        String title = new String();
        Date postdate = new Date(1, 11, 1);
        int readcount = 0;
        String body = new String();
        String imagepath = new String();
        int img_index = 0;
        int id = 0, mid = 0, eval_count = 0;
        String act_user = new String();
        int clob_length = 0;
        Clob clob = null;
        JSONObject obj1[] = new JSONObject[pagecount];
        JSONArray obj2 = new JSONArray();
        int index = 0;
        int type = 0;
        int pid = 0;
        while (rs.next()) {
            id = rs.getInt("id");
            mid = rs.getInt("mid");
            pid = rs.getInt("pid");
            type = rs.getInt("type");
            if (type == 1) {
                sql = "select title from activity_info where id = " + pid;
            } else if (type == 2) {
                sql = "select title from share_info where id = " + pid;
            }


            rs1 = u_stmt.executeQuery(sql);
            title = "";
            if (rs1.next()) {
                title = rs1.getString(1);
            }
            rs1.close();


            obj1[index] = new JSONObject();
            obj1[index].put("id", id);
            obj1[index].put("title", title);
            obj1[index].put("type", type);

            obj2.add(index, obj1[index]);
            index++;
        }
        obj.put("count", index);
        obj.put("data", obj2);
        out.println(obj.toJSONString());
    }
    conn.close();
%>
