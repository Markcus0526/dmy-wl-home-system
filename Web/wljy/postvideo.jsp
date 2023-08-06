<%-- 
    Document   : postvideo
    Created on : 10-Dec-2013, 10:17:11
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
        <script type="text/javascript" src="js/jQuery-fileUploadButton.1.0.js"></script>
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->
        <%@include file="connection.jsp" %>
        <%
            Cookie[] cookies = request.getCookies();
            String tmp_str = "";
            for (int i = 0; i < cookies.length; i++) {
                String name = cookies[i].getName();
                int pos = name.indexOf('#');

                if (pos != -1) {
                    if (name.substring(0, pos).equals("wljyid")) {
                        tmp_str = name.substring(pos + 1);
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
            String username1 = "";
            String vip = "vip.jsp";
            if (UserId == 0) {
                username1 = "游客";
                vip = "#";
            } else {
                sql1 = "select * from memberinfo where id =" + UserId;
                rs2 = stmt2.executeQuery(sql1);
                if (rs2.next()) {
                    username1 = rs2.getString("name");
                }
                rs2.close();
            }
            
            Integer pid = Integer.parseInt(((request.getParameter("id")== null)?"0":request.getParameter("id")), 10);
            
            String title = "", body = "", path = "", imgpath = "", urlstr = "";
            
            sql1 = "select * from member_data where id =" + pid;
            rs2 = stmt2.executeQuery(sql1);
            if (rs2.next()) {
                title = rs2.getString("TITLE");
                body = rs2.getString("BODY");
                path = rs2.getString("DATAPATH");
                imgpath = rs2.getString("DEFIMAGE");
                urlstr = rs2.getString("OTHERPATH");
                path = path.substring(path.lastIndexOf("/")+1);
                imgpath = imgpath.substring(imgpath.lastIndexOf("/")+1);
            }
            rs2.close();

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
                $(".toptit span a").eq(2).addClass("now");
            })
        </script>
    </head>
    <body>
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
                    <div class="myinfoupdate">
                        <form action="postvideo_add.jsp" method="post"  enctype="multipart/form-data" id="submit_form">
                            <input type="hidden" id="video_id" name="video_id" value="<%=pid%>" />
                            <h5>分享发布</h5>
                            <table width="100%">
                                <tr>
                                    <td width="110" align="right">标题：</td>
                                    <td><input id="video_title" name="video_title" type="text" class="update_input" value="<%=title%>" /></td>
                                </tr>
                                <tr>
                                    <td width="110" align="right">缩略图：</td>
                                    <td>
                                        <div class="clear">
                                            <input type='text' class='update_input fle' id='filepath_image' name='filepath' disabled='disabled' value="<%=imgpath%>" />
                                            <table><tr>
                                                    <td width="40px" align="center"><input type='file' id='video_image' name='video_image' onChange='$("#filepath_image").val($("#video_image").val());' /></td>
                                                    <td><a href='javascript:void(0)' class='update_cancel' onclick='$("#filepath_image").val(""); $("#video_image").val("");'>撤销</a>                                    </td>
                                                </tr></table>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="110" align="right">上传分享：</td>
                                    <td>
                                        <div class="clear">
                                            <input type='text' class='update_input fle' id='filepath_video' name='filepath' disabled='disabled' value="<%=path%>" />
                                            <table><tr>
                                                    <td width="40px" align="center"><input type='file' id='video_data' name='video_data' onChange='$("#filepath_video").val($("#video_data").val());' /></td>
                                                    <td><a href='javascript:void(0)' class='update_cancel' onclick='$("#filepath_video").val(""); $("#video_data").val("");'>撤销</a>                                    </td>
                                                </tr></table>
                                        </div>
                                    </td>
                                </tr>
								<!--
                                <tr>
                                    <td width="110" align="right">外部分享：</td>
                                    <td>
                                        <input id="video_otherpath" name="video_otherpath" type="text" class="update_input" style="width:350px;" value="<% if (urlstr != null) out.print(urlstr); %>"  />
                                    </td>
                                </tr>
								-->
                                <tr>
                                    <td width="110" align="right" valign="top">描述：</td>
                                    <td colspan="2">
                                        <textarea  name="video_body" class="upadate_area"><%=body%></textarea>
                                    </td>
                                </tr>
                            </table>
                            <div class="faqansbtn" style="margin-left:125px;"><input type="button" value="发布分享" class="vipbtn01" onclick="do_submit();" /></div>
                        </form>
                    </div>
                </div>
                <div class="bigbot"></div>
            </div>
        </div>
        <div class="includeDom" include="inc/footer.jsp"></div>
        <script type="text/javascript">
            $(function() {

                $('#video_image').fileUploadButton({
                    height: '24px',
                    width: '24px',
                    image: 'img/load.png'
                })
                $('#video_data').fileUploadButton({
                    height: '24px',
                    width: '24px',
                    image: 'img/load.png'
                })
            })
    
            function do_submit()
            {
                if ($("#video_title").val().length == 0) {
                    alert("请输入您的标题");
                    return;
                }

                if ( $("#filepath_image").val().length == 0) {
                    alert("请输入您的缩略图");
                    return;
                }
                var idx = $("#filepath_image").val().lastIndexOf('.');     
                var ext = $("#filepath_image").val().substr(idx + 1, $("#filepath_image").val().length).toLowerCase();
                if (ext != "jpg" && ext != "png" && ext != "bmp" && ext != "gif") {
                    alert("图片格式错误");
                    return;
                }
            
        
                if ($("#filepath_video").val().length == 0) {
                    alert("请输入您的分享");
                    return;
                }
                idx = $("#filepath_video").val().lastIndexOf('.');     
                var ext = $("#filepath_video").val().substr(idx + 1, $("#filepath_video").val().length).toLowerCase();
                if (ext != "flv" && ext != "mp4" && ext != "avi" && ext != "mpg" && ext != "mpeg" && ext != "rm" && ext != "rmvb" && ext != "f4v") {
                    alert("视频格式错误");
                    return;
                }
        
                $("#submit_form").submit();
            }
        </script>
    </body>
</html>