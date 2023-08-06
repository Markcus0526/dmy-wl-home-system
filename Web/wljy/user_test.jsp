<%-- 
    Document   : user_test
    Created on : 2013/12/14, 下午 08:50:05
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<%@ include file="connection.jsp" %>
<%@page import="java.util.Date"%>
<%@page import="java.sql.*"%>
<%
    request.setCharacterEncoding("UTF-8");
	session.setAttribute("logintype", "normal");
   String userid = request.getParameter("username");
   userid = userid.replace("'", "");
   String password = request.getParameter("password");
   password = password.replace("'", "");
   String login_check = request.getParameter("loginradio");
   String checktenday = request.getParameter("checktenday");
   String strIPAddress = request.getRemoteAddr();

   Statement stmt = conn.createStatement();   
   int login = -1;
   int privilege = 0;
   String type = "userid";
    if (login_check.equals("admin")) 
	{
		String sql = "select * from memberinfo where deleted = 0 and nickname ='" + userid + "' and namepassword='" + password + "' and firstlogin=0";

        String userid_str = "";
		ResultSet rs = stmt.executeQuery(sql);

		while (rs.next()) 
		{
			login = rs.getInt("id");
			userid_str = rs.getString("userid");
            privilege = rs.getInt("privilege");
        }
        rs.close();

        if (login == -1) 
		{
			sql = "select * from memberinfo where deleted = 0 and userid ='" + userid + "' and password='" + password + "' and firstlogin = 1";
            rs = stmt.executeQuery(sql);
            while (rs.next()) 
			{
				login = rs.getInt("id");
                privilege = rs.getInt("privilege");
            }
            rs.close();
        }
		else 
		{
			type = "nickname";
			session.setAttribute("logintype", "nickname");
		}
    } 
	else 
	{
      login = 0;
      userid = "anony";
    }
   
	if (login == -1){
       out.println("<script>alert('用户ID及密码有错误');</script>");
       out.println("<script>window.location.href='login.jsp';</script>");
        conn.close();
       return;
    } else if (login != 0 && privilege == 0) {
       out.println("<script>alert('您的账号被禁用，请联系管理者！');</script>");
       out.println("<script>window.location.href='login.jsp';</script>");
        conn.close();
       return;
    } else {
               Cookie[] cookies = request.getCookies();
            String user_name= new String();

            if (cookies != null && cookies.length != 0) {
                String name = new String();
                int pos = -1;

                for(int i = 0;i< cookies.length;i++) {         
                     name = cookies[i].getName();
                     pos = name.indexOf('#');

                     if(pos != -1) {
                        if(name.substring(0, pos).equals("wljy") || name.substring(0, pos).equals("wljyid")) {
                            user_name=name.substring(pos+1);
                            Cookie cookie = new Cookie(name, "");
                            cookie.setMaxAge(0);
                            response.addCookie(cookie);                    
                        }                               
                    }

                }
             }
       String sql = "select lastlogindate from memberinfo where deleted = 0 and id=" + login;     
       Date tmp = new Date();
       java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
      ResultSet rs = stmt.executeQuery(sql), rs1 = null;
       boolean first = false;
      if (rs.next()) {
            Date today = rs.getDate("lastlogindate");
			if (today == null)
				first = true;
            else if (today.getYear() != d.getYear() || today.getMonth() != d.getMonth() || today.getDate() != d.getDate()) {
              first = true;
      }
        }
       rs.close();

       sql = "update memberinfo set lastlogindate = ?, registipaddress = ? where deleted = 0 and id=" + login;
       PreparedStatement pstmt = conn.prepareStatement(sql); 
       
       pstmt.setTimestamp(1, d);
	   pstmt.setString(2, strIPAddress);
       pstmt.execute();
       pstmt.close();     
       
       sql = "select max(id) from memberloginlist";
       rs = stmt.executeQuery(sql);
       int maxloginid = 0;
       if (rs.next()) {
           maxloginid = rs.getInt(1);           
       }
       maxloginid++;
             
           sql = "insert into memberloginlist (id, mid, logintime, loginip) values (?, ?, ?, ?)";
           pstmt = conn.prepareStatement(sql);
           pstmt.setInt(1, maxloginid);
           pstmt.setInt(2, login);
           java.sql.Timestamp now = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(),0);
           pstmt.setTimestamp(3, now);   
           pstmt.setString(4, strIPAddress);   
		   pstmt.execute();
		   pstmt.close();     
       
       if(checktenday != null && checktenday.equals("on")) {
           sql = "update MEMBERINFO set ISTENDAYS = ?, TENDAYSDATE = ? where deleted = 0 and id = " + login;
           pstmt = conn.prepareStatement(sql);
           pstmt.setBoolean(1, true);
            pstmt.setTimestamp(2, d);
           pstmt.execute();
           pstmt.close();
       } else {
           sql = "update MEMBERINFO set ISTENDAYS = ? where deleted = 0 and id = " + login;
           pstmt = conn.prepareStatement(sql);
           pstmt.setBoolean(1, false);
           pstmt.execute();
           pstmt.close();
       }
       
       
       int logincount = 0, todaycount = 0;
       Statement u_stmt = conn.createStatement();
       Statement u_stmt1 = conn.createStatement();
       sql = "select logincount, integral from MEMBERINFO where deleted = 0 and id = " + login;
      rs = u_stmt.executeQuery(sql);
       int integral = 0;
       if(rs.next()) {
           logincount = rs.getInt("logincount");
           integral = rs.getInt("integral");
       }
       rs.close();
       u_stmt.close();
        if (first) {
            logincount = 0;
        }
       if(logincount < 5) {
           logincount ++;               

         

                   String strDate = Integer.toString(tmp.getYear()+1900);
            if (tmp.getMonth() < 9) {
                           strDate += "-0" + Integer.toString(tmp.getMonth()+1);
            } else {
                           strDate += "-" + Integer.toString(tmp.getMonth()+1);
            }
            if (tmp.getDate() < 10) {
                           strDate += "-0" + Integer.toString(tmp.getDate());
            } else {
                           strDate += "-" + Integer.toString(tmp.getDate());
            }
                   /*
                   String strEndDate = strDate + " 23:59:59";
                                           
                   strDate += " 00:00:00";
                   */
                //   out.println(strDate);
                         
               int reason_id = 1;
               int def_reason = 1;
               u_stmt1 = conn.createStatement();
               sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = "+reason_id;
               rs1 = u_stmt1.executeQuery(sql);
            if (rs1.next()) {
                   def_reason = rs1.getInt("DEFAULTINTEGRAL");
            }
               rs1.close();
               u_stmt1.close();
			   sql = "update memberinfo set logincount = ?, integral = integral + " + def_reason +  " where deleted = 0 and id=" + login;
			   pstmt = conn.prepareStatement(sql); 
			   pstmt.setInt(1, logincount);
			   pstmt.execute();
			   pstmt.close();  

               int max_id = 0;
               u_stmt1 = conn.createStatement();
               sql = "select MAX(id) as maxid from INTEGRALLOG";
               rs1 = u_stmt1.executeQuery(sql);
            if (rs1.next()) {
                   max_id = rs1.getInt("maxid");
            }
               rs1.close();
               u_stmt1.close();

               sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
               pstmt = conn.prepareStatement(sql);
               pstmt.setInt(1, max_id + 1);
               pstmt.setInt(2, login);
            pstmt.setTimestamp(3, d);
               pstmt.setInt(4, def_reason);
               pstmt.setInt(5, reason_id);
               pstmt.setInt(6, 1);
               pstmt.execute();
               pstmt.close();
 
       }

	   Statement mystmt = conn.createStatement();
       sql = "select firstlogin from MEMBERINFO where deleted = 0 and id = " + login;
		ResultSet myrs = mystmt.executeQuery(sql);
       int isActive = 0;
       if(myrs.next()) {
           isActive = myrs.getInt("firstlogin");
       }
       myrs.close();
       mystmt.close();
       
       HttpSession sess=request.getSession(true);
       session.setMaxInactiveInterval(30*24*60*60);
       userid = "wljy#" + userid;       
       String s = sess.getId();  

	   userid=java.net.URLEncoder.encode(userid,"UTF-8");
                       
       Cookie cookie = new Cookie(userid ,s);
        if(checktenday != null && checktenday.equals("on")) 
            cookie.setMaxAge(10*60*60*24);    
        else
            cookie.setMaxAge(60*60*12);
       userid = "wljyid#" + login;
       Cookie cookie1 = new Cookie(userid, s);
       if(checktenday != null && checktenday.equals("on")) 
            cookie1.setMaxAge(10*60*60*24);    
        else
            cookie1.setMaxAge(60*60*12);       
		
		userid = "wljyisactive#" + isActive;
		Cookie cookie2 = new Cookie(userid ,s);
        if(checktenday != null && checktenday.equals("on")) 
            cookie2.setMaxAge(10*60*60*24);    
        else
            cookie2.setMaxAge(60*60*12);

       response.addCookie(cookie);
       response.addCookie(cookie1);
	   response.addCookie(cookie2);
       
        conn.close();
       out.println("<script>window.location.href='login.jsp?type=" + type + "';</script>"); 
   }
%>
