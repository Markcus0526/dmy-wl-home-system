<%-- 
    Document   : exchange_add
    Created on : Jan 7, 2014, 5:26:04 PM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@ include file="../connection.jsp" %>
<%@page language="Java" import="java.util.Date"%>
<%
    request.setCharacterEncoding("UTF-8");

    Statement stmt = conn.createStatement();
    Statement u_stmt = conn.createStatement();
    String sql = new String();
    ResultSet rs, rs1;

    String act = (request.getParameter("act") == "") ? "add" : request.getParameter("act");
    int id = Integer.parseInt((request.getParameter("id") == "") ? "0" : request.getParameter("id"), 10);
    String state = (request.getParameter("state") == "") ? "" : request.getParameter("state");
    String page_num = (request.getParameter("tmp_pagenum") == "") ? "0" : request.getParameter("tmp_pagenum");
    String page_count = (request.getParameter("tmp_pagecount") == "") ? "10" : request.getParameter("tmp_pagecount");

    if (act.equals("add")) {
        if (state.equals("2")) {
            Date tmp = new Date();
            java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
            sql = "update order_product set state = 2, receivedate = ? where deleted = 0 and id = " + id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setTimestamp(1, d);
            pstmt.execute();
        } else {
            sql = "update order_product set state = " + Integer.parseInt(state, 10) + " where deleted =0 and id = " + id;
            stmt.execute(sql);
        }

    } else if (act.equals("delete")) {
        //sql = "delete from order_product where id = " + id;
        sql = "update order_product set deleted = 1 where id = " + id;
        stmt.execute(sql);
    } else if (act.equals("deleteall")) {
        String ids = request.getParameter("ids") == null ? "" : request.getParameter("ids");
        if (ids.length() > 0) {
            String[] id_data = ids.split(",");
            if (id_data.length > 0) {
                for (int i = 0; i < id_data.length; i++) {
                    if (!id_data[i].equals("0")) {
                        sql = "update order_product set deleted = 1 where id = " + id_data[i];
                        stmt.execute(sql);
                    }

                }
            }
        }
    }

    stmt.close();
    conn.close();
    out.println("<script>window.location.href='exchange.jsp?row=" + page_count + "&page=" + page_num + "';</script>");
%>
