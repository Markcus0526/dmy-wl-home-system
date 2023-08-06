<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>卧龙家园后台</title>
	<link href="favicon.ico" rel="shortcut icon"/>
	<script type="text/javascript" src="../js/jquery-1.9.0.min.js"></script>
	<script type="text/javascript" src="../js/jQuery-fileUploadButton.1.0.js"></script>
<style>
*{margin:0;padding:0;}
body {font-size: 12px;}
table {
	border-collapse: collapse;
	border-spacing: 0;
}
.wrap {
	width: 722px;
	margin: 0 auto;
	padding: 10px 0;
	border-bottom: 1px solid #dddfde;
}
.wrap h4 {
	height: 30px;
	font-size: 16px;
	color: #333;
}
.wrap .cont {
	padding-left: 20px;
}
.wrap .msg {
	margin-bottom: 20px;
}
.wrap .table table {
	margin-bottom: 20px;
}
.wrap .table th {
	background: #efefef;
	font-weight: normal;
}
.wrap .table td, .wrap .table th {
	border: 1px solid #c4c4c4;
	padding: 5px 0;
	text-align: center;
}
.wrap .down {
	color: #47828b;
}
</style>
</head>

<body>
<div class="wrap">
	<h4>步骤1 创建xls文件</h4>
	<div class="cont">
		<p class="msg">文字提示修改为：使用Microsoft Excel 一类电子表格程序创建或修改xls文件。xls文件应该采用表格形式，并需要包含标题，该行定义表中的字段。标题为：工号、姓名、分部、部门、用户名、昵称、积分、手机号码、电子邮件、权限、备注、密码等信息。</p>
		<div class="table">
			示例：<br />
			<table cellspacing="0" cellpadding="0" width="100%">
				<tr>
					<th>工号</th>
					<th>姓名</th>
					<th>分部</th>
					<th>部门</th>
					<th>用户名</th>
					<th>昵称</th>
					<th>积分</th>
					<th>手机号码</th>
					<th>电子邮件</th>
					<th>权限</th>
                                        <th>密码</th>
                                        <th>备注</th>

				</tr>
				<tr>
					<td>工号</td>
					<td>姓名</td>
					<td>分部</td>
					<td>部门</td>
					<td>用户名</td>
					<td>昵称</td>
					<td>积分</td>
					<td>手机号码</td>
					<td>电子邮件</td>
					<td>权限</td>
                                         <th>密码</th>
                                        <th>备注</th>
				</tr>
				<tr>
					<td>工号</td>
					<td>姓名</td>
					<td>分部</td>
					<td>部门</td>
					<td>用户名</td>
					<td>昵称</td>
					<td>积分</td>
					<td>手机号码</td>
					<td>电子邮件</td>
					<td>权限</td>
                                       <th>密码</th>
                                        <th>备注</th> 
				</tr>
			</table>
			<a href="../admin/file/Model.xls" class="down">[下载xls文件示例]</a>
		</div>
	</div>
</div>
<div class="wrap">	
	<h4>步骤2 导入xls文件</h4>
	<div class="cont">		
		<form action='excelupload.jsp' method='post' enctype="multipart/form-data" id="ExcelUploadForm" name="ExcelUploadForm">
			<table>
				<tr>				
					<td><label for="">选择文件：</label></td>
					<td><input type="hidden" id="Excelfilepath" name="excelpath" value="upload_data/member_info/" /></td>
					<td><input type="hidden" id="Excelfilename" name="excelname" /></td>
					<td><input type='text' id='filepath' disabled='disabled' /></td>
					<td><input type='file' id='Excelfile' name='imagefile' onChange='$("#filepath").val($("#Excelfile").val().toString());' /></td>
					<td>&nbsp;&nbsp;&nbsp;</td>
					<td><a href='#' class='update_cancel' onclick='$("#Excelfile").val(""); $("#filepath").val("");'>撤销</a></td>		
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td><input type='button' onclick='submit_xls();' style='width:100px;' value='确定导入'></td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td><input type='button' onclick='return_mainpage();' style='width:100px;' value='返回'></td>
				</tr>
			</table>
		</form>
	</div>
</div>
</body>

<script type="text/javascript">
	$(function() {
		$('#Excelfile').fileUploadButton({
			height: '24px',
			width: '24px',
			image: '../img/load.png'
		});
	});

	function submit_xls()
    {
		if($("#filepath").val().length == 0) 
		{
           alert("请选择Excel文件");
           return;
        }
		var filename =  $("#filepath").val();
		var idx = filename.lastIndexOf('.');     
		var ext = filename.substr(idx + 1, filename.length).toLowerCase();
		if (ext != "xls") {
		   alert("请选择正确的 Excel文件");
		   return;
		}
		
		var tmpStr = $("#Excelfile").val().toString();
		
		var ind = tmpStr.lastIndexOf("\\") + 1;
		if(ind < 0) 
			ind = tmpStr.lastIndexOf("/") + 1;
		cur_img_path = "tmp_" + tmpStr.substring(ind);
		$("#Excelfilename").attr("value", cur_img_path);

		$("#ExcelUploadForm").submit();
    }

	function return_mainpage()
	{
		window.location.href='user.jsp?row=10&page=1';
	}
</script>

</html>