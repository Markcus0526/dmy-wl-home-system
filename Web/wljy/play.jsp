<%-- 
    Document   : play
    Created on : 10-Dec-2013, 10:14:06
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
    
</head>

<body>
<%@include file="connection.jsp" %>
<%
 Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++)
    {
        String name=cookies[i].getName();
        int pos=name.indexOf('#');
        if(pos != -1)
        {
            if(name.substring(0, pos).equals("wljyid"))
            {
                tmp_str=name.substring(pos+1);
                break;
            }
        }
    }
    if (tmp_str.equals("")) 
        out.println("<script>window.location.href='login.jsp';</script>");

    int UserId = Integer.parseInt(tmp_str, 10);
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

        
    request.setCharacterEncoding("UTF-8");
    
     String spage = request.getParameter("page")== null?"0":request.getParameter("page");
     int pagenum = Integer.parseInt(spage);
     int pagecount = 8;
     
    
     Statement stmt = conn.createStatement();   
     Statement u_stmt = conn.createStatement();
        
     String sql = "select count(*) as count from ACTIVITY_INFO where " + youke_context + " deleted = 0 and type = 2 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR')";
     ResultSet rs = stmt.executeQuery(sql);
     
     int total_count = 0, total_page = 0;
    
     if (rs.next()) {
        total_count = rs.getInt("count");
    /*    if (total_count == 0) {
            out.println("<script>window.location.href='postevent.jsp';</script>");
            return;
        }*/
        
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = total_page;
    }
     
    rs.close();
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;
    
    ResultSet rs1 = null;    
    
    int last_index = total_count - (total_page - pagenum) * pagecount;
    int first_index = last_index - pagecount + 1;
    if (first_index <= 0) first_index = 1;
    
    sql = "select * from (select * from (select * from ACTIVITY_INFO where " + youke_context + " deleted = 0 and type = 2 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by id) where ID >= (select MAX(ID) from (select * from (select * from ACTIVITY_INFO where " + youke_context + " deleted = 0 and type = 2 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
    rs = stmt.executeQuery(sql);
    
    String title = new String();
    Date postdate = new Date(1,11,1);
    int readcount = 0;
    String body = new String();
    String imagepath = new String();
    int img_index = 0;
    int id = 0, mid = 0, eval_count = 0;
    String act_user = new String();
    int clob_length = 0;
    Clob clob = null;
    
%>
 <script type="text/javascript">
    $(function(){
	$(".includeDom").each(function(){
            var html = $(this).attr("include");
            $(this).load(html,function() {
		$(".menu li a").eq(1).css("color","#b20101");
		$(".toptit span a").eq(0).addClass("now");
                 $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
 
            });
	})
    })
    
    function change_page(index) {
        window.location.href = "play.jsp?page=" + index;
    }
    
    function select_change() {
        change_page($("#page").val());
    }
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
            <div class="content fle">
		<div class="conttop playconttop"></div>
                    <div class="main">
                        <div class="faqlist">                            
                            <ul class="clear">
                            <%
                               while (rs.next()) {
                                id = rs.getInt("id");
                                mid = rs.getInt("mid");
                                
                                sql = "Select * from memberinfo where deleted = 0 and id = " + mid;
                                rs1 = u_stmt.executeQuery(sql);
                                
                                while (rs1.next()) {
                                    act_user = rs1.getString("name");
                                }
                                rs1.close();
                                
                                title = rs.getString("title");
                                
                                sql = "Select * from activity_image where deleted = 0 and aid = " + id;
                                rs1 = u_stmt.executeQuery(sql);
                                if (rs1.next()) {
                                    imagepath = rs1.getString("datapath"); 
                                }
                                rs1.close();   
                                
                                clob = rs.getClob("body");
                                clob_length = (clob == null)?-1:(int)clob.length();
        
                                if (clob_length < 0)
                                    body = "";
                                else if (clob_length > 32)
                                    body = clob.getSubString(1, 32) + "...";
                                else 
                                    body = clob.getSubString(1, clob_length);
        
                                postdate = rs.getDate("postdate");     
                                readcount = rs.getInt("readcount");
                                
                                sql = "select count(*) as count from activity_eval where aid = " + id;
                                rs1 = u_stmt.executeQuery(sql);
                                if (rs1.next()) {
                                    eval_count = rs1.getInt("count");
                                }
                                rs1.close(); 
                            %>
				<li class="clear">
                                    <div class="playlistl fle">
					<a href="play_info.jsp?id=<%=id%>">
                                            <img src="<%=imagepath%>" style="width: 100%" alt="" />
                                        </a>
                                    </div>
                                    <div class="playlistr fri">
					<h3>
                                            <a href="play_info.jsp?id=<%=id%>">管理者: <%=title%></a>
                                        </h3>
					<p>
                                            <span>活动时间：<%=postdate%></span>
                                            浏览：<span style="color:#fc741a"><%=readcount%></span>
                                            评论：<span style="color:#0065a5"><%=eval_count%></span> 
                                        </p>
					<div class="faqintro">
                                            <%=body%>
                                            <a href="play_info.jsp?id=<%=id%>">[详细]</a>
                                        </div>
                                    </div>
				</li>
                                <% } 
                                   rs.close();
                                   stmt.close();
                                   u_stmt.close();
                                   conn.close();
                                %>						
			</ul>
                    </div>
                    <!-- paginator -->
                    <div class="page mar15 clear" align="center">
                            共 <%=total_count%>条数据（<%=total_page%> 页）
                            <a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);">
                                 <img src="img/page.jpg" alt="" />
                            </a> 
                            <select id="page" onchange="select_change();">
                            <%
                                int i = 0;
                                for (i = total_page; i > 0;i--) {
                                    if (i == pagenum)   {                                                  
                            %>
                                <option value="<%=i%>" selected="true"><%=i%></option>
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
                <div class="contbot"></div>
            </div>
            <div class="includeDom" include="inc/playright.jsp"></div>		
	</div>
    </div>
    <div class="includeDom" include="inc/footer.jsp"></div>
</body>
</html>