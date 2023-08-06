<%-- 
    Document   : share
    Created on : Jan 4, 2014, 1:35:12 PM
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
        <script src="../js/jquery.form.js"></script>
        <script src="../js/ajaxupload.js"></script>
        <style type="text/css">
            .progress { position:relative; width:200px; border: 1px solid #ddd; padding: 1px; border-radius: 3px; margin-top:10px;}
            .bar { background-color: rgb(108, 203, 233); width:0%; height:20px; border-radius: 3px; }
            .percent { position:absolute; display:inline-block; top:3px; left:48%; }
        </style>
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->
        <%@ include file="../connection.jsp" %>
        <%@include file="cookie_check.jsp" %>
        <%!    public String ConvertDateString(String dateStr) {
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


            String spage = request.getParameter("page") == null ? "1" : request.getParameter("page");
            String spagecount = request.getParameter("count") == null ? "10" : request.getParameter("count");

            int pagenum = Integer.parseInt(spage);
            int pagecount = Integer.parseInt(spagecount);

            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();
            Statement u_stmt1 = conn.createStatement();
            Statement u_stmt2 = conn.createStatement();

            String sql = new String();
            if (add_condition.equals("")) {
                sql = "select count(*) as count from SHARE_INFO where deleted = 0";
            } else {
                sql = "select count(*) as count from SHARE_INFO where deleted = 0 and " + add_condition;
            }

            ResultSet rsforCount = u_stmt2.executeQuery(sql);
            int total_count = 0;
            int total_page = 0;
            if (rsforCount.next()) {
                total_count = rsforCount.getInt("count");
                total_page = (total_count - 1) / pagecount + 1;
                if (pagenum > total_page) {
                    pagenum = total_page;
                }
            }
            rsforCount.close();

            int prev_page = 1, next_page = total_page;
            if (pagenum > 1) {
                prev_page = pagenum - 1;
            }
            if (pagenum < total_page) {
                next_page = pagenum + 1;
            }

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
            if (add_condition.equals("")) {
                sql = "select * from (select * from (select * from SHARE_INFO where deleted = 0 order by id)  where ID >= (select MAX(ID) from (select * from (select * from SHARE_INFO where deleted = 0 order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id DESC";
            } else {
                sql = "select * from (select * from (select * from SHARE_INFO where deleted = 0 and " + add_condition + " order by id)  where ID >= (select MAX(ID) from (select * from (select * from SHARE_INFO where deleted = 0 and " + add_condition + "  order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id DESC";
            }

            ResultSet rs = stmt.executeQuery(sql);
            ResultSet rs1, rs2;

            String title = new String();
            int id = 0, mid = 1;
            int type = 1;
            String body = new String();
            Clob clob = null;
            String postdate = new String();
            int readcount, isVisible, is_public = 0;
            String public_string = new String();
            int clob_len, did = 0, imagecount = 0, videocount = 0;
            String datapath = new String(), images = new String(), videos = new String();
        %> 
        <script type="text/javascript">
			var file_cnt = 0;
			$(function(){
				$(".share_upload a").click(function(){
					var tmpStr = "";
					tmpStr = "<div class='marT20 clear' id='file_div_"+file_cnt+"'>";
					tmpStr += "<table><tr>";
					tmpStr += "<td><input type='text' class='update_input fle' id='filepath_"+file_cnt+"' name='filepath_"+file_cnt+"' disabled='disabled' /></td>";
					tmpStr += "<td width='40px' align='center'><input type='file' id='uploadfile_"+file_cnt+"' name='uploadfile_"+file_cnt+"' onChange='$(\"#filepath_"+file_cnt+"\").val($(\"#uploadfile_"+file_cnt+"\").val());' /></td>";
					tmpStr += "<td><a href='javascript:void(0)' class='update_cancel' onclick='file_cancel(\""+file_cnt+"\")'>撤销</a></td>";
					tmpStr += "</tr></table>";
					tmpStr += "</div>";
					$(".share_upload").before(tmpStr);
					
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
            var imagefile_submit_clicked = 0;
    
            function pageselectCallback(page_index, jq) {
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
                if(type == "share_type")
                    $("#form_edit_type").attr("value", $("#increase_page").val()); 

                ////////////////
                else if(type=="ispublic")
                    $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());
                //////////////////    
    
                else
                    $("#info_type").attr("value", $("#info_page").val()); 
            }
            function change_check() {
                var obj, obj1;
                obj = $("#increase_visible_check");
                obj1 = $("#visible_val");

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
                $("#act").attr("value", "add");
                $("#body").html("");    
    
                $("#increase_title").attr("value", "");
                $("#increase_page").attr("value", 1);   
    
                ////////////////////    
                $("#select_ispublic").val(1);  
                ////////////////////
    
                $("#form_edit_visible").attr("value", 1);
                $("#increase_visible_check").attr("src", "img/i-yes.gif");

				for ( i = 0; i<file_cnt; i++)
				{
					$("#file_div_" + i).remove();
				}		
 
                $(".increase").show();
            }
            function delete_data(id) {
                if (confirm("您要删除选择的分享资料吗?")) {
                    $("#act").attr("value", "delete");
                    $("#id").attr("value", id);
                    $("#form_edit").submit();
                }
            }

			function ajax_edit(id, mid)
			{
				for ( i = 0; i<file_cnt; i++)
				{
					$("#file_div_" + i).remove();
				}	

				$.ajax({
					url: "shareajax.jsp",
					type: "POST",
					dataType: "json",
					data: {
						id: id,
						mid: mid
					},
					success: successedit,
					error: erroredit
				});
			}

			function successedit(res)
			{
				file_cnt = 0;
				$("#act").attr("value", "edit");
				$("#id").attr("value", res.id);
				$("#mid").attr("value", res.mid);
				$("#increase_visible_check").attr("src", $("#visible_" + res.id).attr("src"));
				if ($("#visible_" + res.id).attr("src").search("yes") != -1)    
                    isVisible = 1;
                else isVisible = 0;                      
                $("#increase_visible_check").attr("value", isVisible);  
				var tempBody;
				tempBody = res.body.replace(/&<br>/g, "\r\n");
				$("#body").val(tempBody);
				$("#increase_title").attr("value", res.title);
                $("#"+res.type).attr("selected", true); 
				ispublic = ($("#public_" + res.id).html().search("不公开") == -1)?1:0;
                $("#select_ispublic").val(ispublic);
				
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
					$(".share_upload").before(tmpStr);
					
					$('#uploadfile_'+file_cnt).fileUploadButton({
							height: '24px',
							width: '24px',
							image: '../img/load.png'
					});
					
					file_cnt++;
				}
				$(".increase").show();
			}

			function erroredit(res)
			{        
			}

            function submit_data() {
                if($("#increase_title").val().length > 0) {
                    if ($("#selectedvideo").val() == "" && file_cnt == 0) {
                            alert("请选择分享资料");
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

                    $("#form_edit_title").attr("value", $("#increase_title").val());
                    $("#form_edit_type").attr("value", $("#increase_page").val());       
 
                    /////////////////////
                    $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());  
                    /////////////////////       

                    if ($("#selectedvideo").val() != "")
                    {
                        $("form[name=uploadform]").submit();
                    } else {
                        $("#form_edit").submit();
                    }
                } else {
                    alert("请输入标题");
                    $("#increase_title").focus();
                }
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

            var initFormUpload = function () {
                var bar = $('.bar');
                var percent = $('.percent');
                var status = $('#status');
                $('form[name=uploadform]').ajaxForm({
                    beforeSend: function () {
                        status.empty();
                        $(".progress").css("display", "block");
                        var percentVal = '0%';
                        bar.width(percentVal)
                        percent.html(percentVal);
                    },
                    uploadProgress: function (event, position, total, percentComplete) {
                        var percentVal = percentComplete + '%';
                        bar.width(percentVal)
                        percent.html(percentVal);
                    },
                    success: function () {
                        var percentVal = '100%';
                        bar.width(percentVal)
                        percent.html(percentVal);
                    },
                    complete: function (xhr) {
                        status.html(xhr.responseText);
                        //$("form[name=form_agent]").submit();
                        $("#videopath").attr("value", xhr.responseText.trim());
                        $("#form_edit").submit();
                    }
                });
            };

            function showSelectedFile()
            {
                var ext = $('input[name=uploadfile]').val().split('.').pop();
                if (!((ext && /^(FLV)$/.test(ext.toUpperCase())) || 
                    (ext && /^(MP4)$/.test(ext.toUpperCase())) || 
                    (ext && /^(AVI)$/.test(ext.toUpperCase())) ||
                    (ext && /^(MPG)$/.test(ext.toUpperCase())) ||
                    (ext && /^(MPEG)$/.test(ext.toUpperCase())) ||
                    (ext && /^(RM)$/.test(ext.toUpperCase())) ||
                    (ext && /^(RMVB)$/.test(ext.toUpperCase())) ||
                    (ext && /^(F4V)$/.test(ext.toUpperCase()))
            )) {
                    alert("请选择视频文件");
                } else {
                    $('#status').html($("input[name=uploadfile]").val());
                    $('#selectedvideo').attr("value", $('input[name=uploadfile]').val());
                }

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
                        type: "share",
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
                        type: "share",
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
                    if (confirm("您确定要把勾选的分享删除吗?"))
                    {
                        $("#ids").attr("value", ids);
                        $("#act").attr("value", "deleteall");

                        $("#form_edit").submit();
                        
                    }
                }
                
               
            }
        </script>
        <script type="text/javascript">
            $(function(){
                initFormUpload();
                $(".includeDom").each(function(){
                    var html = $(this).attr("include");
                    $(this).load(html, function() {
                        $(".nav a").eq(3).addClass("on");
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
                    <li><a href="javascript:void(0);" class="on"><span>分享管理</span></a></li>
                </ul>
            </div>
            <div class="clear"></div>
        </div>
        <div class="main">
            <div class="side">
                <div class="side-list">
                    <h2>分享管理</h2>
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
                                        <h2>分享管理<a href="javascript:void(0)" onclick="add_data()">添加</a><a id="del" href="#1" onclick="select_delete();">删除</a></h2>
                                    </td>
                                    <td>
                                        <div style="align:center" align="center">
                                            <form action="share.jsp" method="post" id="search_form">
                                                账号: <input type="text" id="search_name" name="search_name" size="15" value="<%=search_name%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                                标题: <input type="text" id="search_title" name="search_title" size="15" value="<%=search_title%>" />&nbsp;&nbsp;&nbsp;&nbsp;
                                                期间: <input type="text" id="from_datepicker" name="from_datepicker" readonly size="10" value="<%=tmp_from%>" />&nbsp;~&nbsp;<input type="text" id="to_datepicker" readonly name="to_datepicker" size="10" value="<%=tmp_to%>"/>&nbsp;&nbsp;&nbsp;&nbsp;
                                                <input type="hidden" name="count" id="search_row" value="10" />
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
                                    <th style="width:10%;">上传资料</th>
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
                                    while (rs.next()) {
                                        if (isBlank) {
                                            blank = "blank";
                                        } else {
                                            blank = "";
                                        }

                                        id = rs.getInt("id");
                                        mid = rs.getInt("mid");
                                        sql = "select name from memberinfo where id = " + mid;
                                        rs1 = u_stmt.executeQuery(sql);
                                        if (rs1.next()) {
                                            username = rs1.getString("name");
                                        } else {
                                            username = "管理者";
                                        }

                                        rs1.close();

                                        title = rs.getString("title");
                                        type = rs.getInt("type");
                                        clob = rs.getClob("body");
                                        clob_len = (clob == null) ? -1 : (int) clob.length();
                                        if (clob_len < 0) {
                                            body = "";
                                        } else {
                                            body = clob.getSubString(1, clob_len).replaceAll("\r\n", "&<br>");
                                            body = body.replaceAll("\n", "&<br>");
                                        }

                                        postdate = rs.getString("postdate");
                                        readcount = rs.getInt("readcount");

                                        isVisible = rs.getInt("isvisible");
                                        if (isVisible > 0) {
                                            visibleCheckImage = "img/i-yes.gif";
                                        } else {
                                            visibleCheckImage = "img/i-no.gif";
                                        }

                                        imagecount = 0;
                                        images = "";
                                        sql = "select * from SHARE_DATA where deleted = 0 and type = 0 and rid = " + id + " order by id";
                                        rs1 = u_stmt1.executeQuery(sql);
                                        while (rs1 != null && rs1.next()) {
                                            did = rs1.getInt("id");
                                            //datapath = rs1.getString("datapath");
                                            images += "&id&" + did + "&path&" + rs1.getString("datapath");
                                            imagecount++;
                                        }
                                        rs1.close();

                                        videocount = 0;
                                        videos = "";
                                        sql = "select * from SHARE_DATA where deleted = 0 and type = 1 and rid = " + id + " order by id";
                                        rs1 = u_stmt2.executeQuery(sql);
                                        while (rs1 != null && rs1.next()) {
                                            did = rs1.getInt("id");
                                            //datapath = rs1.getString("datapath");
                                            videos += "&id&" + did + "&path&" + rs1.getString("datapath");
                                            videocount++;
                                        }
                                        rs1.close();

                                        is_public = rs.getInt("ISPUBLIC");
                                        if (is_public == 1) {
                                            public_string = "公开";
                                        } else {
                                            public_string = "不公开";
                                        }
                                %>
                                <tr class ="<%=blank%>">
                                    <td class="checkboxes" ><input type="checkbox" value="<%=id%>"/></td>
                                    <td><%=(imagecount + videocount)%></td>
                                    <td><%=username%></td>
                                    <td style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><%=title%></td>
                                    <td><a href="#" id="public_<%=id%>" onclick="change_public('<%=id%>');"><%=public_string%></a></td>
                                    <td>
                                        <a href="javascript:void(0);"><img id="visible_<%=id%>" onclick="change_visible('<%=id%>');" src="<%=visibleCheckImage%>" alt="" /></a>

                                    </td>
                                    <td>
                                        <a href="javascript:void(0)" onclick="ajax_edit('<%=id%>', '<%=mid%>')">编辑</a> | 
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
                            <div class="increase-title"><h2>添加分享管理</h2>
                                <a href="javascript:void(0)" onclick="$('.increase').hide()">关闭 [X]</a>
                            </div>
                        </div>
                        <div class="increase-top">
						<form action="share_addinfo.jsp" method="post" id="form_edit" enctype="multipart/form-data" >
							<input type="hidden" value="0" name="id" id="id">
							<input type="hidden" value="0" name="mid" id="mid">
                            <div class="imgtable" style="width: 600px;">
                                <table width="100%">
                                    <tr>
                                        <td>分享标题:</td>
                                        <td><input type="text" id="increase_title" name="increase_title" value=""/></td>
                                    </tr>
                                    <tr>
                                        <td>分享分类:</td>
                                        <td>
                                            <%
                                                sql = "select * from SHARE_TYPE order by id";
                                                rs2 = u_stmt.executeQuery(sql);
                                                int typeid = 0;
                                                String typename = null;
                                                boolean started = true;
                                            %>
                                            <select id="increase_page" name="increase_page"">
                                                <%
                                                    while (rs2.next()) {
                                                        typeid = rs2.getInt("id");
                                                        typename = rs2.getString("name");
                                                        if (started) {
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
                                        <td>是否游客公开:</td>
                                        <td>
                                            <select id="select_ispublic" name="select_ispublic">
                                                <option value="0" >不公开</option>
                                                <option value="1" selected>公开</option>
                                            </select>
                                        </td>
                                    </tr>


                                    <tr>
                                        <td>显隐:</td>
                                        <td>
                                            <a href="  #"><img id="increase_visible_check" name="increase_visible_check" src="" alt=""  onclick="change_check();"/></a>
											<input type="hidden" id="visible_val" name="visible_val" value="1"/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="clear"></div>
							<div class="imgtext">
                            <h2>分享详情</h2>                            
                                <textarea id="form_edit_body" name ="form_edit_body" value=""></textarea>
	                        </div>
							<input type="hidden" value="add" name="act" id="act">
							<input type="hidden" value="" name="videopath" id="videopath">
							<input type="hidden" value="" name="ids" id="ids">
                            <div class="imglist"> 
								<div class="imgupload" align="center">
									<div class="share_upload">
										<a href='javascript:void(0)' onclick=''>上传分享配图</a><font color='#FF0000'>&nbsp;&nbsp;(必须)</font>
									</div>
	                            </div>
								</form>
                                <div class="imglist-right">
                                    <ul>
                                        <h4>上传视频</h4>  
                                        <li>
                                            <table> <tr> 
                                                    <form action='../uploadfile.jsp' method='post' enctype='multipart/form-data'  id="uploadform" name="uploadform">
                                                        <input type="hidden" id="selectedvideo" name="selectedvideo" value="" />
                                                        <td>
                                                            <input type="file" id="uploadfile" name="uploadfile" onchange="showSelectedFile();"  />
                                                            <div class="progress" style="display:none;">
                                                                <div class="bar" style="width: 0%;"></div>
                                                                <div class="percent">100%</div>
                                                            </div>
                                                            <div id="status">
                                                            </div>

                                                        </td>
                                                    </form>
                                                </tr>
                                                <tr>
                                                    <span style="margin:0; padding:2px 0px;">最大文件大小：500 MB</span>
                                                </tr>
                                            </table>
                                        </li>
                                    </ul>
                                </div>
                                <div class="clear"></div>
                            </div>
                        </div>                        
                        <center><input class="dialog_addbutton" type="button" value="保存" onclick="submit_data()" style="font-size:20px; width:100px; height:30px"/></center>						
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
