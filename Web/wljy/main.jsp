
<%@page contentType="text/html" pageEncoding="UTF-8"%>

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
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->


<script type="text/javascript" src="js/banner.js"></script>
</head>
<%@include file="cookie_check.jsp" %>
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
    
    request.setCharacterEncoding("UTF-8");
    
    Statement stmt = conn.createStatement();
    Statement stmt1 = conn.createStatement();
    String sql, sql1;
    ResultSet rs, rs1;
        String username="";
        String vip = "vip.jsp";
    if (UserId == 0 ) {
        username = "游客";
        youke_context = "ISPUBLIC = 1 and ";
        vip = "#";
               }
    else 
               {
            sql = "select * from memberinfo where deleted = 0 and id =" + UserId;
            rs = stmt.executeQuery(sql);
            if (rs.next()) {
                username = rs.getString("name");
            }
            rs.close();
    }
    
    //------------Selected Activity------------
    sql = "select ID, TITLE, BODY from ACTIVITY_INFO where " + youke_context + " deleted = 0 and type=2 and ISSELECTED=1";
    rs = stmt.executeQuery(sql);
    
    int select_activity_count = 4;
    int cur_select_activity_count = 0;
    int[] select_activity_ids = new int[select_activity_count];
    String[] select_activity_titles = new String[select_activity_count];
    String[] select_activity_bodys = new String[select_activity_count];
    String[] select_activity_images = new String[select_activity_count];
    
    int i;
    
    i = 0;
    while ( rs.next() )
    {
        if ( i == select_activity_count )
            break;
        
        select_activity_ids[i] = rs.getInt("ID");
        select_activity_titles[i] = rs.getString("TITLE");
        select_activity_bodys[i] = rs.getString("BODY") == null ? "" : rs.getString("BODY");
        
        if ( select_activity_bodys[i].length() > 38 )
            select_activity_bodys[i] = select_activity_bodys[i].substring(0, 35) + "...";
        
        sql1 = "select DATAPATH from ACTIVITY_IMAGE where deleted = 0 and AID='"+select_activity_ids[i]+"'";
        rs1 = stmt1.executeQuery(sql1);
        
        if ( rs1.next() )
            select_activity_images[i] = rs1.getString("DATAPATH");
        else
            select_activity_images[i] = "";
        rs1.close();
        i++;
    }
    cur_select_activity_count = i;
    rs.close();
    
    //------------Recent 8 Activity------------
    int recent_activity_count = 8;
    int cur_recent_activity_count = 0;
    int[] recent_activity_ids = new int[recent_activity_count];
    String[] recent_activity_titles = new String[recent_activity_count];
    String[] recent_activity_bodys = new String[recent_activity_count];
    Date[] recent_activity_dates = new Date[recent_activity_count];
    
    sql = "select * from (select * from ACTIVITY_INFO where " + youke_context + " deleted = 0 and type = 2 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') ORDER BY ID DESC) where ROWNUM <= " + recent_activity_count;
    rs = stmt.executeQuery(sql);
    
    i = 0;
    while ( rs.next() )
    {
        if ( i == recent_activity_count )
            break;
        
        recent_activity_titles[i] = "";
        recent_activity_bodys[i] = "";
        
        recent_activity_ids[i] = rs.getInt("ID");
        recent_activity_titles[i] = rs.getString("TITLE") == null ? "" : rs.getString("TITLE");
        recent_activity_bodys[i] = rs.getString("BODY") == null ? "" : rs.getString("BODY");
        recent_activity_dates[i] = rs.getDate("POSTDATE");
        
        if ( recent_activity_titles[i].length() > 18 )
            recent_activity_titles[i] = recent_activity_titles[i].substring(0, 15) + "...";
        
        if ( recent_activity_bodys[i].length() > 58 )
            recent_activity_bodys[i] = recent_activity_bodys[i].substring(0, 55) + "...";
        i++;
    }
    cur_recent_activity_count = i;
    rs.close();
    
    //------------Recent 4 Problem------------
    int recent_problem_count = 4;
    int cur_recent_problem_count = 0;
    int[] recent_problem_ids = new int[recent_problem_count];
    String[] recent_problem_titles = new String[recent_problem_count];
    String[] recent_problem_images = new String[recent_problem_count];
    Date[] recent_problem_dates = new Date[recent_problem_count];
    
    sql = "select * from (select * from PROBLEM_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') ORDER BY ID DESC) where ROWNUM <= " + recent_problem_count;
    rs = stmt.executeQuery(sql);
    
    i = 0;
    while ( rs.next() )
    {
        if ( i == recent_problem_count )
            break;
        
        recent_problem_titles[i] = "";
        
        recent_problem_ids[i] = rs.getInt("ID");
        recent_problem_titles[i] = rs.getString("TITLE") == null ? "" : rs.getString("TITLE");
        recent_problem_dates[i] = rs.getDate("POSTDATE");
        
        if ( recent_problem_titles[i].length() > 38 )
            recent_problem_titles[i] = recent_problem_titles[i].substring(0, 35) + "...";
        
        sql1 = "select PHOTO from MEMBERINFO where deleted = 0 and ID='"+rs.getInt("MID")+"'";
        rs1 = stmt1.executeQuery(sql1);
        
        if ( rs1.next() )
            recent_problem_images[i] = rs1.getString("PHOTO");
        else
            recent_problem_images[i] = "";
        
        rs1.close();
        
        i++;
    }
    cur_recent_problem_count = i;
    rs.close();
    
    
    //------------Recent 6 Share------------
    int recent_share_count = 6;
    int cur_recent_share_count = 6;
    int[] recent_share_ids = new int[recent_share_count];
    String[] recent_share_titles = new String[recent_share_count];
    String[] recent_share_images = new String[recent_share_count];
    
    sql = "select * from (select * from SHARE_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') ORDER BY ID DESC) where ROWNUM <= " + recent_share_count;
    rs = stmt.executeQuery(sql);
    
    i = 0;
    while ( rs.next() )
    {
        if ( i == recent_share_count )
            break;
        
        recent_share_titles[i] = "";
        
        recent_share_ids[i] = rs.getInt("ID");
        recent_share_titles[i] = rs.getString("TITLE") == null ? "" : rs.getString("TITLE");
        
        if ( recent_share_titles[i].length() > 13 )
            recent_share_titles[i] = recent_share_titles[i].substring(0, 10) + "...";
        
        sql1 = "select * from SHARE_DATA where deleted = 0 and RID='"+recent_share_ids[i]+"'";
        rs1 = stmt1.executeQuery(sql1);
        
		String videoimg = "";
		String fileExtension = "";
		String video_path = "";
		int sdtype = 0;
        if ( rs1.next() ) {
			sdtype = rs1.getInt("type");
			if (sdtype == 0) {
	            recent_share_images[i] = rs1.getString("DATAPATH");
			} else {
				video_path = rs1.getString("DATAPATH");
				if (video_path != null && video_path != "") {
					int idx2 = video_path.lastIndexOf(".");
					fileExtension = video_path.substring(idx2 + 1);
					videoimg = video_path.replace(fileExtension, "jpg");
					recent_share_images[i] = videoimg;
				} else {
					recent_share_images[i] = "img/share_img07.jpg";
				}
			}

		} else {
		}
        
        rs1.close();
        
        i++;
    }
    cur_recent_share_count = i;
    rs.close();
    
    //------------Recent 6 Product------------
    int recent_product_count = 6;
    int cur_recent_product_count = 0;
    int[] recent_product_ids = new int[recent_product_count];
    String[] recent_product_names = new String[recent_product_count];
    int[] recent_product_integrals = new int[recent_product_count];
    String[] recent_product_images = new String[recent_product_count];
    
    sql = "select * from (select * from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 ORDER BY ID DESC) where ROWNUM <= " + recent_product_count;
    rs = stmt.executeQuery(sql);
    
    i = 0;
    while ( rs.next() )
    {
        if ( i == recent_product_count )
            break;
        
        recent_product_names[i] = "";
        
        recent_product_ids[i] = rs.getInt("ID");
        recent_product_names[i] = rs.getString("NAME") == null ? "" : rs.getString("NAME");
        recent_product_integrals[i] = rs.getInt("INTEGRAL_PRICE");
        
        if ( recent_product_names[i].length() > 13 )
            recent_product_names[i] = recent_product_names[i].substring(0, 10) + "...";
        
        sql1 = "select DATAPATH from PRODUCT_IMAGE where deleted = 0 and PID='"+recent_product_ids[i]+"'";
        rs1 = stmt1.executeQuery(sql1);
        
        if ( rs1.next() )
            recent_product_images[i] = rs1.getString("DATAPATH");
        else
            recent_product_images[i] = "";
        
        rs1.close();
        
        i++;
    }
    cur_recent_product_count = i;
    rs.close();
  
    //------------Recent 5 Study------------
    int recent_study_count = 5;
    int cur_recent_study_count = 0;
    int[] recent_study_ids = new int[recent_study_count];
    String[] recent_study_titles = new String[recent_study_count];
    String[] recent_study_images = new String[recent_study_count];
    Date[] recent_study_dates = new Date[recent_study_count];
    
    sql = "select * from (select * from STUDY_QINFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') ORDER BY ID DESC) where ROWNUM <= " + recent_study_count;
    rs = stmt.executeQuery(sql);
    
    i = 0;
    while ( rs.next() )
    {
        if ( i == recent_study_count )
            break;
        
        recent_study_titles[i] = "";
        
        recent_study_ids[i] = rs.getInt("ID");
        recent_study_titles[i] = rs.getString("TITLE") == null ? "" : rs.getString("TITLE");
        recent_study_images[i] = rs.getString("IMAGEPATH");
        recent_study_dates[i] = rs.getDate("POSTDATE");
        
        if ( recent_study_titles[i].length() > 18 )
            recent_study_titles[i] = recent_study_titles[i].substring(0, 15) + "...";

        i++;
    }
    cur_recent_study_count = i;
    rs.close();
    
    
    //------------max integral 8 members------------
    int integral_member_count = 8;
    int cur_integral_member_count = 0;
    int[] integral_member_ids = new int[integral_member_count];
    String[] integral_member_names = new String[integral_member_count];
    int[] integral_member_integrals = new int[integral_member_count];
    
    
    sql = "select * from (select * from MEMBERINFO where deleted = 0 ORDER BY INTEGRAL DESC) where firstlogin = 1 and ROWNUM <= " + integral_member_count;
    rs = stmt.executeQuery(sql);
    
    i = 0;
    while ( rs.next() )
    {
        if ( i == integral_member_count )
            break;
        
        integral_member_ids[i] = rs.getInt("ID");
        integral_member_names[i] = rs.getString("NAME");
        integral_member_integrals[i] = rs.getInt("INTEGRAL");

        i++;
    }
    cur_integral_member_count = i;
    rs.close();
    
    stmt.close();
    stmt1.close();
    conn.close();
    
%>
<script type="text/javascript">
    $(function(){
	$(".includeDom").each(function(){
            var html = $(this).attr("include");
            $(this).load(html, function() {
                $(".includeDom .menu li a").eq(0).addClass("on");
                $(".box3rcon li:lt(3)").find("span.num").addClass("on");
                $(".includeDom .name").html("<%=username%>");
                $(".includeDom .vip").attr("href", "<%=vip%>");
            });
	})
    })
</script>
<body>
    <div class="w960">
        <div class="includeDom" include="inc/top.jsp"></div>
        <div class="indextit">
            <span>> <a href="main.jsp">首页</a></span>
        </div>
        <div class="box1 clear">
            <div class="box1l fle">
                <div class="box1lcon">
                    <ul>
                        <% for ( i = 0; i < cur_select_activity_count; i ++) { %>
                        <li>
                            <p><img src="<%=select_activity_images[i]%>" style="width:100%" alt="" /></p>
                            <h3><a href="play_info.jsp?id=<%=select_activity_ids[i]%>"><%=select_activity_titles[i]%></a></h3>
                            <p><a href="play_info.jsp?id=<%=select_activity_ids[i]%>"><%=select_activity_bodys[i]%></a></p>
                        </li>
                        <% } %>
                    </ul>
                </div>
                <div class="box1btn"></div>
            </div>
            <div class="box1r fri">
                <div class="box1rtit clear"><a href="play.jsp">查看更多</a><b>最新活动</b></div>
                <div class="box1rhot mar">		
					<% if (recent_activity_titles[0] == null) { %>
					<% } else {%>
                    <h4><a href="play_info.jsp?id=<%=recent_activity_ids[0]%>"><%=recent_activity_titles[0]%></a></h4>
                    <time><%=recent_activity_dates[0]%></time>
                    <p><%=recent_activity_bodys[0]%><a href="play_info.jsp?id=<%=recent_activity_ids[0]%>">[详细]</a></p>
					<% } %>
                </div>
                <div class="box1rlist">
                    <ul>
                        <% for ( i = 1; i < cur_recent_activity_count; i++ ) { %>
                        <li class="clear"><span><%=recent_activity_dates[i]%></span><a href="play_info.jsp?id=<%=recent_activity_ids[i]%>"><%=recent_activity_titles[i]%></a></li>
                        <% } %>
                    </ul>
                </div>
            </div>
        </div>
        <div class="box2 clear">
            <div class="box2l fle">
                <div class="box2ltit"><a href="faq.jsp">查看更多</a><b>问答</b></div>
                <div class="box2lcon">
                <ul>
                    <% for ( i = 0; i < cur_recent_problem_count; i++ ) { %>
                    <li class="clear">
                        <div class="box2ldet fri">
                            <a href="faq_info.jsp?id=<%=recent_problem_ids[i]%>"><%=recent_problem_titles[i]%></a>
                            <p><%=recent_problem_dates[i]%></p>
                        </div>
                        <a href="faq_info.jsp?id=<%=recent_problem_ids[i]%>"><img src="<%=recent_problem_images[i]%>" width="48" height="48" alt="" /></a>
                    </li>
                    <% } %>
                </ul>
                </div>
            </div>
            <div class="box2r fri">
                <div class="box2ltit"><a href="share.jsp">查看更多</a><b>分享</b></div>
                <div class="box2rcon">
                    <ul>
                        <% for ( i = 0; i < cur_recent_share_count; i++ ) { %>
                        <li>
                            <a href="share_info.jsp?id=<%=recent_share_ids[i]%>">
                                <img src="<%=recent_share_images[i]%>" style="width: 100%;" alt="" />
                                <%=recent_share_titles[i]%>
                            </a>
                        </li>
                        <% } %>
                    </ul>
                </div>
            </div>
        </div>
        <div class="box3 clear">
            <div class="box3l fle">
                <div class="box3ltit"><a href="exchange.jsp">查看更多</a><b>兑换</b></div>
                <div class="box3lcon">
                    <ul>
                        <% for ( i = 0; i < cur_recent_product_count; i++ ) { 
                            %>
                        <li>
                            <a href="exchange_info.jsp?id=<%=recent_product_ids[i]%>">
                                <img src="<%=recent_product_images[i]%>" width="90" height="69" alt="" />
                            </a>
                            <p><a href="exchange_info.jsp?id=<%=recent_product_ids[i]%>"><%=recent_product_names[i]%></a></p>
                            <p><%=recent_product_integrals[i]%>积分</p>
                        </li>
                        <% } %>
                    </ul>
                </div>
            </div>
            <div class="box3m fle">
                <div class="box3ltit"><a href="study.jsp">查看更多</a><b>学习</b></div>
				<%
					if (recent_study_images[0] != null)
					{
				%>
                <div><img src="<%=recent_study_images[0]%>" width="274" height="99" alt="" /></div>
				<%
					}
				%>
                <div class="box3mcon">
                    <ul>
                        <% for(i = 0; i < cur_recent_study_count; i++) { %>
                        <li><span class="fri">[<%=recent_study_dates[i]%>]</span><a href="study_info.jsp?id=<%=recent_study_ids[i]%>"><%=recent_study_titles[i]%></a></li>
                        <% } %>
                    </ul>
                </div>
            </div>
            <div class="box3r fri">
                <div class="box3ltit"><b>积分排行</b></div>
                <div class="box3rcon">
                    <ul>
                        <% for(i = 0; i < cur_integral_member_count; i++) {
		%>
                        <li>
						<span class="num"><%=i+1%></span> 
						<span class="name"><a class="mj-ellipsis" href="person.jsp?id=<%=integral_member_ids[i]%>"><%=integral_member_names[i]%></a></span> 
						<span class="total">积分: <%=integral_member_integrals[i]%></span></li>
                        <% } %>
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <div class="includeDom" include="inc/footer.jsp"></div>
</body>
</html>
