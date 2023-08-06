<%-- 
    Document   : postquestion
    Created on : 10-Dec-2013, 10:16:45
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


    %>
    <script type="text/javascript">
        $(function(){
            $(".includeDom").each(function(){
            var html = $(this).attr("include")    ;
                $(this).load(html,function() {
                    $(".name").html("<%=username1%>");
                    $(".vip").attr("href", "<%=vip%>");
                });
            })
        })
    </script>
    <script type="text/javascript">
        $(function() {
            $(".toptit span a").eq(3).addClass("now");
        })
    </script>
    <%
        Statement stmt = conn.createStatement();

        String sql = "select COUNT(*) from PROBLEM_TYPE";
        ResultSet rs = stmt.executeQuery(sql);

        int type_count = 0;
        if (rs.next()) {
            type_count = rs.getInt(1);
        }

        rs.close();

        String[] type_names = new String[type_count];

        int i;
        i = 0;
        sql = "select NAME from PROBLEM_TYPE";
        rs = stmt.executeQuery(sql);
        while (rs.next()) {
            type_names[i] = rs.getString("NAME");
            i++;
        }
        rs.close();

        sql = "select * from integralreason where id = 14";
        rs = stmt.executeQuery(sql);
        int max_integral = 0;
        while (rs.next()) {
            max_integral = rs.getInt("DEFAULTINTEGRAL");
        }

        rs.close();
        
        Integer pid = Integer.parseInt(((request.getParameter("id")== null)?"0":request.getParameter("id")), 10);
            
        String title = "", body = "";
        int type = 0, integral = 0;

        sql1 = "select * from PROBLEM_QINFO where id =" + pid;
        rs2 = stmt2.executeQuery(sql1);
        if (rs2.next()) {
            title = rs2.getString("TITLE");
            body = rs2.getString("BODY");
            type = rs2.getInt("TYPE");
            integral = rs2.getInt("REWARDINTEGRAL");
        }
        rs2.close();
        
        stmt.close();
        conn.close();

    %>
    <body>
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
                    <div class="myinfoupdate">
                        <form action="postquestion_add.jsp" method="post"  id="submit_form">
                            <input type="hidden" id="question_id" name="question_id" value="<%=pid%>" />
                            <h5>问题发布</h5>
                            <table width="100%">
                                <tr>
                                    <td width="110" align="right">标题：</td>
                                    <td><input type="text" id="ques_title" name="ques_title" class="update_input" value="<%=title%>" /></td>
                                </tr>
                                <tr>
                                    <td width="110" align="right">分类：</td>
                                    <td>
                                        <input type="hidden"  name="ques_type" id="ques_type" />
                                        <div class="update_input01">
                                            <dl class="postvideoselect" style="height:37px; vertical-align: middle;">
                                                <dt style="height:37px;" vertical-align="middle"><a style="height:30px;" vertical-align="middle" href="javascript:void(0)">&nbsp;</a><div style="height:37px;padding-top: 8px"><% if (type == 0) {%>请选择分类<%} else { out.print(type_names[type-1]); }%></div></dt>
                                                <dd>
                                                    <ul>
                                                        <% for (i = 0; i < type_count; i++) {%>
                                                        <li><%=type_names[i]%></li>
                                                        <% }%>
                                                    </ul>
                                                </dd>
                                            </dl>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="110" align="right">悬赏积分：</td>
                                    <td class="clear">
                                        <input type="text"  id="ques_integral" name="ques_integral" class="update_input fle" style="width:55px;" value="<% if (integral > 0) out.print(integral); %>" /> <span class="num fle" style="padding:15px 0 0 5px;">&nbsp;输入该资料积分值，最大值为&nbsp;<%=max_integral%></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="110" align="right" valign="top">描述：</td>
                                    <td colspan="2">
                                        <textarea  name="ques_body" class="upadate_area" id="ques_body"><%=body%></textarea>
                                    </td>
                                </tr>
                            </table>
                            <div class="faqansbtn" style="margin-left:125px;"><input type="button" value="发布问题" class="vipbtn01" onClick="do_submit();" /></div>
                        </form>
                    </div>
                </div>
                <div class="bigbot"></div>
            </div>
        </div>
        <div class="includeDom" include="inc/footer.jsp"></div>
        <script type="text/javascript">
            $(function() {
                $(".postvideoselect a").click(function() {
                    if($(this).parent().next().css("display")=="none") {
                        $(this).parent().next().slideDown();
                    }else {
                        $(this).parent().next().slideUp();
                    }
                })
                $(".postvideoselect li").click(function() {
                    $(".postvideoselect div").html($(this).html());
                    $(".postvideoselect dd").slideUp();
                })          
            });

            function do_submit()
            {
                $("#ques_type").val($(".postvideoselect div").html());
        
                if ($("#ques_title").val().length == 0) {
                    alert("请输入您的主题");
                    return;
                }
        
                if ($("#ques_type").val() == "请选择分类") {
                    alert("请输入分类");
                    return;
                }
        
                if (isNaN($("#ques_integral").val()) || $("#ques_integral").val() == "") {
                    alert("请输入正确积分");
                    return;
                }
        
                if ($("#ques_integral").val() > parseInt('<%=max_integral%>', 10)) {
                    alert("您已超量输入了积分");
                    return;
                }
        
                if ($("#ques_body").val().length == 0) {
                    alert("请输入您的描述");
                    return;
                }
        
        
                $("#submit_form").submit();
            }
        </script>
    </body>
</html>