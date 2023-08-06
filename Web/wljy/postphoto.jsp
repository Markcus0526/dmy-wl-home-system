<%-- 
    Document   : postphoto
    Created on : 10-Dec-2013, 10:16:18
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
    <%@include file="connection.jsp" %>
    <body>
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
            
            String title = "", body = "", path = "";
            
            sql1 = "select * from member_data where deleted = 0 and id =" + pid;
            rs2 = stmt2.executeQuery(sql1);
            if (rs2.next()) {
                title = rs2.getString("TITLE");
                body = rs2.getString("BODY");                
            }
            rs2.close();

			String query = "select * from member_image where deleted = 0 and rid = " + pid;
			ResultSet queryRS = stmt2.executeQuery(query);

			int nCount = 0;

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
                $(".toptit span a").eq(1).addClass("now");
            })
        </script>
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
                if($("#photoname").val().toString().length == 0) {
                    alert("请输入您的标题");
                    return;
                }

				if (file_cnt < 1)
				{
					alert("请选择上传的图片");
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
                    <div class="myinfoupdate postphoto">
                        <form action="postphoto_add.jsp" method="post"  enctype="multipart/form-data" id="submit_form">
                            <h5>照片发布</h5>
                            <div class="postevent_det">
								<input type="hidden" name="photo_id" id="photo_id" value="<%= pid%>"/>
								<p>标题：</p>
									<input type="text" name="photo_title" class="update_input" id="photoname" value="<%if (pid != 0) {%><%= title%><%}%>"/>
								<p>照片：</p>
									<%
										while (queryRS.next())
										{
											path = queryRS.getString("DATAPATH");
							                path = path.substring(path.lastIndexOf("/")+1);;
									%>
											<div class="marT20 clear" id="file_div_<%=nCount%>">
											<table>
											<tbody>
											<tr>
												<td>
													<input type="text" class="update_input fle" id="filepath_<%=nCount%>" name="filepath_<%=nCount%>" value="<%=path%>">
												</td>
												<td width="40px" align="center">
													<div style="cursor: pointer; position: relative; overflow: hidden; height: 24px; width: 24px; background-image: url(img/load.png);">
														<input type="file" id="uploadfile_<%=nCount%>" name="uploadfile_<%=nCount%>" onchange="$(&quot;#filepath_<%=nCount%>&quot;).val($(&quot;#uploadfile_<%=nCount%>&quot;).val());" style="height: 100%; cursor: pointer; position: absolute; top: 0px; right: 0px; z-index: 99; opacity: 0; font-size: 24px;">
													</div>
												</td>
												<td>
													<a href="javascript:void(0)" class="update_cancel" onclick="file_cancel(&quot;<%=nCount%>&quot;)">撤销</a>
												</td>
											</tr>
											</tbody>
											</table>
											</div>
									<%
											nCount++;
										}

										queryRS.close();
										stmt2.close();
									%>
									<script type="text/javascript">
										file_cnt = <%=nCount%>
									</script>
									<div class="postevent_upload">
										<a href="javascript:void(0)">上传活动配图</a><font color="#FF0000">&nbsp;&nbsp;(必须)</font>
									</div>   
								<p>描述：</p>
			                        <textarea name="photo_body" class="upadate_area"><%if (pid != 0) {%><%= body%><%}%></textarea>
                            </div>
                            <div class="faqansbtn" style="margin-left:50px;"><input type="button" value="发布照片" class="vipbtn01" onClick="do_submit();" /></div>
                        </form>
                    </div>
                </div>
                <div class="bigbot"></div>
            </div>
        </div>
        <div class="includeDom" include="inc/footer.jsp"></div>        
    </body>
</html>