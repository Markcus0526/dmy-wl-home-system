<%-- 
    Document   : user
    Created on : Jan 9, 2014, 2:50:55 PM
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
                    $(".nav a").eq(1).addClass("on");
                    //$(".box3rcon li:lt(3)").find("span.num").addClass("on");
                });
            });
			/* FixME
            $("#searchbtn").click(function() {
                window.location.href="user.jsp?search=" + $("#search").val();
            });
			*/
            $("#clearbtn").click(function() {
                window.location.href="user.jsp?";
            });
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
        String search = request.getParameter("search") == null ? "" : request.getParameter("search");
		String search_realname = request.getParameter("search_realname") == null ? "" : request.getParameter("search_realname");
		String search_userid = request.getParameter("search_userid") == null ? "" : request.getParameter("search_userid");
		String search_namepassword = request.getParameter("search_namepassword") == null ? "" : request.getParameter("search_namepassword");

        Statement stmt = conn.createStatement();
        Statement u_stmt = conn.createStatement();
        String sql = "select count(*) as count from memberinfo where deleted = 0";
        String searchcontext = "1=1";
		String searchcontext_realname = "1=1";
		String searchcontext_userid = "1=1";
		String searchcontext_namepassword = "1=1";
        if (search != null && search.length() > 0) {
            searchcontext = "(name like '" + search + "%' or name like '%" + search + "' or name like '%" + search + "%')";
            sql = sql + " and " + searchcontext;
        }

		if (search_realname != null && search_realname.length() > 0) {
            searchcontext_realname = "(nickname like '" + search_realname + "%' or nickname like '%" + search_realname + "' or nickname like '%" + search_realname + "%')";
            sql = sql + " and " + searchcontext_realname;
        }

		if (search_userid != null && search_userid.length() > 0) {
            searchcontext_userid = "(userid like '" + search_userid + "%' or userid like '%" + search_userid + "' or userid like '%" + search_userid + "%')";
            sql = sql + " and " + searchcontext_userid;
        }

		if (search_namepassword != null && search_namepassword.length() > 0) {
            searchcontext_namepassword = "(namepassword like '" + search_namepassword + "%' or namepassword like '%" + search_namepassword + "' or namepassword like '%" + search_namepassword + "%')";
            sql = sql + " and " + searchcontext_namepassword;
        }

        ResultSet rs = stmt.executeQuery(sql);

        int total_count = 0, total_page = 0;

        if (rs.next()) {
            total_count = rs.getInt("count");
            total_page = (total_count - 1) / pagecount + 1;
            if (pagenum == 0) {
                pagenum = 1;
            } else if (pagenum > total_page) {
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

		sql = "select * from (select * from (select * from memberinfo where deleted = 0 and " + searchcontext + " and " + searchcontext_realname + " and " + searchcontext_userid + " and " + searchcontext_namepassword + " order by id) where ID >= (select MAX(ID) from (select * from (select * from memberinfo where deleted = 0 and " + searchcontext + " order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id desc";

        rs = stmt.executeQuery(sql);

        String userid = new String();
        int privilege = 0;
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
        String nickname = new String();

		String privilege_image = new String();

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

			var total_page_count = parseInt(<%=total_count%> / <%=pagecount%>) + 1;
			$("#TotalPages").val(total_page_count);
         
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
            $("#search_row").val(row);
            $("#search_page").val('<%=pagenum%>');

            $("#search_form").submit();
        }

		function select_page()
	    {	
			var selPageno = parseInt($("#selectpageno").val());
			if (isNaN(selPageno))
			{
				$("#selectpageno").val('');
				return;
			}
			var pagetotalcount = parseInt($("#TotalPages").val());
			if (selPageno > pagetotalcount)
			{
				$("#selectpageno").val('');
				return;
			}
			
			$("#search_row").val(<%=pagecount%>);
            $("#search_page").val(selPageno);

            $("#search_form").submit();
		}

        function add()
        {       
            pass = '';
            $("#id").attr("value", "0");
            $("#name").attr("value", '');        
            $("#userid").attr("value", "");
            $("#namepassword").attr("value", "");
            $("#photo").attr("src", "");
            $("#phonenum").attr("value", "");
            $("#email").attr("value", "");
            $("#registip").attr("value", "");
            $("#sel_1").attr("selected", true);
            $("#part").attr("value", "");
            $("#section").attr("value", "");
            $("#act").attr("value", "add");
            $("#nickname").attr("value", "");
        
            $('.actincrease').show();
        }

        function change_check() {
            var obj, obj1;
            obj = $("#privilege");
            obj1 = $("#tmp_privilege");

            if (obj.attr("src") == "img/i-no.gif") {
                obj.attr("src", "img/i-yes.gif");
                obj1.attr("value", 1);
            }            
            else {
                obj.attr("src", "img/i-no.gif");
                obj1.attr("value", 0);
            }

        }

        function reset_password(id)
        {
            $(".div_resetpwd").show();
            $("#newpwd").val("");
            $("#confirmpwd").val("");
            $("#resetid").val(id);
        }

        function edit(id, name, userid, password, photo, phonenum, email, privilege, part, section, nickname, namepassword)
        {
            pass = password;
            $("#id").attr("value", id);
            $("#name").attr("value", name);        
            $("#userid").attr("value", userid);
            $("#phonenum").attr("value", phonenum);
            $("#email").attr("value", email);
            if (privilege == 1) {
                $("#privilege").attr("src", "img/i-yes.gif");    
                $("#tmp_privilege").attr("value", 1);
            } else {
                $("#privilege").attr("src", "img/i-no.gif");
                $("#tmp_privilege").attr("value", 0);
            
            }
            $("#part").attr("value", part);
            $("#section").attr("value", section);
            $("#act").attr("value", "edit");
            $("#namepassword").attr("value", namepassword);
            $("#photo").attr("src", "../" + photo);
            $("#nickname").attr("value", nickname);
                
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
        
            $("#photo").attr("src", "../upload_data/member_info/"+cur_img_path);
        }
    
        function submit_add()
        {
            if ($("#nickname").val().length == 0) {
                alert("请输入您的姓名");
                return;
            }

            if ($("#name").val().length == 0) {
                alert("请输入您的昵称");
                return;
            }

            if ($("#namepassword").val().length == 0) {
                alert("请输入您的工号");
                return;
            }
            /*

            if ($("#userid").val().length == 0) {
               alert("请输入您的帐号");
               return;
            }

            if ($("#password").val().length == 0) {
               alert("请输入您的密码");
               return;
            }
            if (isNaN($("#integral").val())) {
                 alert("请输入正确积分");
               return;
            }
             */      
            var email = $("#email").val();
            if (email.length != 0 && email.search(/^([a-zA-Z0-9])+@([a-zA-Z0-9])+\./g) == -1)
            {
                alert('请输入正确电子邮件');
                return;                
            }        

            /*
            var ip_part = ipaddr.split(/\./);
            if (ip_part.length != 4) {
                alert("请输入正确登录IP");
                return;
            }
            for (var i = 0;i < 4;i++) {
                if (ip_part[i].search(/^([0-9])+$/g) == -1 || isNaN(ip_part[i]) || parseInt(ip_part[i], 10) > 255 || parseInt(ip_part[i], 10) < 1){
                    alert("请输入正确登录IP");
                return;
                }
        }
             */
            $("#tmp_image").attr("value", $("#photo").attr("src"));   
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
       
        $("#xlsfile").attr("value", $("#Excelfilename").    val());  
        $("#tmp_pagenum").attr("value", "<%=pagenum%>");
            $("#tmp_pagecount").attr("value", "<%=pagecount%>");
            $("#act_post").submit();
        }
    
        function delete_user(id, userid)
        {
        
            if (confirm("您要删除选择的会员吗?"))
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
                url: "user_resetpassword.jsp",
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

	function change_privilege(id)    
	{
        var data = $("#privilege_" + id).attr("src");        
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
                type: "member",
                act: "privilege",
                id: id,
                value: data
            },
            success: edit_privilege,
            error: errorfunc1
        });
    }

	function edit_privilege(res)
    {
        if (res.success == 1)
            if (res.privilege == 1)
                $("#privilege_" + res.id).attr("src","img/i-yes.gif");
        else
            $("#privilege_" + res.id).attr("src","img/i-no.gif");
    }

	function errorfunc1(res)
    {
        
    }
        function reset_success()
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
                if (confirm("您确定要把勾选的会员删除吗?"))
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
                    <li><a href="integral.jsp"><span>积分管理</span></a></li>
                    <li><a href="user.jsp" class="on"><span>会员管理</span></a></li>	
                    <li><a href="loginlist.jsp"><span>登录管理</span></a></li>
                </ul>
            </div>
            <div class="clear"></div>
        </div>
        <div class="main">
            <div class="side">
                <div class="side-list">
                    <h2>会员管理</h2>				
                </div>
                <div class="copyright">
                    <p>技术支持: <a href="http://www.bocweb.cn" target="_blank">博采网络</a></p>
                </div>
            </div>
            <div class="content">
                <div class="content-main">
                    <div class="content-box">
                        <div class="content-title">    
                            <table width="100%">
                                <tr>
                                    <td>	
                                        <h2>
                                            <iframe src='about:blank' name='hExcelUpload' id='hExcelUpload' style='display:none;'></iframe>
                                            <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hExcelUpload' id="ExcelUploadForm">
                                                <table> <tr>
                                                        <td>会员管理</td>
                                                        <td><a href="#1" onclick="add();">添加</a><a id="del" href="#1" onclick="select_delete();">删除</a></td>
                                                        <td><a href="importhelp.jsp">批量导入会员 </a></td> 
                                                    </tr>
                                                </table>
                                            </form>  		  

                                        </h2>
                                    </td>

                                    <td>

                                        <div style="align:left" align="left">
                                            <form action="user.jsp" method="post" id="search_form">
												姓名 : <input style="width: 50px;" type="text" name="search_realname" id="search_realname" size="15" value="<%=search_realname%>"/>&nbsp;&nbsp;
                                                昵称 : <input style="width: 50px;" type="text" name="search" id="search" size="15" value="<%=search%>"/>&nbsp;&nbsp;
												用户名 : <input style="width: 50px;" type="text" name="search_userid" id="search_userid" size="15" value="<%=search_userid%>"/>&nbsp;&nbsp;
												工号 : <input style="width: 50px;" type="text" name="search_namepassword" id="search_namepassword" size="15" value="<%=search_namepassword%>"/>&nbsp;&nbsp;
                                                <input type="hidden" name="row" id="search_row" value="10" />
                                                <input type="hidden" name="page" id="search_page" value="1" />
                                                <input type="submit" id="searchbtn" value="查找" style="width:40px" onclick=""/>
                                                <input type="button" id="clearbtn" value="清空" style="width:40px" onclick=""/>
                                            </form>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="page fr">
                                            <div>
												<div id="Pagination" class="pagination" style="float:left;"></div>
												<div style="float: right;">
													到&nbsp;<input type="text" name="selectpageno" id="selectpageno" style="width: 40px; height: 20px; text-align: center;" onkeyup="this.value=this.value.replace(/[^\d]/,'')" />&nbsp;/&nbsp;<input type="text" name="TotalPages" id="TotalPages" style="width: 40px; height: 20px; text-align: center;" disabled/>&nbsp;页&nbsp;
													<input type="button" name="btnSelectPageNo" id="btnSelectPageNo" style="width: 45px;height: 25px;" value="确定" onclick="select_page();"/>
												</div>
											</div>
                                        </div>
                                    </td>
                                </tr>
                            </table>


                            <div class="clear"></div>
                            <p><%=total_count%>个符合 |  每页 <a href="#" onclick="change_row('10');">10个</a> » <a href="#" onclick="change_row('25');">25个</a> » <a href="#" onclick="change_row('50')">50个</a></p>
                        </div>
                        <div class="content-table">
                            <table width="100%">
                                <tr>
                                    <th style="width:3%"><input type="checkbox" class="group-checkable"/></th>
                                    <th>姓名</th>
                                    <th>昵称</th>
                                    <th>用户名</th>
                                    <th>工号</th>
                                    <th>注册日期</th>
                                    <th>上次登录</th>
									<th>权限</th>
                                    <th>操作</th>
                                </tr>
                                <%
                                    String blank = new String();
                                    blank = "blank";
                                    int pos = 0;
                                    String namepassword = new String();
                                    while (rs.next()) {
                                        if (blank.length() == 0) {
                                            blank = "blank";
                                        } else {
                                            blank = "";
                                        }

                                        id = rs.getInt("id");
                                        name = rs.getString("name");
                                        nickname = rs.getString("nickname");
                                        if (name == null || name.length() == 0) {
                                            name = "";
                                        }
                                        userid = rs.getString("userid");
                                        if (userid == null || userid.length() == 0) {
                                            userid = "";
                                        }
                                        password = rs.getString("password");
                                        photo = rs.getString("photo");
                                        //integral = rs.getInt("integral");
                                        integral = 0;
                                        namepassword = rs.getString("namepassword");

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
                                            pos = lastlogin.lastIndexOf(".");
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
                                        privilege = rs.getInt("privilege");
										if (privilege == 0) {
                                            privilege_image = "img/i-no.gif";
                                        } else {
                                            privilege_image = "img/i-yes.gif";
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
                                    <td><%=nickname%></td>
                                    <td><a href="#" onclick="edit(<%=id%>, '<%=name%>','<%=userid%>','<%=password%>','<%=photo%>', '<%=phonenum%>', '<%=email%>', '<%=privilege%>', '<%=part%>', '<%=section%>', '<%=nickname%>','<%=namepassword%>');"><%=name%></a></td>
                                    <td><%=userid%></td>
                                    <td><%=namepassword%></td>
                                    <td><%=registdate%></td>									
                                    <td><%=lastlogin%></td>
									<td><a href="#"><img id="privilege_<%=id%>" onclick="change_privilege('<%=id%>');" src="<%=privilege_image%>" alt="" /></a></td>
                                    <td>
                                        <a href="#" onclick="reset_password(<%=id%>);">设置密码</a> | 
                                        <a href="#" onclick="edit(<%=id%>, '<%=name%>' ,'<%=userid%>','<%=password%>', '<%=photo%>', '<%=phonenum%>', '<%=email%>', '<%=privilege%>', '<%=part%>', '<%=section%>', '<%=nickname%>','<%=namepassword%>');">编辑</a> | 
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
                            <div class="increase-title"><h2> 会员管理</h2><a href="#1" onclick="$('.actincrease').hide()">关闭 [X]</a></div>
                        </div>
                        <div class="increase-top">
                            <div class="imgupload1" align="center">
                                <img id="photo" src="" width="" height="" alt=""  />
                                <iframe src='about:blank' name='hImageUpload' id='hImageUpload' style='display:none;' onload='imagefile_read();'></iframe>
                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload' id="imageUploadForm">
                                    <input type="hidden" name="fileType" value="image"/>
                                    <input type="hidden" id="imagefilename" name="imagefilename" />
                                    <input type="hidden" id="imagefilepath" name="imagefilepath" value="upload_data/member_info/" />															
                                    <input type="file" id="imagefile" name="imagefile" onchange="check_ext();" /><font style="size:12px;">请设置您的头像</font>
                                    <input type='button' id='hImageUploadButton' name='hImageUploadButton' style='display:none;' onclick='imagefile_submit(true);' />
                                </form>                                                      
                            </div>
                            <div class="imgtable">
                                <table width="100%">
                                    <form action="user_add.jsp" method="post" id="act_post">
                                        <tr>
                                            <td>姓名</td>
                                            <td><input name="nickname" id="nickname" type="text" /></td>
                                        </tr>
                                        <tr>
                                            <td>昵称</td>
                                            <td><input name="name" id="name" type="text" /></td>
                                        </tr>
                                        <tr>
                                            <td>工号</td>
                                            <td><input name="namepassword" id="namepassword" type="text" /></td>
                                        </tr>
                                        <tr>
                                            <td>用户名</td>
                                            <td><input name="userid" id="userid" type="text" /></td>									
                                        </tr>
                                        <!--
                                        <tr>
                                                <td>积分</td>
                                                <td><input name="integral" id="integral" type="text" /></td>									
                                        </tr> -->
                                        <tr>
                                            <td>手机号码</td>
                                            <td><input name="phonenum" id="phonenum" type="text" onkeyup="this.value=this.value.replace(/[^\d]/,'')"/></td>									
                                        </tr>
                                        <tr>
                                            <td>电子邮件</td>
                                            <td><input name="email" id="email" type="text" /></td>									
                                        </tr>                                                                                                     
                                        <tr>
                                            <td>权限</td>
                                            <td>
                                                <a href=" #"><img id="privilege" src="img/i-yes.gif" alt=""  onclick="change_check();"/></a>
                                            </td>									
                                        </tr>
                                        <tr>
                                            <tr>
                                                <td>分部</td>
                                                <td><input name="section" id="section" type="text" /></td>									
                                            </tr>
                                            <tr>
                                                <td>部门</td>
                                                <td><input name="part" id="part" type="text" /></td>									
                                            </tr>
                                            <input type="hidden" id="tmp_image" name="tmp_image" value=""/>
                                            <input type="hidden" id="tmp_pagenum" name="tmp_pagenum" value=""/>
                                            <input type="hidden" id="tmp_pagecount" name="tmp_pagecount" value=""/>
                                            <input type="hidden" name="act" id="act" value="add"/>
                                            <input type="hidden" name="id" id="id" value="0"/>
                                            <input type="hidden" name="ids" id="ids" value=""/>
                                            <input type="hidden" id="imagechanged" name="imageChanged" value="0"/>
                                            <input type="hidden" id="tmp_privilege" name="tmp_privilege" value="1"/>
                                            <input type="hidden" id ="xlsfile" name="xlsfile" />
                                    </form>
                                </table>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div style="font-size:14pt;height: 30px;" align="center">                                            
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