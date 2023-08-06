<%-- 
    Document   : faqright
    Created on : 10-Dec-2013, 09:55:16
    Author     : PAK SONG HYOK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
	String str_IsActive = "";
    for(int i = 0;i<cookies.length;i++) {
        String name=cookies[i].getName();
        int pos=name.indexOf('#');
        
        if(pos != -1) {
            if(name.substring(0, pos).equals("wljyid")) {
                tmp_str=name.substring(pos+1);
            }
			if(name.substring(0, pos).equals("wljyisactive")) {
                str_IsActive=name.substring(pos+1);
            }
        }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
	int IsActive = 0;
	String queryFirstLogin = "select firstlogin from memberinfo where id = " + UserId;
	Statement stmtFirstLogin = conn.createStatement();
	ResultSet rsFirstLogin = stmtFirstLogin.executeQuery(queryFirstLogin);
	if (rsFirstLogin.next()) {
		IsActive = rsFirstLogin.getInt("firstlogin");
	}
	rsFirstLogin.close();
	stmtFirstLogin.close();
    
%>

<div class="right fri">
  <div class="faqtwo">
      <div class="faqone" align="right">
          <% if (UserId > 0 && IsActive == 1) { %>
    <a href="postquestion.jsp"><img src="img/faq_img05.jpg" width="258" height="83" alt=""></a>
    <% }%>
  </div>
    <div class="faqtwotit playtwotit">最新被解决的问题</div>
    <div class="faqtwocon">
      <ul>
                   <%
  int pagecount = 8;
  Statement stmt = conn.createStatement();   
  Statement u_stmt = conn.createStatement();
  Statement u_stmt1 = conn.createStatement();
   String youke_context = "";
   String youke_context1 = "";
   if (UserId == 0 ) {
         youke_context = "ISPUBLIC = 1 and ";    
         youke_context1 = "b.ISPUBLIC = 1 and ";    
   }
  String sql = "select * from (select * from PROBLEM_QINFO where " + youke_context + "deleted = 0 and isvisible = 1 order by postdate DESC) where ROWNUM <= " + pagecount;
  ResultSet rs = stmt.executeQuery(sql);
  ResultSet rs1 = null;
  int id = 0;
  String title = null;
   while (rs.next()) {
    id = rs.getInt("id");
    title = "";
    title = rs.getString("title");
    if (title.length() > 10)
        title = title.substring(0, 10) + "...";
    %>
      <li><a href="faq_info.jsp?id=<%=id%>"><%=title%></a></li>
        <%
               }
  rs.close();
        %>      
      </ul>
    </div>
  </div>
  <div class="faqthree mar15">
    <div class="faqtwotit playtwotit">回答最多的问题</div>
    <div class="faqtwocon">
      <ul>
 <%
 sql = "select * from (select pid, count(*) as count from PROBLEM_AINFO group by pid order by count DESC) a INNER JOIN PROBLEM_QINFO b on a.pid = b.id where " + youke_context1 + "b.deleted = 0 and b.isvisible = 1";
  //sql = "select * from (select *, (select count(*) from PROBLEM_AINFO where pid = id) as answercount from PROBLEM_QINFO ORDER BY answercount DESC) where ROWNUM <= " + pagecount;
  rs1 = stmt.executeQuery(sql);
  
  ResultSet rs2;  
  int pid = 0;
  while (rs1.next()) {
    pid = rs1.getInt("pid");
    
    rs2 = null;
    sql  = "select * from PROBLEM_QINFO where " + youke_context + "deleted = 0 and id =" + pid;
    rs2 = u_stmt1.executeQuery(sql);
    title = "";
    id = pid;
    while(rs2.next()) {
        id = rs2.getInt("id");
        title = "";
         title = rs2.getString("title");
         if (title.length() > 10)
                title = title.substring(0, 10) + "...";
    }
    rs2.close();
 %>
        <li><a href="faq_info.jsp?id=<%=id%>"><%=title%></a></li>
        <%
               }
  rs1.close();
        %>      
      </ul>
    </div>
  </div>
</div>
