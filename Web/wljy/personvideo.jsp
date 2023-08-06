<%-- 
    Document   : personvideo
    Created on : 2013/12/15, 下午 01:42:19
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@include file="connection.jsp" %>
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
    
    ResultSet rs2;
    Statement stmt2 = conn.createStatement();
    String sql1 = "";
  String username1="";
        String vip = "vip.jsp";
    if (UserId == 0 ) {
        username1= "游客";
        vip = "#";
               }
    else 
               {
            sql1 = "select * from memberinfo where id =" + UserId;
            rs2 = stmt2.executeQuery(sql1);
            if (rs2.next()) {
                username1 = rs2.getString("name");
            }
            rs2.close();
    }

        
    request.setCharacterEncoding("UTF-8");    
    String sid = request.getParameter("id")== null?"0":request.getParameter("id");
    int user_id = Integer.parseInt(sid);
    if (user_id == 0){
       out.println("<script>history.back();</script>");
       return;
    }
    
    String spage = request.getParameter("page")== null?"0":request.getParameter("page");
    int pagenum = Integer.parseInt(spage);
    int pagecount = 8;
               
    Statement stmt = conn.createStatement();   
    Statement u_stmt = conn.createStatement();
    
    String sql = "select count(*) as count from member_data where type = 1 and deleted = 0  and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and mid = " + user_id;
       
    ResultSet rs = stmt.executeQuery(sql);
     
    int total_count = 0, total_page = 0;
    
     if (rs.next()) {
        total_count = rs.getInt("count");
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
    
    sql = "select * from (select * from (select * from member_data where type = 1 and deleted = 0 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and mid = '" + user_id + "' order by id) where ID >= (select MAX(ID) from (select * from (select * from member_data where type = 1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and mid = '" + user_id + "' order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
                
    rs = stmt.executeQuery(sql);
    
    String title = new String();
    String image_path = new String();    
%>
<script type="text/javascript">
$(function() {
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html,function() {
                      $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
                });
	})
})
</script>
<script type="text/javascript">
$(function() {
	$(".toptit span a").eq(2).addClass("now");
})
 function change_page(index) {
        window.location.href = "personvideo.jsp?id=<%=sid%>&page=" + index;            
    }
    
    function select_change() {
        change_page($("#page").val());
    }
</script>
<body>
<div class="w964">
	<div class="includeDom" include="inc/top.jsp"></div>
	<div class="toptit exchangetit">
		<b>会员</b>
		<span>
			<a href="person.jsp?id=<%=sid%>">基本信息</a>
			<a href="personphoto.jsp?id=<%=sid%>">他的照片</a>
			<a href="personvideo.jsp?id=<%=sid%>">他的视频</a>
		</span>
	</div>
	<div class="site clear">
		<div class="bigtop exchange_bigtop"></div>
		<div class="bigmid">
			<div class="exchangelist myphotolist marT20">
				<ul class="clear">
                                     <%
                                    while (rs.next()) {
                                        title = rs.getString("title");
                                        image_path = rs.getString("defimage");
                                %>
					<li align="center">
						<img src="<%=image_path%>" width="196" height="217" />
						<span><%=title%></span>						
					</li>
                                 <%
                                    };
                                    rs.close();
                                    stmt.close();
                                    conn.close();    
                                 %>					
				</ul>
			</div>
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
                                <option value="<%=i%>" selected="selected"><%=i%></option>
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