<%-- 
    Document   : passmail
    Created on : Jan 30, 2014, 2:43:20 PM
    Author     : Hercules
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>卧龙家园后台</title>
<meta name="keywords" content="" />
<meta name="description" content="" />
<meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
<meta name="renderer" content="webkit" />
<link href="favicon.ico" rel="shortcut icon" />
<link href="css/reset.css" rel="stylesheet" type="text/css" />
<link href="css/style.css"  rel="stylesheet" type="text/css" />
<script type="text/javascript" src="js/jQuery.js"></script>

<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->
</head>

<body class="nobg">
        <table style="height: 100%; width: 100%" border ="0px" cellpadding="0px" cellspacing ="0px">
        <tr><td align="center">
            <table class="mailcon" style="margin-top: 100px;">                 
                <form action="mailcheck.jsp" method="post">
                    <tr><td><h1>忘记密码了?</h1></td></tr>
                    <tr><td><img src="img/forget_img.jpg" /></td></tr>
                    <tr><td>请输入您注册时输入的邮箱地址, 重新设置您的密码</td></tr>
                    <tr><td>
                            <img src="img/login_img01.jpg" height="37px"/>
                            <input type="text" class="inputname" style="width:310px;" onClick="this.value=''" onBlur="if(this.value==''){this.value='会员账号'}" value="会员账号"  name="username"/> 
                    </td></tr>
                    <tr><td>
                            <img src="img/mail_img01.jpg" height="37px"/>
                            <input type="text" class="inputmail" onClick="this.value=''" onBlur="if(this.value==''){this.value='Email地址'}" value="Email地址"  name="mailaddr"/> 
                    </td></tr>
                    <tr>
                        <td style="padding-left: 20px; padding-right: 20px; padding-bottom: 20px;">
                            <input type="button" class="mailbtn-back" value="返回" onclick="window.location='login.jsp'"/>
                            <input type="submit" class="mailbtn-post" value="发送邮件" />
                        </td>
                    </tr>
                </form>
            </table>
        </td></tr>
    </table>
</body>
</html>
