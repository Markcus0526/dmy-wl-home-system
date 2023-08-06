<%-- 
    Document   : mycartee
    Created on : 2014/2/11, 上午 09:22:31
    Author     : kimsui
--%>

<%@page import="org.json.simple.JSONArray"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="org.json.simple.JSONObject"%>
<%@ include file="../connection.jsp" %>
<%@page import="java.util.Date"%>
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
        int product_id = Integer.parseInt(request.getParameter("product_id") == null ? "0" : request.getParameter("product_id"));
        int exchange_count = Integer.parseInt(request.getParameter("exchange_count") == null ? "0" : request.getParameter("exchange_count"));
        int product_integral = Integer.parseInt(request.getParameter("product_integral") == null ? "0" : request.getParameter("product_integral"));

        PreparedStatement pstmt;
        sql = "select count(*) as count from ORDER_PRODUCT where mid = " + userid + " and state = 0 and pid = " + product_id;
        rs = stmt.executeQuery(sql);
        int cur_cnt = 0;
        int newId = 0;
        if (rs.next()) {
            cur_cnt = rs.getInt("count");

            if (cur_cnt == 0) {
                sql = "select MAX(ID) as NEWID from ORDER_PRODUCT";
                rs1 = stmt.executeQuery(sql);
                if (rs1.next()) {
                    newId = rs1.getInt("NEWID");
                }

                newId++;

                sql = "INSERT INTO ORDER_PRODUCT (ID, PID, MID, COUNT, PRICE, ORDERDATE, STATE) VALUES(?, ?, ?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, newId);
                pstmt.setInt(2, product_id);
                pstmt.setInt(3, Integer.parseInt(userid, 10));
                pstmt.setInt(4, exchange_count);
                pstmt.setInt(5, product_integral);
                Date tmp = new Date();
                java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
                pstmt.setTimestamp(6, d);
                pstmt.setInt(7, 0);
                pstmt.execute();
                pstmt.close();
            } else {
                sql = "UPDATE ORDER_PRODUCT SET COUNT = COUNT + ? where mid = " + userid + " and state = 0 and pid = " + product_id;
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, exchange_count);
                pstmt.execute();
                pstmt.close();
            }

            sql = "UPDATE PRODUCT_INFO SET TOTAL_SECURE = TOTAL_SECURE - ? where id = " + product_id;
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, exchange_count);
            pstmt.execute();
            pstmt.close();

        }
    }
    out.println(obj.toJSONString());
    conn.close();

%>