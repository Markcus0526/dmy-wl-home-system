<%-- 
    Document   : myidea
    Created on : 2013/12/15, 下午 01:40:54
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
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->


    </head>
    <%@ include file="connection.jsp" %>
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


            request.setCharacterEncoding("UTF-8");

            String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");
            int pagenum = Integer.parseInt(spage);
            int pagecount = 8;

            int idea_state = Integer.parseInt(request.getParameter("state") == null ? "-1" : request.getParameter("state"));

            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();

            String sql = "select count(*) as count from OPINION where deleted = 0 and mid = " + UserId;
            if (idea_state > -1) {
                sql = sql + " and state = " + idea_state;
            }


            ResultSet rs = stmt.executeQuery(sql);

            int total_count = 0, total_page = 0;

            if (rs.next()) {
                total_count = rs.getInt("count");
                /*
                if (total_count == 0) {
                    out.println("<script>window.location.href='feedback.jsp';</script>");
                    return;
                }
                */
                total_page = (total_count - 1) / pagecount + 1;
                if (pagenum == 0) {
                    pagenum = total_page;
                }
            }

            rs.close();

            int prev_page = 1, next_page = total_page;
            if (pagenum > 1) {
                prev_page = pagenum - 1;
            }
            if (pagenum < total_page) {
                next_page = pagenum + 1;
            }

            ResultSet rs1 = null;

            int last_index = total_count - (total_page - pagenum) * pagecount;
            int first_index = last_index - pagecount + 1;
            if (first_index <= 0) {
                first_index = 1;
            }

            if (idea_state < 0) {
                sql = "select * from (select * from (select * from OPINION where deleted = 0 and mid = '" + UserId + "' order by id) where ID >= (select MAX(ID) from (select * from (select * from OPINION where deleted = 0 and mid = '" + UserId + "' order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
            } else {
                sql = "select * from (select * from (select * from OPINION where deleted = 0 and state = " + idea_state + " and mid = '" + UserId + "' order by id) where ID >= (select MAX(ID) from (select * from (select * from OPINION where deleted = 0 and state = " + idea_state + " and mid = '" + UserId + "' order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
            }

            rs = stmt.executeQuery(sql);

            String title = new String();
            Date postdate = new Date(1, 11, 1);

            String body = new String();
            String state_str = new String();
            int id = 0, state = 0, gainintegral = 0;

            int clob_length = 0;
            Clob clob = null;


        %>
        <script type="text/javascript">
            $(function() {
                $(".includeDom").each(function(){
                    var html = $(this).attr("include"        );
                    $(this).load(html, function()         {
                        $(".name").html("<%=username1%>");
                        $(".vip").attr("href", "<%=vip%>");

                    });
                })
            })
        </script>
        <script type="text/javascript">
            $(function() {
                $(".toptit span a").eq(6).addClass("now");
                $(".myinfo li").eq(<%=idea_state%> + 1).find("span").show().css("display","block");
                $(".myinfo li a").eq(<%=idea_state%> + 1).addClass("on");
                // $(".myinfo li a").hover(function() {
                // 	$(this).addClass("on");
                // 	$(this).parent().find("span").show().css("display","block");
                // }, function() {
                // 	$(this).removeClass("on");
                // 	$(this).parent().find("span").hide();
                // })
            })
            function change_page(index) {
                if (<%=idea_state%> < 0)
                window.location.href = "myidea.jsp?page=" + index;
                else
                    window.location.href = "myidea.jsp?page=" + index + "&state=" + <%=idea_state%>;
             
            }
    
            function select_change() {
                change_page($("#page").val());
            }
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
                    <div class="myinfo">
                        <ul class="clear">
                            <li>
                                <a href="myidea.jsp">全部</a>
                                <span><img src="img/myidea_img03.jpg" width="10" height="4" alt="" /></span>
                            </li>
                            <li>
                                <a href="myidea.jsp?state=0">未采纳</a>
                                <span><img src="img/myidea_img03.jpg" width="10" height="4" alt="" /></span>
                            </li>
                            <li>
                                <a href="myidea.jsp?state=1">已采纳</a>
                                <span><img src="img/myidea_img03.jpg" width="10" height="4" alt="" /></span>
                            </li>
                        </ul>
                    </div>

                    <div class="photoEdit">
                        <div class="myexchangetit">
                            <span style="width:180px; border-right:1px solid #e0e0e0; padding-left: 80px;">标题</span>
                            <span style="width:150px; border-right:1px solid #e0e0e0; text-align:center">状态</span>
                            <span style="width:160px; border-right:1px solid #e0e0e0; text-align:center">献策日期</span>
                            <span style="width:170px; text-align:center">操作</span>
                        </div>
                        <div class="myexchangelist photEditCon">
                            <ul>
                                <form action="myidea_del.jsp" method="post" id="submit_form">
                                    <%
                                        int tmpInd = 0;
                                        while (rs.next()) {
                                            id = rs.getInt("id");
                                            title = rs.getString("title");

                                            clob = rs.getClob("body");
                                            clob_length = (clob == null) ? -1 : (int) clob.length();

                                            if (clob_length < 0) {
                                                body = "";
                                            } else {
                                                body = clob.getSubString(1, clob_length);
                                            }

                                            postdate = rs.getDate("postdate");
                                            state = rs.getInt("state");
                                            gainintegral = rs.getInt("gainintegral");
                                            if (state == 1) {
                                                state_str = "已采纳";
                                            } else if (state == 0) {
                                                state_str = "未采纳";
                                            }
                                    %>
                                    <li class="clear" style="height: 100px;">
                                        <span style="width:20px;" class="editCheck">
                                            <input type="checkbox" name="check_<%=tmpInd%>" value="" />
                                            <input type="hidden" name="id_<%=tmpInd%>" value="<%=id%>" />
                                        </span>
                                        <span style="width:230px;"><%=title%></span>
                                        <span style="width:160px; text-align:center;"><em style="color: #0e8102; font-size: 13px;"><%=state_str%></em>
										<%if (gainintegral != -1) {%>
										&nbsp;:&nbsp;&nbsp;&nbsp;										
										<em style="color: #e2022c; font-size: 24px;"><%=gainintegral%></em>&nbsp;分
										<%}%>
										</span>								
                                        <span style="width:165px; text-align:center;"><%=postdate%></span>
                                        <span style="width:195px; text-align:center;"><a href="feedback_info.jsp?id=<%=id%>">查看详细</a> | <a href="javascript:;" class="editDelete" onclick="delete_act('<%=id%>', '<%=title%>')">删除</a>  <a <% if (state == 0) { %> href="feedback.jsp?id=<%=id%>" <%}%> >| 编辑</a></span>
                                    </li>
                                    <%
                                            tmpInd++;
                                        };
                                        rs.close();
                                        stmt.close();
                                        conn.close();
                                    %> 
                                </form>
                            </ul>
                        </div>
                        <div class="mycartbot mar15 clear">
                            <div class="page mar fri" align="right">
                                共 <%=total_count%>条数据（<%=total_page%> 页）
                                <a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);">
                                    <img src="img/page.jpg" alt=""/>
                                </a> 
                                <select id="page" onchange="select_change();">
                                    <%
                                        int i = 0;
                                        for (i = total_page; i > 0; i--) {
                                            if (i == pagenum) {
                                    %>
                                    <option value="<%=i%>" selected="selected"><%=i%></option>
                                    <%
                                    } else {
                                    %>
                                    <option value="<%=i%>"><%=i%></option>
                                    <%
                                            }
                                        }
                                    %>   
                                </select> 
                                <a href="javascript:void(0)" onclick="change_page(<%=next_page%>)">
                                    <img src="img/page01.jpg" alt=""/>
                                </a>
                            </div>
                            <span style="width:20px;" class="checkall"><input name="" id="selectAll" type="checkbox" value="" /></span><span style="padding:0 10px;">全选</span> | <a href="javascript:void(0)" class="selectall" onclick="delete_act1()">删除</a>
                        </div>
                    </div>

                </div>
                <div class="bigbot"></div>
            </div>
        </div>
        <div class="includeDom" include="inc/footer.jsp"></div>

        <script>
            $(function() {
                $("#selectAll").click(function() {
                    var isSelect = this.checked;
                    if (isSelect) {
                        $(".myexchangelist li span.editCheck").each(function() {
                            $(this).find("input")[0].checked = true;
                        });
                    } else {
                        $(".myexchangelist li span.editCheck").each(function() {
                            $(this).find("input")[0].checked = false;
                        });
                    }
                });

                $(".myexchangelist li span.editCheck").find("input").click(function() {
                    var isSelect = this.checked;

                    if (!isSelect) {
                        $("#selectAll")[0].checked = false;
                    }
                });
    
            })
            
            function delete_act(id, title)
            {
                if (confirm("您确定要删除你的献策'" + title + "'吗?"))
                {
                    window.location.href = "myidea_del.jsp?id="+id;
                }
            }
    
            function delete_act1()
            {
                var selected_id = "";
                $('.myexchangelist input:checked').each(function () {
                    selected_id += this.value + ",";
                });
        
                if (selected_id != "")
                {
                    if (confirm("您确定要把勾选的献策删除吗?"))
                    {
                        $("#submit_form").submit();
                    }
                }
            }
        </script>
    </body>
</html>
