<%-- 
    Document   : index
    Created on : Dec 25, 2013, 11:23:48 AM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>卧龙家园后台</title>
<meta name="keywords" content=""  />
<meta name="description" content="" />
<meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
<link rel="shortcut icon" href="favicon.ico" />
<link rel="icon" href="logo.png" type="logo.png" />
<link href="css/css_login.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="js/jquery-1.7.2.js"></script>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->
</head>
<body>
<div class="main">
  <div class="bigbox">
    <div class="button">
      <form action="user_test.jsp" method="post">
      <input name="act" value="login" type="hidden">
        <div class="login">
          <h1>用户登录</h1>
          <div class="input">
            <li>
				<div class="dloginbg">
              <input name="username" type="text" class="text1" />
			  </div>
            </li>
            <li>
				<div class="dloginpwdbg">
              <input name="password" type="password" class="text2" />
			  </div>
            </li>
          </div>
          <div class="" style="font-size: 12px;">
		  <input type="submit" style="background:url(img/cms/login1.jpg); width:86px; height:22px;"  value=" "/>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

</body>
</html>
