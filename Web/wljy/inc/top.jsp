

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%
 Cookie[] cookies1 = request.getCookies();
    String tmp_str1= "";
    
    for(int k = 0;k<cookies1.length;k++) {
       String name1=cookies1[k].getName();
       int pos1=name1.indexOf('#');
       if(pos1 != -1) {
         if(name1.substring(0, pos1).equals("wljyid")) {
             tmp_str1=name1.substring(pos1+1);
             break;
         }
       }
    }
     Statement stmt = conn.createStatement();   
    String sql = "select * from memberinfo where id=" + tmp_str1;
    ResultSet rs = stmt.executeQuery(sql);
    String  nickname = "";
    String vip = "vip.jsp";
    if (tmp_str1.equals("0")) {
        nickname = "游客";
        vip = "#";
               }
    if (rs.next()) {
        nickname = rs.getString("name");
    }
    
    
conn.close();    

%>
<div class="top clear">
  <div class="toptxt" align="right">
    <a href="vip.jsp" class="name"><%=nickname%></a>，欢迎登录，<a href="<%=vip%>">我的账户</a> 
	&nbsp;&nbsp;| &nbsp;&nbsp;<a href="mycart.jsp" class="cancel">我的兑换</a> 
	&nbsp;&nbsp;| &nbsp;&nbsp;<a href="logout.jsp" class="cancel">
	<% if (nickname.equals("游客")) { %>
	登录
	<% } else {%>
	注销
	<% } %>
	</a>
  </div>
  <div class="logo fle"><a href="index.jsp"><img src="img/logo.jpg" width="265" height="26" /></a></div>
  <div class="menu fri">
    <ul class="clear">
      <li><a href="main.jsp">首页</a></li>
      <li><a href="play.jsp">活动</a></li>
      <li><a href="share.jsp">分享</a></li>
      <li><a href="faq.jsp">问答</a></li>
      <li><a href="study.jsp">学习</a></li>
      <li><a href="feedback.jsp">献策</a></li>
      <li><a href="exchange.jsp">兑换</a></li>
    </ul>
  </div>
</div>
