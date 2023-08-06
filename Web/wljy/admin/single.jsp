<%-- 
    Document   : single
    Created on : Jan 5, 2014, 9:44:55 AM
    Author     : Hercules
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
<script type="text/javascript" src="../js/jQuery-fileUploadButton.1.0.js"></script>
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
<%@ include file="cookie_check.jsp" %>
<%@ include file="../connection.jsp" %>
</head>

<%!
    public String ConvertDateString(String dateStr){
        String ret;
        String[] tmp = {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"};
        
        try {
            ret = dateStr.substring(8, 10) + "-" + tmp[Integer.parseInt(dateStr.substring(5, 7), 10) - 1] + "-" + dateStr.substring(0, 4);
        }
        catch (Exception e)
        {
            ret = "";
        }
        return ret;
    }

%>
<%
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i < cookies.length;i++) {
       String name= cookies[i].getName();
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

     String search_name = request.getParameter("search_name")== null?"":request.getParameter("search_name");
     String search_title = request.getParameter("search_title")== null?"":request.getParameter("search_title");
     String search_from = request.getParameter("from_datepicker")== null?"":request.getParameter("from_datepicker");
     String search_to = request.getParameter("to_datepicker")== null?"":request.getParameter("to_datepicker");
     
     String tmp_from = search_from;
     String tmp_to = search_to;
     
     
     String add_condition = "";
     Statement tmp_stmt = conn.createStatement();
     String tmp_sql;
     ResultSet tmp_rs;
     
     if ( !search_name.equals("") )
     {
         add_condition = "(name like '" + search_name + "%' or name like '%" + search_name + "' or name like '%" + search_name + "%')";
         tmp_sql = "select ID from memberinfo where deleted = 0 and " + add_condition;
         
         add_condition = "(";
         
         tmp_rs = tmp_stmt.executeQuery(tmp_sql);
         while ( tmp_rs.next() )
         {
            add_condition += "MID = " + Integer.toString(tmp_rs.getInt("ID"), 10) + " or ";
         }
         tmp_rs.close();
         tmp_stmt.close();
         
         if ( !add_condition.equals("(") )
             add_condition = add_condition.substring(0, add_condition.length() - 4) + ")";
         else if (search_name.equals("管理者"))
             add_condition = "(MID = 0)";
         else
             add_condition = "(1=0)";
     }
     
     if ( !search_title.equals("") )
     {
         if ( !add_condition.equals("") )
             add_condition += " and ";
         add_condition += "(title like '" + search_title + "%' or title like '%" + search_title + "' or title like '%" + search_title + "%')";
     }
     
     if (!search_from.equals(""))
     {
         search_from = ConvertDateString(search_from);
     }
     
     if (!search_to.equals(""))
     {
         search_to = search_to.substring(0, 4)+search_to.substring(5, 7) + search_to.substring(8, 10);
     }

     if (!search_from.equals("") && search_to.equals("")) {
         if ( !add_condition.equals(""))
            add_condition += " and ";
         add_condition += " (postdate >= '" + search_from + "')";
     }
     else if(search_from.equals("") && !search_to.equals(""))
     {
         if ( !add_condition.equals(""))
            add_condition += " and ";
         add_condition += " (postdate <= TO_DATE('" + search_to + "', 'yyyymmdd') + 1)";
     }
     else if(!search_from.equals("") && !search_to.equals(""))
     {
         if ( !add_condition.equals(""))
            add_condition += " and ";
         add_condition += " (postdate >= '" + search_from+ "' and postdate <= TO_DATE('" + search_to + "', 'yyyymmdd')+1)";
     }
     
     if ( !add_condition.equals("") )
         add_condition = " and " + add_condition;

     String spage = request.getParameter("page")== null?"0":request.getParameter("page");
     int pagenum = Integer.parseInt(spage);
     int pagecount = Integer.parseInt(request.getParameter("row")== null?"10":request.getParameter("row"), 10);
    
     
    
     Statement stmt = conn.createStatement();   
     Statement u_stmt = conn.createStatement();
        
     String sql = "select count(*) as count from ACTIVITY_INFO where deleted = 0 and type = 1 " + add_condition;
     ResultSet rs = stmt.executeQuery(sql);
     
     int total_count = 0, total_page = 0;
    
     if (rs.next()) {
        total_count = rs.getInt("count");
        
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = 1;
        if ( pagenum > total_page ) pagenum = total_page;
    }
     
    rs.close();
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;

    int last_index = total_count -  (pagenum - 1) * pagecount;
    int first_index = last_index - pagecount + 1;
    if (first_index <= 0) first_index = 1;
    int count = pagecount;
    
    ResultSet rs1 = null;
        if (first_index == 1) count = last_index;
    if (first_index > total_count) {
        count = last_index;
    }
    
    
    sql = "select * from (select * from (select * from activity_info where deleted = 0 and type = 1 "+ add_condition+"  order by id) where ID >= (select MAX(ID) from (select * from (select * from ACTIVITY_INFO where deleted = 0 and type = 1 "+ add_condition+"  order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ")  and ROWNUM <= " + count + ") order by id DESC";
    rs = stmt.executeQuery(sql);
    
    String title = new String();
    int readcount = 0;
     
    
    String imagepath = new String();
    int id = 0, mid = 0, eval_count = 0;
    int is_visible = 0, is_select = 0, is_public = 0;
    String public_string = new String();
    String select_image = new String(), visible_image = new String();
    String body = new String();
    int clob_length = 0;
    Clob clob = null;
%>
<script type="text/javascript">
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
        
        $('#imagefile').fileUploadButton({
                height: '24px',
                width: '24px',
                image: '../img/load.png'
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
    function change_row(row)
    {
        $("#search_row").val(row);
        $("#search_page").val('<%=pagenum%>');
          
        $("#search_form").submit();
    }
    function change_check(str)
    {
        var obj, obj1;
        if (str == "select") {
            obj = $("#select");
            obj1 = $("#select_val");
        }
        else {
            obj = $("#visible");
            obj1 = $("#visible_val");
        }
        
            
        if (obj.attr("src") == "img/i-no.gif") {
            obj.attr("src", "img/i-yes.gif");
            obj1.attr("value", 1);
        }            
        else {
            obj.attr("src", "img/i-no.gif");
            obj1.attr("value", 0);
        }           
    }
    
    function select_change(type) {
        if(type=="ispublic")
            $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());
    }
    
    function add()
    {        
        $("#id").attr("value", "0");
        $("#title").attr("value", '');
        $("#visible").attr("src", "img/i-yes.gif");
        $("#select_val").attr("value", 0);
        $("#visible_val").attr("value", 1);
        
        $("#select_ispublic").val(1);  
        
        $("#body").html("");
        $("#act").attr("value", "add");
        $('.actincrease').show();
    }

    function edit(id, title, isselect, isvisible, imagepath, body, ispublic)
    {
        $("#id").attr("value", id);
        $("#act").attr("value", "edit");
        $("#title").attr("value", title);
        
        $("#select").attr("src", $("#select_" + id).attr("src"));

            if ($("#select_" + id).attr("src").search("yes") != -1)    
                isselect = 1;
            else isselect = 0;
            $("#select_val").attr("value", isselect);
            
            $("#visible").attr("src", $("#visible_" + id).attr("src"));
            
            $("#select_ispublic").val(ispublic);

            if ($("#visible_" + id).attr("src").search("yes") != -1)    
                isvisible = 1;
            else isvisible = 0;
            $("#visible_val").attr("value", isvisible);
        
        body = body.replace(/&<br>/g, "\r\n");
        $("#body").val(body);
        $("#main_image").attr("src", "../" + imagepath);
        $(".actincrease").show();
    }
    
    var imagefile_submit_clicked = -1;
    var cur_img_path;
    var img_index = 0;
    function imagefile_submit()
    {
        imagefile_submit_clicked = 1;
        var tmpStr = $("#imagefile").val().toString();
        var ind = tmpStr.lastIndexOf("\\") + 1;
        if(ind < 0) ind = tmpStr.lastIndexOf("/") + 1;
        cur_img_path = <%= UserId %> + "_tmp_" + tmpStr.substring(ind);
        
        $("#imagefilename").attr("value", cur_img_path);
        //img_index++;
        $("#imagechanged").attr("value", "1");
        $("#imageUploadForm").submit();
    }

    function imagefile_read()
    {
        if (imagefile_submit_clicked < 0)
            return;

        imagefile_submit_clicked = -1;
        
        $("#main_image").attr("src", "../upload_data/activity/"+cur_img_path);
    }
    
    function submit_add()
    {
        if ($("#title").val().length == 0) {
           alert("请输入您的标题");
           return;
        }
            
        $("#tmp_title").attr("value", $("#title").val());    
        $("#tmp_select").attr("value", $("#select_val").val());    
        $("#tmp_visible").attr("value", $("#visible_val").val());
        $("#tmp_image").attr("value", $("#main_image").attr("src"));
        $("#page").attr("value", "<%=pagenum%>");
        $("#count").attr("value", "<%=pagecount%>");
        
        $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());  
        
        $("#act_post").submit();
    }
    
    function delete_act(id, title)
    {
        if (confirm("您确定要删除 '" + title + "'吗?"))
        {
          $("#id").attr("value", id);
          $("#act").attr("value", "delete");
          $("#tmp_pagenum").attr("value", "<%=pagenum%>");
          $("#tmp_pagecount").attr("value", "<%=pagecount%>");
          $("#act_post").submit();
        }
    }
    	function check_ext()
	{
		 var idx = $("#imagefile").val().lastIndexOf('.');     
                 var ext = $("#imagefile").val().substr(idx + 1, $("#imagefile").val().length).toLowerCase();
        if (ext != "jpg" && ext != "png" && ext != "bmp" && ext != "gif") {
            alert("图片格式错误");
            return;
        }
		
		$('#hImageUploadButton').click();
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
        $("#search_form").submit();
   
}  
  function change_visible(id)
        {            
        
            var data = $("#visible_" + id).attr("src");        
            if (data.search("yes") != -1) 
            {
                data = 0;
            }
            else {
                data= 1;
            }
        
                  $.ajax({
                    url: "ajax.jsp",
                    type: "POST",
                    dataType: "json",
                    data: {
                        type: "activity",
                        act: "visible",
                        id: id,
                        value: data
                    },
                    success: edit_visible,
                    error: errorfunc1
                });
        }
        
        function edit_visible(res)
        {
            if (res.success == 1)
                if (res.visible == 1)
                    $("#visible_" + res.id).attr("src","img/i-yes.gif");
                else
                    $("#visible_" + res.id).attr("src","img/i-no.gif");
        }
        function errorfunc1(res)
        {
        
        }
        
        function change_select(id)
        {            
        
            var data = $("#select_" + id).attr("src");        
            if (data.search("yes") != -1) 
            {
                data = 0;
            }
            else {
                data= 1;
            }
        
                  $.ajax({
                    url: "ajax.jsp",
                    type: "POST",
                    dataType: "json",
                    data: {
                        type: "activity",
                        act: "select",
                        id: id,
                        value: data
                    },
                    success: edit_select,
                    error: errorfunc1
                });
        }
        
        function edit_select(res)
        {
            if (res.success == 1)
                if (res.select == 1)
                    $("#select_" + res.id).attr("src","img/i-yes.gif");
                else
                    $("#select_" + res.id).attr("src","img/i-no.gif");
        }
        
                function change_public(id)
        {            
        
            var data = $("#public_" + id).html();        
            if (data.search("不公开") != -1) 
            {
                data = 1;
            }
            else {
                data= 0;
            }
        
                  $.ajax({
                    url: "ajax.jsp",
                    type: "POST",
                    dataType: "json",
                    data: {
                        type: "activity",
                        act: "public",
                        id: id,
                        value: data
                    },
                    success: edit_public,
                    error: errorfunc1
                });
        }
        
        function edit_public(res)
        {
            if (res.success == 1)
                if (res.public == 1)
                    $("#public_" + res.id).html("公开");
                else
                   $("#public_" + res.id).html("不公开");
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
                    if (confirm("您确定要把勾选的活动删除吗?"))
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
                $(".nav a").eq(2).addClass("on");
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
                            <li><a href="activity.jsp"><span>官方活动管理</span></a></li>
                            <li><a href="single.jsp" class="on"><span>会员活动管理</span></a></li>
			</ul>
		</div>
		<div class="clear"></div>
	</div>
	<div class="main">
		<div class="side">
			<div class="side-list">
				<h2>会员活动管理</h2>				
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
														<h2>会员活动管理<a id="del" href="#1" onclick="select_delete();">删除</a></h2>
                                                    </td>
                                                    <td>
                                                        <div style="align:center" align="center">
                                                            <form action="single.jsp" method="post" id="search_form">
                                                            账号: <input type="text" id="search_name" name="search_name" size="15" value="<%=search_name%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                                            标题: <input type="text" id="search_title" name="search_title" size="15" value="<%=search_title%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                                            期间: <input type="text" id="from_datepicker" readonly name="from_datepicker" size="10" value="<%=tmp_from%>" />&nbsp;~&nbsp;<input type="text" readonly id="to_datepicker" name="to_datepicker" size="10" value="<%=tmp_to%>"/>&nbsp;&nbsp;&nbsp;&nbsp;
                                                            <input type="hidden" name="row" id="search_row" value="10" />
                                                            <input type="hidden" name="page" id="search_page" value="0" />
                                                            <input type="button" onclick="check_search();" id="searchbtn" value="查找" style="width:40px" onclick=""/>
                                                            <input type="button" onclick="clear_search();" id="searchbtn" value="清空" style="width:40px" onclick=""/>
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
						<p><%=total_count%>个符合 |  每页 <a href="#" onclick="change_row('10');">10个</a> » <a href="#" onclick="change_row('25');">25个</a> » <a href="#" onclick="change_row('50')">50个</a></p>
					</div>
					<div class="content-table">
						<table width="100%" style="table-layout:fixed">
							<tr>
                                                             <th style="width:3%"><input type="checkbox" class="group-checkable"/></th>
								<th style="width:10%;">图片</th>
                                <th style="width:15%;">账户</th>
								<th style="width:40%;">标题</th>
								<th style="width:10%;">是否游客公开</th>
								<th style="width:8%;">显隐</th>
								<th style="width:8%;">精华</th>
								<th style="width:9%;">操作</th>                    
							</tr>
                                                        <%
                                                            String blank = new String();
                                                            blank = "blank";
                                                            
                                                            String username = new String();
                                                            while (rs.next()) {
                                                                if (blank.length() == 0) blank = "blank";
                                                                else blank = "";
                                                                mid = rs.getInt("mid");
                                                                if ( mid > 0 )
                                                                {
                                                                sql = "select name from memberinfo where deleted = 0 and id = " + mid;
                                                                rs1 = u_stmt.executeQuery(sql);
                                                                if (rs1.next())
                                                                    username = rs1.getString("name");
                                                                else 
                                                                        username = "";
                                                                    
                                                                    rs1.close();
                                                                }
                                                                else
                                                                    username = "管理者";
                                                                
                                                                
                                                                   
                                                                title = rs.getString("title");
                                                                                                                               
                                                                is_select = rs.getInt("isselected");
                                                                if (is_select == 0) select_image = "img/i-no.gif";
                                                                else select_image = "img/i-yes.gif";
                                                                    
                                                                is_visible = rs.getInt("isvisible");
                                                                if (is_visible == 0) visible_image = "img/i-no.gif";
                                                                else visible_image = "img/i-yes.gif";
                                                                
                                                                id = rs.getInt("id");
                                                                imagepath = "";
                                                                sql = "Select * from activity_image where deleted = 0 and aid = " + id;
                                                                rs1 = u_stmt.executeQuery(sql);
                                                                if (rs1.next()) {
                                                                    imagepath = rs1.getString("datapath"); 
                                                                }
                                                                rs1.close();  
                                                                
                                                                body = "";
                                                                clob = rs.getClob("body");
                                                                clob_length = (clob == null)?-1:(int)clob.length();
                                                                    
                                                                if (clob_length < 0)
                                                                    body = "";
                                                                 else 
                                                                    body = clob.getSubString(1, clob_length);                                                                                                                                                                                      
                                                                 body = body.replaceAll("\r\n", "&<br>");
                                                                  body = body.replaceAll("\n", "&<br>");
                                                             
                                                                  is_public = rs.getInt("ISPUBLIC");
                                                                 if(is_public == 1)
                                                                     public_string = "公开";
                                                                 else
                                                                     public_string = "不公开";
                                                        %>
							<tr class="<%=blank%>">
								<td class="checkboxes" ><input type="checkbox" value="<%=id%>"/></td>
								<td><img src="../<%=imagepath%>" width="50" height="50" alt="" /></td>
								<td><%=username%></td>   
								<td style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><%=title%></td>
								<td><a href="#" id="public_<%=id%>" onclick="change_public('<%=id%>');"><%=public_string%></a></td>
								<td><a href="#1"><img id="visible_<%=id%>" onclick="change_visible('<%=id%>')" src="<%=visible_image%>" alt="" /></a></td>
								<td><a href="#1"><img id="select_<%=id%>" onclick="change_select('<%=id%>');" src="<%=select_image%>" alt="" /></a></td>
								<td>
									<a href="#" onclick="edit('<%=id%>', '<%=title%>', '<%=is_select%>', '<%=is_visible%>', '<%=imagepath%>', '<%=body%>', '<%=is_public%>')">编辑</a> | <a href="#" onclick="delete_act(<%=id%>, '<%=title%>');">删除</a>
								</td>
							</tr>
                                                                <%
                                                                    }
                                                            rs.close();
                                                            stmt.close();
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
						<div class="increase-title"><h2>会员活动管理</h2><a href="#1" onclick="$('.actincrease').hide()">关闭 [X]</a></div>
					</div>
					<div class="increase-top">
                                             <div class="imgupload" align="center">
							<img id="main_image" src="" width="" height="" alt="" />
							<iframe src='about:blank' name='hImageUpload' id='hImageUpload' style='display:none;' onload='imagefile_read();'></iframe>
                                                        <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload' id="imageUploadForm">
                                                            <input type="hidden" id="imagefilename" name="imagefilename" />
                                                            <input type="hidden" id="imagefilepath" name="imagefilepath" value="upload_data/activity/" />
                                                            <input type="file" id="imagefile" name="imagefile" onchange="check_ext();" />
                                                            <input type='button' id='hImageUploadButton' name='hImageUploadButton' style='display:none;' onclick='imagefile_submit();' />
                                                        </form>                                                      
						</div>
						<div class="imgtable">
							<table width="100%">
								<tr>
									<td>个人活动名称</td>
									<td><input name="title" id="title" type="text" /></td>
								</tr>
                                                            
                                                                <tr>
                                                                    <td>是否游客公开:</td>
                                                                    <td>
                                                                        <select id="select_ispublic" onchange="select_change('ispublic');">
                                                                            <option value="0">不公开</option>
                                                                            <option value="1" selected>公开</option>
                                                                        </select>
                                                                    </td>
                                                                </tr>
                                                            
                                                                <tr>
									<td>显隐</td>
									<td>
                                                                            <a href="#"><img id="visible" src="img/i-yes.gif" alt=""  onclick="change_check();"/></a>
                                                                            <input type="hidden" id="visible_val" value="1"/>
                                                                        </td>
								</tr>
                                                                <tr>
									<td>推荐</td>
									<td>
                                                                            <a href="#" ><img id="select" src="img/i-no.gif" alt=""  onclick="change_check('select');"/></a>
                                                                            <input type="hidden" id="select_val" value="0"/>
                                                                        </td>
								</tr>
							</table>
						</div>
						<div class="clear"></div>
					</div>
					<div class="acttext">
						<h2>个人活动详情</h2>
                                                <form action="single_addinfo.jsp" method="post" id="act_post">
                                                    <input type="hidden" name="page" value="<%=pagenum%>" />
                                                    <input type="hidden" name="count" value="<%=pagecount%>" />
                                                    <input type="hidden" name="act" id="act" value="add"/>
                                                    <input type="hidden" name="ids" id="ids" value=""/>
                                                    <input type="hidden" id="tmp_title" name="tmp_title" value=""/>
                                                    <input type="hidden" id="tmp_image" name="tmp_image" value=""/>
                                                    <input type="hidden" id="tmp_select" name="tmp_select" value=""/>
                                                    <input type="hidden" id="tmp_visible" name="tmp_visible" value=""/>                                                    
                                                    
                                                    <input type="hidden" id="form_edit_ispublic" name="ispublic" value="1"/>
                                                    
                                                    <input type="hidden" name="id" id="id" value="0"/>
                                                    <input type="hidden" id="imagechanged" name="imageChanged" value="0"/>
						<textarea id="body" name="body"></textarea>
                                                </form>
					</div>
                                        <div style="font-size:14pt;height: 30px;"  align="center">
                                            <input class="dialog_addbutton" type="button" value="保存" onclick="submit_add();"/>                                    
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

