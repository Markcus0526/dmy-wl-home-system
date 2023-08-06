<%-- 
    Document   : feedback
    Created on : 10-Dec-2013, 10:07:40
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
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
        <script type="text/javascript" src="js/jQuery-fileUploadButton.1.0.js"></script>
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->


    </head>
    <%@ include file="connection.jsp" %>
    <%
        Cookie[] cookies = request.getCookies();
        String tmp_str = "";
		String str_IsActive = "";
        for (int i = 0; i < cookies.length; i++) {
            String name = cookies[i].getName();
            int pos = name.indexOf('#');

            if (pos != -1) {
                if (name.substring(0, pos).equals("wljyid")) {
                    tmp_str = name.substring(pos + 1);
                }
				if (name.substring(0, pos).equals("wljyisactive")) {
                    str_IsActive = name.substring(pos + 1);
                }
            }
        }
        int UserId = Integer.parseInt(tmp_str, 10);
		int IsActive = 0;

		String queryFirstLogin = "select firstlogin from memberinfo where id = " + UserId;
		Statement stmtFirstLogin = conn.createStatement();
		ResultSet rsFirstLogin = stmtFirstLogin.executeQuery(queryFirstLogin);
		if (rsFirstLogin.next()) {
			IsActive = rsFirstLogin.getInt("firstlogin");
		}
		rsFirstLogin.close();
		stmtFirstLogin.close();

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


        request.setCharacterEncoding("UTF-8");

        Statement stmt = conn.createStatement();
        Statement stmt1 = conn.createStatement();
        String sql;
        ResultSet rs;

        //------------max integral 8 members------------
        int integral_member_count = 8;
        int cur_integral_member_count = 0;
        int[] integral_opinion_ids = new int[integral_member_count];
        String[] integral_opinion_titles = new String[integral_member_count];
        int[] integral_opinion_integrals = new int[integral_member_count];
        int i;

        sql = "select * from (select * from (SELECT MID,SUM(GAININTEGRAL) AS subtotal FROM OPINION WHERE STATE=1 GROUP BY MID ORDER BY MID desc) INNER JOIN MEMBERINFO ON MID=MEMBERINFO.ID) where ROWNUM <=" + integral_member_count;
        rs = stmt.executeQuery(sql);

        i = 0;
        while (rs.next()) {
            if (i == integral_member_count) {
                break;
            }

            integral_opinion_ids[i] = rs.getInt("ID");
            integral_opinion_titles[i] = rs.getString("NAME");
            if (integral_opinion_titles[i].length() > 4) {
                integral_opinion_titles[i] = integral_opinion_titles[i].substring(0, 4) + "...";
            }
            integral_opinion_integrals[i] = rs.getInt("subtotal");

            i++;
        }
        cur_integral_member_count = i;
        rs.close();

        Integer pid = Integer.parseInt(((request.getParameter("id") == null) ? "0" : request.getParameter("id")), 10);

        String title = "", body = "", path = "";

        sql1 = "select * from OPINION where id =" + pid;
        rs2 = stmt2.executeQuery(sql1);
        if (rs2.next()) {
            title = rs2.getString("TITLE");
            body = rs2.getString("BODY");
            path = rs2.getString("DATAPATH");
            if (path == null || path == "" || path.equals("upload_data/feedback/")) {
                path = "";
            } else {
                path = path.substring(path.lastIndexOf("/") + 1);
            }
        }
        rs2.close();

        stmt.close();
        conn.close();
    %>
    <script type="text/javascript">
        $(function(){
            $(".includeDom").each(function(){
                var html = $(this).attr("include");
                $(this).load(html,function() {
                    $(".menu li a").eq(5).css("color","#9b139b");
                    $(".toptit span a").eq(0).addClass("now");
                    $(".box3rcon li:lt(3)").find("span.num").addClass("on1");
                        
                    $(".vip").attr("href", "<%=vip%>");
                });
            })
        })
    </script>
    <body>
        <div class="w964">
            <div class="includeDom" include="inc/top.jsp"></div>
            <div class="toptit feedtit">
                <b>献策</b>

            </div>
            <div class="site clear">
                <div class="content fle">
                    <form action="feedback_add.jsp" method="post"  enctype="multipart/form-data" name="submit_form" id="submit_form">
                        <input type="hidden" id="feed_id" name="feed_id" value="<%=pid%>" />
                        <div class="conttop"></div>
                        <div class="main">
                            <div class="study_tit">
                                <b>卧龙的明天，离不开你的建言献策</b>
                                <p>马上献策，获取积分，被采纳认可的献策内容还能获得高额积分哦！</p>
                            </div>
                            <div class="feedbacktab marT20">
                                <table width="100%">
                                    <tr>
                                        <td>
                                            <p>标题</p>
                                            <input type="text" class="feed_input" name="feed_title" id="title" value="<%=title%>" />
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>
                                            <p>内容</p>
                                            <textarea class="feed_area" name="feed_body" ><%=body%></textarea>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>
                                            <p>上传附件</p>
                                            <table><tr>
                                                    <td><input type='text' class='update_input fle' id='filepath' name='filepath' disabled='disabled' value="<%=path%>" /></td>
                                                    <td width="40px" align="center"><input type='file' id='uploadfile' name='uploadfile' onChange='$("#filepath").val($("#uploadfile").val());' /></td>
                                                    <td><a href='javascript:void(0)' class='update_cancel' onclick='$("#filepath").val(""); $("#uploadfile").val("");'>撤销</a>                                    </td>
                                                </tr></table>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td><div class="studybtn">
                                                <% if (UserId != 0 && IsActive == 1) {%>
                                                <a  onClick="do_submit();">提 交</a>
                                                <%}%>
                                            </div></td>
                                    </tr>
                                </table>
                            </div>				
                        </div>
                        <div class="contbot"></div>
                    </form>
                </div>
                <% if (UserId != 0) { %>
                <div class="right fri">
                    <div class="faqtwo">
                        <div class="faqtwotit">献策积分排行榜</div>
                        <div class="faqtwocon">
                            <div class="box3rcon">
                                <ul>
                                    <% for (i = 0; i < cur_integral_member_count; i++) {%>
                                    <li>
                                        <span class="num"><%=i + 1%></span> 
                                        <span class="name"><%=integral_opinion_titles[i]%></span> 
                                        <span class="total">积分: <%=integral_opinion_integrals[i]%></span>
                                    </li>
                                    <% }%>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
        <div class="includeDom" include="inc/footer.jsp"></div>
    </body>

    <script type="text/javascript">
        $(function() {
            $('#uploadfile').fileUploadButton({
                height: '24px',
                width: '24px',
                image: 'img/load.png'
            });
        });
        function do_submit()
        {
            if ($("#title").val().length == 0)
            {
                alert("请输入您的标题");
                return;
            }
            $("#submit_form").submit();
        }
    </script>

</html>