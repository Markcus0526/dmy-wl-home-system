
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<meta charset="UTF-8">
<title></title>
<meta name="keywords" content=""  />
<meta name="description" content="" />
<meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
<link rel="shortcut icon" href="favicon.ico">
<link rel="icon" href="logo.png" type="logo.png" >
<link href="css/css.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->
<script type="text/javascript">
$(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html);
	})
})
</script>
