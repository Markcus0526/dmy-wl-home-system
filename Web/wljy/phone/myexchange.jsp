<%-- 
    Document   : myexchange
    Created on : 2014/1/23, 下午 04:32:07
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
    ResultSet rs = stmt.executeQuery(sql), rs1, rs2;

    if (!rs.next()) {
        obj.put("success", 0);
    } else {
        obj.put("success", 1);
        rs.close();
        String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");

        int pagenum = Integer.parseInt(spage);
        int pagecount = 8;


        Statement u_stmt = conn.createStatement();
        Statement u_stmt1 = conn.createStatement();

        sql = "select count(*) as count from ORDER_PRODUCT where deleted = 0 and mid = " + userid + " and TO_CHAR(orderdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
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

        sql = "select * from (select * from (select * from ORDER_PRODUCT where deleted = 0 and mid = " + userid + " and TO_CHAR(orderdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by pid ASC) where pid >= (select MAX(PID) from (select * from (select * from ORDER_PRODUCT where deleted = 0 and mid = " + userid + " and TO_CHAR(orderdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by pid ASC) where ROWNUM <= " + last_index + " order by pid) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by pid DESC";
        rs = stmt.executeQuery(sql);

        String title = new String();
        Date postdate = new Date(1, 11, 1);
        int readcount = 0;

        String imagepath = new String();

        String body = new String();

        int img_index = 0;
        int id = 0, integral_price = 0, state = 0;
        String exchange_state = new String();
        int clob_length = 0;
        Clob clob = null;


        JSONArray obj1 = new JSONArray();
        JSONObject obj2[] = new JSONObject[pagecount];

        int index = 0, iid = 0, market_price = 0;
        String name = new String();

        while (rs.next()) {

            id = rs.getInt("pid");

            sql = "select * from PRODUCT_INFO where deleted = 0 and id = " + id;
            rs1 = u_stmt.executeQuery(sql);
            name = "";
            iid =  0;
            imagepath = "";
            market_price = 0;
            integral_price = 0;
            if (rs1.next()) {
                name = rs1.getString("name");
                iid = rs1.getInt("iid");

                sql = "select * from product_image where id = " + iid;
                rs2 = u_stmt1.executeQuery(sql);
                imagepath = "";
                while (rs2.next()) {
                    imagepath = rs2.getString(3);
                }
                rs2.close();

                market_price = rs1.getInt("market_price");
                integral_price = rs1.getInt("integral_price");
            }
            rs1.close();

            state = rs.getInt("state");
            switch (state) {
                case 0:
                    exchange_state = "产品邀请";
                    break;
                case 1:
                    exchange_state = "等待受理";
                    break;
                case 2:
                    exchange_state = "已受理可领取";
                    break;
                default:
                    exchange_state = "没有兑换";
            }


            obj2[index] = new JSONObject();
            obj2[index].put("id", id);
            obj2[index].put("title", name);
            obj2[index].put("market_price", market_price);
            obj2[index].put("integral_price", integral_price);
            obj2[index].put("imagepath", phoneImageSrc(imagepath));
            obj2[index].put("state", exchange_state);



            obj1.add(index, obj2[index]);
            index++;
        }
        obj.put("count", index);
        obj.put("data", obj1);
        out.println(obj.toJSONString());
    }
    conn.close();
%>
