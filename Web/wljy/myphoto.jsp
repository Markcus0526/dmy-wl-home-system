<%-- 
    Document   : myphoto
    Created on : 10-Dec-2013, 10:11:57
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@ include file="connection.jsp" %>
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

        <script type="text/javascript">
            $(function() {
                $(".toptit span a").eq(1).addClass("now");
            })
    
            function change_page(index) {
                window.location.href = "myphoto.jsp?page=" + index;            
            }
    
            function select_change() {
                change_page($("#page").val());
            }
        </script>
    </head>
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

            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();

            String sql = "select count(*) as count from member_data where deleted = 0 and mid = " + UserId;

            ResultSet rs = stmt.executeQuery(sql);

            int total_count = 0, total_page = 0;

            if (rs.next()) {
                total_count = rs.getInt("count");
                /*if (total_count == 0) {
                    out.println("<script>window.location.href='postphoto.jsp';</script>");
                    return;
                }*/

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

            sql = "select * from (select * from (select * from member_data where deleted = 0 and mid = '" + UserId + "' order by id) where ID >= (select MAX(ID) from (select * from (select * from member_data where deleted = 0 and mid = '" + UserId + "' order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";

            rs = stmt.executeQuery(sql);

            int photoid = 0;
            String title = new String();
            String image_path = new String();
            Date postdate;
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
                    <div class="editbtn" align="right"><a href="postphoto.jsp">上 传 照 片</a></div>
                    <div class="photoEdit">
                        <div class="myexchangetit">
                            <span style="width:120px; border-right:1px solid #e0e0e0; margin-left: 30px;">简缩图</span>
                            <span style="width:210px; border-right:1px solid #e0e0e0; text-align:center">标题</span>
                            <span style="width:180px; border-right:1px solid #e0e0e0; text-align:center">日期</span>
                            <span style="width:220px; text-align:center">操作</span>
                        </div>
                        <div class="myexchangelist photEditCon">
                            <ul>
                                <form action="myphoto_del.jsp" method="post" id="submit_form">
                                    <%
                                        int tmpInd = 0;
                                        while (rs.next()) {
                                            photoid = rs.getInt("ID");
                                            title = rs.getString("title");
											String queryImage = "select * from member_image where deleted = 0 and rid = " + photoid;
											Statement queryStmt = conn.createStatement();
											ResultSet queryRS = queryStmt.executeQuery(queryImage);
											if (queryRS.next())
	                                            image_path = queryRS.getString("datapath");
											queryRS.close();
											queryStmt.close();
                                            postdate = rs.getDate("postdate");
                                    %>
                                    <li class="clear">
                                        <span style="width:20px;" class="editCheck">
                                            <input type="checkbox" name="check_<%=tmpInd%>" value="" />
                                            <input type="hidden" name="id_<%=tmpInd%>" value="<%=photoid%>" />
                                        </span>
                                        <span style="width:120px;">
											<img src="<%=image_path%>" width="102" height="77" alt="">
										</span>
                                        <span class="editTit" style="width:215px; text-align:center;"><%=title%></span>
                                        <span style="width:190px; text-align:center;"><%=postdate%></span>
                                        <span style="width:260px; text-align:center;"><a href="myphoto_info.jsp?id=<%=photoid%>">查看详细</a> | <a href="javascript:;" class="editDelete" onclick="delete_act('<%=photoid%>')">删除</a> | <a href="postphoto.jsp?id=<%=photoid%>">编辑</a> | <a href="myphoto_mine_add.jsp?id=<%=photoid%>">分享照片</a></span>
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
            
            function delete_act(id)
            {
                if (confirm("您要删除你的照片吗?"))
                {
                    window.location.href = "myphoto_del.jsp?id="+id;
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
                    if (confirm("您确定要把勾选的照片删除吗?"))
                    {
                        $("#submit_form").submit();
                    }
                }
            }
        </script>
    </body>
</html>