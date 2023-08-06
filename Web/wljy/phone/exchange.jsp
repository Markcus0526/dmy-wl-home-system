<%-- 
    Document   : exchange
    Created on : 2014/1/17, 上午 09:57:38
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

        switch (type) {
            case 0:
                sql = "select count(*) as count from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 0 and MARKET_PRICE <= 2000";
                break;
            case 1:
                sql = "select count(*) as count from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 2001 and MARKET_PRICE <= 8000";
                break;
            case 2:
                sql = "select count(*) as count from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 8001 and MARKET_PRICE <= 10000";
                break;
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

        switch (type) {
            case 0:
                sql = "select * from (select * from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 0 and MARKET_PRICE <= 2000 order by id) where ID >= (SELECT MAX(ID) from (select * from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 0 and MARKET_PRICE <= 2000 order by id) where ROWNUM <= " + first_index + ") and ROWNUM <= " + pagecount + " order by id desc";
                break;
            case 1:
                sql = "select * from (select * from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 2001 and MARKET_PRICE <= 8000 order by id) where ID >= (SELECT MAX(ID) from (select * from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 2001 and MARKET_PRICE <= 8000 order by id) where ROWNUM <= " + first_index + ") and ROWNUM <= " + pagecount + " order by id desc";
                break;
            case 2:
                sql = "select * from (select * from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 8001 and MARKET_PRICE <= 10000 order by id) where ID >= (SELECT MAX(ID) from (select * from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 8001 and MARKET_PRICE <= 10000 order by id) where ROWNUM <= " + first_index + ") and ROWNUM <= " + pagecount + " order by id desc";
                break;
        }
        rs = stmt.executeQuery(sql);

        String name = new String();
        Date postdate = new Date(1, 11, 1);

        String body = new String();
        String imagepath = new String();
        int img_index = 0;
        int id = 0, iid = 0, rewardintegral = 0;

        int clob_length = 0;
        Clob clob = null;
        JSONObject obj1[] = new JSONObject[pagecount];
        JSONArray obj2 = new JSONArray();
        int index = 0;
        int market_price = 0, integral_price = 0;

        while (rs.next()) {
            id = rs.getInt("id");
            name = rs.getString("name");
            iid = rs.getInt("iid");

            imagepath = "";
            sql = "select * from product_image where id = " + iid;
            rs1 = u_stmt.executeQuery(sql);
            if (rs1.next()) {
                imagepath = rs1.getString(3);
            }
            rs1.close();

            market_price = rs.getInt("market_price");
            integral_price = rs.getInt("integral_price");

            obj1[index] = new JSONObject();
            obj1[index].put("id", id);
            obj1[index].put("name", name);
            obj1[index].put("market_price", market_price);
            obj1[index].put("integral_price", integral_price);
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
