<%-- 
    Document   : integral
    Created on : Dec 25, 2013, 11:25:20 AM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
<script type="text/javascript" src="js/jquery.min.js"></script>
<script type="text/javascript" src="js/jquery.pagination.js"></script>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->
</head>

<script type="text/javascript">
    $(function(){
	$(".includeDom").each(function(){
            var html = $(this).attr("include");
            $(this).load(html, function() {
                $(".nav a").eq(1).addClass("on");
                //$(".box3rcon li:lt(3)").find("span.num").addClass("on");
            });
	})
    })
</script>
<%@ include file="cookie_check.jsp" %>
<%@ include file="../connection.jsp" %>
<%
   Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyadminid"))
           {
                 tmp_str=name.substring(pos+1);
                 break;
           }
       }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
     request.setCharacterEncoding("UTF-8");

     String spage = request.getParameter("page")== null?"0":request.getParameter("page");
     int pagenum = Integer.parseInt(spage);
     int pagecount = Integer.parseInt(request.getParameter("row")== null?"10":request.getParameter("row"), 10);
     
    
     Statement stmt = conn.createStatement();   
     Statement u_stmt = conn.createStatement();
        
     String sql = "select count(*) as count from memberinfo";
     ResultSet rs = stmt.executeQuery(sql);
     
     int total_count = 0, total_page = 0;
    
     if (rs.next()) {
        total_count = rs.getInt("count");
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = 1;
        if (pagenum > total_page) pagenum = total_page;
    }
     
    rs.close();
    
    int reason_cnt = 0;
    int reason_row_cnt = 0;
    sql = "select count(*) as cnt from INTEGRALREASON";
    rs = u_stmt.executeQuery(sql);
    if ( rs.next() )
        reason_cnt = rs.getInt("cnt");
    rs.close();
    u_stmt.close();

	/* FixME
	* 问题回答现实问题
	*/
	reason_cnt = reason_cnt - 1;
	/* FixME
	*/
    
    String[] reason_string = new String[reason_cnt];
    int[] reason_value = new int[reason_cnt];
    int i = 0;
    
    if (reason_cnt > 0)
    {
        sql = "select * from INTEGRALREASON order by id asc";
        u_stmt = conn.createStatement();
        rs = u_stmt.executeQuery(sql);
        while ( rs.next() )
        {
			/* FixME
			* 问题回答现实问题
			*/
			if ( reason_cnt == i)
				break;
			/* FixME
			*/
            reason_string[i] = rs.getString("REASON");
            reason_value[i] = rs.getInt("DEFAULTINTEGRAL");
            i++;
        }
        reason_row_cnt = (reason_cnt % 2 == 0) ? (reason_cnt / 2) : (reason_cnt / 2 + 1);
    }
    
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;
    
    ResultSet rs1 = null;    
    
    int last_index = pagenum * pagecount;
    int first_index = last_index - pagecount + 1;
    if (first_index <= 0) first_index = 1;
    int count = pagecount;
    
    if (last_index > total_count) {
        last_index = total_count;
        count = last_index - first_index + 1;
    }
    
    
    sql = "select * from (select * from memberinfo order by id) where ID >= (select MAX(ID) from (select * from (select * from memberinfo order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count;
    rs = stmt.executeQuery(sql);
    
    String username = new String();
	String nickname = new String();
	String namepassword = new String();
         
    int id = 0, mid = 0, integral = 0;
    
%>
<script type="text/javascript">
    var flag = false;
    
    function pageselectCallback(page_index, jq){
      if (!flag) {
          flag = true;
          return false;
      }
      else window.location.href="integral.jsp?page=" + (page_index + 1) + "&row=" + <%=pagecount%>;
    }
    
    $(document).ready(function() {
         var optInit = {callback: pageselectCallback};
        optInit['items_per_page'] = <%=pagecount%>;
        optInit['num_display_entries'] = 3;
		optInit['current_page'] = <%=pagenum%> - 1;
       
        $("#Pagination").pagination(<%=total_count%>, optInit);
		
		var total_page_count = parseInt(<%=total_count%> / <%=pagecount%>) + 1;
		$("#TotalPages").val(total_page_count);
    })
    function change_row(row)
    {
        window.location.href = "integral.jsp?row=" + row + "&page=" + <%=pagenum%>;
    }

	function select_page()
    {
		var selPageno = parseInt($("#selectpageno").val());
		if (isNaN(selPageno))
		{
			$("#selectpageno").val('');
			return;
		}
		var pagetotalcount = parseInt($("#TotalPages").val());
		if (selPageno > pagetotalcount)
		{
			$("#selectpageno").val('');
			return;
		}
        
		window.location.href = "integral.jsp?row=" + <%=pagecount%> + "&page=" + selPageno;
    }
    
    function edit()
    {       
        $('.actincrease').show();
    }
    
    function submit_edit()
    {
        $("#act_post").submit();
    }
</script>
<body>
	<div class="header">
            <div class="includeDom" include="top.jsp"></div>	
		<div class="nav-list">
			<ul>
				<li><a href="integral.jsp" class="on"><span>积分管理</span></a></li>
                                <li><a href="user.jsp"><span>会员管理</span></a></li>
                 <li><a href="loginlist.jsp"><span>登录管理</span></a></li>
			</ul>
		</div>
		<div class="clear"></div>
	</div>
	<div class="main">
		<div class="side">
			<div class="side-list">
				<h2>积分管理</h2>				
			</div>
			<div class="copyright"><p>技术支持: <a href="http://www.bocweb.cn" target="_blank">博采网络</a></p></div>
		</div>
		<div class="content">
			<div class="content-main">
				<div class="content-box">
					<div class="content-title">
                        <h2>
                            积分管理&nbsp;
                            <a href="#1" onclick="edit();">积分自定义设置</a>
                        </h2>
						<div class="page fr">
							<div>
								<div id="Pagination" class="pagination" style="float:left;"></div>
								<div style="float: right;">
									到&nbsp;<input type="text" name="selectpageno" id="selectpageno" style="width: 50px; height: 20px; text-align: center;" onkeyup="this.value=this.value.replace(/[^\d]/,'')" />&nbsp;/&nbsp;<input type="text" name="TotalPages" id="TotalPages" style="width: 50px; height: 20px; text-align: center;" disabled/>&nbsp;页&nbsp;
									<input type="button" name="btnSelectPageNo" id="btnSelectPageNo" style="width: 50px;height: 25px;" value="确定" onclick="select_page();"/>
								</div>
							</div>
						</div>
						<div class="clear"></div>
						<p><%=total_count%>个符合 |  每页 <a href="#" onclick="change_row('10');">10个</a> » <a href="#" onclick="change_row('25');">25个</a> » <a href="#" onclick="change_row('50')">50个</a></p>
					</div>
					<div class="content-table">
						<table width="100%">
							<tr>
								<th>姓名</th>
								<th>昵称</th>
								<th>工号</th>
								<th>积分</th>
								<th>操作</th>
							</tr>
                                                        <%
                                                        while (rs.next()) {
                                                            id = rs.getInt("id");
                                                            integral = rs.getInt("integral");
                                                            username = rs.getString("name");
															nickname = rs.getString("nickname");
															namepassword = rs.getString("namepassword");                                                            
                                                        %>
							<tr>
								<td><!--<a href="system.jsp">--><%=nickname%><!--</a>--></td>
								<td><!--<a href="system.jsp">--><%=username%><!--</a>--></td>
								<td><!--<a href="system.jsp">--><%=namepassword%><!--</a>--></td>
								<td><%=integral%>积分</td>
								<td><a href="integral_info.jsp?id=<%=id%>">查看积分详细</a></td>
							</tr>
                                                        <%
                                                           }
    rs.close();
    stmt.close();
    u_stmt.close();
    conn.close();
                            %>
    
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
							
    <div class="actincrease">
        <table width="100%">
            <tr>
                <td colspan="3" class="dlg-trans">&nbsp;</td>
            </tr>
            <tr>
                <td class="dlg-transl">&nbsp;</td>
                <td class="drwrap">
                    <div class="increase-main">
                        <div class="increase-title"><h2> 积分管理</h2><a href="#1" onclick="$('.actincrease').hide()">关闭 [X]</a></div>
                    </div>
                    <div class="increase-top">
                        <div class="" align="center" style="padding-top: 15px;">
                            <table width="80%" cellspacing="20px">
                                <form action="integral_default_edit.jsp" method="post" id="act_post">
                                <% for ( i = 0; i < reason_row_cnt; i++ ) { %>
                                <tr>
                                    <td width="20%" align="center"><%=reason_string[i*2]%></td>
                                    <td width="20%" align="center"><input name="integral_<%=i*2%>" id="integral_<%=i*2%>" type="text" value="<%=reason_value[i*2]%>" onkeyup="this.value=this.value.replace(/[^\d]/,'')"/></td>
                                    <% if ( i * 2 + 1 < reason_cnt ) { %>
                                    <td width="20%" align="center"></td>
                                    <td width="20%" align="center"><%=reason_string[i*2+1]%></td>
                                    <td width="20%" align="center"><input name="integral_<%=i*2+1%>" id="integral_<%=i*2+1%>" type="text" value="<%=reason_value[i*2+1]%>" onkeyup="this.value=this.value.replace(/[^\d]/,'')"/></td>
                                    <% } else { %>
                                    <td width="20%" align="center" colspan="3"></td>
                                    <% } %>
                                </tr>
                                <tr><td colspan="5">&nbsp;</td></tr>
                                <% } %>
                                </form>
						</table>
					</div>
                        <div class="clear"></div>
				</div>
                    <div style="font-size:14pt;height: 30px;" align="center">                                            
                        <input class="dialog_addbutton" type="button" value="保存" onclick="submit_edit();"/>                                    
			</div>
                </td>
                <td class="dlg-transl"></td>
            </tr>
            <tr>
                <td colspan="3" class="dlg-trans">&nbsp;</td>
            </tr>
        </table>
		</div>
                            
</body>
</html>
