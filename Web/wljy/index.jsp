

<%@page contentType="text/html" pageEncoding="UTF-8"%>

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
                if(name.substring(0, pos).equals("wljyid")) {
                    user_name=name.substring(pos+1);
                    break;
                }
            }            
        }
    }
    
    if(user_name.length() == 0)
       out.println("<script>window.location.href='login.jsp';</script>");  
     else
       out.println("<script>window.location.href='main.jsp';</script>");     
           
 %>
