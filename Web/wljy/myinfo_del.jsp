<%-- 
    Document   : myinfo_del
    Created on : 2014-3-16, 10:52:32
    Author     : Hercules
--%>

<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@ include file="connection.jsp" %>
<%@page import="java.util.Date"%>
<%
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyid"))
           {
                 tmp_str=name.substring(pos+1);
                 break;
           }
       }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
  
    request.setCharacterEncoding("UTF-8");
    
    Statement stmt = conn.createStatement();
    String sql = new String();
    int id = Integer.parseInt((request.getParameter("id") == null)?"0":request.getParameter("id"), 10);
    int type = Integer.parseInt((request.getParameter("type") == null)?"0":request.getParameter("type"), 10);
    
    if (id != 0) {
        if(type == 0)
            sql = "update DATA_DOWNLOAD set deleted = 1 where id = " + id;
        else 
            sql = "update STUDY_QINFO set deleted = 1 where id = " + id;
        
        stmt.executeQuery(sql);
    }
    else
    {
        int i = 0;
        int tmpId = 0, ischeck = 0;
        for ( i = 0; i < 8; i++ )
        {
            tmpId = Integer.parseInt((request.getParameter("id_"+i) == null)?"0":request.getParameter("id_"+i), 10);
            ischeck = 0;
            if ( tmpId > 0 )
                ischeck = request.getParameter("check_"+i)==null?0:1;            
            
            if ( ischeck == 1 )
            {
                if(type == 0)
                    sql = "update DATA_DOWNLOAD set deleted = 1 where id = " + tmpId;
                else
                    sql = "update STUDY_QINFO set deleted = 1 where id = " + tmpId;
                stmt.executeQuery(sql);
            }
        }
    }

    stmt.close();
    conn.close();
     
    out.println("<script>window.location.href='myinfo.jsp?type="+type+"';</script>");

%>
