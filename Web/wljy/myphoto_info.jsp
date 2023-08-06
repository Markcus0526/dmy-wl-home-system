<%-- 
    Document   : postphoto
    Created on : 10-Dec-2013, 10:16:18
    Author     : KIMSUI
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
        <link href="css/css.css" rel="stylesheet" type="text/css" />
        <script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
        <script type="text/javascript" src="js/jQuery-fileUploadButton.1.0.js"></script>
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->

    </head>
    <%@include file="connection.jsp" %>
    <body>
        <%
            Cookie[] cookies = request.getCookies();
            String tmp_str = "";
            for (int i = 0; i < cookies.length; i++) {
                String name = cookies[i].getName();
                int pos = name.indexOf('#');

                if (pos != -1) {
                    if (name.substring(0, pos).equals("wljyid")) {
                        tmp_str = name.substring(pos + 1);
                        break;
                    }
                }
            }
            int UserId = Integer.parseInt(tmp_str, 10);
            if (UserId == 0) {
                out.println("<script>history.back();</script>");
                return;
            }
            ResultSet rs2;
            Statement stmt2 = conn.createStatement();
            String sql1 = "";
            String username1 = "";
            String vip = "vip.jsp";
            if (UserId == 0) {
                username1 = "游客";
                vip = "#";
            } else {
                sql1 = "select * from memberinfo where id =" + UserId;
                rs2 = stmt2.executeQuery(sql1);
                if (rs2.next()) {
                    username1 = rs2.getString("name");
                }
                rs2.close();
            }

            Integer pid = Integer.parseInt(((request.getParameter("id") == null) ? "0" : request.getParameter("id")), 10);

            String title = "", body = "", path = "";
            Date postdate = new Date(1, 11, 1);

            sql1 = "select * from member_data where deleted = 0 and id =" + pid;
            rs2 = stmt2.executeQuery(sql1);
            if (rs2.next()) {
                title = rs2.getString("TITLE");
                body = rs2.getString("BODY");
                body = body.replaceAll("\r\n", "<br>");
                body = body.replaceAll("\n", "<br>");
                postdate = rs2.getDate("POSTDATE");
        %>
        <script type="text/javascript">
            $(function(){
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
                $(".toptit span a").eq(1).addClass("now");
            })
        </script>
        <div class="w964">
            <div class="includeDom" include="inc/top.jsp"></div>
            <div class="toptit exchangetit">
                <b>会员</b>
                <span>
                    <a href="vip.jsp">基本信息</a>
                    <a href="myphoto.jsp">我的照片</a>
                    <a href="myvideo.jsp">我的分享</a>
                    <a href="myquestion.jsp">我的问答</a>
                    <a href="myinfo.jsp">我的资料</a>
                    <a href="myexchange.jsp">我的兑换</a>
                    <a href="myidea.jsp">我的献策</a>
                </span>
            </div>
            <div class="site clear">
                <div class="bigtop exchange_bigtop"></div>
                <div class="bigmid">
                    <div class="main">           
                        <div class="study_tit">
                            <b><%=title%></b>
                            <p><span>发布时间：<%=postdate%></span></p>
                        </div>
                        <div class="photoEdit_con">
							<%
								String queryImage = "select * from member_image where deleted = 0 and rid = " + pid;
								Statement queryStmt = conn.createStatement();
								ResultSet queryRS = queryStmt.executeQuery(queryImage);
								while (queryRS.next())
								{
									path = queryRS.getString("datapath");
							%>
							<div style="text-align: center">
								<img align="center" src="<%=path%>" width="100%" alt="" />
								<p>&nbsp;</p>
							</div>
							<%
								}
								queryRS.close();
								queryStmt.close();
								}
								rs2.close();
							%>
							<p>&nbsp;</p>
                            <p align="center" class="update_input" style = "width: 100%"><%=body%></p>
                        </div>
                    </div>
                </div>
                    <div class="bigbot"></div>
                

            </div>

        </div>
        <div class="includeDom" include="inc/footer.jsp"></div>
        
    </body>
</html>