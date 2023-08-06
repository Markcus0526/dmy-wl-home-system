<%-- 
    Document   : integral_info
    Created on : Dec 25, 2013, 11:26:21 AM
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

     String sid = request.getParameter("id") == null?"0":request.getParameter("id");
     int mid = Integer.parseInt(sid, 10);
     
     if (mid == 0) {
         out.println("<script>history.back;</script>");
         return;
     }
     
     
     String spage = request.getParameter("page")== null?"0":request.getParameter("page");
     int pagenum = Integer.parseInt(spage);
     int pagecount = Integer.parseInt(request.getParameter("row")== null?"10":request.getParameter("row"), 10);
     
    
     Statement stmt = conn.createStatement();   
     Statement u_stmt = conn.createStatement();
        
     String sql = "select count(*) as count from integrallog where enabled = 1 and mid = " + mid;
     ResultSet rs = stmt.executeQuery(sql);
     
     int total_count = 0, total_page = 0;
    
     if (rs.next()) {
        total_count = rs.getInt("count");
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = 1;
        if (pagenum > total_page) pagenum = total_page;
    }
     
    rs.close();
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;
    
    sql = "select * from memberinfo where id = " + mid;
    rs = stmt.executeQuery(sql);
    
    String name = new String();
    if (rs.next()) {
        name = rs.getString("name");
    }
    rs.close();
    
    ResultSet rs1 = null;    
    
    int last_index = total_count -  (pagenum - 1) * pagecount;
    int first_index = last_index - pagecount + 1;
    if (first_index <= 0) first_index = 1;
    int count = pagecount;
    
        
    if (first_index > total_count) {
        count = last_index;
    }
    
    
    sql = "select * from (select * from (select * from integrallog where enabled = 1 and mid = " + mid + " order by id) where ID >= (select MAX(ID) from (select * from (select * from integrallog where enabled = 1 and mid = " + mid + " order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id desc";
    rs = stmt.executeQuery(sql);
    
    String reason = new String();
    int id = 0, reason_id = 0, default_integral = 0;         
   
    
%>
<script type="text/javascript">
    var flag = false;
    
    function pageselectCallback(page_index, jq){
      if (!flag) {
          flag = true;
          return false;
      }
      else window.location.href="integral_info.jsp?id=<%=mid%>&page=" + (page_index + 1) + "&row=" + <%=pagecount%>;
    }
    
    $(document).ready(function() {
         var optInit = {callback: pageselectCallback};
        optInit['items_per_page'] = <%=pagecount%>;
        optInit['num_display_entries'] = 3;
	optInit['current_page'] = <%=pagenum%> - 1;
       
         $("#Pagination").pagination(<%=total_count%>, optInit);
    })
    function change_row(row)
    {
        window.location.href = "integral_info.jsp?id=<%=mid%>&row=" + row + "&page=" + <%=pagenum%>;
    }
    var add_data = '';
    var index = 0;
    function add()
    {
        $(".content-table tr").each(function() {
            if ($(this).find(".info_id").val() != undefined)
            {
                if ($(this).find("img").attr("src") == "img/i-yes.gif") {
                    add_data = add_data + $(this).find(".info_id").val() + "&" + $(this).find(".text").val() + ":";
                    index++;
                }
                    
            }
           
        });
        $("#add_data").attr("value", add_data);
        $("#add_cnt").attr("value", index);
        $("#tmp_pagenum").attr("value", "<%=pagenum%>");
        $("#tmp_pagecount").attr("value", "<%=pagecount%>");
        $("#integral_add").submit();
    }
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
						<h2>积分管理(<%=name%>)<a href="#1"></a></h2>
						<div class="page fr">
						<div id="Pagination" class="pagination">
                                                         </div>	
						</div>
						<div class="clear"></div>
						<p><%=total_count%>个符合 |  每页 <a href="#" onclick="change_row('10');">10个</a> » <a href="#" onclick="change_row('25');">25个</a> » <a href="#" onclick="change_row('50')">50个</a></p>
                                                
					</div>
					<div class="content-table">
						<table width="100%" style="table-layout:fixed">
							<tr>
								<th style="width:40%;">操作日期</th>
								<th style="width:30%;">产生积分事件</th>
								<th style="width:30%;">事件产生积分</th>
							</tr>
                                                    <%
													 String strDate = new String();
                                                     String blank = new String();
                                                     blank = "blank";
													 int gainIntegral = 0;
                                                    while (rs.next()) {
                                                         if (blank.length() == 0) blank = "blank";
                                                         else blank = "";
                                                         
                                                        id = rs.getInt("id");
                                                        reason_id = rs.getInt("reason");
														strDate = rs.getString("adddate");
														gainIntegral = rs.getInt("gainintegral");
														if (strDate != null && strDate.length() > 0)
														{
															int nPos = strDate.lastIndexOf(".");
															if (nPos > 0 )
																strDate = strDate.substring(0, nPos);
														}
                                                        sql = "select * from integralreason where id = " + reason_id;
                                                        rs1 = u_stmt.executeQuery(sql);
                                                        
                                                        while (rs1.next()) {															
                                                            default_integral = rs1.getInt("defaultintegral");
                                                            reason = rs1.getString("reason");
                                                        }
                                                        rs1.close();
                                                            
                                                    %>
							<tr class="<%=blank%>">
                                                                <input class="info_id" type="hidden" value="<%=id%>"/>
								<td><%=strDate%></td>
								<td><%=reason%></td>
								<td><%=gainIntegral%></td>
							</tr>
                                                    <%
                                                                                                       }
                                                            rs.close();
                                                            u_stmt.close();
                                                            stmt.close();
                                                    %>							
						</table>
					</div>
				</div>
                                                <form action="integral_add.jsp" method="post" id="integral_add">
                                                    <input type="hidden" name="add_data" id="add_data" value=""/>
                                                    <input type="hidden" name="id" value="<%=mid%>"/>
                                                    <input type="hidden" id="tmp_pagenum" name="tmp_pagenum" value=""/>
                                                    <input type="hidden" id="tmp_pagecount" name="tmp_pagecount" value=""/>
                                                    <input type="hidden" name="add_cnt" id="add_cnt" value=""/>
                                                </form>
			</div>
		</div>
	</div>
</body>
</html>
