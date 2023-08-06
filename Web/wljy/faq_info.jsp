<%-- 
    Document   : faq_info
    Created on : 10-Dec-2013, 10:06:54
    Author     : PAK SONG HYOK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
<%@include file="cookie_check.jsp" %>
<%@ include file="connection.jsp" %>
<%@page import="java.util.Date"%>
    <%    
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
	String str_IsActive = "";
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

    String sql1 = "";
     ResultSet rs2;
    Statement stmt2 = conn.createStatement();
    
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
      
    String sql = new String();
    ResultSet rs;
    
    int readcount = 0;
    if (spage == "0"){    
        sql = "Select * from PROBLEM_QINFO where ID =" + id;
        rs = stmt.executeQuery(sql);
        while (rs.next()) {
            readcount = rs.getInt("readcount") + 1;
        }
        rs.close();
        
        sql = "update PROBLEM_QINFO set readcount = " + readcount + "where id = " + id;
        stmt.executeUpdate(sql);
    }           
      
    sql = "select * from PROBLEM_QINFO where id = " + id;
    rs = stmt.executeQuery(sql);    
      
    ResultSet rs1;
	int CommendNo = 0;
    String title = new String();
    Date postdate = new Date(1,11,1);
    int rewardintegral = 0;
    String body = new String();
    int mid = 0;
	int queryMID = 0;
    String username = new String();      
    String type_name = new String();
    int type = 0;
    Clob clob = null;
    int clob_len = 0, answer_count = 0;
    while (rs.next()) {
        mid = rs.getInt("mid");
		queryMID = mid;
        title = rs.getString("title");
		CommendNo = rs.getInt("commendno");
        
        sql = "Select * from memberinfo where id = " + mid;
        rs1 = u_stmt.executeQuery(sql);
        while (rs1.next()) {
            username = rs1.getString("name");
        }
        rs1.close();
        
        type = rs.getInt("type");
        
        sql = "select * from PROBLEM_TYPE where id = " + type;
        rs1 = u_stmt.executeQuery(sql);
        while (rs1.next()) {
            type_name = rs1.getString("name");
        }
        rs1.close();
        
        clob = rs.getClob("body");
        clob_len = (clob==null)?-1:(int)clob.length();
        if (clob_len < 0)
            body = "";
               else {
            body = clob.getSubString(1, clob_len).replaceAll("\r\n", "<br>");
            body = body.replaceAll("\n", "&<br>");
                       }
        
        rewardintegral = rs.getInt("rewardintegral");
        postdate = rs.getDate("postdate");     
        readcount = rs.getInt("readcount");
        
        sql = "select count(*) as count from problem_ainfo where pid = " + id;
        rs1 = u_stmt.executeQuery(sql);
        if (rs1.next())
            answer_count = rs1.getInt("count");
    }
    %>
	<%
		String user_image = null;
		String commendName = "";
		String commendBody = "";
		Date commendDate = new Date(1,11,1);
		if ( CommendNo != 0 )
		{
			Statement stmtCommend = conn.createStatement();
			String queryCommend = "select * from PROBLEM_AINFO where id = " + CommendNo;
			ResultSet rsCommend = stmtCommend.executeQuery(queryCommend);
			while (rsCommend.next()) {
				Clob clobcommend = rsCommend.getClob("BODY");
				int clobCommend_length = (clobcommend==null)?-1:(int)clobcommend.length();
				if (clobCommend_length < 0)
					commendBody = "";
				else 
				{
					commendBody = clobcommend.getSubString(1, clobCommend_length).replaceAll("\r\n", "<br>");
					commendBody = commendBody.replaceAll("\n", "&<br>");
				}
				commendDate = rsCommend.getDate("postdate");
				int commendID = rsCommend.getInt("mid");
				Statement stmtCommendID = conn.createStatement();
				String queryCommendID = "select name, photo from memberinfo where id = " + commendID;
				ResultSet rsCommendID = stmtCommendID.executeQuery(queryCommendID);
				while (rsCommendID.next())
				{
					commendName = rsCommendID.getString("NAME");
					user_image = rsCommendID.getString("photo");
					if (user_image == null)
						user_image = "img/defimg.png";
				}
				rsCommendID.close();
				stmtCommendID.close();
			}
			rsCommend.close();
			stmtCommend.close();
		}
	%>
<script type="text/javascript">
$(function(){
    $(".includeDom").each(function(){
        var html = $(this).attr("include");
        $(this).load(html,function() {
            $(".menu li a").eq(3).css("color","#fc741a");
            $(".toptit span a").eq(0).addClass("now");
                            $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
        });
    })
})
</script>
<script type="text/javascript">
function change_page(index) {
    window.location.href = "faq_info.jsp?id=" + <%=id%> + "&page=" + index;
}
function select_change() {
    change_page($("#page").val());
}
function submit_eval() {
    var eval = $("#eval_text").val();
    if(eval.length < 1 || eval == "输入回答...")
        alert("请输入正确回答");
    else
        $("#eval_form").submit();
}
function on_commend() {
	$("#form_commend").submit();
}
</script>
    <div class="w964">
	<div class="includeDom" include="inc/top.jsp"></div>
	<div class="toptit">
            <b>问答</b>
            <span><a href="faq.jsp">全部问题</a><a href="faq.jsp?type=1">专业知识</a><a href="faq.jsp?type=2">企业相关</a><a href="faq.jsp?type=3">其他综合</a></span>
            
	</div>
	<div class="site clear">
            <div class="content fle">
                <div class="conttop"></div>
		<div class="main">
                    <div class="faqinfo_tit">
                        <b><%=title%></b>
			<p>提问人：<em style="color:#c51a38"><%=username%></em>悬赏积分：<em style="color:#e56917"><%=rewardintegral%></em></p>
			<span>提问时间：<%=postdate%></span> <span>浏览：<%=readcount%> </span> <span>回答：<%=answer_count%></span> <span> 所述分类：<%=type_name%>  </span>
                    </div>
                    <div class="faqinfo_con">
                        <p><%=body%></p>					
                    </div>
					<div class="faqinfo_ans">
						<ul class="clear">
							<%
										if (CommendNo != 0)
										{
							%>
											<li class="best">                                                    
												<h4>最佳回答</h4>
												<div class="clear">
												<div class="faqansl fle"><img src=<%=user_image%> width="64" height="64" alt=""></div>
												<div class="faqansr fri">
													<h3><%=commendName%></h3>
													<p><%=commendBody%></p>
													<em><%=commendDate%></em>
													<span></span>
												</div>
											</li>
							<%
										}
							%>
						</ul>
					</div>
                                         
                    <!--<ul class="clear">-->
                    <%
                    int pagenum = Integer.parseInt(spage);
                    int pagecount = 2;

                    sql = "select count(*) as count from PROBLEM_AINFO where id != " + CommendNo + " and pid = '" + id + "'";
					//sql = "select count(*) as count from PROBLEM_AINFO where pid = '" + id + "'";
                    rs = stmt.executeQuery(sql);

                    int total_count = 0;
                    int total_page = 0;
                    int prev_page = 1, next_page = 1, first_index = 1, last_index = 1;

                    int  clob_length = 0;

                    if (rs.next()) {
                        total_count = rs.getInt("count");
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

                            sql = "select * from (select * from  (select * from PROBLEM_AINFO where id != " + CommendNo + " and pid = '" + id + "' order by id ASC) where ID >= (select MAX(ID) from (select * from PROBLEM_AINFO where id != " + CommendNo + " and pid = '" + id + "' and ROWNUM <= " + last_index + " order by id) where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
                            rs = stmt.executeQuery(sql);
                            mid = 0;
                            String answer_name = null, answer_body = null;
							int answer_id = 0;
                            boolean first;
                            if(pagenum ==total_page)   first  = true;
                            else  first = false;
                    %>
                    <div class="faqinfo_ans">
						<ul class="clear">							
							<%
								while (rs.next()) 
								{
									mid = rs.getInt("mid");
									answer_id = rs.getInt("id");
								
									sql = "select name, photo from memberinfo where id = " + mid;
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
										body = "";
									else 
									{
										answer_body = clob.getSubString(1, clob_length).replaceAll("\r\n", "<br>");
										answer_body = answer_body.replaceAll("\n", "&<br>");
									}
									postdate = rs.getDate("postdate");  
							%>
									<li class="clear">
											<div class="clear">
												<div class="faqansl fle"><img src=<%=user_image%> width="64" height="64" alt=""></div>
												<div class="faqansr fri">
													<h3><%=answer_name%></h3>
													<p><%=answer_body%></p>
													<em><%=postdate%></em>
													<span></span>
							<%						if (queryMID == UserId && CommendNo == 0)
													{
							%>
														<div style="float: right;_display:inline;">
															<form id="form_commend" action="faq_info_commend.jsp" method="post" >
																<input type="hidden" name="answerid" value="<%=answer_id%>">
																<input type="hidden" name="queryid" value="<%=id%>">
															</form>
															<input type="button" class="faqanscommend" onclick="on_commend();">
														</div>
							<%
													}
							%>
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
                                if (i == pagenum) {                                                  
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
                <%                                                                                                                            }
                }
                %>
                    <div class="faqanstab">
                        <form action="faq_info_addans.jsp" method="post" id ="eval_form">  
                            <h4>回答问题 <span>（共<%=total_count%>条回答）</span></h4>
                            <div class="faqanseare">
				<textarea name="postdata" class="faqansinput" onclick="if (this.value=='输入文本...') this.value=''" id="eval_text" >输入文本...</textarea>
                            </div>
                            <input type="hidden" id="action" name="id" value="<%=id%>"/>
                            <% if ( UserId != 0 && IsActive == 1 )  { %>
                            <div class="faqansbtn" align="right"><input type="button" value="回 答" class="faqansbtn01" onclick="submit_eval()"></div>
                            <% } %>
                        </form>
                    </div>                  
		</div>          
		<div class="contbot"></div>
            </div>                    
            <div class="includeDom" include="inc/faqright.jsp"></div>
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