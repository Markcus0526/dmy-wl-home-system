<%-- 
    Document   : person
    Created on : 2013/12/15, 下午 01:41:28
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
<%@ page language="Java" import="java.sql.*" %>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->

</head>
<body>
<%@ include file="connection.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    
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

    
    
   Statement stmt = conn.createStatement();   
    
    String sid = request.getParameter("id")== null?"0":request.getParameter("id");
    int user_id = Integer.parseInt(sid);
    if (user_id == 0){
         out.println("<script>history.back();</script>");
         return;
    }

    String sql = "Select * from MEMBERINFO where ID = " + user_id;
    ResultSet rs = stmt.executeQuery(sql);
    
    String name = "";
    String oname = "";
    String phone = "";
    String image = "";
    int     nIntegral = 0;
    
    while (rs.next()) {
        name = rs.getString("NAME");
        oname = name;
        image = rs.getString("PHOTO");
        nIntegral = rs.getInt("INTEGRAL");
        phone = rs.getString("PHONENUM");
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
                <div class="myinfotop personcon">
                    <table width="100%">
                        <tr>
                            <td rowspan="3" width="110">
                                <img src="<%=image%>" width="75" height="75" alt=""/>
                            </td>
                            <td width="290">登录名：<%=name %></td>
                            <td>昵称：<%= oname%></td>
			</tr>
			<tr>
                            <td>联系方式：<%=phone%></td>
                            <td>积分：<%=nIntegral %></td>
			</tr>
                    </table>
		</div>
            </div>
            <div class="bigbot"></div>
	</div>
    </div>
    <div class="includeDom" include="inc/footer.jsp"></div>
<%
    stmt.close();
    rs.close();
    conn.close();
%>
</body>
</html>
