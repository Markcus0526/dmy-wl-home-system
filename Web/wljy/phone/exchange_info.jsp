<%-- 
    Document   : exchange_info
    Created on : 2014/1/24, 上午 10:12:21
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
        Statement u_stmt = conn.createStatement();
        String id = request.getParameter("id") == null ? "0" : request.getParameter("id");

        sql = "select * from PRODUCT_INFO where id = " + id;
        rs = stmt.executeQuery(sql);

        String name = new String();
        String body = new String();
        String imagepath = new String();
        String property = new String();
        String detail = new String();
        String[] sub_image = new String[7];

        int uid = 0, iid = 0, market_price = 0, integral_price = 0;
        int total_exchange = 0, total_secure = 0, count = 0;
        int index = 0;
        Clob clob = null;
        int clob_length = 0;

        while (rs.next()) {
            name = rs.getString("name");
            iid = rs.getInt("iid");

            sql = "Select * from product_image where id = " + iid;
            rs1 = u_stmt.executeQuery(sql);
            imagepath = "";
            if (rs1.next()) {
                imagepath = rs1.getString("datapath");
            }
            rs1.close();

            sql = "select * from product_image where pid = " + id + " and ismain=0 order by id";
            rs1 = u_stmt.executeQuery(sql);
            JSONArray obj1 = new JSONArray();
            obj1.add(0, phoneImageSrc(imagepath));
            index = 1;
            while (rs1.next()) {
                if (index == 7) {
                    break;
                }
                sub_image[index] = rs1.getString("datapath");
                if (sub_image[index] != null && !sub_image[index].equals("null")) {
                    obj1.add(index, phoneImageSrc(sub_image[index]));
                    index++;
                }
            }
            rs1.close();

            market_price = rs.getInt("market_price");
            integral_price = rs.getInt("integral_price");
            total_exchange = rs.getInt("total_exchange");
            total_secure = rs.getInt("total_secure");

            count = 0;

            clob = rs.getClob("property");
            clob_length = (clob == null) ? -1 : (int) clob.length();

            if (clob_length < 0) {
                property = "";
            } else {
                property = clob.getSubString(1, clob_length);
            }

            clob = rs.getClob("detail");
            clob_length = (clob == null) ? -1 : (int) clob.length();
            if (clob_length < 0) {
                detail = "";
            } else {
                detail = clob.getSubString(1, clob_length);
            }



            obj.put("title", name);
            obj.put("market_price", market_price);
            obj.put("integral_price", integral_price);
            obj.put("total_exchange", total_exchange);
            obj.put("total_secure", total_secure);
            obj.put("property", property);
            //obj.put("main_image", imagepath);
            //obj.put("sub_image", obj1);
            obj.put("imagepath", obj1);
        }
        out.println(obj.toJSONString());
    }
    conn.close();
%>
