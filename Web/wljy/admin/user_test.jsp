<%-- 
    Document   : user_test.jsp
    Created on : Dec 28, 2013, 11:05:13 AM
    Author     : Hercules
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<%@ include file="../connection.jsp" %>
<%@page import="java.util.Date"%>
<%
    request.setCharacterEncoding("UTF-8");
       Cookie[] cookies = request.getCookies();
    String tmp_str= "";
	if (cookies != null && cookies.length > 0)
	{
		for(int i = 0;i<cookies.length;i++) {
		   String name=cookies[i].getName();
		   int pos=name.indexOf('#');
		   if(pos != -1) {
			   if(name.substring(0, pos).equals("wljyadmin"))
			   {
					 tmp_str=name.substring(pos+1);
					 break;
			   }
		   }
		}
	}
    
   String userid = request.getParameter("username");
   userid = userid.replace("'", "");
   String password = request.getParameter("password");
   password = password.replace("'", "");
   String strIPAddress = request.getRemoteAddr();
   if (tmp_str.equals(userid)) {
       out.println("<script>window.location.href='system.jsp';</script>");  
   }
   Statement stmt = conn.createStatement();   
   
   String sql = "select * from managerinfo where deleted = 0 and USERID ='" + userid + "' and PASSWORD='" + password + "'";   
   ResultSet rs = stmt.executeQuery(sql);
   
   int login = 0;
   
   while (rs.next()) {
       login = rs.getInt("id");
   }
   rs.close();

   if (login == 0){
       out.println("<script>alert('用户ID及密码有错误');</script>");
       out.println("<script>window.location.href='index.jsp';</script>");
   }
   else {       
       sql = "update managerinfo set lastlogindate = ?, registipaddress = ? where deleted = 0 and id=" + login;
       PreparedStatement pstmt = conn.prepareStatement(sql); 
       Date tmp = new Date();
       java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);       
	   pstmt.setTimestamp(1, d);
	   pstmt.setString(2, strIPAddress);
       pstmt.execute();
       pstmt.close();
       
       HttpSession sess=request.getSession(true);
       session.setMaxInactiveInterval(12*60*60);
       userid = "wljyadmin#" + userid;       
       String s = sess.getId();  

       Cookie cookie = new Cookie(userid ,s);
       cookie.setMaxAge(60*60*12);
       userid = "wljyadminid#" + login;
       Cookie cookie1 = new Cookie(userid, s);
       cookie1.setMaxAge(60*60*12);
       response.addCookie(cookie);
       response.addCookie(cookie1);
       
       out.println("<script>window.location.href='system.jsp';</script>");  
   }
%>