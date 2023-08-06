<%-- 
    Document   : system
    Created on : Dec 25, 2013, 11:26:33 AM
    Author     : KIMSUI
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
        <!--[if LTE IE 8]>
                <style type="text/css">
                        #filepath {
                                disabled:true;
                        }
                </style>
        <![endif]-->
        <style type="text/css">
            .div_resetpwd
            {
                width: 450px;
                position: absolute;
                left: 50%;
                top: 200px;
                margin-left: -140px;
                display: none;
            }
        </style>

    </head>
    <%@ include file="cookie_check.jsp" %>
    <%@ include file="../connection.jsp" %>
    <script type="text/javascript">
        $(function(){
            $(".includeDom").each(function(){
                var html = $(this).attr("include");
                $(this).load(html, function() {
                    $(".nav a").eq(0).addClass("on");
                    //$(".box3rcon li:lt(3)").find("span.num").addClass("on");
                });
            })
        })
    </script>
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

        String spage = request.getParameter("page") == null ? "0" : request.getParameter("page");
        int pagenum = Integer.parseInt(spage);
        int pagecount = Integer.parseInt(request.getParameter("row") == null ? "10" : request.getParameter("row"), 10);


        Statement stmt = conn.createStatement();
        Statement u_stmt = conn.createStatement();

        String sql = "select count(*) as count from managerinfo where deleted = 0";
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


        sql = "select * from (select * from (select * from managerinfo where deleted = 0 order by id) where ID >= (select MAX(ID) from (select * from (select * from managerinfo where deleted = 0 order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id desc";
        rs = stmt.executeQuery(sql);

        String userid = new String();

        String registdate = new String();
        String registip = new String();
        String lastlogin = new String();
        String name = new String();
        String password = new String();
        String photo = new String();

        String phonenum = new String();
        String email = new String();
        String part = new String();
        String section = new String();

        int id = 0, integral = 0;

    %>
    <script type="text/javascript">
        var flag = false;
        var pass = '';
        function pageselectCallback(page_index, jq){
            if (!flag) {
                flag = true;
            return false;
            }
            else window.location.href="system.jsp?page=" + (page_index + 1) + "&row=" + <%=pagecount%>;
        }
    
        $(document).ready(function() {
            var optInit = {callback: pageselectCallback};
            optInit['items_per_page'] = <%=pagecount%>;
            optInit['num_display_entries'] = 3;
            optInit['current_page'] = <%=pagenum%> - 1;
       
            $("#Pagination").pagination(<%=total_count%>, optInit);
         
            $('#imagefile').fileUploadButton({
                height: '24px',
                width: '24px',
                image: '../img/load.png'
            });
            $('#Excelfile').fileUploadButton({
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
            window.location.href = "system.jsp?row=" + row + "&page=" + <%=pagenum%>;
        }

        function add()
        {       
            pass = '';
            $("#id").attr("value", "0");
            $("#name").attr("value", '');        
            $("#userid").attr("value", "");
            //        $("#password").attr("value", "");
            $("#photo").attr("src", "");
            $("#integral").attr("value", "");
            $("#phonenum").attr("value", "");
            $("#email").attr("value", "");
            $("#registip").attr("value", "");
            $("#sel_1").attr("selected", true);
            $("#part").attr("value", "");
            $("#section").attr("value", "");
            $("#act").attr("value", "add");        
        
            $('.actincrease').show();
        }

        function edit(id, name, userid, password, photo, integral, phonenum, email, part, section)
        {
            pass = password;
            $("#id").attr("value", id);
            $("#name").attr("value", name);        
            $("#userid").attr("value", userid);
            //        $("#password").attr("value", password);
        
            $("#integral").attr("value", integral);
            $("#phonenum").attr("value", phonenum);
            $("#email").attr("value", email);

            $("#part").attr("value", part);
            $("#section").attr("value", section);
            $("#act").attr("value", "edit");
     
            $("#photo").attr("src", "../" + photo);                
                
            $(".actincrease").show();
        }
    
        var imagefile_submit_clicked = -1;
        var cur_img_path;
        var img_index = 0;
        function imagefile_submit(isImage)
        {
            if(isImage) {
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
            } else {
                var tmpStr = $("#Excelfile").val().toString();
                var ind = tmpStr.lastIndexOf("\\") + 1;
                if(ind < 0) ind = tmpStr.lastIndexOf("/") + 1;
                cur_img_path = <%= UserId%> + "_tmp_" + tmpStr.substring(ind);
            
                $("#filepath").val(cur_img_path);
                $("#Excelfilename").attr("value", cur_img_path);
                $("#xlsfile").attr("value", cur_img_path);
                $("#ExcelUploadForm").submit();
            }        
        }

        function imagefile_read()
        {
            if (imagefile_submit_clicked < 0)
                return;

            imagefile_submit_clicked = -1;
        
            $("#photo").attr("src", "../upload_data/manager_info/"+cur_img_path);
        }
    
        function submit_add()
        {
            if ($("#name").val().length == 0) {
                alert("请输入您的名称");
                return;
            }

            if ($("#userid").val().length == 0) {
                alert("请输入您的帐号");
                return;
            }

            if (isNaN($("#integral").val())) {
                alert("请输入正确积分");
                return;
            }
            var email = $("#email").val();
            if (email.search(/^([a-zA-Z0-9])+@([a-zA-Z0-9])+\./g) == -1)
            {
                alert('请输入正确电子邮件');
                return;
                
            }
        
            $("#tmp_image").attr("value", $("#photo").attr("src"));   
        
            var idx = $("#tmp_image").val().lastIndexOf('.');     
            var ext = $("#tmp_image").val().substr(idx + 1, $("#tmp_image").val().length).toLowerCase();
            if (ext != "jpg" && ext != "png" && ext != "bmp" && ext != "gif") {
                alert("图片格式错误");
                return;
            }
        
            $("#tmp_pagenum").attr("value", "<%=pagenum%>");
            $("#tmp_pagecount").attr("value", "<%=pagecount%>");     
            $("#act_post").submit();
        }
    
        function submit_loadxls() {
        
            if($("#xlsfile").val().length == 0) {
                alert("请选择文件");
                return;
            }
            var filename =  $("#Excelfilename").val();
            var idx = filename.lastIndexOf('.');     
            var ext = filename.substr(idx + 1, filename.length).toLowerCase();
            if (ext != "xls") {
                alert("请选择正确文件");
                return;
            }      
       
        $("#xlsfile").attr("value", $("#Excelfilename").val());   
        $("#tmp_pagenum").attr("value", "<%=pagenum%>");
            $("#tmp_pagecount").attr("value", "<%=pagecount%>");
            $("#act_post").submit();
        }
    
        function delete_user(id, userid)
        {
            if (<%=UserId%> == $("#id").val()) {
                alert('没有权限');
                return;
            }
        
            if (confirm("您要删除选择的管理者吗?"))
            {
                $("#id").attr("value", id);
                $("#act").attr("value", "delete");
            $("#integral").attr("value", "0");
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
        function reset_password(id)
        {
            $(".div_resetpwd").show();
            $("#newpwd").val("");
            $("#confirmpwd").val("");
            $("#resetid").val(id);
        }
        function submitreset()
        {
            var newpwd = $("#newpwd").val();
            var confirmpwd = $("#confirmpwd").val();
            var ind = $("#resetid").val();

            if (newpwd.length < 6)
            {
                alert("密码要至少6位!");
                return;
            }

            if (newpwd != confirmpwd)
            {
                alert("设置密码不一致，请再确认一下!");
                return;
            }

            $.ajax({
                url: "admin_resetpassword.jsp",
                type: "POST",
                dataType: "json",
                data: {
                    id: ind,
                    password: newpwd
                },
                success: reset_success,
                error: reset_fail
            });
        }

        function reset_success(ret)
        {
            alert("密码设置成功！");
            $(".div_resetpwd").hide();
            return;
        }

        function reset_fail(xhr)
        {
            alert(xhr.status);
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
                if (confirm("您确定要把勾选的管理者删除吗?"))
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
    <body>
        <div class="header">
            <div class="includeDom" include="top.jsp"></div>	
            <div class="nav-list">
                <ul>
                    <li><a href="javascript:void(0);" class="on"><span>管理者列表</span></a></li>	
                </ul>
            </div>
            <div class="clear"></div>
        </div>
        <div class="main">
            <div class="side">
                <div class="copyright">
                    <p>技术支持: <a href="http://www.bocweb.cn" target="_blank">博采网络</a></p>
                </div>
            </div>
            <div class="content">
                <div class="content-main">
                    <div class="content-box">
                        <div class="content-title">    
                            <h2>
                                <iframe src='about:blank' name='hExcelUpload' id='hExcelUpload' style='display:none;'></iframe>
                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hExcelUpload' id="ExcelUploadForm">
                                    <table> <tr>
                                            <td>管理者管理</td>
                                            <td><a href="#1" onclick="add();">添加</a><a id="del" href="#1" onclick="select_delete();">删除</a></td>
                                            <!--
                                              <td><a href="#1" style="border:none;" onclick="submit_loadxls();" >批量导入会员</a></td>
                                              <td>&nbsp;</td>
                                              <input type="hidden" name="fileType" value="excel"/>
                                              <input type="hidden" id="Excelfilename" name="imagefilename" />
                                              <input type="hidden" id="Excelfilepath" name="imagefilepath" value="upload_data/manager_info/" />
                                              
                                              <td><input type='text' id='filepath' disabled='disabled' /></td>
                                              <td><input type='file' id='Excelfile' name='imagefile'  value="选择文件" onChange='$("#hExcelUploadButton").click();' /></td>
                                              </tr>
                                            -->
                                    </table>

                                    <input type='button' id='hExcelUploadButton' name='hImageUploadButton' style='display:none;' onclick='imagefile_submit(false);' />                                       

                                </form>  
                            </h2>
                            <div class="page fr">
                                <div id="Pagination" class="pagination">
                                </div>
                            </div>
                            <div class="clear"></div>
                            <p><%=total_count%>个符合 |  每页 <a href="#" onclick="change_row('10');">10个</a> » <a href="#" onclick="change_row('25');">25个</a> » <a href="#" onclick="change_row('50')">50个</a></p>
                        </div>
                        <div class="content-table">
                            <table width="100%">
                                <tr>
                                    <th style="width:3%"><input type="checkbox" class="group-checkable"/></th>
                                    <th>姓名</th>
                                    <th>昵称</th>                  
                                    <th>注册日期</th>
                                    <th>登录IP</th>
                                    <th>上次登录</th>
                                    <th>操作</th>
                                </tr>
                                <%
                                    String blank = new String();
                                    blank = "blank";
                                    int pos = 0;
                                    while (rs.next()) {
                                        if (blank.length() == 0) {
                                            blank = "blank";
                                        } else {
                                            blank = "";
                                        }

                                        id = rs.getInt("id");
                                        name = rs.getString("name");
                                        if (name == null || name.length() == 0) {
                                            name = "";
                                        }
                                        userid = rs.getString("userid");
                                        if (userid == null || userid.length() == 0) {
                                            userid = "";
                                        }
                                        password = rs.getString("password");
                                        photo = rs.getString("photo");
                                        integral = rs.getInt("integral");

                                        phonenum = rs.getString("phonenum");
                                        if (phonenum == null || phonenum.length() == 0) {
                                            phonenum = "";
                                        }
                                        email = rs.getString("emailaddress");
                                        if (email == null || email.length() == 0) {
                                            email = "";
                                        }

                                        registdate = rs.getString("registdate");
                                        pos = registdate.indexOf(" ");
                                        if (pos > 0) {
                                            registdate = registdate.substring(0, pos);
                                        }
                                        lastlogin = rs.getString("lastlogindate");
                                        if (lastlogin != null) {
                                            pos = lastlogin.indexOf(".");
                                            if (pos > 0) {
                                                lastlogin = lastlogin.substring(0, pos);
                                            }
                                        } else {
                                            lastlogin = "-尚未登录-";
                                        }

                                        registip = rs.getString("registipaddress");

                                        if (registip == null || registip.length() == 0) {
                                            registip = "";
                                        }

                                        part = rs.getString("part");
                                        if (part == null || part.length() == 0) {
                                            part = "";
                                        }
                                        section = rs.getString("section");
                                        if (section == null || section.length() == 0) {
                                            section = "";
                                        }
                                %>
                                <tr class="<%=blank%>">
                                    <td class="checkboxes" ><input type="checkbox" value="<%=id%>"/></td>
                                    <td><%=name%></td>
                                    <td><a href="#" onclick="edit(<%=id%>, '<%=name%>','<%=userid%>','<%=password%>','<%=photo%>', '<%=integral%>', '<%=phonenum%>', '<%=email%>', '<%=part%>', '<%=section%>');"><%=userid%></a></td>                  
                                    <td><%=registdate%></td>
                                    <td><%=registip%></td>
                                    <td><%=lastlogin%></td>
                                    <td>
                                        <a href="#" onclick="reset_password(<%=id%>);">设置密码</a> | 
                                        <a href="#" onclick="edit(<%=id%>, '<%=name%>' ,'<%=userid%>','<%=password%>', '<%=photo%>', '<%=integral%>', '<%=phonenum%>', '<%=email%>', '<%=part%>', '<%=section%>');">编辑</a> | 
                                        <a href="#" onclick="delete_user(<%=id%>, '<%=userid%>');">删除</a> </td>
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
                    <div class="button">
                        <!--
                      <ul>
                        <li> <a href="#1"><span>全选</span></a> </li>
                        <li> <a href="#1"><span>不选</span></a> </li>
                        <li> <a href="#1"><span>删除</span></a> </li>
                      </ul>
                      <div class="page fr"> <a href="#1">«</a> <a href="#1" class="on">1</a> <a href="#1">2</a> <a href="#1">3</a> <a href="#1">...13</a> <a href="#1">»</a> </div>
                        -->
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
                            <div class="increase-title"><h2>管理者管理</h2><a href="#1" onclick="$('.actincrease').hide()">关闭 [X]</a></div>
                        </div>
                        <div class="increase-top">
                            <div class="imgupload2" align="center">
                                <img id="photo" src="" width="" height="" alt=""  />
                                <iframe src='about:blank' name='hImageUpload' id='hImageUpload' style='display:none;' onload='imagefile_read();'></iframe>
                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload' id="imageUploadForm">
                                    <input type="hidden" name="fileType" value="image"/>
                                    <input type="hidden" id="imagefilename" name="imagefilename" />
                                    <input type="hidden" id="imagefilepath" name="imagefilepath" value="upload_data/manager_info/" />
                                    <input type="file" id="imagefile" name="imagefile"  onchange="check_ext();" /><font style="size:12px;">请设置您的头像</font>
                                    <input type='button' id='hImageUploadButton' name='hImageUploadButton' style='display:none;' onclick='imagefile_submit(true);' />
                                </form>                                                      
                            </div>
                            <div class="imgtable">
                                <table width="100%">
                                    <form action="system_add.jsp" method="post" id="act_post">
                                        <tr>
                                            <td>名称</td>
                                            <td><input name="name" id="name" type="text" /></td>
                                        </tr>
                                        <tr>
                                            <td>昵称</td>
                                            <td><input name="userid" id="userid" type="text" /></td>									
                                        </tr>
                                        </tr>
                                        <tr>
                                            <td>积分</td>
                                            <td><input name="integral" id="integral" type="text" /></td>									
                                        </tr>
                                        <tr>
                                            <td>手机号码</td>
                                            <td><input name="phonenum" id="phonenum" type="text" /></td>									
                                        </tr>
                                        <tr>
                                            <td>电子邮件</td>
                                            <td><input name="email" id="email" type="text" /></td>									
                                        </tr>                                                                																
                                        <tr>
                                            <td>区划</td>
                                            <td><input name="section" id="section" type="text" /></td>									
                                        </tr>
                                        <tr>
                                            <td>部分</td>
                                            <td><input name="part" id="part" type="text" /></td>									
                                        </tr>
                                        <input type="hidden" id="tmp_image" name="tmp_image" value=""/>
                                        <input type="hidden" id="tmp_pagenum" name="tmp_pagenum" value=""/>
                                        <input type="hidden" id="tmp_pagecount" name="tmp_pagecount" value=""/>
                                        <input type="hidden" name="act" id="act" value="add"/>
                                        <input type="hidden" name="id" id="id" value="0"/>
                                        <input type="hidden" name="ids" id="ids" value=""/>
                                        <input type="hidden" id="imagechanged" name="imageChanged" value="0"/>
                                        <input type="hidden" id ="xlsfile" name="xlsfile" />
                                    </form>
                                </table>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <!--<div id ="AddXlsFile" style="margin-left: 10%; height: 30px;">  
                            <table style="padding-left: 5px;"><tr>
                                <td>Members From Excel File:&nbsp;</td>
                                <td>
                                    <form action='common_upload.jsp' method='post' enctype='multipart/form-data' id="ExcelUploadForm">
                                        <input type="hidden" id="Excelfilename" name="imagefilename" />
                                        <input type="hidden" id="Excelfilepath" name="imagefilepath" value="upload_data/member_info/" />
                                        <input type="file" id="Excelfile" name="imagefile" style="width:400px;" onchange="$('#hExcelUploadButton').click();" />
                                        <input type='button' id='hExcelUploadButton' name='hImageUploadButton' style='display:none;' onclick='imagefile_submit(false);' />
                                    </form>  
                                </td>
                            </tr></table>
                        </div>-->
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
        <div class="div_resetpwd">
            <table width="100%">
                <tr>
                    <td colspan="3" class="dlg-trans">&nbsp;</td>
                </tr>
                <tr>
                    <td class="dlg-transl">&nbsp;</td>
                    <td class="drwrap">
                        <div class="increase-main">
                            <div class="increase-title"><h2> 设置密码</h2><a href="#1" onclick="$('.div_resetpwd').hide()">关闭 [X]</a></div>
                        </div>
                        <div class="increase-top">
                            <div class="imgtable">
                                <table width="100%">
                                    <tr>
                                        <td>新密码：</td>
                                        <td><input name="newpwd" id="newpwd" type="password" /></td>
                                    </tr>
                                    <tr>
                                        <td>确认密码：</td>
                                        <td><input name="confirmpwd" id="confirmpwd" type="password" /></td>										
                                    </tr>
                                    <input type="hidden" id="resetid" name="resetid" value=""/>
                                </table>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div style="font-size:14pt;height: 30px;" align="center">                                            
                            <input class="dialog_addbutton" type="button" value="确定" onclick="submitreset();"/> 
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
