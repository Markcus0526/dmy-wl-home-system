<%-- 
    Document   : postevent
    Created on : 10-Dec-2013, 10:15:14
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
<link rel="stylesheet" href="css/themes/base/jquery.ui.all.css" />
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
<script type="text/javascript" src="js/jquery.ui.core.js"></script>
<script type="text/javascript" src="js/jquery.ui.datepicker.js"></script>
<script type="text/javascript" src="js/jquery.ui.widget.js"></script>
<script type="text/javascript" src="js/jQuery-fileUploadButton.1.0.js"></script>
<%@include file="connection.jsp" %>
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

%>
<%@ page language="Java" import="java.sql.*" %>
<!--[if IE 6]>
	<script src="js/IE6PNG.js"></script>
	<script type="text/javascript">
		IE6PNG.fix('.png');
	</script>
<![endif]-->

<script type="text/javascript">
$(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html,function() {
			$(".menu li a").eq(1).css("color","#b20101");;
			$(".toptit span a").eq(1).addClass("now");
                           $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");

		});
	});
});
</script>
</head>
<body>

<div class="w964">
    <div class="includeDom" include="inc/top.jsp"></div>
    <div class="toptit playtit">
        <b>活动</b>
        <span><a href="play.jsp">卧龙活动展示</a><a href="single.jsp">个人活动组织</a></span>
    </div>
    <div class="site clear">
        <form action="play_mine_add.jsp" method="post"  enctype="multipart/form-data" name="submit_form" id="submit_form">
            <div class="content fle">
                <div class="conttop playconttop"></div>
                <div class="main postevent">
                    <div class="single_tit">
                        <b>发起活动</b>
                    </div>
                    <div class="postevent_det">
                        <p>活动主题</p>
                        <input type="text" name="play_title" class="postevent_input" id="title" onClick="if (this.value =='活动主题') this.value=''" onBlur="if(this.value==''){this.value='活动主题'}" value="活动主题" />
                        <p>活动介绍</p>
                        <textarea name="play_body" class="postevent_textarea" value=""></textarea>
                        <div class="postevent_upload">
                            <a href="javascript:void(0)">上传活动配图</a> (非必须)
                        </div>
                        <div class="postevent_btn marT20">
                            <a onClick="do_submit();">发起活动</a>
                            <a href="single.jsp" class="postevent_btn01">取 消</a>
                        </div>
                    </div>
                </div>
                <div class="contbot"></div>
            </div>
        <div class="includeDom" include="inc/playright.jsp"></div>
        </form>
    </div>
</div>
<div class="includeDom" include="inc/footer.jsp"></div>
<script type="text/javascript">
    
    var file_cnt = 0;
    $(function(){
	$(".postevent_upload a").click(function(){
            var tmpStr = "";
            tmpStr = "<div class='marT20 clear' id='file_div_"+file_cnt+"'>";
            tmpStr += "<table><tr>";
            tmpStr += "<td><input type='text' class='update_input fle' id='filepath_"+file_cnt+"' name='filepath_"+file_cnt+"' disabled='disabled' /></td>";
            tmpStr += "<td width='40px' align='center'><input type='file' id='uploadfile_"+file_cnt+"' name='uploadfile_"+file_cnt+"' onChange='$(\"#filepath_"+file_cnt+"\").val($(\"#uploadfile_"+file_cnt+"\").val());' /></td>";
            tmpStr += "<td><a href='javascript:void(0)' class='update_cancel' onclick='file_cancel(\""+file_cnt+"\")'>撤销</a></td>";
            tmpStr += "</tr></table>";
            tmpStr += "</div>";
            $(".postevent_upload").before(tmpStr);
            
            $('#uploadfile_'+file_cnt).fileUploadButton({
                    height: '24px',
                    width: '24px',
                    image: 'img/load.png'
            });
            
            file_cnt++;
	});
        
    })

    function file_cancel(index)
    {
        $("#file_div_"+index).remove();
    }
    

    function do_submit()
    {
        
        if ($("#title").val().length == 0 || $("#title").val() == "活动主题")
            {
                alert("请输入您的主题");
                return;
            }

        var i;
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
            }
        $("#submit_form").submit();
    }
</script>
</body>
</html>