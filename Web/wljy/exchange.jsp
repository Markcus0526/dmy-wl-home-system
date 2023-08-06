<%-- 
    Document   : exchange
    Created on : 10-Dec-2013, 10:04:18
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
    for(int i = 0;i<cookies.length;i++)
    {
        String name=cookies[i].getName();
        int pos=name.indexOf('#');
        if(pos != -1)
        {
            if(name.substring(0, pos).equals("wljyid"))
            {
                tmp_str=name.substring(pos+1);
                break;
            }
        }
    }
    if (tmp_str.equals("")) 
        out.println("<script>window.location.href='login.jsp';</script>");

    int UserId = Integer.parseInt(tmp_str, 10);



    request.setCharacterEncoding("UTF-8");
    
     String spage = request.getParameter("page")== null?"0":request.getParameter("page");
     String typestr = request.getParameter("type")== null?"0":request.getParameter("type");
     int type = Integer.parseInt(typestr);
     int pagenum = Integer.parseInt(spage);
     int pagecount = 8;
     
     Statement stmt = conn.createStatement();
     Statement u_stmt = conn.createStatement();
     
     String youke_context = "";
         
     String sql = "";
     ResultSet rs;
         String username1="";
        String vip = "vip.jsp";
    if (UserId == 0 ) {
        username1= "游客";
        youke_context = "ISPUBLIC = 1 and ";
        vip = "#";
               }
    else 
               {
            sql = "select * from memberinfo where deleted = 0 and id =" + UserId;
            rs = stmt.executeQuery(sql);
            if (rs.next()) {
                username1 = rs.getString("name");
            }
            rs.close();
    }
        
        
     switch (type) {
        case 0:
            sql = "select count(*) as count from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 0 and MARKET_PRICE <= 2000"; 
          break;
        case 1:
            sql = "select count(*) as count from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 2001 and MARKET_PRICE <= 8000"; 
          break;
        case 2:            
            sql = "select count(*) as count from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 8001 and MARKET_PRICE <= 10000"; 
          break;
     }
      rs = stmt.executeQuery(sql);
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
    
     switch (type) {
        case 0:
            sql = "select * from (select * from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 0 and MARKET_PRICE <= 2000 order by id) where ID >= (SELECT MAX(ID) from (select * from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 0 and MARKET_PRICE <= 2000 order by id) where ROWNUM <= "+first_index+") and ROWNUM <= "+pagecount+" order by id desc"; 
          break;
        case 1:
            sql = "select * from (select * from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 2001 and MARKET_PRICE <= 8000 order by id) where ID >= (SELECT MAX(ID) from (select * from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 2001 and MARKET_PRICE <= 8000 order by id) where ROWNUM <= "+first_index+") and ROWNUM <= "+pagecount+" order by id desc"; 
          break;
        case 2:            
            sql = "select * from (select * from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 8001 and MARKET_PRICE <= 10000 order by id) where ID >= (SELECT MAX(ID) from (select * from PRODUCT_INFO where " + youke_context + " deleted = 0 and ISVISIBLE=1 and MARKET_PRICE >= 8001 and MARKET_PRICE <= 10000 order by id) where ROWNUM <= "+first_index+") and ROWNUM <= "+pagecount+" order by id desc"; 
          break;
     }        
   
    rs = stmt.executeQuery(sql);
    
    ResultSet rs1 = null;
    String name = new String();
    int id = 0, iid = 0;
    String username = new String();
    String imagepath = new String();
    int market_price = 0, integral_price = 0;
             
 %>
<script type="text/javascript">
    $(function(){
            $(".includeDom").each(function(){
                    var html = $(this).attr("include");
                    $(this).load(html, function() {
                            $(".menu li a").eq(6).css("color","#c50e50");
                            $(".toptit span a").eq(<%=type%>).addClass("now");
                                   $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
                    });
            })
    })
    
    function change_page(index) {
        window.location.href = "exchange.jsp?type=<%=type%>&page=" + index;
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
                    <div class="exchangelist">
                        <ul class="clear">
                        <%
                            while (rs.next()) {
                                id = rs.getInt("id");
                                name = rs.getString("name");
                                iid = rs.getInt("iid");
                                
                                sql = "select * from product_image where deleted = 0 and id = " + iid;
                                rs1 = u_stmt.executeQuery(sql);
                                while (rs1.next()) {
                                    imagepath = rs1.getString(3);
                                }
                                rs1.close();
                                
                                market_price = rs.getInt("market_price");
                                integral_price = rs.getInt("integral_price");            
                           %>
                             <li align="center">
				<a href="exchange_info.jsp?type=<%=type%>&id=<%=id%>">
                                    <img src="<%=imagepath%>" width="137" height="137"/>
                                </a>
				<h4><%=name%></h4>
				<p>价格：<span style="color:#c90000;">¥<%=market_price%></span></p>
				<p>积分：<span style="color:#dfa300;"><%=integral_price%></span></p>
                            </li>   
                           <%
                              }
                              rs.close();
                              stmt.close();
                              u_stmt.close();
                              conn.close();  
                            %>
                    </ul>
                 </div>
		<div class="page mar15 clear" align="center">
                    共 <%=total_count%>条数据（<%=total_page%> 页）
                    <a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);">
                        <img src="img/page.jpg" alt=""/>
                    </a> 
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
                    <a href="javascript:void(0)" onclick="change_page(<%=next_page%>)">
                        <img src="img/page01.jpg" alt="" />
                    </a>
		</div>
            </div>
            <div class="bigbot"></div>
	</div>
    </div>
    <div class="includeDom" include="inc/footer.jsp"></div>
</body>
</html>