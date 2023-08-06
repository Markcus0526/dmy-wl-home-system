<%-- 
    Document   : contact
    Created on : 10-Dec-2013, 10:01:33
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@page import="java.util.Date"%>
<%@ include file="connection.jsp" %>

<%

    Cookie[] cookies = request.getCookies();
    String tmp_str = "";
    for (int i = 0; i < cookies.length; i++) {
        String name = cookies[i].getName();
        int pos = name.indexOf('#');
        if (pos != -1) {
            if (name.substring(0, pos).equals("wljyid")) {
                tmp_str = name.substring(pos + 1);
                break;
            }
        }
    }
    int UserId = Integer.parseInt(tmp_str, 10);

    request.setCharacterEncoding("UTF-8");

    Statement stmt = conn.createStatement();

    String sql = "select MAX(ID) from PROBLEM_QINFO";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;

    if (rs.next()) {
        newID = rs.getInt(1);
    }
    newID++;

    rs.close();

    String ques_id = (request.getParameter("question_id") == null) ? "0" : request.getParameter("question_id");
    String ques_title = (request.getParameter("ques_title") == null) ? "" : request.getParameter("ques_title");
    String ques_typestr = (request.getParameter("ques_type") == null) ? "1" : request.getParameter("ques_type");
    String ques_integral = (request.getParameter("ques_integral") == null) ? "0" : request.getParameter("ques_integral");
    if (ques_integral.equals("")) {
        ques_integral = "0";
    }
    String ques_body = (request.getParameter("ques_body") == null) ? "" : request.getParameter("ques_body");

    java.sql.NClob nclob_body = conn.createNClob();
    byte[] utf8bytes = ques_body.getBytes("UTF-8");
    nclob_body.setString(1, new String(utf8bytes, "UTF8"));

    int ques_type = 0;

    sql = "select ID, NAME from PROBLEM_TYPE";
    rs = stmt.executeQuery(sql);
    String tmpstr;
    while (rs.next()) {
        tmpstr = rs.getString("NAME");
        if (tmpstr.equals(ques_typestr)) {
            ques_type = rs.getInt("ID");
            break;
        }
    }
    rs.close();
    stmt.close();

    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

    if (ques_id.equals("0")) {
        sql = "Insert into PROBLEM_QINFO (ID, MID, TITLE, TYPE, BODY, REWARDINTEGRAL, POSTDATE, ISVISIBLE) VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, UserId);
        pstmt.setString(3, ques_title);
        pstmt.setInt(4, ques_type);
        pstmt.setNClob(5, nclob_body);
        pstmt.setInt(6, Integer.parseInt(ques_integral));
        pstmt.setTimestamp(7, d);

        pstmt.execute();
        pstmt.close();
        conn.close();
    
        out.println("<script>window.location.href='myquestion.jsp';</script>");
    } else {
        sql = "UPDATE PROBLEM_QINFO SET TITLE = ?, TYPE = ?, BODY = ?, REWARDINTEGRAL = ?, POSTDATE = ? where id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, ques_title);
        pstmt.setInt(2, ques_type);
        pstmt.setNClob(3, nclob_body);
        pstmt.setInt(4, Integer.parseInt(ques_integral));
        pstmt.setTimestamp(5, d);
        pstmt.setInt(6, Integer.parseInt(ques_id));

        pstmt.execute();
        pstmt.close();
        conn.close();
    
        out.println("<script>window.location.href='myquestion.jsp';</script>");
    }
    
%>
