<%-- 
    Document   : group_activity.jsp
    Created on : 2014/1/16, 上午 10:20:13
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
        int type = Integer.parseInt(request.getParameter("type") == null ? "2" : request.getParameter("type"), 10);
        int pagenum = Integer.parseInt(spage);
        int pagecount = 8;


        Statement u_stmt = conn.createStatement();

        sql = "select count(*) as count from ACTIVITY_INFO where deleted = 0 and type = " + type + " and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR')";
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

        sql = "select * from (select * from (select * from ACTIVITY_INFO where deleted = 0 and type = " + type + " and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by id) where ID >= (select MAX(ID) from (select * from (select * from ACTIVITY_INFO where deleted = 0 and  type = " + type + " and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
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
        JSONArray obj1 = new JSONArray();
        JSONObject obj2[] = new JSONObject[pagecount];

        int index = 0;
        int img_count = 0;
        while (rs.next()) {            
            id = rs.getInt("id");
            mid = rs.getInt("mid");

            sql = "Select * from memberinfo where id = " + mid;
            rs1 = u_stmt.executeQuery(sql);
            act_user = "";
            while (rs1.next()) {
                act_user = rs1.getString("name");
            }
            rs1.close();

            title = rs.getString("title");

            sql = "Select * from activity_image where aid = " + id;
            rs1 = u_stmt.executeQuery(sql);

            JSONArray obj3 = new JSONArray();
            img_count = 0;
            while (rs1.next()) {
                imagepath = "";
                imagepath = rs1.getString("datapath");
                obj3.add(img_count, phoneImageSrc(imagepath));
                img_count++;
                if (img_count == 3) {
                    break;
                }
            }
            rs1.close();

            clob = rs.getClob("body");
            clob_length = (clob == null) ? -1 : (int) clob.length();

            if (clob_length < 0) {
                body = "";
            } else if (clob_length > 32) {
                body = clob.getSubString(1, 32) + "...";
            } else {
                body = clob.getSubString(1, clob_length);
            }

            postdate = rs.getDate("postdate");
            readcount = rs.getInt("readcount");

            sql = "select count(*) as count from activity_eval where aid = " + id;
            rs1 = u_stmt.executeQuery(sql);
            eval_count = 0;
            if (rs1.next()) {
                eval_count = rs1.getInt("count");
            }
            rs1.close();

            obj2[index] = new JSONObject();
            obj2[index].put("id", id);
            obj2[index].put("title", title);
            obj2[index].put("body", body);
            obj2[index].put("postdate", postdate.toString());
            obj2[index].put("eval_count", eval_count);
            obj2[index].put("read_count", readcount);
            obj2[index].put("imagepath", obj3);

            obj1.add(index, obj2[index]);
            index++;
        }
        obj.put("count", index);
        obj.put("data", obj1);
        out.println(obj.toJSONString());        
    }
    conn.close();
%>
