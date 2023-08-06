<%-- 
    Document   : faq_addinfo
    Created on : Jan 4, 2014, 2:36:25 PM
    Author     : Hercules
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page language="Java" import="java.util.Date"%>
<%@include file="cookie_check.jsp" %>
<%@include file="../connection.jsp" %>
<%    
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyadminid"))
           {
                 tmp_str=name.substring(pos+1);
                 break;
           }
       }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
    
    request.setCharacterEncoding("UTF-8");
    
    String spage = request.getParameter("page"); if(spage == null) spage = "1";
    String scount = request.getParameter("count"); if(spage == null) scount = "10";
    
   
    
    String strId = request.getParameter("id");
    
        
 
        if(strId != null) {
            int id = Integer.parseInt(strId);
            
            Statement stmt = conn.createStatement();
         
            String sql = "delete from memberloginlist where id = " + id;
            ResultSet rs = stmt.executeQuery(sql);
            rs.close();
        }              
  
        
    conn.close();
      
    out.println("<script>window.location.href='loginlist.jsp?page=" + spage + "&count=" + scount + "';</script>");
%>

