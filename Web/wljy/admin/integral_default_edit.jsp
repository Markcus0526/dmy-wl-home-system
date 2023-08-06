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
    
    request.setCharacterEncoding("UTF-8");
    
    Statement stmt;
    Statement u_stmt = conn.createStatement();
    String sql = new String();
    ResultSet rs;
    
    int reason_cnt = 0;
    sql = "select count(*) as cnt from INTEGRALREASON";
    rs = u_stmt.executeQuery(sql);
    if ( rs.next() )
        reason_cnt = rs.getInt("cnt");
    rs.close();
    u_stmt.close();
    
    String[] reason_string = new String[reason_cnt];
    int[] reason_value = new int[reason_cnt];
    int[] reason_id = new int[reason_cnt];
    int i = 0;
    
    if (reason_cnt > 0)
    {
        sql = "select * from INTEGRALREASON order by id asc";
        u_stmt = conn.createStatement();
        rs = u_stmt.executeQuery(sql);
        while ( rs.next() )
        {
            reason_id[i] = rs.getInt("ID");
            reason_string[i] = rs.getString("REASON");
            reason_value[i] = rs.getInt("DEFAULTINTEGRAL");
            i++;
        }
    }
    
    rs.close();
    
    int changed_value = 0;
    
    for ( i = 0; i < reason_cnt; i++ )
    {
        changed_value = Integer.parseInt(request.getParameter("integral_"+i)== null?"0":request.getParameter("integral_"+i), 10);
        if ( changed_value != reason_value[i] )
        {
            stmt = conn.createStatement();
            sql = "UPDATE INTEGRALREASON SET DEFAULTINTEGRAL = "+changed_value+" WHERE id = "+reason_id[i];
            stmt.execute(sql);
            stmt.close();
        }
    }
    
    out.println("<script>window.location.href='integral.jsp?';</script>");

               
%>
