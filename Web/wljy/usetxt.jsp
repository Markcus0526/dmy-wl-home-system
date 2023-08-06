<%-- 
    Document   : law
    Created on : 10-Dec-2013, 10:10:01
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
<script type="text/javascript">
$(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html);
	})
	$(".toptit span a").eq(3).addClass("now");
})
</script>
</head>
<body>
<%@include file="cookie_check.jsp" %>
<div class="w964">
	<div class="includeDom" include="inc/top.jsp"></div>
	<div class="toptit maptoptit">
		<b>家园</b>
		<span><a href="sitemap.jsp">网站地图</a><a href="law.jsp">法律申明</a><a href="contact.jsp">联系我们</a><a href="usetxt.jsp">使用说明</a></span>
	</div>
	<div class="site clear">
		<div class="bigtop"></div>
		<div class="bigmid">
			<div class="lawcon">资料整理中...</div>
		</div>
		<div class="bigbot"></div>
	</div>
</div>
<div class="includeDom" include="inc/footer.jsp"></div>
</body>
</html>
