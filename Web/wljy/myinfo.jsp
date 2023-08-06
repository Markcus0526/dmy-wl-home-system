<%-- 
    Document   : myinfo
    Created on : 10-Dec-2013, 10:11:25
    Author     : KIMSUI
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
<%@page language="Java" import="java.sql.*" %>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->

<%
    int type = Integer.parseInt((request.getParameter("type") == null)?"0":request.getParameter("type"), 10);
%>
<script type="text/javascript">
    $(function() {
	$(".toptit span a").eq(4).addClass("now");
	$(".myinfo li").eq(<%=type%>).find("span").show().css("display","block");
        $(".myinfo li a").eq(<%=type%>).addClass("on");
	// $(".myinfo li a").hover(function() {
	// 	$(this).addClass("on");
	// 	$(this).parent().find("span").show().css("display","block");
	// }, function() {
	// 	$(this).removeClass("on");
	// 	$(this).parent().find("span").hide();
	// })
    })
    
    function change_page(index) {
        window.location.href = "myinfo.jsp?type=<%=type%>&page=" + index;
    }
    
    function select_change() {
        change_page($("#page").val());
    }
</script>
</head>
<body>
<%@ include file="connection.jsp" %>
<%

    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
         if(name.substring(0, pos).equals("wljyid")) {
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
     
     int pagenum = Integer.parseInt(spage);
     int pagecount = 8;


     Statement stmt = conn.createStatement();   
     Statement u_stmt = conn.createStatement();

     String sql;
     if ( type == 0 )
        sql = "select count(*) as count from DATA_DOWNLOAD where deleted = 0 and TO_CHAR(downloaddate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and MID = "+UserId;
     else
        sql = "select count(*) as count from STUDY_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and MID = "+UserId;

     ResultSet rs = stmt.executeQuery(sql);
     ResultSet rs1;
     
     int total_count = 0, total_page = 0;

     if (rs.next()) {
        total_count = rs.getInt("count");
        /*
        if (total_count == 0) {
            out.println("<script>window.location.href='postinfo.jsp';</script>");
            return;
        }*/

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
    
    if ( type == 0 )
        sql = "select * from (select * from DATA_DOWNLOAD where deleted = 0 and TO_CHAR(downloaddate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and ID >= (select MAX(ID) from (select * from DATA_DOWNLOAD where deleted = 0 and TO_CHAR(downloaddate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and MID="+UserId+" and ROWNUM <= " + last_index + " order by ID) where MID="+UserId+" and rownum <= " + first_index + ") and MID="+UserId+" and ROWNUM <= " + pagecount + ") order by ID DESC";
    else
        sql = "select * from (select * from STUDY_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and ID >= (select MAX(ID) from (select * from STUDY_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') and MID="+UserId+" and ROWNUM <= " + last_index + " order by ID) where MID="+UserId+" and rownum <= " + first_index + ") and MID="+UserId+" and ROWNUM <= " + pagecount + ") order by ID DESC";
    rs = stmt.executeQuery(sql);

    int id = 0;
    int info_id[] = new int[pagecount];
    int infodata_id[] = new int[pagecount];
    String info_titles[] = new String[pagecount];
    String info_bodys[] = new String[pagecount];
    Date info_postdate[] = new Date[pagecount];
    int info_integral[] = new int[pagecount];
    int t;
    int cur_count;
    t = 0;
    int clob_length = 0;
    Clob clob = null;
    
    while ( rs.next() )
    {
        info_titles[t] = "";
        info_bodys[t] = "";
        if ( type == 0 )
        {
            id = rs.getInt("SQID");
            sql = "SELECT * FROM STUDY_QINFO WHERE ID="+id;
            rs1 = u_stmt.executeQuery(sql);
            if ( rs1.next() )
            {
                info_titles[t] = rs1.getString("TITLE");
                clob = rs1.getClob("BODY");
                clob_length = (clob == null)?-1:(int)clob.length();
                                
                info_id[t] = rs1.getInt("ID");
                info_postdate[t] = rs1.getDate("POSTDATE");
                info_integral[t] = rs1.getInt("INTEGRAL");
            }
            infodata_id[t] = rs.getInt("ID");
        }
        else
        {
            info_titles[t] = rs.getString("TITLE");
            clob = rs.getClob("BODY");
            clob_length = (clob == null)?-1:(int)clob.length();
            
            info_id[t] = rs.getInt("ID");
            info_postdate[t] = rs.getDate("POSTDATE");
            info_integral[t] = rs.getInt("INTEGRAL");
            
            infodata_id[t] = info_id[t];
        }
        if (clob_length < 0)
            info_bodys[t] = "";
        else if (clob_length > 32)
            info_bodys[t] = clob.getSubString(1, 32) + "...";
        else 
            info_bodys[t] = clob.getSubString(1, clob_length);
        
        t++;
    }
    cur_count = t;
    
%>
<script type="text/javascript">
$(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html, function(){
                             $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
                });
	})
})
</script>
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
			<div class="singlebtn" align="right"><a href="postinfo.jsp">上 传 资 料</a></div>
			<div class="myinfo">
				<ul class="clear">
					<li>
                                            <a href="myinfo.jsp?type=0">下载的资料</a>
						<span><img src="img/myidea_img03.jpg" width="10" height="4" alt="" /></span>
					</li>
					<li>
						<a href="myinfo.jsp?type=1" >上传的资料</a>
						<span><img src="img/myidea_img03.jpg" width="10" height="4" alt="" /></span>
					</li>
				</ul>
			</div>
                        <div class="photoEdit">
                            <div class="myexchangetit">
                                <span style="width:230px; border-right:1px solid #e0e0e0; padding-left: 80px;">标题</span>
<!-- FixME                                <span style="width:150px; border-right:1px solid #e0e0e0; text-align:center">悬赏积分</span>  -->
                                <span style="width:210px; border-right:1px solid #e0e0e0; text-align:center">日期</span>
                                <span style="width:220px; text-align:center">操作</span>
                            </div>                                
                            <div class="myexchangelist photEditCon">
                                <ul>
                                    <form action="myinfo_del.jsp?type=<%=type%>" method="post" id="submit_form">
                                        <% for ( t = 0; t < cur_count; t++ ) { %>
                                        <li class="clear">
                                            <span style="width:50px;" class="editCheck">
                                                <input type="checkbox" name="check_<%=t%>" value="" />
                                                <input type="hidden" name="id_<%=t%>" value="<%=infodata_id[t]%>" />
                                            </span>
                                            <span style="width:230px;"><%=info_titles[t]%></span>
<!-- FixME                                  <span class="editTit" style="width:160px; text-align:center;"><%=info_integral[t]%>分</span> -->
                                            <span style="width:245px; text-align:center;"><%=info_postdate[t]%></span>
                                            <span style="width:225px; text-align:center;"><a href="study_info.jsp?id=<%=info_id[t]%>">查看详细</a> | <a href="javascript:;" class="editDelete" onclick="delete_act('<%=infodata_id[t]%>', '<%=info_titles[t]%>')">删除</a> | <a href="postinfo.jsp?id=<%=infodata_id[t]%>&type=<%=type%>">编辑</a></span>
                                        </li>
                                         <% } %>
                                    </form>
                                </ul>
                            </div>        

                            <div class="page mar15 clear">
                                <div class="page mar fri" align="right">
                                    共 <%=total_count%>条数据（<%=total_page%> 页）
                                    <a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);">
                                         <img src="img/page.jpg" alt="" />
                                    </a> 
                                    <select id="page" onchange="select_change();">
                                    <%
                                        int i = 0;
                                        for (i = total_page; i > 0;i--) {
                                            if (i == pagenum)   {                                                  
                                    %>
                                        <option value="<%=i %>" selected="selected"><%=i%></option>
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
                                    <span style="width:20px;" class="checkall"><input name="" id="selectAll" type="checkbox" value="" /></span><span style="padding:0 10px;">全选</span> | <a href="javascript:void(0)" class="selectall" onclick="delete_act1()">删除</a>
                            </div>
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
                        $(".myexchangelist li span.editCheck").each(function() {
                            $(this).find("input")[0].checked = true;
                        });
                    } else {
                        $(".myexchangelist li span.editCheck").each(function() {
                            $(this).find("input")[0].checked = false;
                        });
                    }
                });

                $(".myexchangelist li span.editCheck").find("input").click(function() {
                    var isSelect = this.checked;

                    if (!isSelect) {
                        $("#selectAll")[0].checked = false;
                    }
                });
    
            })
            
            function delete_act(id, title)
            {
                if (confirm("您确定要删除你的资料'" + title + "'吗?"))
                {
                    window.location.href = "myinfo_del.jsp?id="+id+"&type=<%=type%>";
                }
            }
    
            function delete_act1()
            {
                var selected_id = "";
                $('.myexchangelist input:checked').each(function () {
                    selected_id += this.value + ",";
                });
        
                if (selected_id != "")
                {
                    if (confirm("您确定要把勾选的资料删除吗?"))
                    {
                        $("#submit_form").submit();
                    }
                }
            }
        </script>

</body>
</html>