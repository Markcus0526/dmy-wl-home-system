<%-- 
    Document   : exchange
    Created on : Jan 7, 2014, 2:36:51 PM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%@include file="cookie_check.jsp" %>
<%@page import="java.util.Date"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>卧龙家园后台</title>
        <meta name="keywords" content="" />
        <meta name="description" content="" />
        <meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
        <meta name="renderer" content="webkit"/>
        <link href="favicon.ico" rel="shortcut icon"/>
        <link href="css/reset.css" rel="stylesheet" type="text/css" />
        <link href="css/style.css"  rel="stylesheet" type="text/css" />
        <script type="text/javascript" src="js/jQuery.js"></script>
        <link rel="stylesheet" href="../css/themes/base/jquery.ui.all.css" />
        <script type="text/javascript" src="../js/jquery-1.9.0.min.js"></script>
        <link rel="stylesheet" href="css/pagination.css" />
        <script type="text/javascript" src="js/jquery.pagination.js"></script>
        <script type="text/javascript" src="../js/jquery.ui.core.js"></script>
        <script type="text/javascript" src="../js/jquery.ui.widget.js"></script>
        <script type="text/javascript" src="../js/jquery.ui.datepicker.js"></script>
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->
    </head>
    <%!    public String ConvertDateString(String dateStr) {
            String ret;
            String[] tmp = {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"};

            try {
                ret = dateStr.substring(8, 10) + "-" + tmp[Integer.parseInt(dateStr.substring(5, 7), 10) - 1] + "-" + dateStr.substring(0, 4);
            } catch (Exception e) {
                ret = "";
            }
            return ret;
        }

    %>

    <%
        Cookie[] cookies = request.getCookies();
        String tmp_str = "";

        for (int i = 0; i < cookies.length; i++) {
            String name = cookies[i].getName();
            int pos = name.indexOf('#');
            if (pos != -1) {
                if (name.substring(0, pos).equals("wljyadminid")) {
                    tmp_str = name.substring(pos + 1);
                    break;
                }
            }
        }
        int UserId = Integer.parseInt(tmp_str, 10);

        String search_name = request.getParameter("search_name") == null ? "" : request.getParameter("search_name");
        String search_title = request.getParameter("search_title") == null ? "" : request.getParameter("search_title");
		String search_type = request.getParameter("search_type") == null ? "3" : request.getParameter("search_type");
        String search_from = request.getParameter("from_datepicker") == null ? "" : request.getParameter("from_datepicker");
        String search_to = request.getParameter("to_datepicker") == null ? "" : request.getParameter("to_datepicker");

        String tmp_from = search_from;
        String tmp_to = search_to;
		
		int nSearchType = -1;
		nSearchType = Integer.parseInt(search_type, 10);

        String add_condition = "";
        Statement tmp_stmt = conn.createStatement();
        String tmp_sql;
        ResultSet tmp_rs;

        if (!search_name.equals("")) {
            add_condition = "(name like '" + search_name + "%' or name like '%" + search_name + "' or name like '%" + search_name + "%')";
            tmp_sql = "select ID from memberinfo where deleted = 0 and " + add_condition;

            add_condition = "(";

            tmp_rs = tmp_stmt.executeQuery(tmp_sql);
            while (tmp_rs.next()) {
                add_condition += "MID = " + Integer.toString(tmp_rs.getInt("ID"), 10) + " or ";
            }
            tmp_rs.close();
            tmp_stmt.close();

            if (!add_condition.equals("(")) {
                add_condition = add_condition.substring(0, add_condition.length() - 4) + ")";
            } else if (search_name.equals("管理者")) {
                add_condition = "(MID = 0)";
            } else {
                add_condition = "(1=0)";
            }
        }

        if (!search_title.equals("")) {
            if (!add_condition.equals("")) {
                add_condition += " and ";
            }

            tmp_sql = "select ID from PRODUCT_INFO where deleted = 0 and " + "(name like '" + search_title + "%' or name like '%" + search_title + "' or name like '%" + search_title + "%')";

            add_condition = "(";

            tmp_rs = tmp_stmt.executeQuery(tmp_sql);
            while (tmp_rs.next()) {
                add_condition += "PID = " + Integer.toString(tmp_rs.getInt("ID"), 10) + " or ";
            }
            tmp_rs.close();
            tmp_stmt.close();

            if (!add_condition.equals("(")) {
                add_condition = add_condition.substring(0, add_condition.length() - 4) + ")";
            } else {
                add_condition = "(1=0)";
            }
        }

        if (!search_from.equals("")) {
            search_from = ConvertDateString(search_from);
        }

        if (!search_to.equals("")) {
            search_to = search_to.substring(0, 4) + search_to.substring(5, 7) + search_to.substring(8, 10);
        }

        if (!search_from.equals("") && search_to.equals("")) {
            if (!add_condition.equals("")) {
                add_condition += " and ";
            }
            add_condition += " (orderdate >= '" + search_from + "')";
        } else if (search_from.equals("") && !search_to.equals("")) {
            if (!add_condition.equals("")) {
                add_condition += " and ";
            }
            add_condition += " (orderdate <= TO_DATE('" + search_to + "', 'yyyymmdd') + 1)";
        } else if (!search_from.equals("") && !search_to.equals("")) {
            if (!add_condition.equals("")) {
                add_condition += " and ";
            }
            add_condition += " (orderdate >= '" + search_from + "' and orderdate <= TO_DATE('" + search_to + "', 'yyyymmdd')+1)";
        }

        if (!add_condition.equals("")) {
            add_condition = " and " + add_condition;
        }

        int pagenum = Integer.parseInt(request.getParameter("page") == null ? "0" : request.getParameter("page"));
        int pagecount = Integer.parseInt(request.getParameter("row") == null ? "10" : request.getParameter("row"), 10);

        Statement stmt = conn.createStatement();
        Statement u_stmt = conn.createStatement();

        String sql = new String();
		if (nSearchType == -1)
			sql = "select count(*) as count from order_product where state > -1 and deleted = 0 " + add_condition;
		else
			sql = "select count(*) as count from order_product where state > -1 and state = " + nSearchType + " and deleted = 0 " + add_condition;
        ResultSet rs = stmt.executeQuery(sql);

        int total_count = 0, total_page = 0;

        if (rs.next()) {
            total_count = rs.getInt("count");
            total_page = (total_count - 1) / pagecount + 1;
            if (pagenum == 0) {
                pagenum = 1;
            } else if (pagenum > total_page) {
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

        int last_index = total_count - (pagenum - 1) * pagecount;
        int first_index = last_index - pagecount + 1;
        if (first_index <= 0) {
            first_index = 1;
        }
        int count = pagecount;
        if (first_index == 1) {
            count = last_index;
        }

        if (first_index > total_count) {
            count = last_index;
        }
		
		if (nSearchType == -1)
	        sql = "select * from (select * from (select * from order_product where state > -1 and deleted = 0 " + add_condition + "  order by id) where ID >= (select MAX(ID) from (select * from (select * from order_product where state > -1 and deleted = 0 " + add_condition + "  order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id desc";
		else
			sql = "select * from (select * from (select * from order_product where state > -1 and state = " + nSearchType + " and deleted = 0 " + add_condition + "  order by id) where ID >= (select MAX(ID) from (select * from (select * from order_product where state > -1 and deleted = 0 " + add_condition + "  order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id desc";
        rs = stmt.executeQuery(sql);

        int order_id[] = new int[pagecount];
        String[] product_name = new String[pagecount];
        String[] user_name = new String[pagecount];
        String[] exchange_state = new String[pagecount];
        String[] exchange_state_color = new String[pagecount];
        int[] product_price = new int[pagecount];
        int[] user_integral = new int[pagecount];
        int[] product_count = new int[pagecount];
        int[] state = new int[pagecount];

        int pid = 0, mid = 0;


        int i = 0;
        int cur_cnt = 0;
        while (rs.next()) {
            order_id[i] = rs.getInt("ID");
            pid = rs.getInt("pid");
            sql = "select * from product_info where deleted = 0 and id = " + pid;
            rs1 = u_stmt.executeQuery(sql);

            while (rs1.next()) {
                product_name[i] = rs1.getString("name");
            }
            rs1.close();

            mid = rs.getInt("mid");
            sql = "select * from memberinfo where deleted = 0 and id = " + mid;
            rs1 = u_stmt.executeQuery(sql);

            while (rs1.next()) {
                user_name[i] = rs1.getString("name");
                user_integral[i] = rs1.getInt("integral");
            }
            rs1.close();

            product_price[i] = rs.getInt("price");
            product_count[i] = rs.getInt("count");
            state[i] = rs.getInt("state");

            switch (state[i]) {
                case 0:
                    exchange_state[i] = "产品邀请";
                    exchange_state_color[i] = "#00000";
                    break;
                case 1:
                    exchange_state[i] = "等待受理";
                    exchange_state_color[i] = "#FF0000";
                    break;
                case 2:
                    exchange_state[i] = "已受理可领取";
                    exchange_state_color[i] = "#50d44d";
                    break;
				case 3:
                    exchange_state[i] = "已领取";
                    exchange_state_color[i] = "#0000FF";
                    break;
            }
            i++;
        }
        cur_cnt = i;
    %>

    <script charset="utf-8" src="kindeditor/kindeditor-min.js"></script>
    <script type="text/javascript">
    
       
        function change_row(row)
        {
            $("#search_row").val(row);
            $("#search_page").val('<%=pagenum%>');

            $("#search_form").submit();
        }
    
        var flag = false;
        function pageselectCallback(page_index, jq){
            if (!flag) {
                flag = true;
                return false;
            }
        else
            {
                $("#search_row").val('<%=pagecount%>');
                $("#search_page").val(page_index + 1);
          
                $("#search_form").submit();
            }
        }
    
        $(document).ready(function() {
            var optInit = {callback: pageselectCallback};
            optInit['items_per_page'] = <%=pagecount%>;
            optInit['num_display_entries'] = 3;
            optInit['current_page'] = <%=pagenum%> - 1;
       
            $("#Pagination").pagination(<%=total_count%>, optInit);
         
            $("#from_datepicker").datepicker({
                dateFormat: "yy-mm-dd"
            });
            $("#to_datepicker").datepicker({
                dateFormat: "yy-mm-dd"
            });
            $(".group-checkable").change(function() {
                var checked = this.checked;
               
                $(" .checkboxes").each(function() {                  
                  
                    if (checked)               
                    {                    
                        $(this).find("input")[0].checked = true;
                    }                    
                    else {                    
                        $(this).find("input")[0].checked = false;
                    }      
                    
                
                }) ;
             
            });
            $(".checkboxes").click(function() {
                var isSelect = $(this).find("input")[0].checked;

                if (!isSelect) {
                    $(".group-checkable")[0].checked = false;
                }
            });
        })
   
    
        function submit_add()
        {
            if ($("#state").val() == 1 && parseInt($("#user").val(),10) < parseInt($("#product").val(), 10)) {
                alert('产品积分比会员积分大');
                return;
            }
        $("#tmp_pagenum").attr("value", "<%=pagenum%>");
            $("#tmp_pagecount").attr("value", "<%=pagecount%>");     
            $("#act_post").submit();
        }
    
    
        function edit(ind, title, state, user_integral, product_integral)
        {
            $("#name").html(title);
            $("#id").attr("value", ind);
            $("#user").attr("value", user_integral);
            $("#product").attr("value", product_integral);
            $("#state").children().each(function() {
                if ($(this).val() == parseInt(state, 10)) {
                    $(this).attr("selected", true);             
                }
                else $(this).attr("selected", false);
            });        
            $('.ex_increase').show();
        }
        
        function delete_act(ind, name)
        {
            if (confirm("您确定要删除 兑换记录'" + name + "'吗?"))
            {
                $("#id").attr("value", ind);
            $("#act").attr("value", "delete");              
            $("#tmp_pagenum").attr("value", "<%=pagenum%>");
                $("#tmp_pagecount").attr("value", "<%=pagecount%>");
                $("#act_post").submit();
            }
        }
        function check_search()
        {
            if ( ($("#to_datepicker").val() != "") && ($("#from_datepicker").val() > $("#to_datepicker").val())) {
                alert("请输入正确期间");
                return;
            }
            $("#search_form").submit();
    
        }
        function clear_search()
        {
            $("#to_datepicker").val("");
            $("#from_datepicker").val("");
            $("#search_name").val("");
            $("#search_title").val("");
			$("#search_type").val("3");
            $("#search_form").submit();
   
        }  
        function select_delete()
        {
            var ids = "";
            $(" .checkboxes").each(function() {                                                          
                if ($(this).find("input")[0].checked)
                    ids = ids + $(this).find("input").attr("value") + ",";
            }) ;
            if (ids != "")
            {
                if (confirm("您确定要把勾选的兑换记录删除吗?"))
                {
                    $("#ids").attr("value", ids);
                       
                $("#act").attr("value", "deleteall");              
                $("#tmp_pagenum").attr("value", "<%=pagenum%>");
                    $("#tmp_pagecount").attr("value", "<%=pagecount%>");
            
                    $("#act_post").submit();
                        
                }
            }
                
               
        }

    
    
    </script>
    <script type="text/javascript">
        $(function(){
            $(".includeDom").each(function(){
                var html = $(this).attr("include");
                $(this).load(html, function() {
                    $(".nav a").eq(7).addClass("on");
                    //$(".box3rcon li:lt(3)").find("span.num").addClass("on");
                });
            })
        })
    </script>
    <body>
        <div class="header">
            <div class="includeDom" include="top.jsp"></div>
            <div class="nav-list">
                <ul>
                    <li><a href="exchange.jsp;" class="on"><span>兑换记录</span></a></li>
                    <li><a href="commodity.jsp"><span>商品管理</span></a></li>
                </ul>
            </div>
            <div class="clear"></div>
        </div>
        <div class="main">
            <div class="side">
                <div class="side-list">
                    <h2>商品管理</h2>               
                </div>
                <div class="copyright"><p>技术支持: <a href="http://www.bocweb.cn" target="_blank">博采网络</a></p></div>
            </div>
            <div class="content">
                <div class="content-main">
                    <div class="content-box">
                        <div class="content-title">

                            <table width="100%">
                                <tr>
                                    <td>	
                                        <h2>兑换记录<a id="del" href="#1" onclick="select_delete();">删除</a></h2>
                                    </td>
                                    <td>
                                        <div style="align:center" align="center">
                                            <form action="exchange.jsp" method="post" id="search_form">
                                                账号: <input type="text" id="search_name" name="search_name" size="15" value="<%=search_name%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                                商品名称: <input type="text" id="search_title" name="search_title" size="15" value="<%=search_title%>" />&nbsp;&nbsp;&nbsp;&nbsp;
												交换状态: <select name="search_type" id="search_type">
															<option value="-1" <%if (nSearchType == -1) {%> selected <%}%>>全部</option>
															<option value="0" <%if (nSearchType == 0) {%> selected <%}%>>产品邀请</option>
															<option value="1" <%if (nSearchType == 1) {%> selected <%}%>>等待受理</option>
															<option value="2" <%if (nSearchType == 2) {%> selected <%}%>>已受理可领取</option>
															<option value="3" <%if (nSearchType == 3) {%> selected <%}%>>已领取</option>
														  </select>&nbsp;&nbsp;&nbsp;&nbsp;
                                                期间: <input type="text" id="from_datepicker" name="from_datepicker" size="10" value="<%=tmp_from%>" />&nbsp;~&nbsp;<input type="text" id="to_datepicker" name="to_datepicker" size="10" value="<%=tmp_to%>"/>&nbsp;&nbsp;&nbsp;&nbsp;
                                                <input type="hidden" name="row" id="search_row" value="10" />
                                                <input type="hidden" name="page" id="search_page" value="1" />
                                                <input type="button" onclick="check_search();" id="searchbtn" value="探索" style="width:40px" />
                                                <input type="button" onclick="clear_search();" id="clearbtn" value="清空" style="width:40px" />
                                            </form>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="page fr">
                                            <div id="Pagination" class="pagination">
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </table>




                            <div class="clear"></div>
                            <p><%=total_count%>个符合 |  每页 
                                <a href="#" onclick="change_row('10');">10个</a> » 
                                <a href="#" onclick="change_row('25');">25个</a> » 
                                <a href="#" onclick="change_row('50')">50个</a>
                            </p>
                        </div>
                        <div class="content-table">
                            <table width="100%">
                                <tr>
                                    <th style="width:3%"><input type="checkbox" class="group-checkable"/></th>
                                    <th>商品名称</th>
                                    <th>会员姓名</th>
                                    <th>产品积分</th>
                                    <th>兑换状态</th>
                                    <th>操作</th>
                                </tr>

                                <%
                                    String blank = new String();
                                    blank = "blank";
                                    for (i = 0; i < cur_cnt; i++) {
                                        if (blank.length() == 0) {
                                            blank = "blank";
                                        } else {
                                            blank = "";
                                        }
                                %>

                                <tr class="<%=blank%>">
                                    <td class="checkboxes" ><input type="checkbox" value="<%=order_id[i]%>"/></td>
                                    <td><%=product_name[i]%></td>
                                    <td><%=user_name[i]%></td>
                                    <td><%=product_price[i] * product_count[i]%>积分</td>
                                    <td><font color="<%=exchange_state_color[i]%>"><%=exchange_state[i]%></font></td>
                                    <td>
                                        <a href="#" onclick="edit('<%=order_id[i]%>', '<%=product_name[i]%>', <%=state[i]%>, <%=user_integral[i]%>, <%=product_price[i] * product_count[i]%>)">编辑</a> | <a href="#" onclick="delete_act('<%=order_id[i]%>', '<%=product_name[i]%>');">删除</a>
                                    </td>
                                </tr>
                                <% }%>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="ex_increase">
            <form action="exchange_add.jsp" method="post" id="act_post">
                <table width="100%">
                    <tr>
                        <td colspan="3" class="dlg-trans">&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="dlg-transl">&nbsp;</td>
                        <td class="drwrap">
                            <div class="increase-main">
                                <div class="increase-title"><h2>兑换管理</h2><a href="#" onclick="$('.ex_increase').hide()">关闭 [X]</a></div>
                            </div>
                            <div class="increase-top">
                                <div >
                                    <table width="100%">
                                        <tr>
                                            <td>商品名称</td>
                                            <td id="name"></td>
                                        </tr>
                                        <tr>
                                            <td>兑换状态</td>
                                            <td>
                                                <select name="state" id="state">
                                                    <option value="0" selected="true">产品邀请</option>
                                                    <option value="1">等待受理</option>
                                                    <option value="2">已受理可领取</option>
													<option value="3">已领取</option>
                                                </select>
                                            </td>
                                        </tr>								
                                    </table>
                                </div>
                                <div class="clear"></div>
                            </div>
                            <div style="font-size:14pt; height: 30px;" align="center">
                                <input type="hidden" value="0" id="id" name="id"/>   
                                <input type="hidden" id="user"/>
                                <input type="hidden" id="product"/>
                                <input type="hidden" value="add" id="act" name="act"/>
                                <input type="hidden" name="ids" id="ids" value=""/>
                                <input type="hidden" id="tmp_pagenum" name="tmp_pagenum" value=""/>
                                <input type="hidden" id="tmp_pagecount" name="tmp_pagecount" value=""/>
                                <input type="button" class="dialog_addbutton" value="保存" onclick="submit_add();"/>                                             
                            </div>
                        </td>
                        <td class="dlg-transl"></td>
                    </tr>
                    <tr>
                        <td colspan="3" class="dlg-trans">&nbsp;</td>
                    </tr>
                </table>
            </form>
        </div>
    </body>
</html>

