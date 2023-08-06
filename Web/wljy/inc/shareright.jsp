<%-- 
    Document   : shareright
    Created on : 10-Dec-2013, 09:52:56
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
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
     String youke_context = "";
     if (UserId == 0) {
         youke_context = "b.ISPUBLIC = 1 and ";
     }
    
    request.setCharacterEncoding("UTF-8");            
    
    Statement stmt = conn.createStatement();  
    Statement stmt1 = conn.createStatement();  
    Statement u_stmt = conn.createStatement();  
    String sql = new String();
    sql = "select name from MEMBERINFO where deleted = 0 and id = " + UserId;
    ResultSet rs = u_stmt.executeQuery(sql);
    String username = new String();
    if(rs.next()) {
        username = rs.getString("name");
    }
    rs.close();
           
    sql = "select * from (select * from SHARE_DATA where deleted = 0 and type = 0 and mid = " + UserId + "order by id desc) where ROWNUM <= 12";    
    rs = stmt.executeQuery(sql);
    
    int id, rid, mid, type, infoid;
    String datapath = new String();
%> 
<div class="right shareright fri">
    <div class="sharerightbtn"><a href="sharemy.jsp"><img src="img/share_img08.jpg" width="259" width="83" alt=""></a></div>
    <div class="faqtwo">
        <div class="faqtwotit sharetwotit"><b><%=username%></b> <span>分享的照片</span></div>
         <div class="faqtwocon">
            <div class="sharepic clear">
           <%
                sql = "select * from (select a.ID as id , a.RID as rid, a.MID as mid, a.TYPE as type, a.DATAPATH as datapath, b.id as infoid from SHARE_DATA a INNER JOIN SHARE_INFO b ON a.RID=b.ID where a.deleted = 0 and b.deleted = 0 and b.isvisble = 1 and " + youke_context + "a.type = 0 and a.mid = " + UserId + " order by a.id desc) where ROWNUM <= 12";    
                rs = stmt1.executeQuery(sql);
                while (rs.next()) {
                    id = rs.getInt("id");
                    infoid = rs.getInt("infoid");
                    rid = rs.getInt("rid");
                    type = rs.getInt("type");
                    datapath = rs.getString("datapath");
            %>
                <!-- <a href="video_play.jsp?name=<%=datapath%>"><img src="img/share_img07.jpg" width="72" height="48" alt=""></a> -->
				<a href="share_info.jsp?id=<%=infoid%>"><img src="<%=datapath%>" width="72" height="48" alt=""></a>
            <%
                }
                rs.close();
            %>
            </div>
        </div>
    </div>
    <div class="faqtwo mar15">
        <div class="faqtwotit sharetwotit"><b><%=username%></b> <span>分享的视频</span></div>
        <div class="faqtwocon">
            <div class="sharepic clear">
            <%
                sql = "select * from (select a.ID as id , a.RID as rid, a.MID as mid, a.TYPE as type, a.DATAPATH as datapath, b.id as infoid from SHARE_DATA a INNER JOIN SHARE_INFO b ON a.RID=b.ID where a.deleted = 0 and b.deleted = 0 and b.isvisible = 1 and " + youke_context + "a.type = 1 and a.mid = " + UserId + " order by a.id desc) where ROWNUM <= 12";    
                rs = stmt1.executeQuery(sql);
                while (rs.next()) {
                    id = rs.getInt("id");
                    infoid = rs.getInt("infoid");
                    rid = rs.getInt("rid");
                    type = rs.getInt("type");
                    datapath = rs.getString("datapath");	

					if (datapath != null && datapath.length() > 0)
					{
						int nPos = datapath.lastIndexOf(".");
						if (nPos > 0)
						{
							datapath = datapath.substring(0, nPos) + ".jpg";
						}
					}
					else
						datapath = "img/share_img07.jpg";
            %>
                <!-- <a href="video_play.jsp?name=<%=datapath%>"><img src="img/share_img07.jpg" width="72" height="48" alt=""></a> -->
				<a href="share_info.jsp?id=<%=infoid%>"><img src="<%=datapath%>" width="72" height="48" alt=""></a>
            <%
                }
                rs.close();
            %>
            </div>
        </div>
    </div>
</div>

<%
    stmt.close();
    stmt1.close();
    u_stmt.close();
    conn.close();
%>	