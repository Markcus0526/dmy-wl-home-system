<%-- 
    Document   : sharemy
    Created on : 2013/12/15, 下午 01:42:45
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
<link rel="stylesheet" href="css/themes/base/jquery.ui.all.css" />
<script type="text/javascript" src="js/jquery-1.9.0.min.js"></script>
<script type="text/javascript" src="js/jQuery-fileUploadButton.1.0.js"></script>

<%
    request.setCharacterEncoding("UTF-8");
    
    String  share_type = request.getParameter("type")==null?"1":request.getParameter("type");
    int type = Integer.parseInt(share_type);
%>

    <style type="text/css">
        .progress { position:relative; width:400px; border: 1px solid #ddd; padding: 1px; border-radius: 3px; margin-top:10px;}
        .bar { background-color: rgb(108, 203, 233); width:0%; height:20px; border-radius: 3px; }
        .percent { position:absolute; display:inline-block; top:3px; left:48%; }
    </style>

</head>
<body>
<%@ include file="connection.jsp" %>      
<div class="w964">
    <div class="includeDom" include="inc/top.jsp"></div>    
<%
 Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++)
    {
        String name=cookies[i].getName();
        int pos=name.indexOf('#');
        if(pos != -1)
        {
            if(name.substring(0, pos).equals("wljyid"))
            {
                tmp_str=name.substring(pos+1);
                break;
            }
        }
    }
    if (tmp_str.equals("")) 
        out.println("<script>window.location.href='login.jsp';</script>");

    int UserId = Integer.parseInt(tmp_str, 10);
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

	Integer pid = Integer.parseInt(((request.getParameter("id")== null)?"0":request.getParameter("id")), 10);

	String title = "", body = "", path = "", video_path = "";
	int nType = 0;
	String query = "select * from share_info where deleted = 0 and id =" + pid;
	ResultSet queryRS;
    Statement querySTMT = conn.createStatement();
	queryRS = querySTMT.executeQuery(query);
	if (queryRS.next()) {
		title = queryRS.getString("TITLE");
		nType = queryRS.getInt("TYPE");
		body = queryRS.getString("BODY");
	}
	queryRS.close();

	query = "select * from share_data where deleted = 0 and type = 0 and rid = " + pid;
	queryRS = querySTMT.executeQuery(query);

	Statement stmtTypes = conn.createStatement();
	String sqlTypes = "select COUNT(*) from SHARE_TYPE";
    ResultSet rsTypes = stmtTypes.executeQuery(sqlTypes);
    
    int type_count = 0;
    if ( rsTypes.next() )
        type_count = rsTypes.getInt(1);

    String[] type_names = new String[type_count];
    
    int i = 0;
    sqlTypes = "select NAME from SHARE_TYPE order by id";
    rsTypes = stmtTypes.executeQuery(sqlTypes);
    while (rsTypes.next())
    {
        type_names[i] = rsTypes.getString("NAME");
        i++;
    }
    rsTypes.close();
	stmtTypes.close();

	int nCount = 0;
%>
<script type="text/javascript">
$(function(){
	$(".includeDom").each(function(){
		var html = $(this).attr("include");
		$(this).load(html,function() {
			$(".menu li a").eq(2).css("color","#017ab2");
			$(".toptit span a").eq(<%= type%>).addClass("now");
                     $(".name").html("<%=username1%>");
                $(".vip").attr("href", "<%=vip%>");
		});
    });
})
</script>
<script type="text/javascript">
    var img_cnt = 0;
    var vid_cnt = 0;
    $(function(e) {
        $('#share_picture').fileUploadButton({
                height: '24px',
                width: '24px',
                image: 'img/load.png'
        });

		initFormUpload();
    })
    
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
				$("#videopath").attr("value", xhr.responseText);
				$('form[name=submit_form]').submit();
			}
		});
	};

	function showSelectedFile() {
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
			//$('#status').html($("input[name=uploadfile]").val());
			$('#selectedvideo').attr("value", $('input[name=uploadfile]').val());
		}
	}

	$(function(){
		$(".share_upload a").click(function(){
				var tmpStr = "";
				tmpStr = "<div class='marT20 clear' id='image_div_"+img_cnt+"'>";
				tmpStr += "<table><tr>";
				tmpStr += "<td><input type='text' class='update_input fle' id='imgfilepath_"+img_cnt+"' name='imgfilepath_"+img_cnt+"' disabled='disabled' /></td>";
				tmpStr += "<td width='40px' align='center'><input type='file' id='uploadfile_"+img_cnt+"' name='uploadfile_"+img_cnt+"' onChange='$(\"#imgfilepath_"+img_cnt+"\").val($(\"#uploadfile_"+img_cnt+"\").val());' /></td>";
				tmpStr += "<td><a href='javascript:void(0)' class='update_cancel' onclick='image_cancel(\""+img_cnt+"\")'>撤销</a></td>";
				tmpStr += "</tr></table>";
				tmpStr += "</div>";
				$(".share_upload").before(tmpStr);
				
				$('#uploadfile_'+img_cnt).fileUploadButton({
						height: '24px',
						width: '24px',
						image: 'img/load.png'
				});
				
				img_cnt++;
		});

		$(".postvideoselect a").click(function() {
			if($(this).parent().next().css("display")=="none") {
				$(this).parent().next().slideDown();
			}else {
				$(this).parent().next().slideUp();
			}
		})
			
		$(".postvideoselect li").click(function() {
				$(".postvideoselect div").html($(this).html());
			$(".postvideoselect dd").slideUp();
		})
        
    })

    function image_cancel(index)
    {
        $("#file_div_"+index).remove();
    }
    
    function video_cancel(index)
    {
        $("#video_div_"+index).remove();
    }
    
    function do_submit()
    {
		$("#type").val($(".postvideoselect div").html());

        if ($("#share_title").val().length == 0) {
           alert("请输入您的标题");
           return;
        }

        //if (img_cnt == 0 && ($("#uploadfile").val().length == 0 && $("#videopath").val().length == 0)) {
		if (img_cnt == 0 && $("#uploadfile").val().length == 0) {
           alert("请输入您的分享资料");
           return;
        }

		if ($("#uploadfile").val().length > 0)
		{
			showSelectedFile();      
		}
        
		
		var count = 0;
        if ( img_cnt > 0 )
        {
            for ( i = 0; i < img_cnt; i++ )
            {
                if ($("#imgfilepath_"+i).val() == undefined)
                    continue;
                
                var idx = $("#imgfilepath_"+i).val().lastIndexOf('.');     
                var ext = $("#imgfilepath_"+i).val().substr(idx + 1, $("#imgfilepath_"+i).val().length).toLowerCase();
                if (ext != "jpg" && ext != "png" && ext != "bmp" && ext != "gif") {
                    alert("图片格式错误");
                    return;
                }
				count++;
            }
        }

		if (count == 0 && $("#uploadfile").val().length == 0) {
           alert("请输入您的分享资料1");
           return;
        }
        
		$("form[name=uploadform]").submit();
		return;
    }
</script>

	<div class="site clear">
		<div class="content fle">
			<div class="conttop"></div>
			<div class="main">
				<div class="single_tit">
					<b>我要分享</b>
				</div>
				<div class="postevent_det">
				    <form action="share_mine_edit_add.jsp?id=<%=pid%>" method="post"  enctype="multipart/form-data" name="submit_form" id="submit_form">
					<p>标题</p>
					<input type="text" id="share_title" name="share_title" class="postevent_input"  value="<%= title%>" />
					<em style="color:#f00">*</em>	
					<p>分类</p>					
					<input type="hidden" name="type" id="type" value ="" />
					<div class="update_input01">
						<dl class="postvideoselect">
							<dt ><a style="height:30px; vertical-align:middle;" href="javascript:void(0)">&nbsp;</a><div style="height:37px;padding-left:10px;"><% if (nType == 0) {%>请选择分类<%} else { out.print(type_names[nType-1]); }%></div></dt>
							<dd>
								<ul>
									<% for ( i = 0; i < type_count; i++ ) { %>
										<li><%=type_names[i]%></li>
									<% } %>
								</ul>
							</dd>
						</dl>
					</div>
					<p>分享内容</p>
					<textarea name="share_body" class="postevent_textarea" ><%= body%></textarea>					
					<div class="marT20 clear">
						<p>图片</p>
						<%
							while (queryRS.next())
							{
								path = queryRS.getString("DATAPATH");
								path = path.substring(path.lastIndexOf("/")+1);
						%>
								<div class="marT20 clear" id="file_div_<%=nCount%>">
								<table>
								<tbody>
								<tr>
									<td>
										<input type="text" class="update_input fle" id="imgfilepath_<%=nCount%>" name="imgfilepath_<%=nCount%>" value="<%=path%>">
									</td>
									<td width="40px" align="center">
										<div style="cursor: pointer; position: relative; overflow: hidden; height: 24px; width: 24px; background-image: url(img/load.png);">
											<input type="file" id="uploadfile_<%=nCount%>" name="uploadfile_<%=nCount%>" onchange="$(&quot;imgfilepath_<%=nCount%>&quot;).val($(&quot;#uploadfile_<%=nCount%>&quot;).val());" style="height: 100%; cursor: pointer; position: absolute; top: 0px; right: 0px; z-index: 99; opacity: 0; font-size: 24px;">
										</div>
									</td>
									<td>
										<a href="javascript:void(0)" class="update_cancel" onclick="image_cancel(&quot;<%=nCount%>&quot;)">撤销</a>
									</td>
								</tr>
								</tbody>
								</table>
								</div>
						<%
								nCount++;
							}

							queryRS.close();
							querySTMT.close();
						%>
						<script type="text/javascript">
							img_cnt = <%=nCount%>
						</script>
						<div class="share_upload">
                            <a href="javascript:void(0)"><U>上传活动配图</U></a><font color="#FF0000">&nbsp;&nbsp;(非必须)</font>
                        </div>
					</div>
					<%
						Statement querySTMT1 = conn.createStatement();
						query = "select * from share_data where deleted = 0 and type = 1 and rid = " + pid;
						ResultSet queryRS1 = querySTMT1.executeQuery(query);
						if (queryRS1.next()) {
							video_path = queryRS1.getString("datapath");         
						}
						queryRS1.close();
						querySTMT1.close();
					%>
					<input type="hidden" id="selectedvideo" name="selectedvideo" value="" />
					<input type="hidden" id="videopath" name="videopath" value="<%=video_path%>" />
				    </form>
					<form id="uploadform" name="uploadform" action="uploadfile.jsp" method="post" enctype="multipart/form-data">
					<p>视频</p>					
					<p> </p>
					<div class="clear" style="margin-bottom:20px;">
                        <table>
							<tr>
								<td>
								<input type="file" name="uploadfile" id="uploadfile" value="<%=video_path%>"/>
								<div class="progress" style="display:none;">
									<div class="bar" style="width: 0%;"></div>
									<div class="percent">100%</div>
								</div>
								<div id="status">
								</div>
								</td>
							</tr>
							<tr>
								<td>
								<span style="margin:0; padding:2px 0px;">最大文件大小：500 MB</span>
								</td>
							</tr>
						</table>
					</div>
					</form>
                    <div class="mar"><input type="button" value="提 交" class="sharemy_btn" onclick="do_submit();" /></div>
				</div>
			</div>
			<div class="contbot"></div>
		</div>

		<div class="includeDom" include="inc/shareright.jsp"></div>
	</div>
</div>
<div class="includeDom" include="inc/footer.jsp"></div>
<script src="js/jquery.form.js"></script>
<script src="js/ajaxupload.js"></script>

</body>
</html>
