<%-- 
    Document   : mycart
    Created on : 2013/12/15, 下午 01:40:27
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
        <%@page import="java.util.Date"%>
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->
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

            ResultSet rs3;
            Statement stmt2 = conn.createStatement();
            String sql1 = "";
            String username1 = "";
            String vip = "vip.jsp";
            if (UserId == 0) {
                username1 = "游客";
                vip = "#";
            } else {
                sql1 = "select * from memberinfo where id =" + UserId;
                rs3 = stmt2.executeQuery(sql1);
                if (rs3.next()) {
                    username1 = rs3.getString("name");
                }
                rs3.close();
            }


            request.setCharacterEncoding("UTF-8");

            String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");
            int pagenum = Integer.parseInt(spage);
            int pagecount = 8;

            int product_id = Integer.parseInt(request.getParameter("product_id") == null ? "0" : request.getParameter("product_id"));
            int exchange_count = Integer.parseInt(request.getParameter("exchange_count") == null ? "0" : request.getParameter("exchange_count"));
            int product_integral = Integer.parseInt(request.getParameter("product_integral") == null ? "0" : request.getParameter("product_integral"));
            int onlydisplay = Integer.parseInt(request.getParameter("onlydisplay") == null ? "1" : request.getParameter("onlydisplay"));

            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();
            Statement u_stmt1 = conn.createStatement();
            PreparedStatement pstmt;

            String sql;
            ResultSet rs = null, rs1 = null, rs2 = null;

            if (onlydisplay == 0) {
                int remaincnt = 0;
                ResultSet rs_remain;
                Statement stmt_remain = conn.createStatement();
                sql = "SELECT total_secure FROM PRODUCT_INFO where id = " + product_id;
                rs_remain = stmt_remain.executeQuery(sql);
                if (rs_remain.next()) {
                    remaincnt = rs_remain.getInt("total_secure");
                }
                rs_remain.close();

                if (remaincnt < 1) {
                    out.print("<script>alert('很抱歉！没有库存商品，不能兑换商品。'); window.location.href='mycart.jsp'</script>");
                    return;
                } else if (remaincnt < exchange_count) {
                    exchange_count = remaincnt;
                }

                sql = "select count(*) as count from ORDER_PRODUCT where deleted = 0 AND mid = " + UserId + " and state = -1 and pid = " + product_id;
                rs = stmt.executeQuery(sql);
                int cur_cnt = 0;
                int newId = 0;
                if (rs.next()) {
                    cur_cnt = rs.getInt("count");

                    if (cur_cnt == 0) {
                        sql = "select MAX(ID) as NEWID from ORDER_PRODUCT";
                        rs1 = stmt.executeQuery(sql);
                        if (rs1.next()) {
                            newId = rs1.getInt("NEWID");
                        }

                        newId++;

                        sql = "INSERT INTO ORDER_PRODUCT (ID, PID, MID, COUNT, PRICE, ORDERDATE, STATE) VALUES(?, ?, ?, ?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, newId);
                        pstmt.setInt(2, product_id);
                        pstmt.setInt(3, UserId);
                        pstmt.setInt(4, exchange_count);
                        pstmt.setInt(5, product_integral);
                        Date tmp = new Date();
                        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
                        pstmt.setTimestamp(6, d);
                        pstmt.setInt(7, -1);
                        pstmt.execute();
                        pstmt.close();
                    } else {
                        sql = "UPDATE ORDER_PRODUCT SET COUNT = COUNT + ? where deleted = 0 AND mid = " + UserId + " and state = -1 and pid = " + product_id;
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, exchange_count);
                        pstmt.execute();
                        pstmt.close();
                    }
                }

                sql = "UPDATE PRODUCT_INFO SET TOTAL_SECURE = TOTAL_SECURE - ? where id = " + product_id;
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, exchange_count);
                pstmt.execute();
                pstmt.close();
            }

            sql = "select count(*) as count from ORDER_PRODUCT where mid = " + UserId + " and state = -1 and deleted = 0";
            rs = stmt.executeQuery(sql);
            int total_count = 0, total_page = 0;

            if (rs.next()) {
                total_count = rs.getInt("count");


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

            int showcount = pagecount;
            int last_index = total_count - (total_page - pagenum) * pagecount;
            int first_index = last_index - pagecount + 1;
            if (first_index <= 0) {
                first_index = 1;
                showcount = last_index;
            }

            sql = "select * from (select * from (select * from ORDER_PRODUCT where deleted = 0 and mid = " + UserId + " and state = -1 order by id ASC) where id >= (select MAX(ID) from (select * from (select * from ORDER_PRODUCT where deleted = 0 and mid = " + UserId + " and state = -1 order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + showcount + ") order by id DESC";
            rs = stmt.executeQuery(sql);

            int rcount = 0;
            Statement u_stmt2 = conn.createStatement();
            sql = "select count(*) as count from ORDER_PRODUCT where deleted = 0 and mid = " + UserId + " and state = -1 order by id ASC";
            ResultSet rsforCount = u_stmt2.executeQuery(sql);
            if (rsforCount.next()) {
                rcount = rsforCount.getInt("count");
            }
            rsforCount.close();

            String name = new String();
            int id = 0, pid = 0, iid = 0;
            String username = new String();
            String imagepath = new String();
            int market_price = 0, integral_price = 0, product_count = 0;;
            String exchange_state = null;
            int state;
        %>
        <script type="text/javascript">
            $(function(){
                $(".includeDom").each(function(){
                    var html = $(this).attr("include");
                    $(this).load(html,function() {
                $(".top        tit span a").eq(5).addClass("now");
                        $(".name").html("<%=username1%>");
                        $(".vip").attr("href", "<%=vip%>");
                    });
                })
            })
            function change_page(index) {
                window.location.href = "mycart.jsp?page=" + index;
            }    
            function select_change() {
                change_page($("#page").val());
            }
            function delete_act(id, title)
            {
                if (confirm("您确定要删除 兑换购物车'" + title + "'吗?"))
                {
                    window.location.href = "mycart_del.jsp?id="+id+"&page=" + $("#page").val();
                }
            }
            function delete_act1()
            {
                var selected_id = "";
                $('.mycartlist input:checked').each(function () {
                    selected_id += this.value + ",";
                });

                if (selected_id != "")
                {
                    if (confirm("您确定要把勾选的商品从购物车删除吗?"))
                    {
                        $("#submit_form").submit();
                    }
                }
            }
        </script>
    </head>
    <body>
        <div class="w964">
            <div class="includeDom" include="inc/top.jsp"></div>
            <div class="toptit exchangetit">
                <b>兑换</b>
                <span>
                    <a href="exchange.jsp?type=0">0-2000￥</a>
                    <a href="exchange.jsp?type=1">2001-8000￥</a>
                    <a href="exchange.jsp?type=2">8001-10000￥</a>
                </span>
            </div>
            <div class="site clear">
                <div class="bigtop exchange_bigtop"></div>
                <div class="bigmid">
                    <div class="myexchange mycart">
                        <h4>兑换购物车</h4>
                        <% if (rcount != 0) {%> 
                        <div class="mycarttit">
                            <span style="width:170px;">礼品名称</span>
                            <span style="width:100px;">兑换数量</span>
                            <span style="width:100px;">市场价格</span>
                            <span style="width:100px;">所需积分</span>
                            <span style="width:45px;">操作</span>
                        </div>
                        <div class="mycartlist">
                            <ul>
                                <form action="mycart_del.jsp" method="post" id="submit_form">
                                    <%
                                        int tmpInd = 0;
                                        while (rs.next()) {
                                            id = rs.getInt("id");
                                            pid = rs.getInt("pid");
                                            product_count = rs.getInt("COUNT");

                                            sql = "select * from PRODUCT_INFO where id = " + pid;
                                            rs1 = u_stmt.executeQuery(sql);
                                            if (rs1.next()) {
                                                name = rs1.getString("name");
                                                iid = rs1.getInt("iid");

                                                sql = "select * from product_image where id = " + iid;
                                                rs2 = u_stmt1.executeQuery(sql);
                                                while (rs2.next()) {
                                                    imagepath = rs2.getString(3);
                                                }
                                                rs2.close();

                                                market_price = rs1.getInt("market_price");
                                                integral_price = rs1.getInt("integral_price");
                                            }
                                            rs1.close();

                                            state = rs.getInt("state");
                                    %>
                                    <li class="clear">

                                        <span style="width:20px; padding-top:25px;" class="mycart_check">
                                            <input name="<%="check_" + tmpInd%>" type="checkbox" class="chkProduct" value="<%=id%>"  />
                                            <input name="<%="id_" + tmpInd%>" type="hidden" value="<%=id%>" /></span>
                                        <span style="width:130px; height:80px;">
                                            <a href="exchange_info.jsp?id=<%=pid%>">
                                                <img src="<%=imagepath%>"  style="width:80px; height:80px; border:0px solid #cccccc" alt="" />
                                            </a>
                                        </span>
                                        <span style="width:160px;padding-top:20px;"><a href="exchange_info.jsp?id=<%=pid%>"><%=name%></a></span>
                                        <span style="width:80px;padding-left:25px;" class="mycartnum"><%=product_count%></span>
                                        <span style="width:100px;" class="mycartnum"><%=market_price * product_count%>元</span>
                                        <span style="width:90px;" class="mycartnum"><%=integral_price * product_count%>分</span>
                                        <span style="width:60px; cursor:pointer;" onclick="submit_act('<%=id%>', '<%=name%>')"> 立即兑换</span>
                                        <span style="width:30px; cursor:pointer; margin-top:10px" onclick="delete_act('<%=id%>', '<%=name%>')"> 删除</span>

                                    </li>	
                                    <%
                                            tmpInd++;
                                        }
                                        rs.close();
                                        stmt.close();
                                        u_stmt.close();
                                        u_stmt1.close();
                                        conn.close();
                                    %>
                                </form>
                            </ul>
                        </div>
                        <div class="mycartbot clear">
                            <span class="fri"><a href="javascript:;" onclick="submit_all();" style="">立即兑换</a></span>
                            <span style="width:20px;" class="checkall"><input name="" id="selectAll" type="checkbox" value="" />
                            </span><span style="padding:0 10px;">全选</span> | <a href="javascript:void(0)" class="selectall" onclick="delete_act1();">删除</a>
                            <div class="page mar15 clear" align="center">
                                共<%=total_count%>条数据（<%=total_page%>页）
                                <a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);"><img src="img/page.jpg" alt="" /></a> 
                                <select id="page" onchange="select_change();">
                                    <%
                                        int i = 0;
                                        for (i = total_page; i > 0; i--) {
                                            if (i == pagenum) {
                                    %>
                                    <option value = "<%=i%>" selected="selected"><%=i%></option>
                                    <%
                                    } else {
                                    %>
                                    <option value="<%=i%>"><%=i%></option>
                                    <%
                                            }
                                        }
                                    %>   
                                </select> 
                                <a href="javascript:void(0)" onclick="change_page(<%=next_page%>)"><img src="img/page01.jpg" alt="" /></a>
                            </div>
                        </div>
                        <% } else {%>
                        <div style="margin:auto; text-align:center; padding:50px; font-size:16px;">
                            购物车上没有商品！
                        </div>
                        <% }%>
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
                        $(".mycartlist li span.mycart_check").each(function() {
                            $(this).find("input")[0].checked = true;
                        });
                    } else {
                        $(".mycartlist li span.mycart_check").each(function() {
                            $(this).find("input")[0].checked = false;
                        });
                    }
                });

                $(".mycartlist li span.mycart_check").find("input").click(function() {
                    var isSelect = this.checked;

                    if (!isSelect) {
                        $("#selectAll")[0].checked = false;
                    }
                });
                $(".mycartbot a.selectall").click(function() {
                    $(".mycartlist li span.mycart_check").each(function() {
			
                        if ($(this).find("input")[0].checked) {
                            $(this).parent().remove();
                        };
                    });
                });
	
            })

            function submit_act(pid, pname)
            {
                if (confirm("您确定要兑换吗？"))
                {
                    window.location.href = "success.jsp" + "?pid=" + pid;
                }
            }
            function submit_all()
            {
                var selected_id = "";
                $('.mycartlist input:checked').each(function () {
                    selected_id += this.value + ",";
                });

                if (selected_id != "")
                {
                    submit_act(selected_id, "");
                }
            }

        </script>
    </body>
</html>
