<%-- 
    Document   : mycartee
    Created on : 2014/2/11, 上午 09:22:31
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
    ResultSet rs = stmt.executeQuery(sql), rs1, rs2;

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

        sql = "select count(*) as count from ORDER_PRODUCT where deleted = 0 and mid = " + userid + " and state = 0";
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

        int last_index = total_count - (total_page - pagenum) * pagecount;
        int first_index = last_index - pagecount + 1;
        if (first_index <= 0) {
            first_index = 1;
        }
        pagecount = last_index - first_index + 1;

        sql = "select * from (select * from (select * from ORDER_PRODUCT where deleted = 0 and mid = " + userid + " and state = 0 order by id ASC) where id >= (select MAX(ID) from (select * from (select * from ORDER_PRODUCT where deleted = 0 and mid = " + userid + " and state = 0 order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by id DESC";
        rs = stmt.executeQuery(sql);

        String name = new String();
        int id = 0, pid = 0, iid = 0;
        String username = new String();
        String imagepath = new String();
        int market_price = 0, integral_price = 0, product_count = 0;;
        String exchange_state = null;
        int state;

        Statement u_stmt1 = conn.createStatement();
        int tmpInd = 0;
        int index = 0;
        JSONObject obj1[] = new JSONObject[pagecount];
        JSONArray obj2 = new JSONArray();
        while (rs.next()) {
            id = rs.getInt("id");
            pid = rs.getInt("pid");
            product_count = rs.getInt("COUNT");

            sql = "select * from PRODUCT_INFO where deleted = 0 and id = " + pid;
            rs1 = u_stmt.executeQuery(sql);
            name = "";
            iid = 0;
            market_price = 0;
            integral_price = 0;
            if (rs1.next()) {
                name = rs1.getString("name");
                iid = rs1.getInt("iid");

                sql = "select * from product_image where id = " + iid;
                rs2 = u_stmt1.executeQuery(sql);
                imagepath = "";
                if (rs2.next()) {
                    imagepath = rs2.getString(3);
                }
                rs2.close();

                market_price = rs1.getInt("market_price");
                integral_price = rs1.getInt("integral_price");
            }
            rs1.close();

            state = rs.getInt("state");

            obj1[index] = new JSONObject();
            obj1[index].put("id", id);
            obj1[index].put("name", name);
            obj1[index].put("market_price", market_price);
            obj1[index].put("integral_price", integral_price * product_count);
            obj1[index].put("imagepath", phoneImageSrc(imagepath));
            obj2.add(index, obj1[index]);
            index++;

        }
        obj.put("count", index);
        obj.put("data", obj2);
        out.println(obj.toJSONString());
    }
    conn.close();
%>
