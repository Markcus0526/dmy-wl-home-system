<%-- 
    Document   : study
    Created on : 10-Dec-2013, 10:19:57
    Author     : PAK SONG HYOK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="UTF-8" />
<title></title>
<meta name="keywords" content="" />
<meta name="description" content="" />
<meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
<link rel="shortcut icon" href="favicon.ico" />
<link rel="icon" href="logo.png" type="logo.png" />
<link href="css/css.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->
<%@ include file="connection.jsp" %>
<%
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
	String str_IsActive = "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
       if(name.substring(0, pos).equals("wljyid"))
       {
             tmp_str=name.substring(pos+1);
       }
	   if(name.substring(0, pos).equals("wljyisactive"))
       {
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
    
     ResultSet rs4;
    Statement stmt2 = conn.createStatement();
    String sql1 = "";
  String username1="";
        String vip = "vip.jsp";
    if (UserId == 0 ) {
        username1= "游客";
        youke_context = "ISPUBLIC = 1 and ";
        vip = "#";
               }
    else 
               {
            sql1 = "select * from memberinfo where deleted = 0 and id =" + UserId;
            rs4 = stmt2.executeQuery(sql1);
            if (rs4.next()) {
                username1 = rs4.getString("name");
            }
            rs4.close();
    }

    
    request.setCharacterEncoding("UTF-8");
    
    String spage = request.getParameter("page")== null?"0":request.getParameter("page");
    String type = request.getParameter("type")== null?"0":request.getParameter("type");
    String search = request.getParameter("searchText");
    
    int pagenum = Integer.parseInt(spage);
    int pagecount = 8;
    
    Statement stmt = conn.createStatement();   
    Statement u_stmt = conn.createStatement();
    Statement u_stmt1 = conn.createStatement();
    Statement u_stmt2 = conn.createStatement();
    
    String sql = new String();
    String searchContext = new String();
    if(search == null) {
        if (Integer.parseInt(type) > 0) 
            sql = "select count(*) as count from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type =" + type + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
        else
            sql = "select count(*) as count from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
    } else {
        searchContext = "(title like '" + search + "%' or title like '%" + search + "' or title like '%" + search + "%')";
        if (Integer.parseInt(type) > 0) 
            sql = "select count(*) as count from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type =" + type + " and (" + searchContext + ") and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
        else
            sql = "select count(*) as count from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and  (" + searchContext + ") and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
    }
    ResultSet rsforCount = u_stmt2.executeQuery(sql);
    int total_count = 0;
    int total_page = 0;
    if (rsforCount.next()) {
        total_count = rsforCount.getInt(1);
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = total_page;
    }
    rsforCount.close();
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;
    
    int last_index = total_count - (total_page-pagenum) * pagecount+1;
    int first_index = last_index - pagecount;   
    if (first_index <= 0)  {
        first_index = 1 ;
        //pagecount = last_index;
    }
    
    int itype = Integer.parseInt(type);
    if(search == null) {
        if(itype > 0)
            sql = "select * from (select * from (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type = " + itype + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ID >= (select MAX(ID) from (select * from  (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type = " + itype + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ROWNUM <= " + last_index + "  ) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + " and type = " + itype + ") order by id DESC"; 
        else
            sql = "select * from (select * from (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and  ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC)  where ID >= (select MAX(ID) from (select * from (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by id DESC"; 
    } else {
        if(itype > 0)
            sql = "select * from (select * from (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type = " + itype + " and " + searchContext + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ID >= (select MAX(ID) from (select * from  (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type = " + itype + " and " + searchContext + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ROWNUM <= " + last_index + "  ) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + " and type = " + itype + ") order by id DESC"; 
        else
            sql = "select * from (select * from (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and " + searchContext + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC)  where ID >= (select MAX(ID) from (select * from (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and " + searchContext + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by id DESC"; 

    }

    ResultSet rs = stmt.executeQuery(sql);
    ResultSet rs1, rs2;
    
    String title = new String();
    Date postdate = new Date(1,11,1);
    int readcount = 0;
    String body = new String();
    int id = 0, mid = 0, answernum = 0;
    String username = new String();
    String imagepath = new String();
    Clob clob = null;
    int clob_length = 0;
    int download_cnt = 0;
%> 
<script type="text/javascript">
$(function(){
    $(".includeDom").each(function(){
        var html = $(this).attr("include");
	$(this).load(html,function() {
            $(".menu li a").eq(4).css("color","#1b8403");
            $(".toptit span a").eq(<%=type%>).addClass("now");
             $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
	});
    })
})
function change_page(index, type) {
    window.location.href = "study.jsp?page=" +  index + "&type=" +type ;
}
function select_change(type) {
    change_page($("#page").val(), type);
}
</script>
</head>
<body>  
    <div class="w964">
	<div class="includeDom" include="inc/top.jsp"></div>
	<div class="toptit studytoptit">
            <b>学习</b>
            <span><a href="study.jsp">全部资料</a><a href="study.jsp?type=1">专业知识</a><a href="study.jsp?type=2">企业相关</a><a href="study.jsp?type=3">其他综合</a></span>
            <div>
            <table class="search" align="right"> 
                <tr>
                
                    <form action="study.jsp?type=<%=type%>" method="post">
                    <td> <input type="text" class="searchdt" name="searchText" value="<% if (search != null) out.print(search); %>" /></td>
                    <td> <input type="submit" class="searchdd" value="" /> </td>
                    </form>
                    
                </tr>
            </table>
            </div>
	</div>
	<div class="site clear">
            <div class="content fle">
                <div class="conttop"></div>
                <div class="main">
                    <div class="faqlist">
			<ul class="clear">
                            <%
                            while (rs.next()) {
                                id = 0;
                                id = rs.getInt("id");
                                
                                mid = 0;
                                mid = rs.getInt("mid");
                               if (mid == 0)     {
                                   username = "管理者";
                               }
                                                               else {
                                sql = "Select * from memberinfo where id = " + mid;
                                rs1 = u_stmt.executeQuery(sql);
                                while (rs1.next()) {
                                    username = rs1.getString("name");
                                }
                                rs1.close();
                                                               }

                                title = "";
                                title = rs.getString("title");

                                body = "";
                                clob = rs.getClob("body");
                                if(clob == null)
                                    body = "";
                                else  {
                                    clob_length = (int)clob.length();
                                    if (clob_length > 32)
                                        body = clob.getSubString(1, 32) + "...";
                                    else 
                                        body = clob.getSubString(1, clob_length);
                                }       
                                imagepath = "";
                                imagepath = rs.getString("imagepath");

                                postdate = rs.getDate("postdate");
                                
                                readcount = 0;
                                readcount = rs.getInt("readcount");

                                download_cnt = 0;
                                sql =  "select count(*) from data_download where sqid = " + id;
                                rs2 = u_stmt1.executeQuery(sql);
                                if (rs2.next()) {
                                    download_cnt = rs2.getInt(1);
                                }
                                rs2.close();
                                
                                 answernum = 0;   
                                sql = " Select count(*) from STUDY_AINFO where sid = " + id;
                                rs2 = u_stmt1.executeQuery(sql);
                                while( rs2.next())  {
                                    answernum = rs2.getInt(1);
                                }
                                rs2.close();
                            %>
                            <li>
                                <h3><a href="study_info.jsp?id=<%=id%>"><%=username%>：<%=title%></a></h3>
                                <p><span>更新日期：<%=postdate%></span>  浏览：<span style="color:#fc741a"><%=readcount%></span>   下载：<span style="color:#fc741a"><%=download_cnt%></span>    评论：<span style="color:#0065a5"><%=answernum%></span> </p>
                                <div class="faqintro"><%=body%><a href="study_info.jsp?id=<%=id%>">[详细]</a></div>
                            </li>
                            <%
                            } 
    rs.close();
    stmt.close();
    u_stmt.close();
    u_stmt1.close();
                            %>							
			</ul>
                    </div>
                    <div class="page mar15 clear" align="center">
                        共 <%=total_count%>条数据（<%=total_page%> 页）<a href="javascript:void(0)" onclick="change_page(<%=prev_page%>, <%=type%>);"><img src="img/page.jpg" alt=""></a> 
                        <select id="page" onchange="select_change(<%=type%>);">
                            <%
                            int i = 0;
                            for (i = total_page; i > 0;i--) {
                                if (i == pagenum) {                                                  
                            %>
                            <option value="<%=i %>" selected><%=i%></option>
                            <%
                                }
                                else {
                            %>
                            <option value="<%=i %>"><%=i%></option>
                            <%
                                }
                            }
                            %>   
						
			</select> 
			<a href="javascript:void(0)" onclick="change_page(<%=next_page%>, <%=type%>)"><img src="img/page01.jpg" alt=""></a>
                    </div>
		</div>
		<div class="contbot"></div>
		</div>
		<div class="right fri">
                    <div class="faqtwo">
                                 <div class="faqone" align="right">
          <% if (UserId != 0 && IsActive == 1) { %>
    <a href="postinfo.jsp"><img src="img/study_img02.jpg" width="258" height="83" alt=""></a>
    <% }%>
  </div>
                        <div class="faqtwotit">最新学习资料</div>
                        <div class="faqtwocon">
                            <ul>
                                <%

                                sql = "select * from (select * from STUDY_QINFO where " + youke_context + "deleted = 0 and isvisible = 1 order by ID DESC) where ROWNUM <= " + pagecount ;
                                
                                ResultSet rs3 = u_stmt2.executeQuery(sql);
                                id = 0;
                                title = new String();
                                while (rs3.next()) {
                                    id = rs3.getInt("id");
                                    title = "";
                                    title = rs3.getString("title");
                                    if (title != null && title.length() > 10)
                                        title = title.substring(0, 10) + "...";
                                    else if (title == null) title="";
                                %>
                                <li><a href="study_info.jsp?id=<%=id%>"><%=title%></a></li>
                                <%
                                }
                                rs3.close();
                                %>      
		      </ul>
		    </div>
		  </div>
		</div>
	</div>
</div>
<div class="includeDom" include="inc/footer.jsp"></div>
</body>
<%
    conn.close();
%>
</html>