<%-- 
    Document   : exchange_info
    Created on : 10-Dec-2013, 10:05:06
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@ include file="connection.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="UTF-8"/>
<title></title>
<meta name="keywords" content=""  />
<meta name="description" content="" />
<meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
<link rel="shortcut icon" href="favicon.ico"/>
<link rel="icon" href="logo.png" type="logo.png" />
<link href="css/css.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->
<%
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
	String str_IsActive = "";
    for(int i = 0;i<cookies.length;i++) {
        String name=cookies[i].getName();
        int pos=name.indexOf('#');
        
        if(pos != -1) {
            if(name.substring(0, pos).equals("wljyid")) {
                tmp_str=name.substring(pos+1);
            }
			if(name.substring(0, pos).equals("wljyisactive")) {
                str_IsActive=name.substring(pos+1);
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
%>
<%
    request.setCharacterEncoding("UTF-8");
    
    String typestr = request.getParameter("type")== null?"0":request.getParameter("type");
    int type = Integer.parseInt(typestr);
    String id = (request.getParameter("id")== null)?"1":request.getParameter("id");

    Statement stmt = conn.createStatement();   
    Statement u_stmt = conn.createStatement();

    String sql = "select * from PRODUCT_INFO where id = " + id;
    ResultSet rs = stmt.executeQuery(sql);
    ResultSet rs1;
    ResultSet rs2;
    Statement stmt2 = conn.createStatement();
    
	String username1="";
    String vip = "vip.jsp";
	int user_integral = 0;
    if (UserId == 0 ) {
        username1= "游客";
        vip = "#";
               }
    else 
               {
            sql = "select * from memberinfo where id =" + UserId;
            rs2 = stmt2.executeQuery(sql);
            if (rs2.next()) {
                username1 = rs2.getString("name");
				user_integral = rs2.getInt("integral");
            }
            rs2.close();
    }

    

    String name = new String();
    String body = new String();
    String imagepath = new String();
    String property = new String();
    String detail = new String();
    String[] sub_image = new String[6];

    int uid = 0, iid = 0, market_price = 0, integral_price = 0;
    int total_exchange= 0, total_secure = 0, count = 0;
    int index = 0;
    Clob clob = null;
    int clob_length = 0;

    while (rs.next()) {
        name = rs.getString("name");
        iid = rs.getInt("iid");

        sql = "Select * from product_image where id = " + iid;
        rs1 = u_stmt.executeQuery(sql);
        while (rs1.next()) {
          imagepath = rs1.getString("datapath");
        }
        rs1.close();

        sql = "select * from product_image where pid = " + id + " and ismain=0 order by id";
        rs1 = u_stmt.executeQuery(sql);
        index = 0;
        while (rs1.next()) {
           if (index == 6) break;
           sub_image[index] = rs1.getString("datapath");
           if(sub_image[index] != null && !sub_image[index].equals("null"))
           index++;
        }
        rs1.close();

        market_price = rs.getInt("market_price");
        integral_price = rs.getInt("integral_price");
        total_exchange = rs.getInt("total_exchange");
        total_secure = rs.getInt("total_secure");   
        
        /*

        sql = "select * from order_product where pid = " + uid;
        rs1 = u_stmt.executeQuery(sql);
        while (rs1.next()) {
         count = rs1.getInt("count");
        }
        rs1.close();
        */
        
        count = 0;
        
        
        clob = rs.getClob("property");
        clob_length = (clob == null)?-1:(int)clob.length();

        if (clob_length < 0) property = "";
        else property = clob.getSubString(1, clob_length);

        clob = rs.getClob("detail");
        clob_length = (clob == null)?-1:(int)clob.length();
        if (clob_length < 0) detail = "";
        else detail = clob.getSubString(1, clob_length);       
    }
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

	function refresh_total_exchange ()
	{
		var exchange_count = parseInt($("#exchange_count").val(), 10);
		$("#total_exchange").val(<%=integral_price%>*exchange_count);
	}
    
    function do_submit()
    {
		var exchange_count = $("#exchange_count").val();
		var total_exchange = $("#total_exchange").val();

        if ( exchange_count > <%=total_secure%>)
        {
            alert("兑换数量不能超过库存数量。");
            return;
        }
        
        if ( isNaN(exchange_count) || exchange_count=="" || parseInt(exchange_count, 10)<=0 ) {
             alert("请输入正确的数量。");
            return;
        }

		// 检查积分数量
		if ( parseInt(total_exchange, 10) > <%=user_integral%> )
		{
			alert ("您的积分(" + <%=user_integral%> + ")少于要兑换的商品积分数(" + total_exchange + ")，不能兑换。");
			return;
		}
		

		// 提交表格
        $("#product_id").attr("value", "<%=id%>");
        $("#submit_form").submit();
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
                    <div class="exchangetop clear">
                        <div class="exchange_pic fle">
                            <div class="exchange_picshow" style="width:100%; border:1px solid #cccccc;">
								<img src="<%=imagepath%>" style="width:100%;" alt=""/>
                            </div>
                            <div class="exchange_thumb mar15">
                                <ul>
                                <% 
                                    for (int i = 0; i < 6;i++){
                                        if (sub_image[i] != null && !sub_image[i].equals("")) {
                                %>
                                    <li>
                                        <img src="<%=sub_image[i]%>" dataimg="<%=sub_image[i]%>" style="width:100%;" alt=""/>
                                    </li>
                                 <%
                                    }
                                    }
                                 %>							
                                </ul>
                            </div>
                        </div>
			<div class="exchange_info fri">
                            <h4><%=name%></h4>
                            <form action="mycart.jsp" method="post" id="submit_form">
                            <table width="100%" style="border-bottom:#e2e2e2 1px solid;" class="exchange_tab01">
                                <tr>
                                    <td align="right" width="70">市场售价&nbsp;:</td>
                                    <td align="left">￥<span class="exchange_font01"><%=market_price%></span></td>
				</tr>
				<tr>
                                    <td align="right" width="70">所需积分&nbsp;:</td>
                                    <td align="left"><span class="exchange_font02"><%=integral_price%></span></td>
				</tr>
				<tr>
                                    <td align="right" width="70">累计兑换&nbsp;:</td>
                                    <td align="left" ><input id="total_exchange" name="total_exchange" type="text" value="<%=total_exchange%>" class="exchange_input" style="border:none;" readonly="readonly" onfocus="this.blur()"/></td>
				</tr>
				<tr>
                                    <td align="right" width="70">库存&nbsp;:</td>
                                    <td align="left"><%=total_secure%></td>
				</tr>
				<tr>
                                    <td align="right" width="70">兑换数量&nbsp;:</td>
                                    <td align="left"><input id="exchange_count" name="exchange_count" type="text" value="<%=count%>" class="exchange_input" onkeyup="refresh_total_exchange();"/></td>
				</tr>
                            </table>
                                <input type="hidden" id="product_id" name="product_id" />
                                <input type="hidden" id="product_integral" name="product_integral" value="<%=integral_price%>" />
                                <input type="hidden" id="onlydisplay" name="onlydisplay" value="0" />
                            </form>
                            <table width="100%" class="mar exchange_tab02">
                                 <%=property%>					
                            </table>
                            <div class="exchange_btn singler mar">
                                <% if (UserId != 0 && IsActive == 1) { %>
				<a onclick="do_submit();">立即兑换</a>
                                <% } %>
                            </div>
			</div>
                    </div>
                    <div class="exchangebot clear">
                        <div class="exchangebot_tit">商品详情</div>
			<div class="exchangebot_info">
                           <%=detail%>					
			</div>
                    </div>
		</div>
		<div class="bigbot"></div>
            </div>
        </div>
        <div class="includeDom" include="inc/footer.jsp"></div>
<script type="text/javascript">
    $(function() {
            objLi = $(".exchange_thumb li");
            objImg = $(".exchange_picshow").find("img");
            objLi.click(function() {
                    proSlideRun(objLi.index(this));
            })
            function proSlideRun(n) {
            objLi.removeClass("active").eq(n).addClass("active");
                    objImg.fadeTo(300,0,function(){
                            objImg.fadeTo(300,1,function(){
                                    objImg.attr("src",objLi.eq(n).children("img").attr("dataimg"));
                            });
                    })
            }
            proSlideRun(0);
    })
</script>
<%
  stmt.close();
  rs.close();
  conn.close();
%>
</body>
</html>