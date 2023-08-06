<%-- 
    Document   : study_info
    Created on : 10-Dec-2013, 10:20:25
    Author     : PAK SONG HYOK
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
<body>
<%@ include file="connection.jsp" %>
    <%@page import="java.util.Date"%>
    <%
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
	String str_IsActive= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
       if(name.substring(0, pos).equals("wljyid"))
       {
             tmp_str=name.substring(pos+1);
       }
	   if(name.substring(0, pos).equals("wljyisactive"))
       {
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
            sql1 = "select * from memberinfo where deleted = 0 and id =" + UserId;
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
      
    String sql = new String();
    ResultSet rs;
    int readcount = 0;
    if (spage == "0"){        
        sql = "Select * from STUDY_QINFO where deleted = 0 and ID =" + id;
        rs = stmt.executeQuery(sql);    
        while (rs.next()) {
            readcount = rs.getInt("readcount") + 1;
        }
        rs.close();

        sql = "update STUDY_QINFO set readcount = " + readcount + "where deleted = 0 and id = " + id;
        stmt.executeUpdate(sql);    
    }
    int downloadcount = 0;
    sql = "select count(*) as count from data_download where sqid = "+id;
    rs = stmt.executeQuery ( sql );
    if ( rs.next() ) {
	    downloadcount = rs.getInt("count");
    }
    rs.close();
      
    sql = "select * from STUDY_QINFO where deleted = 0 and id = " + id;
    rs = stmt.executeQuery(sql);
      
    ResultSet rs1;
    String title = new String();
    String imagepath = new String();
    Date postdate = new Date(1,11,1);
    int rewardintegral = 0;
    String body = new String();
    int mid = 0;
    String username = new String();      
    String type_name = new String();
    int type = 0;
    Clob clob = null;
    int clob_len = 0, answer_count = 0;
    
    while (rs.next()) {
        mid = rs.getInt("mid");
        title = rs.getString("title");
        imagepath = rs.getString("imagepath");
		rewardintegral = rs.getInt("integral");
        
        sql = "Select * from memberinfo where deleted = 0 and id = " + mid;
        rs1 = u_stmt.executeQuery(sql);
        while (rs1.next()) {
            username = rs1.getString("name");
        }
        rs1.close();
        
        type = rs.getInt("type");
        
        sql = "select * from STUDY_TYPE where id = " + type;
        rs1 = u_stmt.executeQuery(sql);
        while (rs1.next()) {
            type_name = rs1.getString("name");
        }
        rs1.close();
        
        clob = rs.getClob("body");
        clob_len = (clob==null)?-1:(int)clob.length();
        if (clob_len < 0)
            body = "";
        else
            body = clob.getSubString(1, clob_len).replaceAll("\r\n", "<br>");
         body = body.replaceAll("\n", "&<br>");
        
        postdate = rs.getDate("postdate");     
        readcount = rs.getInt("readcount");
        
        sql = "select count(*) as count from STUDY_AINFO where sid = " + id;
        rs1 = u_stmt.executeQuery(sql);
        if (rs1.next())
            answer_count = rs1.getInt("count");
        rs1.close();
        
        
        
    }
    %>
<script type="text/javascript">
$(function(){
    $(".includeDom").each(function(){
        var html = $(this).attr("include");
	$(this).load(html,function() {
            $(".menu li a").eq(4).css("color","#1b8403");
            $(".toptit span a").eq(0).addClass("now");
             $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
	});
    })
})
</script>
<script type="text/javascript">
function change_page(index) {
    window.location.href = "study_info.jsp?id=" + <%=id%> + "&page=" + index;
}
function select_change() {
    change_page($("#page").val());
}
function submit_eval() {
    var eval = $("#eval_text").val();
    if(eval.length < 1 || eval == "输入文本...")
        alert("请输入正确文本");
    else {
        $("#eval_form1").submit();
}
        
}
</script>
    <div class="w964">
	<div class="includeDom" include="inc/top.jsp"></div>
	<div class="toptit studytoptit">
            <b>学习</b>
            <span><a href="study.jsp">全部资料</a><a href="study.jsp?type=1">专业知识</a><a href="study.jsp?type=2">企业相关</a><a href="study.jsp?type=3">其他综合</a></span>
           
	</div>
	<div class="site clear" style="position:relative">
            <div class="content fle">
                <div class="conttop"></div>
		<div class="main">           
                    <div class="study_tit">
			<b><%=title%></b>
			<p><span>发布时间：<%=postdate%></span> <span>下载：<%=downloadcount%></span> <span>浏览：<%=readcount%></span> <span>积分：<%=rewardintegral%></span></p>
                    </div>
                    <div class="faqinfo_con">
					<%
						if (imagepath != null && imagepath.length() > 0)
						{
							char separateSymbol = imagepath.charAt(imagepath.length()-1);
							if (separateSymbol != '/')
							{
					%>
                        <p><img src="<%=imagepath%>" style="width: 100%;"alt=""/></p>
					<%
							}
						}
					%>
			<p><%=body%></p>					
			<div class="studybtn marT20" align="center"><a href="download.jsp?qid=<%=id%>">下载资料</a></div>
                    </div> 
                    <%
                    int pagenum = Integer.parseInt(spage);
                    int pagecount = 2;

                    rs.close();
                    sql = "select count(*) as count from STUDY_AINFO where sid = '" + id + "'";
                    rs = stmt.executeQuery(sql);
                    
                    int total_count = 0;
                    int total_page = 0;
                    int prev_page = 1, next_page = 1, first_index = 1, last_index = 1;
                    int  clob_length = 0;

                    if (rs.next()) {
                        total_count = rs.getInt("count");
                    rs.close();
                                        
                    %>     
                    <div class="faqanstab">
                        <form action="study_info_addans.jsp" method="post" id ="eval_form1"> 
                            <h4>发表评论 <span>（共<%=total_count%>条评论）</span></h4>
                            <div class="faqanseare">
				<textarea name="postdata" class="faqansinput" id="eval_text" onclick="if (this.value=='输入文本...') this.value=''">输入文本...</textarea>
                            </div>
                            <input type="hidden" id="action" name="id" value="<%=id%>"/>
                            <% if ( UserId != 0 && IsActive == 1)  { %>
                            <div class="faqansbtn" align="right"><input type="button" value="评 论" class="faqansbtn01" onclick="submit_eval();"></div>
                            <% } %>
                        </form>		
                    </div>
                    <%
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
                        if(first_index == 1) pagecount = last_index;

                        rs.close();
                        sql = "select * from (select * from  (select * from STUDY_AINFO where sid = '" + id + "' order by id ASC) where ID >= (select MAX(ID) from (select * from STUDY_AINFO where sid = '" + id + "' and ROWNUM <= " + last_index + " order by id) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
                        rs = stmt.executeQuery(sql);

                        mid = 0;
                        String user_image = null, answer_name = null, answer_body = null;
                        boolean first;
                        if(pagenum ==total_page)   first  = true;
                        else  first = false;
                    %> 
                    <div id ="answerpage"  class="faqinfo_ans marT20">
                        <ul class="clear">                                      
                            <%
                            while (rs.next()) {
                                mid = rs.getInt("mid");
                                
                                sql = "select name, photo from memberinfo where deleted = 0 and id = " + mid;
                                rs1 = u_stmt.executeQuery(sql);
                                if (rs1.next())
                                {
                                    answer_name = rs1.getString("name");
                                    user_image = rs1.getString("photo");
                                }
                                rs1.close();

                                clob = rs.getClob("BODY");
                                clob_length = (clob==null)?-1:(int)clob.length();
                                if (clob_length < 0)
                                    answer_body = "";
                                else
                                answer_body = clob.getSubString(1, clob_length).replaceAll("\r\n", "<br>");
                                 answer_body = answer_body.replaceAll("\n", "&<br>");
                                postdate = rs.getDate("postdate");               
                            %>            
                                <% 
                                if (first == true) {
                                first = false;
                                %>
                                <li class="best">                                                    
                                    <h4>最近评论</h4>
                                <%
                                }
                                else {
                                %>
                                <li class="clear">  
                                <%
                                }
                                %>
                                    <div class="clear">
                                        <div class="faqansl fle"><img src=<%=user_image%> width="64" height="64" alt=""></div>
                                        <div class="faqansr fri">  
                                            <h3><%=answer_name%></h3>
                                            <p><%=answer_body%></p>
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
			共 <%=total_count%>条数据（<%=total_page%> 页）<a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);"><img src="img/page.jpg" alt=""></a> 
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
                        <a href="javascript:void(0)" onclick="change_page(<%=next_page%>)"><img src="img/page01.jpg" alt=""></a>
                    </div>	
                    <%                                                                                                                       }
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
                         <form action="study_info_addans.jsp" method="post" id ="eval_form">
                         <div class="playfeedt"><textarea name="postdata" class="playfeedta"></textarea></div>
                         <div class="playfeedbtn">
                             <% if (UserId != 0 && IsActive == 1) { %>
                             <input type="submit" value="提 交" class="faqansbtn01" />
                             <% } %>
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
    <div class="includeDom" include="inc/footer.jsp"></div>
    <%
    rs.close();
    stmt.close();
    u_stmt.close();
    conn.close();
    %>
</body>
</html>