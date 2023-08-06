<%-- 
    Document   : play_info
    Created on : 10-Dec-2013, 10:14:43
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@page import="java.util.Date"%>
<%@page language="Java" import="java.sql.*" %>

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

</head>
<body>
<%@ include file="connection.jsp" %>
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
    
       ResultSet rs2;
    Statement stmt2 = conn.createStatement();
    String sql1 = "";
  String username1="";
        String vip = "vip.jsp";
    if (UserId == 0 ) {
        username1= "游客";
        vip = "#";
               }
    else 
               {
            sql1 = "select * from memberinfo where id =" + UserId;
            rs2 = stmt2.executeQuery(sql1);
            if (rs2.next()) {
                username1 = rs2.getString("name");
            }
            rs2.close();
    }

        
    request.setCharacterEncoding("UTF-8");
       
    String spage = request.getParameter("page")== null?"0":request.getParameter("page");
    String id = (request.getParameter("id")== null)?"1":request.getParameter("id");
    
    Statement stmt = conn.createStatement();  
    Statement u_stmt = conn.createStatement();
    
    String sql = null;
    ResultSet rs = null, rs1 = null;
    int readcount = 0;
    
    if (spage == "0") {
        sql = "Select * from ACTIVITY_INFO where ID =" + id;
        rs = stmt.executeQuery(sql);

        while (rs.next()) {
            readcount = rs.getInt("readcount") + 1;
        }
        sql = "update activity_info set readcount =" + readcount + "where id = " + id;
        stmt.executeUpdate(sql);
        rs.close();
    }
    
    sql = "Select * from ACTIVITY_INFO where deleted = 0 and ID =" + id;
    rs = stmt.executeQuery(sql);
    
    String title = new String();
    Date postdate = new Date(1,11,1);    
    int clob_length = 0, eval_count = 0;
    Clob clob = null;
    String body = new String(), eval_body = null;
    String imagepath = new String(), imagedata = new String();
    
    while (rs.next()) {
       title = rs.getString("title");
       
       sql = "Select * from activity_image where deleted = 0 and aid = " + id;
       rs1 = u_stmt.executeQuery(sql);
        
       while (rs1.next()) {
         imagepath = rs1.getString("datapath"); 
         imagedata += "<img src='" + imagepath + "' style='width: 100%;' alt=''>";
       }
       rs1.close();   
        
       clob = rs.getClob("body");
       clob_length = (clob==null)?-1:(int)clob.length();
       if (clob_length < 0) body = "";
             else {
         body = clob.getSubString(1, clob_length).replaceAll("\r\n", "<br>");
         body = body.replaceAll("\n", "&<br>");
                 }
        
        postdate = rs.getDate("postdate");     
        readcount = rs.getInt("readcount");
        
        sql = "select count(*) as count from activity_eval where aid = " + id;
        rs1 = u_stmt.executeQuery(sql);
        if (rs1.next()) {
           eval_count = rs1.getInt("count");
        }
        rs1.close(); 
    }
    rs.close(); 
    
%>
<script type="text/javascript">
    $(function(){
            $(".includeDom").each(function(){
                    var html = $(this).attr("include");
                    $(this).load(html,function() {
                            $(".menu li a").eq(1).css("color","#b20101");;
                            $(".toptit span a").eq(0).addClass("now");
                                    $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
                    });
            })
    })
</script>
<script type="text/javascript">
    function change_page(index) {
        window.location.href = "play_info.jsp?id=" + <%=id%> + "&page=" + index;
    }
    
    function select_change() {
        change_page($("#page").val());
    }
    function submit_eval() {
    var eval = $("#eval_text").val();
    if(eval.length < 1 || eval == "输入文本...")
        alert("请输入正确文本");
    else
        $("#eval_form").submit();
    }
    function submit_eval_quick() {
        if($("#quick_eval_text").val().length < 1)
            alert("请输入正确文本");
        else
            $("#quick_eval_form").submit();
    }
</script>
    <div class="w964">
        <div class="includeDom" include="inc/top.jsp"></div>
	<div class="toptit playtit">
            <b>活动</b>
            <span>
               <a href="play.jsp">卧龙活动展示</a>
               <a href="single.jsp">个人活动组织</a>
            </span>
	</div>
	<div class="site clear" style="position:relative">
            <div class="content fle">
                <div class="conttop playconttop"></div>
		<div class="main">
                    <div class="playinfo_tit" align="center">
                        <b><%=title%></b>
			<p>
                            <span>活动时间：<%=postdate%></span>
                            <span>浏览：<em style="color:#d59600"><%=readcount%></em></span>
                            评论：<em style="color:#05c000"><%=eval_count%></em></p>
                    </div>
                    <div class="playinfo_det">
                        <p><%=imagedata%></p>
                        <p><%=body%></p>					
                    </div>
                    <%
                         int pagenum = Integer.parseInt(spage);
                         int pagecount = 2;
                         
                         sql = "select count(*) as count from activity_eval where aid = '" + id + "'";
                         rs = stmt.executeQuery(sql);
                         
                         int total_count = 0;
                         int total_page = 0;
                         int prev_page = 1, next_page = 1, first_index = 1, last_index = 1;
                         
                         if ( rs.next() )
                             total_count = rs.getInt("count");
                         
                         if (total_count == 0) {
                         %>
                         <div class="faqanstab">
                           <form action="play_info_addcrit.jsp" method="post" id ="eval_form">                                            
                                <h4>发表评论 <span>（共0条评论）</span></h4>
				<div class="faqanseare">
                                    <textarea name="postdata" class="faqansinput" id="eval_text" onclick="if (this.value=='输入文本...') this.value=''">输入文本...</textarea>
				</div>
                                <input type="hidden" id="action" name="id" value="<%=id%>"/>
				<div class="faqansbtn" align="right">
                                    <% if (UserId != 0 && IsActive == 1) {%>
                                    <input type="button" value="提 交" class="faqansbtn01" onclick="submit_eval()"/>
                                    <% }%>
                                </div>
                            </form>
			</div>	
                         <%
                         }
                         else {
                                                  
                           if (total_count != 0) {
                             total_page = (total_count - 1) / pagecount + 1;
                             if (pagenum == 0) pagenum = total_page;
                             
                             prev_page = 1;
                             next_page = total_page;
                             
                             if (pagenum > 1) prev_page = pagenum - 1;
                             if (pagenum < total_page) next_page = pagenum + 1;

                             last_index = total_count - (total_page - pagenum) * pagecount;
                             first_index = last_index - pagecount + 1;
                             if (first_index <= 0) first_index = 1;

                             sql = "select * from (select * from (select * from ACTIVITY_EVAL where aid = '" + id + "' order by id) where ID >= (select MAX(ID) from (select * from (select * from ACTIVITY_EVAL where aid = '" + id + "' order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
                             rs = stmt.executeQuery(sql);
                             
                             int mid = 0;
                             String user_image = null, eval_name = null;
                        %>       
			<div class="faqanstab">
                           <form action="play_info_addcrit.jsp" method="post" id ="eval_form">                                            
                                <h4>发表评论 <span>（共<%=total_count%>条评论）</span></h4>
				<div class="faqanseare">
									<textarea name="postdata" class="faqansinput" id="eval_text" onclick="if (this.value=='输入文本...') this.value=''">输入文本...</textarea>
				</div>
                                <input type="hidden" id="action" name="id" value="<%=id%>"/>
				<div class="faqansbtn" align="right">
                                    <% if (UserId != 0 && IsActive == 1) {%>
                                    <input type="button" value="提 交" class="faqansbtn01" onclick="submit_eval()" />
                                    <% }%>
                                </div>
                            </form>
			</div>	
			<div class="faqinfo_ans marT20">
                            <ul class="clear">
                            <%
                              while (rs.next()) {
                                  mid = rs.getInt("mid");
                                  
                                  
                                  sql = "select name, photo from memberinfo where id = " + mid;
                                  rs1 = u_stmt.executeQuery(sql);
                                  if (rs1.next())
                                  {
                                    eval_name = rs1.getString("name");
                                    user_image = rs1.getString("photo");
                                    
                                  }
                                 rs1.close();

                                clob = rs.getClob("BODY");
                                clob_length = (clob==null)?-1:(int)clob.length();
                                if (clob_length < 0) body = "";
                                else eval_body = clob.getSubString(1, clob_length).replaceAll("\r\n", "<br>");
                                
                                postdate = rs.getDate("postdate");  
                             %>
				<li>
                                    <div class="clear">
                                    <div class="faqansl fle">
                                        <img src="<%=user_image%>" width="64" height="64" alt=""/></div>
                                        <div class="faqansr fri">
                                		<h3><%=eval_name%></h3>
                                        	<p><%=eval_body%></p>
                                                <em><%=postdate%></em>
                                                <span></span>
                                        </div>
                                    </div>
				</li>
                             <%
                                 }
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
				<option value="<%=i %>" selected><%=i%></option>
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
                                <img src="img/page01.jpg" alt=""/></a>
			</div>
                 <%
                        }
                      }
                 %>
		</div>
                <div class="contbot"></div>
            </div>                                                                        
            <div class="includeDom">
               <div class="right fri">
                  <div class="faqtwo scrollfeed">
                    <div class="faqtwotit playtwotit">快捷评论</div>
                    <div class="faqtwocon">
                         <ul>
                         <form action="play_info_addcrit.jsp" method="post" id ="quick_eval_form">
                         <div class="playfeedt"><textarea name="postdata" id="quick_eval_text" class="playfeedta"></textarea></div>
                         <div class="playfeedbtn">
                             <% if (UserId != 0 && IsActive == 1) { %>
                             <input type="button" value="提 交" class="faqansbtn01" onclick="submit_eval_quick()"/>
                             <% }%>
                         </div>
                         <input type="hidden" id="action" name="id" value="<%=id%>"/>
                         </form>
                       </ul>
                    </div>
                   </div>
                </div> 
            </div>
          </div>
        </div>
        <div class="includeDom" include="inc/footer.jsp">
            
        </div>
</body>
<%
    rs.close();
    stmt.close();
    u_stmt.close();
    conn.close();
%>
</html>