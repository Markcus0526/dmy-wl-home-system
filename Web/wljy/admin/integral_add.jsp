<%-- 
    Document   : integral_add
    Created on : Jan 5, 2014, 12:19:21 PM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@ include file="../connection.jsp" %>
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
    
    String page_num = (request.getParameter("tmp_pagenum") == "")?"0":request.getParameter("tmp_pagenum");
    String page_count = (request.getParameter("tmp_pagecount") == "")?"10":request.getParameter("tmp_pagecount");
    String add_data = (request.getParameter("add_data") == null)?"":request.getParameter("add_data");
    int add_cnt = Integer.parseInt((request.getParameter("add_cnt") == null)?"0":request.getParameter("add_cnt"), 10);
    int id = Integer.parseInt((request.getParameter("id") == null)?"":request.getParameter("id"),10);
    String []split_data = new String[add_cnt]; 
    split_data = add_data.split(":", add_cnt);
    String []data = new String[2];
    int sum = 0, integral = 0;
    for (int i = 0; i < add_cnt;i++) {
        data = split_data[i].split("&");
        data[1] = data[1].replace(":", "");
        sql = "update integrallog set gainintegral = " + Integer.parseInt(data[1], 10) + ", enabled = 1 where id=" + data[0];
        stmt.execute(sql);        
        sum += Integer.parseInt(data[1], 10);
    }
    sql = "select integral from memberinfo where id=" + id;
    rs = stmt.executeQuery(sql);
    
    if (rs.next())
        integral = rs.getInt(1);
    rs.close();
    
    integral += sum;
    sql = "update memberinfo set integral = " + integral + " where id = " + id;
    stmt.execute(sql);
    
    
    out.println("<script>window.location.href='integral_info.jsp?id=" + id + "&row="+page_count+"&page="+page_num+"';</script>");

               
%>
