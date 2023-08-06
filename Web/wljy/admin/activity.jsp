<%-- 
    Document   : activity
    Created on : Dec 25, 2013, 11:24:17 AM
    Author     : KIMSUI
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
        <%@page import="java.util.Date"%>
    </head>

    <%!    
		public String ConvertDateString(String dateStr) {
            String ret;
            String[] tmp = {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"};

            try {
                ret = dateStr.substring(8, 10) + "-" + tmp[Integer.parseInt(dateStr.substring(5, 7), 10) - 1] + "-" + dateStr.substring(0, 4);
            } catch (Exception e) {
                ret = "";
            }
            return ret;
        }

    %>

    <%
        Cookie[] cookies = request.getCookies();
        String tmp_str = "";
        for (int i = 0; i < cookies.length; i++) {
            String name = cookies[i].getName();
            int pos = name.indexOf('#');
            if (pos != -1) {
                if (name.substring(0, pos).equals("wljyadminid")) {
                    tmp_str = name.substring(pos + 1);
                    break;
                }
            }
        }
        int UserId = Integer.parseInt(tmp_str, 10);
        request.setCharacterEncoding("UTF-8");

        String search_name = request.getParameter("search_name") == null ? "" : request.getParameter("search_name");
        String search_title = request.getParameter("search_title") == null ? "" : request.getParameter("search_title");
        String search_from = request.getParameter("from_datepicker") == null ? "" : request.getParameter("from_datepicker");
        String search_to = request.getParameter("to_datepicker") == null ? "" : request.getParameter("to_datepicker");

        String tmp_from = search_from;
        String tmp_to = search_to;


        String add_condition = "";
        Statement tmp_stmt = conn.createStatement();
        String tmp_sql;
        ResultSet tmp_rs;

        if (!search_name.equals("")) {
            add_condition = "(name like '" + search_name + "%' or name like '%" + search_name + "' or name like '%" + search_name + "%')";
            tmp_sql = "select ID from memberinfo where deleted = 0 and " + add_condition;

            add_condition = "(";

            tmp_rs = tmp_stmt.executeQuery(tmp_sql);
            while (tmp_rs.next()) {
                add_condition += "MID = " + Integer.toString(tmp_rs.getInt("ID"), 10) + " or ";
            }
            tmp_rs.close();
            tmp_stmt.close();

            if (!add_condition.equals("(")) {
                add_condition = add_condition.substring(0, add_condition.length() - 4) + ")";
            } else if (search_name.equals("管理者")) {
                add_condition = "(MID = 0)";
            } else {
                add_condition = "(1=0)";
            }
        }

        if (!search_title.equals("")) {
            if (!add_condition.equals("")) {
                add_condition += " and ";
            }
            add_condition += "(title like '" + search_title + "%' or title like '%" + search_title + "' or title like '%" + search_title + "%')";
        }

        if (!search_from.equals("")) {

            search_from = ConvertDateString(search_from);
        }

        if (!search_to.equals("")) {
            search_to = search_to.substring(0, 4) + search_to.substring(5, 7) + search_to.substring(8, 10);
        }

        if (!search_from.equals("") && search_to.equals("")) {
            if (!add_condition.equals("")) {
                add_condition += " and ";
            }
            add_condition += " (postdate >= '" + search_from + "')";
        } else if (search_from.equals("") && !search_to.equals("")) {
            if (!add_condition.equals("")) {
                add_condition += " and ";
            }
            add_condition += " (postdate <= TO_DATE('" + search_to + "', 'yyyymmdd') + 1)";
        } else if (!search_from.equals("") && !search_to.equals("")) {
            if (!add_condition.equals("")) {
                add_condition += " and ";
            }
            add_condition += " (postdate >= '" + search_from + "' and postdate <= TO_DATE('" + search_to + "', 'yyyymmdd')+1)";
        }

        if (!add_condition.equals("")) {
            add_condition = " and " + add_condition;
        }


        String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");
        int pagenum = Integer.parseInt(spage);
        int pagecount = Integer.parseInt(request.getParameter("row") == null ? "10" : request.getParameter("row"), 10);

        Statement stmt = conn.createStatement();
        Statement u_stmt = conn.createStatement();

        String sql = "select count(*) as count from ACTIVITY_INFO where deleted = 0 and type = 2 " + add_condition;
        ResultSet rs = stmt.executeQuery(sql);

        int total_count = 0, total_page = 0;

        if (rs.next()) {
            total_count = rs.getInt("count");

            total_page = (total_count - 1) / pagecount + 1;
            if (pagenum == 0) {
                pagenum = 1;
            }
            if (pagenum > total_page) {
                pagenum = total_page;
            }
        }

        rs.close();

        int prev_page = 1, next_page = total_page;
        if (pagenum > 1) {
            prev_page = pagenum - 1;
        }
        if (pagenum < total_page) {
            next_page = pagenum + 1;
        }

        ResultSet rs1 = null;

        int last_index = total_count - (pagenum - 1) * pagecount;
        int first_index = last_index - pagecount + 1;
        if (first_index <= 0) {
            first_index = 1;
        }
        int count = pagecount;
        if (first_index == 1) {
            count = last_index;
        }
        if (first_index > total_count) {
            count = last_index;
        }

        sql = "select * from (select * from (select * from activity_info where deleted = 0 and type = 2 " + add_condition + " order by id) where ID >= (select MAX(ID) from (select * from (select * from ACTIVITY_INFO where deleted = 0 and type = 2 " + add_condition + " order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ")  and ROWNUM <= " + count + ") order by id DESC";
        rs = stmt.executeQuery(sql);

        String title = new String();
        int readcount = 0;

        String imagepath = new String();
        int id = 0, mid = 0, eval_count = 0;
        int is_select = 0, is_visible = 0, is_public = 0;
        String public_string = new String();
        String select_image = new String(), visible_image = new String();
        String body = new String();
        int clob_length = 0;
        Clob clob = null;

		Statement querySTMT = conn.createStatement();
		ResultSet queryRS = null;

		int nCount = 0;
    %>
    <script type="text/javascript">
		var file_cnt = 0;
		$(function(){
			$(".activit_upload a").click(function(){
				var tmpStr = "";
				tmpStr = "<div class='marT20 clear' id='file_div_"+file_cnt+"'>";
				tmpStr += "<table><tr>";
				tmpStr += "<td><input type='text' class='update_input fle' id='filepath_"+file_cnt+"' name='filepath_"+file_cnt+"' disabled='disabled' /></td>";
				tmpStr += "<td width='40px' align='center'><input type='file' id='uploadfile_"+file_cnt+"' name='uploadfile_"+file_cnt+"' onChange='$(\"#filepath_"+file_cnt+"\").val($(\"#uploadfile_"+file_cnt+"\").val());' /></td>";
				tmpStr += "<td><a href='javascript:void(0)' class='update_cancel' onclick='file_cancel(\""+file_cnt+"\")'>撤销</a></td>";
				tmpStr += "</tr></table>";
				tmpStr += "</div>";
				$(".activit_upload").before(tmpStr);
				
				$('#uploadfile_'+file_cnt).fileUploadButton({
						height: '24px',
						width: '24px',
						image: '../img/load.png'
				});
				
				file_cnt++;
			});
				
		})

		function file_cancel(index)
		{
			$("#file_div_"+index).remove();
		}

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
    function add()
    {        
        $("#id").attr("value", "0");
        $("#title").attr("value", '');        
        $("#select").attr("src", "img/i-no.gif");
        $("#visible").attr("src", "img/i-yes.gif");
        $("#select_val").attr("value", 0);
        $("#visible_val").attr("value", 1);            
        $("#select_ispublic").val(1);
		for ( i = 0; i<file_cnt; i++)
		{
			$("#file_div_" + i).remove();
		}		
        $("#body").html("");
        $("#body").val("");
        $("#act").attr("value", "add");
        $('.actincrease').show();
    }

    function edit(id, title, isselect, isvisible, body, ispublic)
    {
		for ( i = 0; i<file_cnt; i++)
		{
			$("#file_div_" + i).remove();
		}

		file_cnt = 0;
        $("#id").attr("value", id);
        $("#act").attr("value", "edit");
        $("#title").attr("value", title);
        
        $("#select").attr("src", $("#select_" + id).attr("src"));

        if ($("#select_" + id).attr("src").search("yes") != -1)    
            isselect = 1;
        else isselect = 0;
        $("#select_val").attr("value", isselect);
            
        $("#visible").attr("src", $("#visible_" + id).attr("src"));
        ispublic = ($("#public_" + id).html().search("不公开") == -1)?1:0;
        $("#select_ispublic").val(ispublic);

        if ($("#visible_" + id).attr("src").search("yes") != -1)    
            isvisible = 1;
        else isvisible = 0;
        $("#visible_val").attr("value", isvisible);
        body = body.replace(/&<br>/g, "\r\n");
        $("#body").val(body);
        $(".actincrease").show();
    }

	function ajax_edit(id)
    {
		for ( i = 0; i<file_cnt; i++)
		{
			$("#file_div_" + i).remove();
		}

		$.ajax({
            url: "activityajax.jsp",
            type: "POST",
            dataType: "json",
            data: {
                id: id
            },
            success: successedit,
            error: erroredit
        });
    }

	function successedit(res)
    {
		file_cnt = 0;
        $("#id").attr("value", res.id);
        $("#act").attr("value", "edit");
        $("#title").attr("value", res.title);
        
        $("#select").attr("src", $("#select_" + res.id).attr("src"));

        if ($("#select_" + res.id).attr("src").search("yes") != -1)    
            isselect = 1;
        else isselect = 0;
        $("#select_val").attr("value", res.isselect);
            
        $("#visible").attr("src", $("#visible_" + res.id).attr("src"));
        ispublic = ($("#public_" + res.id).html().search("不公开") == -1)?1:0;
        $("#select_ispublic").val(res.ispublic);

        if ($("#visible_" + res.id).attr("src").search("yes") != -1)    
            isvisible = 1;
        else isvisible = 0;
        $("#visible_val").attr("value", res.isvisible);
		var tempBody;
        tempBody = res.body.replace(/&<br>/g, "\r\n");
        $("#body").val(tempBody);
		
		var arrPath = new Array();
		arrPath = res.path.split("#");

		for ( var i = 0; i < arrPath.length - 1; i++)
		{
			var temp = arrPath[i];

			var tmpStr = "";
			tmpStr = "<div class='marT20 clear' id='file_div_"+file_cnt+"'>";
			tmpStr += "<table><tr>";
			tmpStr += "<td><input type='text' class='update_input fle' id='filepath_"+file_cnt+"' name='filepath_"+file_cnt+"' value='" + temp + "'   readonly/></td>";
			tmpStr += "<td width='40px' align='center'><input type='file' id='uploadfile_"+file_cnt+"' name='uploadfile_"+file_cnt+"' onChange='$(\"#filepath_"+file_cnt+"\").val($(\"#uploadfile_"+file_cnt+"\").val());' /></td>";
			tmpStr += "<td><a href='javascript:void(0)' class='update_cancel' onclick='file_cancel(\""+file_cnt+"\")'>撤销</a></td>";
			tmpStr += "</tr></table>";
			tmpStr += "</div>";
			$(".activit_upload").before(tmpStr);
			
			$('#uploadfile_'+file_cnt).fileUploadButton({
					height: '24px',
					width: '24px',
					image: '../img/load.png'
			});
			
			file_cnt++;
		}
        $(".actincrease").show();
    }

	function erroredit(res)
    {        
    }
    
    var imagefile_submit_clicked = -1;
    var cur_img_path;
    var img_index = 0;
    function imagefile_submit()
    {
        imagefile_submit_clicked = 1;
        var tmpStr = $("#imagefile").val().toString();
        //var ind = tmpStr.lastIndexOf(".");
        //cur_img_path = <%= UserId%> + "_tmp_" + img_index + tmpStr.substring(ind);
        var ind = tmpStr.lastIndexOf("\\") + 1;
        if(ind < 0) ind = tmpStr.lastIndexOf("/") + 1;
        cur_img_path = <%= UserId%> + "_tmp_" + tmpStr.substring(ind);
        
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
    }
    
    function submit_add()
    {
        if ($("#title").val().length == 0) {
            alert("请输入您的标题");
            return;
        }
		
		if (file_cnt < 1)
		{
			alert("请选择上传的图片");
			return;
		}
		
		var i;
		var nRealCount = 0;
		for ( i = 0; i < file_cnt; i++ )
		{
			if ($("#filepath_"+i).val() == undefined)
				continue;
								
			var idx = $("#filepath_"+i).val().lastIndexOf('.');     
			var ext = $("#filepath_"+i).val().substr(idx + 1, $("#filepath_"+i).val().length).toLowerCase();
			if (ext != "jpg" && ext != "png" && ext != "bmp" && ext != "gif") {
				alert("图片格式错误");
				return;
			}

			nRealCount++;
		}

		if (nRealCount == 0)
		{
			alert("请选择上传的图片");
			return;
		}

        $("#tmp_title").attr("value", $("#title").val());        
        $("#tmp_select").attr("value", $("#select_val").val());
        $("#tmp_visible").attr("value", $("#visible_val").val());            
        $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());

        $("#act_post").submit();
    }
    
    function delete_act(id)
    {
        if (confirm("您要删除选择的活动吗?"))
        {
            $("#id").attr("value", id);
			$("#act").attr("value", "delete");
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
  
    function isEmpty(str)
    {
        if ( str == null || str == "" )
            return true;
        else
            return false;
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
        
        return false;
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
        
    function select_change(type) {
        if(type=="ispublic")
            $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());
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
        $(".checkboxes").each(function() {                                                          
            if ($(this).find("input")[0].checked)
                ids = ids + $(this).find("input").attr("value") + ",";
        }) ;
        if (ids != "")
        {
            if (confirm("您确定要把勾选的活动删除吗?"))
            {
                $("#ids").attr("value", ids);
                $("#act").attr("value", "deleteall");
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
                    <li><a href="activity.jsp" class="on"><span>官方活动管理</span></a></li>
                    <li><a href="single.jsp"><span>会员活动管理</span></a></li>
                </ul>
            </div>
            <div class="clear"></div>
        </div>
        <div class="main">
            <div class="side">
                <div class="side-list">
                    <h2>官方活动管理</h2>				
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
                                        <h2>官方活动管理<a href="#1" onclick="add();">添加</a><a id="del"  href="#1" onclick="select_delete();">删除</a></h2>
                                    </td>
                                    <td>
                                        <div style="align:center" align="center">
                                            <form action="activity.jsp" method="post" id="search_form">
                                                账号: <input type="text" id="search_name" name="search_name" size="15" value="<%=search_name%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                                标题: <input type="text" id="search_title" name="search_title" size="15" value="<%=search_title%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                                期间: <input type="text" id="from_datepicker" readonly name="from_datepicker" size="10" value="<%=tmp_from%>" />&nbsp;~&nbsp;<input type="text" readonly id="to_datepicker" name="to_datepicker" size="10" value="<%=tmp_to%>"/>&nbsp;&nbsp;&nbsp;&nbsp;
                                                <input type="hidden" name="row" id="search_row" value="10" />
                                                <input type="hidden" name="page" id="search_page" value="0" />
                                                <input type="button" onclick="return check_search();" id="searchbtn" value="查找" style="width:40px" onclick=""/>
                                                <input type="button" onclick="return clear_search();" id="clearbtn" value="清空" style="width:40px" onclick=""/>
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
                                    <th style="width:15%;">账号</th>
                                    <th style="width:40%;">标题</th>
                                    <th style="width:10%;">是否游客公开</th>
                                    <th style="width:8%;">显隐</th>
                                    <th style="width:8%;">推荐</th>
                                    <th style="width:9%;">操作</th>
                                </tr>
                                <%
                                    String blank = new String();
                                    blank = "blank";
                                    String username = new String();
                                    while (rs.next()) {
                                        if (blank.length() == 0) {
                                            blank = "blank";
                                        } else {
                                            blank = "";
                                        }

                                        title = rs.getString("title");
                                        mid = rs.getInt("mid");
                                        if (mid > 0) {
                                            sql = "select name from memberinfo where deleted = 0 and id = " + mid;
                                            rs1 = u_stmt.executeQuery(sql);
                                            if (rs1.next()) {
                                                username = rs1.getString("name");
                                            } else {
                                                username = "";
                                            }
                                            rs1.close();
                                        } else {
                                            username = "管理者";
                                        }



                                        is_select = rs.getInt("isselected");
                                        if (is_select == 0) {
                                            select_image = "img/i-no.gif";
                                        } else {
                                            select_image = "img/i-yes.gif";
                                        }

                                        is_visible = rs.getInt("isvisible");
                                        if (is_visible == 0) {
                                            visible_image = "img/i-no.gif";
                                        } else {
                                            visible_image = "img/i-yes.gif";
                                        }

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
                                        clob_length = (clob == null) ? -1 : (int) clob.length();

                                        if (clob_length < 0) {
                                            body = "";
                                        } else {
                                            body = clob.getSubString(1, clob_length);
                                        }
                                        body = body.replaceAll("\r\n", "&<br>");
                                        body = body.replaceAll("\n", "&<br>");

                                        is_public = rs.getInt("ISPUBLIC");
                                        if (is_public == 1) {
                                            public_string = "公开";
                                        } else {
                                            public_string = "不公开";
                                        }
                                %>
                                <tr class="<%=blank%>">
                                    <td class="checkboxes" ><input type="checkbox" value="<%=id%>"/></td>

                                    <td><img src="../<%=imagepath%>" width="50" height="50" alt="" /></td>
                                    <td><%=username%></td>
                                    <td style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><%=title%></td>
                                    <td><a href="#" id="public_<%=id%>" onclick="change_public('<%=id%>');"><%=public_string%></a></td>
                                    <td><a href="#"><img id="visible_<%=id%>" onclick="change_visible('<%=id%>');" src="<%=visible_image%>" alt="" /></a></td>
                                    <td><a href="#"><img id="select_<%=id%>" onclick="change_select('<%=id%>');" src="<%=select_image%>" alt="" /></a></td>
                                    <td>
                                        <a href="#" onclick="ajax_edit(<%=id%>)">编辑</a> | <a href="#" onclick="delete_act(<%=id%>);">删除</a>
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
                            <div class="increase-title"><h2>活动管理</h2><a href="#1" onclick="$('.actincrease').hide();">关闭 [X]</a></div>
                        </div>
						<form action="activity_add.jsp" method="post" id="act_post" enctype="multipart/form-data" >
						<input type="hidden" value="0" name="id" id="id">
                        <div class="increase-top">
                            <div class="imgupload" align="center">
								<div class="activit_upload">
									<a href='javascript:void(0)' onclick=''>上传活动配图</a><font color='#FF0000'>&nbsp;&nbsp;(必须)</font>
								</div>
                            </div>
                            <div class="imgtable">
                                <table width="100%">
                                    <tr>
                                        <td>活动名称</td>        
                                        <td><input name="title" id="title" type="text" /></td>
                                    </tr>

                                    <tr>
                                        <td>是否游客公开:</td>
                                        <td>
                                            <select id="select_ispublic" name="select_ispublic">
                                                <option value="0">不公开</option>
                                                <option value="1" selected>公开</option>
                                            </select>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>显隐</td>
                                        <td>
                                            <a href="#"><img id="visible" src="img/i-yes.gif" alt=""  onclick="change_check('visible');"/></a>
                                            <input type="hidden" id="visible_val" name="visible_val" value="1"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>推荐</td>
                                        <td>
                                            <a href="#" ><img id="select" src="img/i-no.gif" alt=""  onclick="change_check('select');"/></a>
                                            <input type="hidden" id="select_val" name="select_val" value="0"/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="acttext">
                            <h2>活动详情</h2>
                                <textarea id="body" name="body"></textarea>
                        </div>
                        <div style="font-size:14pt; height: 30px;"  align="center">
                            <input class="dialog_addbutton" type="button" value="保存" onclick="submit_add();"/>                                    
							<input type="hidden" value="add" name="act" id="act">
							<input type="hidden" value="" name="ids" id="ids">
                        </div>
                    </td>
					</form>
                    <td class="dlg-transl"></td>
                </tr>
                <tr>
                    <td colspan="3" class="dlg-trans">&nbsp;</td>
                </tr>
            </table>

        </div>
    </body>
</html>
