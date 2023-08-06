<%-- 
    Document   : video_play
    Created on : 2014/1/20, 上午 09:07:11
    Author     : kimsui
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
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
           <script src="js/jquery.js" type="text/javascript"></script>
<script src="js/jwplayer.min.js" type="text/javascript"></script>

	</head>
    <body>
        <%
        String filename = (request.getParameter("name") == null)?"":request.getParameter("name");
        %>
        
        <div id="content">
<script type="text/javascript">
    $(function(){
        $(".items img").click(function() {
            jwplayer().playlistItem($(this).attr("idx"));
        });
    });
</script>


<div id="container">
    <div align="center"  style="margin-top: 50px;">
        <div id="screen">Loading the player ...</div>

        <script type="text/javascript">
            jwplayer("screen").setup({
                flashplayer: "js/player.swf",
                playlist: eval([{"file": "<%=filename%>"}]),
                height: 360,
                width: 640
            });

        </script>
    </div>
</div>
        </div>
   
    </body>
</html>
