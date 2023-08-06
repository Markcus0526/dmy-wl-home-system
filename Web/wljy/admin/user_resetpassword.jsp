<%-- 
    Document   : user_add
    Created on : Jan 9, 2014, 2:52:03 PM
    Author     : KIMSUI
--%>

<%@page import="jxl.Cell"%>
<%@page import="jxl.Sheet"%>
<%@page import="jxl.Workbook"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.File"%>

<%@include file="cookie_check.jsp" %>
<%@ include file="../connection.jsp" %>
<%@page import="java.util.Date"%>
<%
	
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
         if(name.substring(0, pos).equals("wljyadminid")) {
             tmp_str=name.substring(pos+1);
             break;
         }
       }
    }

    int UserId = Integer.parseInt(tmp_str, 10);

    request.setCharacterEncoding("UTF-8");
    
    Statement stmt = conn.createStatement();
    String sql = new String();
    ResultSet rs;
    
    String password = (request.getParameter("password") == null)?"123456":request.getParameter("password");

    int id = Integer.parseInt((request.getParameter("id") == null)?"0":request.getParameter("id"), 10);
        
	sql = "update MEMBERINFO set password = ? where id=" + id;
	PreparedStatement pstmt = conn.prepareStatement(sql); 
	pstmt.setString(1, password);

	pstmt.execute();
	pstmt.close();       

    conn.close();
     
    out.println("1");

%>
