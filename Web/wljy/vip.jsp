<%-- 
    Document   : vip
    Created on : 10-Dec-2013, 10:20:48
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="UTF-8" />
<title></title>
<meta name="keywords" content=""  />
<meta name="description" content="" />
<meta name="author" content="杭州博采网络科技有限公司-博采互动-http://www.bocweb.cn" />
<link rel="shortcut icon" href="favicon.ico" />
<link rel="icon" href="logo.png" type="logo.png" />
<link href="css/css.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
<script type="text/javascript" src="js/jQuery-fileUploadButton.1.0.js"></script>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->

</head>
<%@ include file="connection.jsp" %>
<body>
    
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
            } else {
            sql1 = "select * from memberinfo where deleted = 0 and id =" + UserId;
            rs2 = stmt2.executeQuery(sql1);
            if (rs2.next()) {
                username1 = rs2.getString("name");
            }
            rs2.close();
    }

        
    request.setCharacterEncoding("UTF-8");
    
    Statement stmt = conn.createStatement();

    String sql = "select * from MEMBERINFO where deleted = 0 and ID = '"+UserId+"'";
    ResultSet rs = stmt.executeQuery(sql);
    rs.next();
    
	int nFirstLogin = rs.getInt("FIRSTLOGIN");
    String mem_Name = rs.getString("NAME");
    String mem_OtherName = rs.getString("NICKNAME");
    String mem_Userid = rs.getString("USERID");
    String mem_Password = rs.getString("PASSWORD");
    String mem_Photo = rs.getString("PHOTO");
    int mem_Integral = rs.getInt("INTEGRAL");
	String mem_lastlog = rs.getString("LASTLOGINDATE");
	int nDotPos = mem_lastlog.lastIndexOf(".");
	if (nDotPos > 0)
		mem_lastlog = mem_lastlog.substring(0, nDotPos);
    String mem_Phone = rs.getString("PHONENUM");
    String mem_Photoname = "";
    if (mem_Photo != null) 
	{
		int ind = mem_Photo.lastIndexOf("/");
		if(ind < 0) ind = mem_Photo.lastIndexOf("\\");
		mem_Photoname = mem_Photo.substring(ind + 1, mem_Photo.length());
		if (mem_Photoname.equals("null")) {
			mem_Photoname = "";
		}
	}

	if ((mem_Photo == null) || ( (mem_Photo != null) && mem_Photo.equals("null") ))
	{
		mem_Photo = "img/defimg.png";
	}

    if (mem_Name == null || mem_Name.equals("null")) mem_Name = "";
    if (mem_Phone == null || mem_Phone.equals("null")) mem_Phone = "";
    if (mem_Userid == null || mem_Userid.equals("null")) mem_Userid = "";
	if (mem_Phone == null || mem_Phone.equals("null")) mem_Phone = "";
    
    rs.close();
    stmt.close();
    conn.close();
%>
    <script type="text/javascript">
    $(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html,function() {
                         $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
                });
	})
    })
</script>
<script type="text/javascript">
    $(function() {
	$(".toptit span a").eq(0).addClass("now");
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
            <div class="myinfotop border01">
                <table width="100%">
                    <tr>
                        <td rowspan="3" width="110"><img src="<%=mem_Photo %>" width="75" height="75" alt="" /></td>
                        <td width="290">姓名：<%=mem_OtherName %></td>
                        <td>用户名：<%=mem_Userid %></td>
                    </tr>
                    <tr>
						<td>昵称：<%=mem_Name %></td>
                        <td>联系方式：<%=mem_Phone %> </td>
                    </tr>
                    <tr>						
                        <td>积分：<%=mem_Integral %></td>
                        <td>上次登录时间：<%=mem_lastlog %></td>
                    </tr>
                </table>
            </div>
            <div class="myinfoupdate border01">
            <h5>基本信息修改</h5>
                <form action="vip_edit.jsp" method="post"  enctype="multipart/form-data" name="submit_form1" id="submit_form1">
                    <table width="100%">
                        <tr>
                            <td align="right" width="110">用户名：<span style="color: #FF0000">*</span></td>
                             <td width="250">
                                 <input type="text" name="mem_userid" id="memberuserid" class="update_input" value="<%=mem_Userid %>" onClick="" onBlur="if(this.value==''){this.value='<%=mem_Userid %>'}" <% if (nFirstLogin == 1) { %> disabled="disabled" <% } %> />
                             </td>
                            <td><span>用户名面向非卧龙员工浏览时显示</span></td>
							<input type="hidden" name="member_userid_advanced" id="member_userid_advanced" value="<%=mem_Userid %>" />
                        </tr>
                        <tr>
                            <td align="right" width="110">昵称：<span style="color: #FF0000">*</span></td>
                            <td width="250"><input type="text" name="mem_other" id="membername" class="update_input" value="<%=mem_Name %>" onClick="" onBlur="if(this.value==''){this.value='<%=mem_Name %>'}"/></td>
                            <td><span>昵称面向非卧龙员工浏览时显示</span></td>
                        </tr>
						<tr>
                            <td width="110" align="right">密码：<span style="color: #FF0000">*</span></td>
                            <td width="250"><input type="password" name="mem_newpass" id="mem_newpass" class="update_input" value="" /></td>
                            <td><span>密码不宜太简单</span></td>
                        </tr>
                        <tr>
                            <td width="110" align="right">确认密码：<span style="color: #FF0000">*</span></td>
                            <td colspan="2">
                                <input type="password" name="mem_newpass1" id="mem_newpass1" class="update_input" />
                            </td>
                        </tr>
                        <tr>
                            <td width="110" align="right">联系方式：</td>
                            <td width="250"><input type="text" name="mem_phone" class="update_input" value="<%=mem_Phone %>" onClick="" onBlur="if(this.value==''){this.value='<%=mem_Phone %>'}" onkeyup="this.value=this.value.replace(/[^\d]/,'')"/></td>
                            <td><span>请留下个人联系方式方便发个人活动时参与人与你联系</span></td>
                        </tr>
                        <tr>
                            <td width="110" align="right">头像上传：</td>
                            <td colspan="2">
                                <div class="clear">
                                    <input type='text' class='update_input fle' id='filepath' name='filepath' disabled='disabled' value="<%=mem_Photoname%>"/>
                                    <table><tr>
                                        <td width="40px" align="center"><input type='file' id='mem_img' name='mem_img' onChange='$("#filepath").val($("#mem_img").val());' /></td>
                                        <td><a href='javascript:void(0)' class='update_cancel' onclick='$("#filepath").val("<%=mem_Photoname%>"); $("#mem_img").val("");'>撤销</a></td>
                                    </tr></table>
                                </div>
                            </td>
                        </tr>                        
                        <tr>
                            <td> </td>
                            <td><div class="faqansbtn"><input type="button" value="保存" class="faqansbtn01" onClick="do_submit1()"/></div></td>
                        </tr>
                    </table>
                </form>
            </div>
        </div>
        <div class="bigbot"></div>
    </div>
</div>
<div class="includeDom" include="inc/footer.jsp"></div>
</body>
<script type="text/javascript">
$(function() {
    $('#mem_img').fileUploadButton({
            height: '24px',
            width: '24px',
            image: 'img/load.png'
    });
});
function do_submit1()
{
	if($("#memberuserid").val().toString().length == 0) {
        alert("请输入您的用户名");
        return;
    }
    if($("#membername").val().toString().length == 0) {
        alert("请输入您的昵称");
        return;
    }

	if($("#membername").val() == ' ') {
        alert("请输入您的昵称");
        return;
    }

	var new_pass = $("#mem_newpass").val();
    var new_pass1 = $("#mem_newpass1").val();     
	if($("#mem_newpass").val().toString().length == 0) {
		alert("请输入您的密码");
		return;
    }
	if($("#mem_newpass1").val().toString().length == 0) {
		alert("请输入您的密码");
		return;
    }
    if ( new_pass != new_pass1 )
    {
        alert("您两次输入的密码不一致");
        return;
    }

	var tmppath = $("#filepath").val().toString();
	if (tmppath.length > 0)
	{
		var idx = $("#filepath").val().lastIndexOf('.');     
		var ext = $("#filepath").val().substr(idx + 1, $("#filepath").val().length).toLowerCase();
		if (ext != "jpg" && ext != "png" && ext != "bmp" && ext != "gif") {
			alert("图片格式错误");
			return;
		}
	}

	$("#member_userid_advanced").val($("#memberuserid").val().toString());
    $("#submit_form1").submit();
}

</script>
</html>