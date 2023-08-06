<%-- 
    Document   : playright
    Created on : 10-Dec-2013, 09:54:52
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>

<div class="right fri">
  <div class="faqtwo">
    <div class="faqtwotit playtwotit">评论最多活动</div>
    <div class="faqtwocon">
      <ul>
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

    String youke_context = "";
    String  youke_context1 = "";
    if (UserId == 0) {
        youke_context = "ISPUBLIC = 1 and ";
        youke_context1 = "b.ISPUBLIC = 1 and ";
    }
  int pagecount = 6;
  Statement stmt = conn.createStatement();   
  Statement u_stmt = conn.createStatement();
  
  String sql = "select * from (select a.AID as AID from (select count(*) as count, AID from ACTIVITY_EVAL GROUP BY AID order by count DESC) a INNER JOIN ACTIVITY_INFO b ON a.AID = b.id where " + youke_context1 + "b.DELETED = 0 and b.ISVISIBLE = 1) where ROWNUM <=" + pagecount;
  ResultSet rs = stmt.executeQuery(sql);
  ResultSet rs1 = null;
  int id = 0;
  String title = null;
   while (rs.next()) {
    id = rs.getInt("AID");
    sql = "select title from activity_info where " + youke_context + "deleted = 0 and id = " + id;
    rs1 = u_stmt.executeQuery(sql);
    title = "";
    if (rs1.next())
        title = rs1.getString("title");
    if (title != null && title.length() > 10)
        title = title.substring(0, 10) + "...";
    else if  (title == null) title = "";
    %>
      <li><a href="play_info.jsp?id=<%=id%>"><%=title%></a></li>
        <%
               }
  rs.close();
        %>      
      </ul>
    </div>
  </div>
  <div class="faqthree mar15">
    <div class="faqtwotit playtwotit">最新活动</div>
    <div class="faqtwocon">
      <ul>
 <%
  sql = "select * from (select * from ACTIVITY_INFO where " + youke_context + "deleted = 0 and type = 2 and isvisible = 1 ORDER BY ID DESC) where ROWNUM <= " + pagecount;
  rs = stmt.executeQuery(sql);
  
  while (rs.next()) {
    id = rs.getInt("ID");
    title = rs.getString("title");
    if (title != null && title.length() > 10)
        title = title.substring(0, 10) + "...";
    else if (title == null) title = "";
%>
        <li><a href="play_info.jsp?id=<%=id%>"><%=title%></a></li>
        <%
               }
  rs.close();
        %>      
      </ul>
    </div>
  </div>
</div>