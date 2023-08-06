<%-- 
    Document   : share
    Created on : 10-Dec-2013, 10:17:41
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="UTF-8" />
<title></title>
<meta name="keywords" content=""  />
<meta name="description" content="" />
<meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
<link rel="shortcut icon" href="favicon.ico" />
<link rel="icon" href="logo.png" type="logo.png" />
<link href="css/css.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
<%@ page language="Java" import="java.sql.*" %>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->
<%
    request.setCharacterEncoding("UTF-8");
    
    String  share_type = request.getParameter("type")==null?"0":request.getParameter("type");
    int type = Integer.parseInt(share_type);
%>

<script type="text/javascript" src="js/lazyload.js"></script>
<script type="text/javascript" src="js/jquery.masonry.min.js"></script>
<script>
    $(function(){
            var $container = $('#containerPic'),sTimer;
            $container.imagesLoaded(function(){
                  $container.masonry({
                 itemSelector: '.sharedet',
                 columnWidth: 1
                  });
            });
            $(window).scroll(function scrollHandler(){
                clearTimeout(sTimer);
                sTimer = setTimeout(function() {
                    if(window.loaded == 1){$(window).unbind("scroll", scrollHandler);}
                    var c=document.documentElement.clientHeight || document.body.clientHeight, t=$(document).scrollTop();
                    if(t+c >= $container.offset().top+$container.height()){loadMore();}
                }, 100);
            });
            var jLoading = $('#loading');
            function loadMore()
            {
                var html="";
                $container.append(html).masonry("reload");
                jLoading.hide();
            }  
      });
      window.onload = function() {
          $('#loading').hide();
      }
 
</script>
</head>
<body>
<%@ include file="connection.jsp" %>
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
    
      ResultSet rs2;
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
            rs2 = stmt2.executeQuery(sql1);
            if (rs2.next()) {
                username1 = rs2.getString("name");
            }
            rs2.close();
    }

    
   String spage = request.getParameter("page")== null?"0":request.getParameter("page");
    int pagenum = Integer.parseInt(spage);
    int pagecount = 8;
    Statement stmt = conn.createStatement();   
    Statement u_stmt = conn.createStatement();
    Statement u_stmt1 = conn.createStatement();
    
    String sql = null;
    if (type == 0)
	    sql = "select count(*) as count from SHARE_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
	else
	    sql = "select count(*) as count from SHARE_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type = " + type + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";

	ResultSet rs = stmt.executeQuery(sql);

    int total_count = 0; if(total_count < pagecount) out.println("<script>jLoading.hide();</script>");
    int total_page = 0;
    if (rs.next()) {
        total_count = rs.getInt(1);
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = total_page;
    }
    rs.close();
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;
    
    int last_index =  total_count - (total_page-pagenum) * pagecount+1;
    int first_index = last_index - pagecount;   
    if (first_index <= 0)  {
        first_index = 1 ;
        //pagecount = last_index;
    } 
    
    if (type == 0)
        sql = "select * from (select * from (select * from SHARE_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ID >= (select MAX(ID) from (select * from (select * from SHARE_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ROWNUM <= " + last_index + ") where ROWNUM <= " + first_index + ")  and ROWNUM <= " + pagecount + ") order by id DESC";
    else
        sql = "select * from (select * from (select * from SHARE_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type = " + type + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ID >= (select MAX(ID) from (select * from (select * from SHARE_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and type = " + type + " and TO_CHAR(postdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by id ASC) where ROWNUM <= " + last_index + ") where ROWNUM <= " + first_index + ")  and type =" + type + " and ROWNUM <= " + pagecount + ") order by id DESC";
        
    rs = stmt.executeQuery(sql);
    ResultSet rs1;
%>
    <script type="text/javascript">
$(function(){
	$(".includeDom").each(function() {
		var html = $(this).attr("include");
		$(this).load(html,function() {
			$(".menu li a").eq(2).css("color","#017ab2");
			$(".toptit span a").eq(<%= type%>).addClass("now");
                                $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
		});
	});
	$(".sharebtn a").hover(function() {
		$(this).find("img").stop().animate({"top": "-129px"}, 100, "linear");
	}, function() {
		$(this).find("img").stop().animate({"top": "0"}, 100, "linear");
	})
})
function change_page(index) {
    window.location.href = "share.jsp?page=" + index;
}
function select_change() {
    change_page($("#page").val());
}
</script>
<div class="w964">
                <div class="includeDom" include="inc/top.jsp"></div>
                <div class="toptit sharetit">
                <b>分享</b>
                <span><a href="share.jsp">全部</a>
<%
	sql = "Select * from SHARE_TYPE";
	rs1 = u_stmt.executeQuery(sql);
	String  tname = new String();
	int tid = 0;
	while (rs1.next()) {
		tid = rs1.getInt("ID");
		tname = rs1.getString("NAME");
		out.println("<a href=\"share.jsp?type=" + tid + "\">" + tname + "</a>");
	}
	rs1.close();
%>
                </span>
	</div>
	<div class="site clear">
		<div class="sharelist" id="containerPic">
			<ul>
<%
    String title = null;
    Date postdate = null;
    int readcount = 0;
    String body = null;
    int id = 0, mid = 0;
    String uname = null;
    String  uimg = null;
    String  data_path = null;
    String  video_path = null;
    int uid = 0;
    
    while (rs.next()) {
        id = rs.getInt("ID");
        mid = rs.getInt("MID");
   
      
        
        uid = 0;
        uname = "";
        uimg = "";
        data_path = "";
        title = "";
				body = "";
				postdate = null;
				readcount = 0;
                                     if (mid == 0) {
            uname = "管理者";
            uid = 0;
            uimg = "";
        }
                                                               else {
                                      sql = "Select * from memberinfo where deleted = 0 and id = " + mid;
        rs1 = u_stmt.executeQuery(sql);
				
        while (rs1.next()) {
            uid = rs1.getInt("ID");
            uname = rs1.getString("NAME");
            uimg = rs1.getString("PHOTO");
        }
        rs1.close();
               }
        
		int sdtype = 0;
		String videoimg = "";
		String fileExtension = "";
        sql = "select * from SHARE_DATA where deleted = 0 and RID = " + id + " order by id asc";
        rs1 = u_stmt1.executeQuery(sql);
        if (rs1.next()) {
			sdtype = rs1.getInt("type");
			if (sdtype == 0) {
	            data_path = rs1.getString("DATAPATH");
			} else {
				video_path = rs1.getString("DATAPATH");
				if (video_path != null && video_path != "") {
					int idx2 = video_path.lastIndexOf(".");
					fileExtension = video_path.substring(idx2 + 1);
					videoimg = video_path.replace(fileExtension, "jpg");
				}
			}
        }
        rs1.close();
        
        title = rs.getString("TITLE");
        body = rs.getString("BODY");
        if (body != null && body.length() > 32)
			body = body.substring(0, 32) + "...";
        postdate = rs.getDate("POSTDATE");     
        readcount = rs.getInt("READCOUNT");

    %>
            <li class="sharedet">
                    <div class="shareinfo">
                            <div class="shareinfopic">
                                    <a href="share_info.jsp?id=<%=id %>">
                                        <% if (data_path.length() > 0) {%>
                                        <img src="<%=data_path%>" width="228" alt="" /></a>
                                        <% } else if (videoimg != "") {%>
                                        <img src="<%=videoimg%>" width="228" alt="" /></a>
                                        <% } else {%>
                                        <img src="img/share_img07.jpg" width="228" alt="" /></a>
										<% } %>
                            </div>
                            <div class="shareinfotxt" style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><%=body %></div>
                    </div>
                    <div class="sharebot clear">
                            <span class="fri"> <%=postdate%></span>
                            <a href="person.jsp?id=<%=uid %>">
                                    <img src="<%=uimg%>" width="34" height="34" alt="" />
                            </a>
                            <a href="person.jsp?id=<%=uid %>" class="mesxtx"><%=uname%></a>
                    </div>
            </li>
<% } 
    rs.close();
    stmt.close();
    u_stmt.close();
    u_stmt1.close();
%>
			</ul>
		</div>
		<div id="loading" align="center">loading</div>
	</div>
			
	<div class="page mar15 clear" align="center">
		共 <%= total_count%>条数据（<%= total_page%> 页）
		<a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);"><img src="img/page.jpg" alt="" /></a> 
		<select id="page" onchange="select_change();">
		<%
			int i = 0;
			for (i = total_page; i > 0;i--) {
				if (i == pagenum)   {
					out.println("<option value='" + i + "' selected>" + i + "</option>");
				}
				else {
					out.println("<option value='" + i + "'>" + i + "</option>");
				}
			}
		%>
		</select> 
		<a href="javascript:void(0)" onclick="change_page(<%=next_page%>)"><img src="img/page01.jpg" alt="" /></a>
	</div>
</div>
<div class="sharebtn">
    <% if (UserId != 0 && IsActive == 1) { 
        if (type != 0) {
        %>
    <a href="sharemy.jsp?type=<%=type%>"><img src="img/share.png" class="png" alt="" /></a>
    <% } 
               else {
        %>
        <a href="sharemy.jsp?type=1"><img src="img/share.png" class="png" alt="" /></a>
        <%
               }
       }
%>
</div>
<div class="includeDom" include="inc/footer.jsp"></div>
</body>
</html>