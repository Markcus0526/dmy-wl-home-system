<%-- 
    Document   : login
    Created on : 10-Dec-2013, 09:19:16
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

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
<%

        String userid = "";
        userid = (request.getParameter("type") == null)?"":request.getParameter("type");
        
%>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->
<script type="text/javascript">
    $(document).ready(function() {
       if ("<%=userid%>" == "userid")  {
           window.location.href="main.jsp";
       }
       else if ("<%=userid%>" == "nickname"){
           if (confirm("您为首次登陆，请修改用户名及设定密码，以后登陆用户名及密码登陆")) {               
                    window.location.href = "vip.jsp";
                    return;
           }               
                  else
           {
               window.location.href = "main.jsp";
           }
       }
     
    });
$(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html);
	})
})
</script>
<script type="text/javascript">
$(function(){
	$("input[type='text'], textarea").focus(function(){
		$(this).addClass("bg");
	})
	$("input[type='text'], textarea").blur(function(){
		$(this).removeClass("bg");
	})
})
</script>
</head>
<body class ="loginbg">
    <table style="height: 100%; width: 100%" border ="0px" cellpadding="0px" cellspacing ="0px">
        <tr><td style="vertical-align: top;" align="center">

	<div class="logintop" align="left">
		<span class="fri"><a href="javascript:void(0)" class="a1">集团官网</a><a href="javascript:void(0)">电气官网</a></span>
		<a href="index.jsp"><img src="img/logo_login.png" class="png" width="222" height="96" alt=""/></a>
	</div>
</td></tr>
<tr><td align="center" style="vertical-align: bottom">
	<div class="logincon png">
            <form action="user_test.jsp" method="post">
		<div class="loginradio" align="center">
			<input type="radio" name="loginradio" checked="checked" value="admin"/> <label>会员登录</label> <input type="radio" name="loginradio" value="user"/> <label>游客登录</label>
		</div>
		<div class="logininput" align="center">
			<img src="img/login_img01.jpg" height="37px"/><input type="text" class="inputname" onClick="this.value=''" placeholder="会员账号" value=""  name="username"/> 
			<img src="img/login_img02.jpg" height="37px"/><input type="password" class="inputpass" value="" onClick="this.value=''" placeholder="密码" name="password"/> 
			<input type="submit" class="inputbtn" value="登 录" />
		</div>
		<div class="">
                    <table>
                        <tr><td>&nbsp;&nbsp;&nbsp;</td></tr>
                        <tr>
                            <td><input type="checkbox" name="checktenday"/> <label>十天内免登录</label></td>
                            <td>&nbsp;&nbsp;&nbsp;</td>
                            <td width="120px" height="42px" style="font-weight: bold;" align="center"><span><a href="passmail.jsp">忘记密码了</a></span></td>
                        </tr>
                    </table>
		</div>
                </form>

	</div>
        </td></tr>
<tr><td align="center" style="vertical-align: bottom">
	<div class="loginfoot png" align="center">
		© 2014 卧龙家园  浙ICP备050246300
	</div>
        </td></tr>

        </table>
</body>
</html>
