<%-- 
    Document   : single
    Created on : 10-Dec-2013, 10:18:37
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="UTF-8"/>
<title></title>
<meta name="keywords" content=""  />
<meta name="description" content="" />
<meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
<link rel="shortcut icon" href="favicon.ico"/>
<link rel="icon" href="logo.png" type="logo.png" />
<link href="css/css.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->

<script type="text/javascript" src="js/lazyload.js"></script>
<script type="text/javascript" src="js/jquery.masonry.min.js"></script>
<script>
    $(function(){
            var $container = $('#containerPic'),sTimer;
            $container.imagesLoaded(function(){
                  $container.masonry({
                 itemSelector: '.singleli',
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
      
      function change_page(index) {
        window.location.href = "single.jsp?page=" + index;
      }
      
      function select_change() {
        change_page($("#page").val());
      }
 
</script>
</head>
<body>
<%@ include file="connection.jsp" %>


<%
    request.setCharacterEncoding("UTF-8");
    
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

    String sql = "select count(*) as count from ACTIVITY_INFO where " + youke_context + " deleted = 0 and type = 1 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR')";
    ResultSet rs = stmt.executeQuery(sql);
    
    int total_count = 0;
    int total_page = 0;
    
    if (rs.next()) {
        total_count = rs.getInt("count");
    /*    if (total_count == 0)
            out.println("<script>window.location.href='postevent.jsp';</script>");*/
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = total_page;
    }
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;   
        
    int last_index = total_count - (total_page - pagenum) * pagecount;
    int first_index = last_index - pagecount + 1;
    if (first_index <= 0) first_index = 1;
    
    sql = "select * from (select * from (select * from ACTIVITY_INFO where " + youke_context + " deleted = 0 and type = 1 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by id) where ID >= (select MAX(ID) from (select * from (select * from ACTIVITY_INFO where " + youke_context + " deleted = 0 and type = 1 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
    rs = stmt.executeQuery(sql);
    
    ResultSet rs1;
    String title = new String();
    String body = new String();
    String imagepath = new String();
    String act_user = new String();
    Date postdate = new Date(1,11,1);
    int readcount = 0,img_index = 0;
    int id = 0, mid = 0;
    int entry_cnt = 0, clob_length = 0;
    Clob clob = null;
%>    
<script type="text/javascript">
$(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html,function() {
			$(".menu li a").eq(1).css("color","#b20101");;
			$(".toptit span a").eq(1).addClass("now");
                           $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
		});
	})
})
</script>
    <div class="w964">
        <div class="includeDom" include="inc/top.jsp"></div>
	<div class="toptit playtit">
            <b>活动</b>
            <span>
                <a href="play.jsp">卧龙活动展示</a>
                <a href="single.jsp">个人活动组织</a>
            </span>
	</div>
	<div class="site clear">
            <div class="bigtop"></div>
		<div class="bigmid">
                    <div class="singlebtn" align="right">
                        <% if (UserId != 0 && IsActive == 1)  { %>
                        <a href="postevent.jsp">发 起 活 动</a>
                        <% } %>
                    </div>
                    <div class="singlelist" id="containerPic">
                        <ul class="clear">
                        <%
                           while (rs.next()) {
                                id = rs.getInt("id");
                                mid = rs.getInt("mid");
                                if (mid == 0) {
                                    act_user = "管理者";
                                }
                                                               else {
                                sql = "Select * from memberinfo where id = " + mid;
                                rs1 = u_stmt.executeQuery(sql);
                                while (rs1.next()) {
                                    act_user = rs1.getString("name");
                                }
                                rs1.close();
                                                               }
                                
                                sql = "Select count(*) as count from activity_entry where deleted = 0 and aid =" + id;
                                rs1 = u_stmt.executeQuery(sql);
                                while (rs1.next()) {
                                    entry_cnt = rs1.getInt(1);
                                }
                                rs1.close();
                                
                                title = rs.getString("title");
                                
                                sql = "Select * from activity_image where deleted = 0 and aid = " + id;
                                rs1 = u_stmt.executeQuery(sql);
                                imagepath = "";
                                if (rs1.next()) {
                                    imagepath = rs1.getString("datapath"); 
                                }
                                rs1.close();   

                                postdate = rs.getDate("postdate");     
                                readcount = rs.getInt("readcount");
                                
                                clob = rs.getClob("body");
                                clob_length = (clob == null)?-1:(int)clob.length();
        
                                if (clob_length < 0) body = "";
                                else if (clob_length > 32)
                                   body = clob.getSubString(1, 32) + "...";
                                else 
                                    body = clob.getSubString(1, clob_length);
                        %>
                            <li class="singleli">
				<h3 style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><a href="single_info.jsp?id=<%=id%>"><%=title%></a></h3>
				<p>
                                    <span><%=postdate%></span>
                                    <span>参加：<%=entry_cnt%> 人</span>
                                    <span>发起人：<%=act_user%></span>
                                </p>
				<div>
                                    <img src="<%=imagepath%>" width="100%" alt=""/>
                                    <%=body%>
                                </div>
			</li>
                       <% 
                           }
                           rs.close();
                           stmt.close();
                           u_stmt.close();
                           conn.close();
                        %>
                    </ul>
                </div>
                <!--<div id="loading" align="center">loading</div>-->
                <div class="page mar15 clear" align="center">
                    共 <%=total_count%>条数据（<%=total_page%> 页）
                    <a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);">
                        <img src="img/page.jpg" alt=""/>
                    </a> 
                    <select id="page" onchange="select_change();">
                    <%
                        int i = 0;
                        for (i = total_page; i > 0;i--) {
                           if (i == pagenum)   {                                                  
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
                    <a href="javascript:void(0)" onclick="change_page(<%=next_page%>)">
                        <img src="img/page01.jpg" alt=""/>
                    </a>
                </div>
            </div>
            <div class="bigbot"></div>
        </div>
    </div>
    <div class="includeDom" include="inc/footer.jsp"></div>
</body>
</html>