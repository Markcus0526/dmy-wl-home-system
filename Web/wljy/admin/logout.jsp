<%-- 
    Document   : logout
    Created on : Jan 9, 2014, 3:26:11 PM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<%
    Cookie[] cookies = request.getCookies();
    String user_name= new String();
    
    if (cookies != null && cookies.length != 0) {
        String name = new String();
        int pos = -1;
        
        for(int i = 0;i< cookies.length;i++) {         
             name = cookies[i].getName();
             pos = name.indexOf('#');
       
             if(pos != -1) {
                if(name.substring(0, pos).equals("wljyadmin") || name.substring(0, pos).equals("wljyadminid")) {
                    user_name=name.substring(pos+1);
                    Cookie cookie = new Cookie(name, "");
                    cookie.setMaxAge(0);
                    response.addCookie(cookie);                    
                }                               
            }
            
        }
    }
    out.println("<script>window.location.href='index.jsp';</script>");
%>

