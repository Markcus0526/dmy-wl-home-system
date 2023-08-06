<%-- 
    Document   : mailcheck
    Created on : Jan 30, 2014, 4:26:13 PM
    Author     : Hercules
--%>

<%@page import="java.util.Properties"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Random"%>
<%@page import = "java.io.IOException" %>
<%@page import="javax.mail.*"%>
<%@page import="javax.mail.internet.*"%>
<%@ include file="connection.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    String username = request.getParameter("username");
    String mailaddr = request.getParameter("mailaddr");
    
    String password = "";
    
    try {
       Statement stmt = conn.createStatement();
       String sql = "select count(*) as count from MEMBERINFO where userid = '" + username + "' and emailaddress = '" + mailaddr + "'";       
       ResultSet rs = stmt.executeQuery(sql);
       boolean found = false;
       if(rs.next() && rs.getInt("count") > 0)
           found = true;
       rs.close(); 
       stmt.close();
       
       if(found) {
           stmt = conn.createStatement();
           int m = 0, test = 0;
           String ddd = new String();
          for (int i = 0; i < 6;i++) {
             double dd =Math.random();
              m = (int)(dd * 10) % 10;
           password += m;
           }
           
           
       
            // password += m.toString();
          //}
                           
           
           sql = "update MEMBERINFO set password = '" + password + "' where userid= '" + username + "' and emailaddress = '" + mailaddr + "'";
           stmt.executeQuery(sql);
           stmt.close();
           
           
           
             try {
            String host = "localhost";
            String to = mailaddr;
            String from = "yyyyy@gmail.com";
            String subject = "密码";
            String messageText = "密码:" + password;
            boolean sessionDebug = false;
            Properties props = System.getProperties();
            props.put("mail.host", host);
            props.put("mail.transport.protocol", "smtp");
            props.put("mail.smtp.port", "465");
            Session mailSession = Session.getDefaultInstance(props, null);
            mailSession.setDebug(sessionDebug);
            Message msg = new MimeMessage(mailSession);
            msg.setFrom(new InternetAddress(from));
            InternetAddress[] address = {new InternetAddress(to)};
            msg.setRecipients(Message.RecipientType.TO, address);
            msg.setSubject(subject);
            msg.setSentDate(new Date());
            msg.setText(messageText);

            Transport.send(msg);
                System.out.println("Sent message successfully....");
        } catch (Exception ex) {
        }

           
           
           out.println("<script>alert('邮政检查成功了! 你的密码从现在 \"" + password + "\"');</script>");
       } else {
           out.println("<script>alert('邮件地址错误. 你是谁?');</script>");            
       }
        
    }
    catch (Exception e) {
        out.println("<script>alert('邮件地址错误. 你是谁?');</script>"); 
    }
    
    conn.close();
    
    out.println("<script>window.location.href='login.jsp';</script>");     
%>
