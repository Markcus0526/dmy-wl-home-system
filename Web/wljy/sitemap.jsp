<%-- 
    Document   : sitemap
    Created on : 10-Dec-2013, 10:19:26
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
<link rel="icon" href="logo.png" type="logo.png"/>
<link href="css/css.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
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

               
%>
<script type="text/javascript">
$(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html, function() {
                           $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
                });
	})
	$(".toptit span a").eq(0).addClass("now");
})
</script>
</head>
<body>
<div class="w964">
	<div class="includeDom" include="inc/top.jsp"></div>
	<div class="toptit maptoptit">
		<b>家园</b>
		<span><a href="sitemap.jsp">网站地图</a><a href="law.jsp">法律申明</a><a href="contact.jsp">联系我们</a><a href="usetxt.jsp">使用说明</a></span>
	</div>
	<div class="site clear">
		<div class="bigtop"></div>
		<div class="bigmid">
			<div class="mapcon">
				<div class="mapmenu"><a href="login.jsp">登陆页</a></div>
				<div class="mapmenu"><a href="index.jsp">首页</a></div>
				<div class="line"></div>
				<div class="smapmenu">
					<ul class="clear">
						<li><a href="play.jsp">活动</a><a href="play.jsp">卧龙活动</a><a href="play.jsp">个人活动</a><a href="postevent.jsp">发起活动</a></li>
						<li><a href="share.jsp">分享</a><a href="share.jsp">分享列表</a><a href="postphoto.jsp">我要分享</a></li>
						<li><a href="faq.jsp">问答</a><a href="faq.jsp">专业知识</a><a href="faq.jsp">企业相关</a><a href="faq.jsp">其他综合</a></li>
						<li><a href="study.jsp">学习</a><a href="study.jsp">类别列表</a></li>
						<li><a href="feedback.jsp">献策</a></li>
						<li><a href="exchange.jsp">兑换</a><a href="exchange.jsp">商品列表</a></li>
                                                <li><a href="vip.jsp">会员</a><a href="vip.jsp">基本信息</a><a href="myphoto.jsp">我的照片</a><a href="myvideo.jsp">我的分享</a><a href="myquestion.jsp">我的问答</a><a href="myinfo.jsp">我的资料</a><a href="myidea.jsp">我的献策</a><a href="myexchange.jsp">我的兑换</a><a href="mycart.jsp">我的兑换购物车</a></li>
					</ul>
				</div>
			</div>
		</div>
		<div class="bigbot"></div>
	</div>
</div>
<div class="includeDom" include="inc/footer.jsp"></div>
</body>
</html>
