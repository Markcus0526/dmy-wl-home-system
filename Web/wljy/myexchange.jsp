<%-- 
    Document   : myexchange
    Created on : 10-Dec-2013, 10:10:49
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
<%@ include file="connection.jsp" %>
<%
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyid"))
           {
                 tmp_str=name.substring(pos+1);
                 break;
           }
       }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
    
    if (UserId == 0) { 
        out.println("<script>history.back();</script>");
        return;
    }
    
    request.setCharacterEncoding("UTF-8");
    
     String spage = request.getParameter("page")== null?"0":request.getParameter("page");
     int pagenum = Integer.parseInt(spage);
     int pagecount = 8;
     
     Statement stmt = conn.createStatement();   
     Statement u_stmt = conn.createStatement();
     Statement u_stmt1 = conn.createStatement();
         
     //String sql = "select count(*) as count from PRODUCT_INFO";
     String sql = "select count(*) as count from ORDER_PRODUCT where deleted = 0 and mid = " + UserId + " and TO_CHAR(orderdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR')";
     ResultSet rs = stmt.executeQuery(sql);
     int total_count = 0, total_page = 0;
     
     if (rs.next()) {
        total_count = rs.getInt("count");

        
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = total_page;
     }
     rs.close();
    
     int prev_page = 1, next_page = total_page;
     if (pagenum > 1) prev_page = pagenum - 1;
     if (pagenum < total_page) next_page = pagenum + 1;   
        
     int last_index = total_count - (total_page - pagenum) * pagecount;
     int first_index = last_index - pagecount + 1;
     if (first_index <= 0) first_index = 1;
    
    //sql = "select * from (select * from PRODUCT_INFO where ID >= (select MAX(ID) from (select * from PRODUCT_INFO where ROWNUM <= " + last_index + " order by id) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by id DESC"; 
    sql = "select * from (select * from (select * from ORDER_PRODUCT where deleted = 0 and mid = " + UserId + " and TO_CHAR(orderdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by pid ASC) where pid >= (select MAX(PID) from (select * from (select * from ORDER_PRODUCT where deleted = 0 and mid = " + UserId + " and TO_CHAR(orderdate, 'YEAR') = TO_CHAR(SYSDATE, 'YEAR') order by pid ASC) where ROWNUM <= " + last_index + " order by pid) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by pid DESC"; 

    rs = stmt.executeQuery(sql);

    rs = stmt.executeQuery(sql);
    
    ResultSet rs1 = null, rs2 = null;
    String name = new String();
    int id = 0, iid = 0;
    String username = new String();
    String imagepath = new String();
    int market_price = 0, integral_price = 0;
    String exchange_state = null;   
    int state;
 %>
<script type="text/javascript">
$(function(){
    $(".includeDom").each(function(){
        var html = $(this).attr("include");
	$(this).load(html,function() {
            $(".toptit span a").eq(5).addClass("now");
	});
    })
})
function change_page(index) {
    window.location.href = "myexchange.jsp?page=" + index;
}    
function select_change() {
    change_page($("#page").val());
}
</script>
</head>
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
                <div class="myexchange">
                    <div class="myexchangetit">
			<span style="width:120px;">简缩图</span>
			<span style="width:150px;">礼品名称</span>
			<span style="width:80px;">市场价格</span>
			<span style="width:80px;">所需积分</span>
			<span style="width:80px;">兑换数量</span>
			<span style="width:80px;">总价格</span>
			<span style="width:90px;">总所需积分</span>
			<span style="width:70px;">兑换状态</span>
                    </div>
                    <div class="myexchangelist">
                        <ul>
                            <%
							int product_count = 0;
                            while (rs.next()) {
                                id = rs.getInt("pid");
                                
                                sql = "select * from PRODUCT_INFO where id = " + id;
                                rs1 = u_stmt.executeQuery(sql);
                                if(rs1.next()) {
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
								product_count = rs.getInt("COUNT");
                                String state_color = "";
                                switch(state) {
                                case 0:
                                    exchange_state = "产品邀请";
                                    state_color="#00000";
                                    break;
                                case 1:
                                    exchange_state = "等待受理";
                                    state_color="#FF0000";
                                    break;
                                case 2:
                                    exchange_state = "已受理可领取";
                                    state_color = "#50d44d";
                                    break;
                                default:
                                    exchange_state = "没有兑换";
                                    state_color="#2f2fdc";
                                }
                                
                                /*id = rs.getInt("id");
                                name = rs.getString("name");
                                iid = rs.getInt("iid");
                                
                                sql = "select * from product_image where id = " + iid;
                                rs1 = u_stmt.executeQuery(sql);
                                while (rs1.next()) {
                                    imagepath = rs1.getString(3);
                                }
                                rs1.close();
                                
                                market_price = rs.getInt("market_price");
                                integral_price = rs.getInt("integral_price"); 

                                sql = "select * from ORDER_PRODUCT where pid = " + id + " and mid = " + UserId;
                                rs1 = u_stmt.executeQuery(sql);
                                if(rs1.next()) {
                                    int state = rs1.getInt("state");
                                    switch(state) {
                                    case 0:
                                        exchange_state = "等待受理";
                                        break;
                                    default:
                                        exchange_state = "没有兑换";
                                    }
                                }
                                else
                                    exchange_state = "没有兑换";*/
                            %>
                            <li class="clear">
				<span style="width:150px;"><a href="exchange_info.jsp?id=<%=id%>"><img src="<%=imagepath%>" width="110" height="110" alt="" /></a></span>
				<span style="width:150px;"><%=name%></span>
				<span style="width:90px;" class="font18">¥<%=market_price%></span>
				<span class="font18" style="color:#bd0000;width:84px;"><%=integral_price%></span>
				<span class="font18" style="color:#bd0000;width:80px;"><%=product_count%></span>
				<span class="font18" style="color:#bd0000;width:85px;">¥<%=market_price*product_count%></span>
				<span class="font18" style="color:#bd0000;width:90px;"><%=integral_price*product_count%></span>
				<span style="width:90px;color:<%=state_color%>"><%=exchange_state%></span>
                            </li>
                            <%
                              }
                              rs.close();
                              stmt.close();
                              u_stmt.close();
                              u_stmt1.close();
                              conn.close();  
                            %>
			</ul>
                    </div>
		</div>
		<div class="page mar15 clear" align="center">
                    共<%=total_count%>条数据（<%=total_page%>页）
                    <a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);"><img src="img/page.jpg" alt="" /></a> 
                    <select id="page" onchange="select_change();">
                        <%
                        int i = 0;
                        for (i = total_page; i > 0;i--) {
                            if (i == pagenum)   {                                                  
                        %>
			<option value = "<%=i%>" selected="selected"><%=i%></option>
                        <%
                            }
                            else {
                        %>
                        <option value="<%=i %>"><%=i%></option>
                        <%
                            }
                        }
                        %>   
		    </select> 
                    <a href="javascript:void(0)" onclick="change_page(<%=next_page%>)"><img src="img/page01.jpg" alt="" /></a>
		</div>
            </div>
            <div class="bigbot"></div>
	</div>
    </div>
    <div class="includeDom" include="inc/footer.jsp"></div>
</body>
</html>
