<%-- 
    Document   : study.jsp
    Created on : Dec 25, 2013, 3:17:19 PM
    Author     : Hercules
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
<meta name="renderer" content="webkit" />
<link href="favicon.ico" rel="shortcut icon" />
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
<%@ include file="../connection.jsp" %>
<%@include file="cookie_check.jsp" %>

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

    
    String spage = request.getParameter("page")== null?"1":request.getParameter("page");
    String spagecount = request.getParameter("count")== null?"10":request.getParameter("count");
    
    int pagenum = Integer.parseInt(spage);
    int pagecount = Integer.parseInt(spagecount);
    
    Statement stmt = conn.createStatement();   
    Statement u_stmt = conn.createStatement();
    Statement u_stmt1 = conn.createStatement();
    Statement u_stmt2 = conn.createStatement();
    
    String sql = new String();
    if ( add_condition.equals(""))
    sql = "select count(*) as count from STUDY_QINFO where deleted = 0";
    else
        sql = "select count(*) as count from STUDY_QINFO where deleted = 0 and " + add_condition;
    
    ResultSet rsforCount = u_stmt2.executeQuery(sql);
    int total_count = 0;
    int total_page = 0;
    if (rsforCount.next()) {
        total_count = rsforCount.getInt("count");
        total_page = (total_count - 1) / pagecount + 1;
         if (pagenum > total_page) pagenum = total_page;
    }
    rsforCount.close();
    
    sql = "select * from integralreason where id= 5";
    ResultSet rs = stmt.executeQuery(sql);
    int  max_integral = 0;
    if (rs.next()) {
        max_integral = rs.getInt("defaultintegral");
    }
    
    //pagenum = total_page - pagenum + 1;
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;
    
    /*int last_index = total_count - (total_page-pagenum) * pagecount+1;
    int first_index = last_index - pagecount;
    int showcount = pagecount;
    if (first_index <= 0)  {
        first_index = 1 ;
        showcount = last_index;
    }
    sql = "select * from (select * from (select * from STUDY_QINFO order by id ASC)  where ID >= (select MAX(ID) from (select * from (select * from STUDY_QINFO order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + showcount + ") order by id DESC";
    */
    
    int last_index = total_count -  (pagenum - 1) * pagecount;
    int first_index = last_index - pagecount + 1;
    if (first_index <= 0) first_index = 1;
    int count = pagecount;  
        if (first_index == 1) count = last_index;
        
    if (first_index > total_count) {
        count = last_index;
    }
    if ( add_condition.equals(""))
    sql = "select * from (select * from (select * from STUDY_QINFO where deleted = 0 order by id ASC)  where ID >= (select MAX(ID) from (select * from (select * from STUDY_QINFO where deleted = 0 order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id DESC"; 
    else
        sql = "select * from (select * from (select * from STUDY_QINFO where deleted = 0 and " + add_condition + "  order by id ASC)  where ID >= (select MAX(ID) from (select * from (select * from STUDY_QINFO where deleted = 0 and " + add_condition + "  order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id DESC"; 
    rs = stmt.executeQuery(sql);
    ResultSet rs1, rs2;
    
    String title = new String();
    int id = 0, mid = 1;
    int type = 1;
    String imagepath = new String();
    String body = new String();
    Clob clob = null;
    String postdate = new String();
    int did, readcount, enabled, isVisible, is_public = 0;
    String public_string = new String();
    String datapath = new String();
    int clob_len;
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
        
        $('#datafile').fileUploadButton({
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
    
function change_page(index, count) {
    $("#search_row").val(count);
    $("#search_page").val(index);

    $("#search_form").submit();
}
function select_change(type) {
    if(type=="data_type")
        $("#form_edit_type").attr("value", $("#increase_page").val());
    else if(type=="ispublic")
        $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());
}
function change_check()
{
    var obj, obj1;
    obj = $("#increase_visible_check");
    obj1 = $("#form_edit_visible");

    if (obj.attr("src") == "img/i-no.gif") {
        obj.attr("src", "img/i-yes.gif");
        obj1.attr("value", 1);
    }            
    else {
        obj.attr("src", "img/i-no.gif");
        obj1.attr("value", 0);
    }
}
function add_data() {    
    $("#form_edit_action").attr("value", "add");
    $("#form_edit_body").html("");    
    $("#form_edit_imagepath").attr("value", "");
    $("#form_edit_imagechanged").attr("value", "1"); 
    $("#form_edit_datapath").attr("value", ""); 
    $("#form_edit_datachanged").attr("value", "1");  
    
    $("#select_ispublic").val(1);   
    
    $("#increase_title").attr("value", "");
    $("#increase_page").attr("value", 1);    
    $("#increase_integral").attr("value", "");
    $("#main_image").attr("src", "");
    $("#imagefile").attr("value", "");
    $("#datafile").attr("value", "");
    $("#datapath_input").attr("value", "");
    
    $("#form_edit_visible").attr("value", 1);
    $("#increase_visible_check").attr("src", "img/i-yes.gif");
    
    $(".increase").show();
}
function delete_data(id) {
    if (confirm("您要删除选择的学习资料吗?")) {
        $("#form_edit_action").attr("value", "delete");
        $("#form_edit_id").attr("value", id);
        $("#form_edit").submit();
    }
}
function modify_data(id, mid, title, type, imagepath, body, postdate, datapath, readcount, enabled, isVisible, integral, ispublic) {
    $("#form_edit_action").attr("value", "edit");
    $("#form_edit_id").attr("value", id);
    $("#form_edit_mid").attr("value", mid);
    $("#form_edit_readcount").attr("value", readcount);
    $("#form_edit_enabled").attr("value", enabled);    
    $("#form_edit_integral").attr("value", integral);

     $("#increase_visible_check").attr("src", $("#visible_" + id).attr("src"));

            if ($("#visible_" + id).attr("src").search("yes") != -1)    
                isVisible = 1;
            else isVisible = 0;
    $("#form_edit_visible").attr("value", isVisible);
       ispublic = ($("#public_" + id).html().search("不公开") == -1)?1:0;
    $("#select_ispublic").val(ispublic);
    
    $("#increase_integral").attr("value", integral);
    if(isVisible > 0) $("#increase_visible_check").attr("src", "img/i-yes.gif");
    else $("#increase_visible_check").attr("src", "img/i-no.gif");
    
    body = body.replace(/&<br>/g, "\r\n");
    $("#form_edit_body").val(body);  
    
    $("#form_edit_imagepath").attr("value", imagepath);  
    $("#form_edit_imagechanged").attr("value", "0");     
    $("#form_edit_datapath").attr("value", datapath); 
    $("#form_edit_datachanged").attr("value", "0"); 
    
     var ind = datapath.toString().lastIndexOf("_");
     $("#datapath_input").attr("value", datapath.toString().substring(ind+1, datapath.toString().length));             
    
    $("#increase_title").attr("value", title);
    $("#"+type).attr("selected", true);    
    $("#main_image").attr("src", "../" + imagepath);   
    //$("#imagefile").attr("value", imagepath);
    //$("#datafile").attr("value", datapath);
    
    $(".increase").show();
}
function submit_data() {
    if($("#increase_title").val().length > 0) {
          if($("#increase_integral").val().length > 0 && !isNaN($("#increase_integral").val()) && $("#increase_integral").val() <= parseInt('<%=max_integral%>' ,10)) {
        $("#form_edit_title").attr("value", $("#increase_title").val());
        $("#form_edit_type").attr("value", $("#increase_page").val());
        $("#form_edit_integral").attr("value", $("#increase_integral").val());
        
        $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());  
        
        $("#form_edit").submit();
          }
          else {
            alert("请输入正确积分");
          }
    } else {
        alert("请输入您的标题");
    }
}

var imagefile_submit_clicked = -1, datafile_submit_clicked = -1;
var cur_img_path, cur_data_path;
var img_index = 0, data_index = 0;
function imagefile_submit(isImage)
{
    if(isImage == true) {
        imagefile_submit_clicked = 1;
        
        var tmpStr = $("#imagefile").val().toString();
        //var ind = tmpStr.lastIndexOf(".");
        //cur_img_path = <%=UserId%> + "_tmp_" + img_index + tmpStr.substring(ind);
        var ind = tmpStr.lastIndexOf("\\") + 1;
        if(ind < 0) ind = tmpStr.lastIndexOf("/") + 1;
        cur_img_path = <%=UserId%> + "_tmp_" + tmpStr.substring(ind);

        $("#imagefilename").attr("value", cur_img_path);
        //img_index++;

        $("#imageUploadForm").submit();

        $("#form_edit_imagechanged").attr("value", "1");
        $("#form_edit_imagepath").attr("value", cur_img_path);  
    } else {
        datafile_submit_clicked = 1;
        
        var tmpStr = $("#datafile").val().toString();
        //var ind = tmpStr.lastIndexOf(".");
        //cur_data_path = "1_tmp_" + data_index + tmpStr.substring(ind);
        var ind = tmpStr.lastIndexOf("\\") + 1;
        if(ind < 0) ind = tmpStr.lastIndexOf("/") + 1;
        cur_data_path = <%=UserId%> + "_tmp_" + tmpStr.substring(ind);

        $("#datafilename").attr("value", cur_data_path);
        //data_index++;

        $("#dataUploadForm").submit();

        $("#form_edit_datachanged").attr("value", "1");
        $("#form_edit_datapath").attr("value", cur_data_path);  
    }
}

function imagefile_read(isImage)
{
    if(isImage == true) {
        if (imagefile_submit_clicked < 0)
            return;
        imagefile_submit_clicked = -1;
        $("#main_image").attr("src", "../upload_data/study/" + cur_img_path); 
    } else {
        if (datafile_submit_clicked < 0)
            return;
        datafile_submit_clicked = -1;
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
                        type: "study",
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
                        type: "study",
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
                    if (confirm("您确定要把勾选的学习删除吗?"))
                    {
                          $("#ids").attr("value", ids);
            $("#form_edit_action").attr("value", "deleteall");
            
                $("#form_edit").submit();
                        
                    }
                }
                
               
        }

</script>
        <script type="text/javascript">
    $(function(){
	$(".includeDom").each(function(){
            var html = $(this).attr("include");
            $(this).load(html, function() {
                $(".nav a").eq(5).addClass("on");
                //$(".box3rcon li:lt(3)").find("span.num").addClass("on");
            });
	})
    })
</script>
</head>
<body>
    <div class="header">
      <div class="includeDom" include="top.jsp"></div>
        <div class="nav-list">
            <ul>
                <li><a href="javascript:void(0);" class="on"><span>学习管理</span></a></li>
            </ul>
        </div>
        <div class="clear"></div>
    </div>
    <div class="main">
	<div class="side">
            <div class="side-list">
		<h2>学习管理</h2>                
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
			<h2>学习管理<a href="javascript:void(0)" onclick="add_data()">添加</a><a id="del" href="#1" onclick="select_delete();">删除</a></h2>
                                </td>
                                <td>
                                    <div style="align:center" align="center">
                                        <form action="study.jsp" method="post" id="search_form">
                                        账号: <input type="text" id="search_name" name="search_name" size="15" value="<%=search_name%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                        标题: <input type="text" id="search_title" name="search_title" size="15" value="<%=search_title%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                        期间: <input type="text" id="from_datepicker" readonly name="from_datepicker" size="10" value="<%=tmp_from%>" />&nbsp;~&nbsp;<input type="text" readonly id="to_datepicker" name="to_datepicker" size="10" value="<%=tmp_to%>"/>&nbsp;&nbsp;&nbsp;&nbsp;
                                        <input type="hidden" name="count" id="search_row" value="<%=pagecount%>" />                                       
                                        <input type="hidden" name="page" id="search_page" value="1" />
                                        <input type="button" onclick="check_search();" id="searchbtn" value="查找" style="width:40px" onclick=""/>
                                        <input type="button" onclick="clear_search();" id="clearbtn" value="清空" style="width:40px" onclick=""/>
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
			<p><%=total_count%>个符合 |  每页 
                            <a href="#" onclick="change_page(<%=pagenum%>, 10);">10个</a> » 
                            <a href="javascript:void(0)" onclick="change_page(<%=pagenum%>, 25)">25个</a> » 
                            <a href="javascript:void(0)" onclick="change_page(<%=pagenum%>, 50)">50个</a>
                        </p>
                    </div>
                    <div class="content-table">
			<table width="100%" style="table-layout:fixed">
                            <tr>
                                 <th style="width:3%"><input type="checkbox" class="group-checkable"/></th>

                                <th style="width:10%;">图片</th>
                                <th style="width:25%;">账户</th>
                                <th style="width:40%;">标题</th>
				<th style="width:8%;">是否游客公开</th>
                                <th style="width:8%;">显隐</th>
                                <th style="width:9%;">操作</th>
                            </tr>
                            <%
                            boolean isBlank = false;
                            String blank = null;
                            String visibleCheckImage;
                                String username = new String();
                                int integral = 0;
                            while (rs.next()) {
                                if(isBlank) blank = "blank";
                                else blank ="";
                                    
                                id = rs.getInt("id");
                                mid = rs.getInt("mid");                                
                                integral = rs.getInt("integral");
                                sql = "select name from memberinfo where deleted = 0 and id = " + mid;
                                                                rs1 = u_stmt.executeQuery(sql);
                                                                if (rs1.next())
                                                                    username = rs1.getString("name");
                                                                else 
                                                                    username = "管理者";
                                                                
                                                                rs1.close();
                                                              
                                title = rs.getString("title");
                                type = rs.getInt("type");
                                imagepath = rs.getString("imagepath");
                                clob = rs.getClob("body");
                                clob_len = (clob==null)?-1:(int)clob.length();
                                if (clob_len < 0)
                                    body = "";
                                else
                                    body = clob.getSubString(1, clob_len).replaceAll("\r\n", "&<br>");
                                 body = body.replaceAll("\n", "&<br>");
                                postdate = rs.getString("postdate");
                                datapath = rs.getString("datapath");
                                /*did = rs.getInt("did");
                                sql = "select * from DATA_INFO where id = " + did;
                                rs1 = u_stmt.executeQuery(sql);
                                if(rs1.next()) {
                                    datapath = rs1.getString("datapath");
                                } else
                                    datapath = "";
                                rs1.close();*/
                                
                                readcount = rs.getInt("readcount");
                                enabled = rs.getInt("enabled");
                                
                                isVisible = rs.getInt("isvisible");
                                if(isVisible > 0) visibleCheckImage = "img/i-yes.gif";
                                else visibleCheckImage = "img/i-no.gif";
                                
                                is_public = rs.getInt("ISPUBLIC");
                                 if(is_public == 1)
                                     public_string = "公开";
                                 else
                                     public_string = "不公开";
                            %>
                            <tr class ="<%=blank%>">
                                <td class="checkboxes" ><input type="checkbox" value="<%=id%>"/></td>
                                <td><img src="<%="../" + imagepath%>" width="50" height="50" alt="" /></td>
                                <td><%=username%></td>
                                <td style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><%=title%></td>
				<td><a href="#" id="public_<%=id%>" onclick="change_public('<%=id%>');"><%=public_string%></a></td>
                                <td>
                                    <a href="javascript:void(0);"><img id="visible_<%=id%>" onclick="change_visible('<%=id%>');" src="<%=visibleCheckImage%>" alt="" /></a>
                                </td>
                                <td>
                                    <a href="javascript:void(0)" onclick="modify_data('<%=id%>', '<%=mid%>', '<%=title%>', '<%=type%>', '<%=imagepath%>', '<%=body%>', '<%=postdate%>', '<%=datapath%>', '<%=readcount%>', '<%=enabled%>', '<%=isVisible%>', '<%=integral%>', '<%=is_public%>')">编辑</a> | 
                                    <a href="javascript:void(0)" onclick="delete_data('<%=id%>')">删除</a>
                                </td>
                            </tr>
                            <%
                                isBlank = !isBlank;
                            } 
                            %>	
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="increase">
            <table width="100%">
                <tr>
                    <td colspan="3" class="dlg-trans">&nbsp;</td>
                </tr>
                <tr>
                    <td class="dlg-transl">&nbsp;</td>
                    <td class="drwrap">
                        <div class="increase-main">
                            <div class="increase-title"><h2>添加学习管理</h2>
                                <a href="javascript:void(0)" onclick="$('.increase').hide()">关闭 [X]</a>
                            </div>
                        </div>
                        <div class="increase-top">
                            <div class="imgupload" align="center">
                                <img id="main_image" src="" width="" height="" alt="" />
                                <iframe src='about:blank' name='hImageUpload' id='hImageUpload' style='display:none;' onload='imagefile_read(true);'></iframe>
                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload' id="imageUploadForm">
                                    <input type="hidden" id="imagefilename" name="imagefilename" />
                                    <input type="hidden" id="imagefilepath" name="imagefilepath" value="upload_data/study/" />
                                    <input type="file" id="imagefile" name="imagefile" onchange="check_ext();" />
                                    <input type='button' id='hImageUploadButton' name='hImageUploadButton' style='display:none;' onclick='imagefile_submit(true);' />
                                </form>   
                            </div>
                            <div class="imgtable">
                                <table width="100%">
                                    <tr>
                                        <td>学习标题:</td>
                                        <td><input type="text" id="increase_title" value=""/></td>
                                    </tr>
                                    <tr>
                                        <td>学习分类:</td>
                                        <td>
                                            <%
                                            sql = "select * from STUDY_TYPE order by id";
                                            rs2 = u_stmt.executeQuery(sql);
                                            int typeid = 0;
                                            String typename = null;
                                            boolean started = true;
                                            %>
                                            <select id="increase_page" onchange="select_change('data_type');">
                                                <%
                                                while(rs2.next()) {  
                                                    typeid = rs2.getInt("id");
                                                    typename = rs2.getString("name");
                                                    if(started) {
                                                %>
                                                        <option id="<%=typeid%>" value="<%=typeid%>" selected><%=typename%></option>
                                                <%
                                                        started = false;
                                                    } else {
                                                %>
                                                    <option id="<%=typeid%>" value="<%=typeid%>"><%=typename%></option>                                                <%
                                                    }
                                                }
                                                %>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>悬赏积分 :</td>
                                        <td><input type="text" id="increase_integral" value="0" style="width: 80px;" />&nbsp; 最大值为&nbsp;<%=max_integral%></td>
                                    </tr>
                                    <tr>
                                        <td>增加资料:</td>
                                        <td>
                                            <table><tr><td>
                                            <input type='text' id='datapath_input' style="width: 180px;" disabled='disabled' />
                                                    </td>
                                                    <td>
                                            <iframe src='about:blank' name='dataUpload' id='dataUpload' style='display:none;' onload='imagefile_read(false);'></iframe>
                                            <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='dataUpload' id="dataUploadForm">
                                                <input type="hidden" id="datafilename" name="imagefilename" />
                                                <input type="hidden" id="datafilepath" name="imagefilepath" value="upload_data/study/" />
                                                <input type="file" id="datafile" name="imagefile" onchange="$('#datapath_input').val($('#datafile').val()); $('#dataUploadButton').click();" />
                                                <input type='button' id='dataUploadButton' name='hImageUploadButton' style='display:none;' onclick='imagefile_submit(false);' />
                                            </form> 
                                        </td>
                                                </tr></table>
                                        </td>
                                    </tr>
                                    
                                    <tr>
                                        <td>是否游客公开:</td>
                                        <td>
                                            <select id="select_ispublic" onchange="select_change('ispublic');">
                                                <option value="0" >不公开</option>
                                                <option value="1" selected>公开</option>
                                            </select>
                                        </td>
                                    </tr>
                                    
                                    <tr>
                                        <td>显隐:</td>
                                        <td>
                                            <a href="  #"><img id="increase_visible_check" src="" alt=""  onclick="change_check();"/></a>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="imgtext">
                            <h2>学习详情</h2>
                            <form action="study_addinfo.jsp" method="post" id="form_edit">
                                <textarea id="form_edit_body" name ="body" value=""></textarea>
                                <input type="hidden" name="page" value="<%=pagenum%>" />
                                <input type="hidden" name="count" value="<%=pagecount%>" />
                                <input type="hidden" id="form_edit_action" name="action" value="add" />
                                <input type="hidden" id="form_edit_id" name="id" value="" />
                                <input type="hidden" id="form_edit_mid" name="mid" value="" />
                                <input type="hidden" id="form_edit_readcount" name="readcount" value="" />
                                <input type="hidden" id="form_edit_enabled" name="enabled" value="" />
                                <input type="hidden" id="form_edit_body" name ="body" value="" />
                                <input type="hidden" id="form_edit_visible" name="isVisible" value="1"/>                                
                                <input type="hidden" name="ids" id="ids" value=""/>
                                <input type="hidden" id="form_edit_ispublic" name="ispublic" value="1"/>
                                
                                <input type="hidden" id="form_edit_integral" name="integral" value="0"/>
                                <input type="hidden" id="form_edit_datapath" name="datapath" value=""/>
                                <input type="hidden" id="form_edit_datachanged" name="dataChanged" value="0"/>
                                <input type="hidden" id="form_edit_type" name="type" value="0"/>
                                <input type="hidden" id="form_edit_title" name ="title" value=""/>
                                <input type="hidden" id="form_edit_imagepath" name="imagepath" value=""/>
                                <input type="hidden" id="form_edit_imagechanged" name="imageChanged" value="0"/>
                            </form>
                        </div>
                        <center><input class="dialog_addbutton" type="button" value="保存" onclick="submit_data()"/></center>
                    </td>
                    <td class="dlg-transl">&nbsp;</td>
                </tr>
                <tr>
                    <td colspan="3" class="dlg-trans">&nbsp;</td>                    
                </tr>
            </table>
    </div>    
</body>
<%
    rs.close();
    stmt.close();
    u_stmt.close();
    u_stmt1.close();
    u_stmt2.close();
    conn.close();
%>
</html>
