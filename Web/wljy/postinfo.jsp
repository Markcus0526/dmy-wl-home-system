<%-- 
    Document   : postinfo
    Created on : 10-Dec-2013, 10:15:50
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

<script type="text/javascript">
    $(function() {
	$(".toptit span a").eq(4).addClass("now");
    })
</script>
</head>
<%@ include file="connection.jsp" %>
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

        
    Statement stmt = conn.createStatement();

    String sql = "select COUNT(*) from STUDY_TYPE";
    ResultSet rs = stmt.executeQuery(sql);
    
    int type_count = 0;
    if ( rs.next() )
        type_count = rs.getInt(1);
    rs.close();

    String[] type_names = new String[type_count];
    
    int i;
    i = 0;
    sql = "select NAME from STUDY_TYPE order by id";
    rs = stmt.executeQuery(sql);
    while (rs.next())
    {
        type_names[i] = rs.getString("NAME");
        i++;
    }
    rs.close();
    
    sql = "select * from integralreason where id = 5";
   rs = stmt.executeQuery(sql);
   int max_integral = 0;
   while (rs.next()) {
       max_integral = rs.getInt("DEFAULTINTEGRAL");
   }
    rs.close();
    
    Integer sid = Integer.parseInt(((request.getParameter("id")== null)?"0":request.getParameter("id")), 10);
    Integer stype = Integer.parseInt(((request.getParameter("type")== null)?"1":request.getParameter("type")), 10);
            
        String title = "", body = "", datapath = "", imagepath = "";
        int type = 0, integral = 0;
        Clob clob = null;
        int clob_length = 0;

        if(stype == 0) {
            int sqid = 0;
            sql = "SELECT SQID FROM DATA_DOWNLOAD WHERE ID="+sid;
            rs2 = stmt2.executeQuery(sql);
            if(rs2.next())
                sqid = rs2.getInt("SQID");
            rs2.close();
            
            sql = "SELECT * FROM STUDY_QINFO WHERE ID="+sqid;
            rs2 = stmt2.executeQuery(sql);
            if ( rs2.next() )
            {
                title = rs2.getString("TITLE");
                type = rs2.getInt("TYPE");
                integral = rs2.getInt("INTEGRAL");
                datapath = rs2.getString("DATAPATH");
                imagepath = rs2.getString("IMAGEPATH");     
                datapath = datapath.substring(datapath.lastIndexOf("/")+1);
                imagepath = imagepath.substring(imagepath.lastIndexOf("/")+1);       

                clob = rs2.getClob("BODY");
                clob_length = (clob == null)?-1:(int)clob.length();            
                body = clob.getSubString(1, clob_length);
            }
            sid = sqid;
        } else {
            sql1 = "select * from STUDY_QINFO where id =" + sid;
            rs2 = stmt2.executeQuery(sql1);
            if (rs2.next()) {
                title = rs2.getString("TITLE");
                type = rs2.getInt("TYPE");
                integral = rs2.getInt("INTEGRAL");
                datapath = rs2.getString("DATAPATH");
                imagepath = rs2.getString("IMAGEPATH");   
                datapath = datapath.substring(datapath.lastIndexOf("/")+1);
                imagepath = imagepath.substring(imagepath.lastIndexOf("/")+1);             

                clob = rs2.getClob("BODY");
                clob_length = (clob == null)?-1:(int)clob.length();            
                body = clob.getSubString(1, clob_length);
            }       
        rs2.close();    
        }
    
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
                <h5>资料发布</h5>
                <form action="postinfo_add.jsp?type=<%=stype%>" method="post"  enctype="multipart/form-data" id="submit_form">
                <input type="hidden" id="info_id" name="info_id" value="<%=sid%>" />
                <table width="100%">
                    
                
                    <tr>
                        <td width="110" align="right">标题：</td>
                        <td><input name="info_title" type="text" class="update_input" id="title"  value="<%=title%>" /></td>
                    </tr>
                    
                    <tr>
                        <td width="110" align="right">分类：</td>
                        <td>
                            <input type="hidden"  name="info_type" id="info_type" />
                            <div class="update_input01">
                                <dl class="postvideoselect" style="height:37px; vertical-align: middle;">
                                    <dt style="height:37px;" vertical-align="middle"><a style="height:30px;" vertical-align="middle" href="javascript:void(0)">&nbsp;</a><div style="height:37px;padding-top: 8px;padding-left:10px;"><% if (type == 0) {%>请选择分类<%} else { out.print(type_names[type-1]); }%></div></dt>
                                    <dd>
                                        <ul>
                                            <% for ( i = 0; i < type_count; i++ ) { %>
                                                <li><%=type_names[i]%></li>
                                            <% } %>
                                        </ul>
                                    </dd>
                                </dl>
                            </div>
                        </td>
                    </tr>
                    <tr>
                            <td width="110" align="right">积分值：</td>
                            <td class="clear">
                                <input type="text" onkeyup="this.value=this.value.replace(/[^\d]/,'')" id="info_integral" name="info_integral" class="update_input fle" style="width:55px;" value="<%if(integral > 0) out.print(integral);%>"/>
                            </td>
                        </tr> 
                    <tr>
                        <td width="110" align="right">资料：</td>
                        <td class="clear">
                            <div class="clear">
                                
                                <input type='text' class='update_input fle' id='filepath' name='filepath' disabled='disabled' value="<%=datapath%>" />
                               <table><tr>
                                    <td width="40px" align="center"><input type='file' id='uploadfile' name='uploadfile' onChange='$("#filepath").val($("#uploadfile").val());' /></td>
                                    <td><a href='javascript:void(0)' class='update_cancel' onclick='$("#filepath").val(""); $("#uploadfile").val("");'>撤销</a>                                    </td>
                                </tr></table>
                            </div>
                        </td>
                    </tr>
                                        
                    <tr>
                        <td width="110" align="right">图片：</td>
                        <td class="clear">
                            <div class="clear">
                                
                                <input type='text' class='update_input fle' id='filepath1' name='filepath1' disabled='disabled' value="<%=imagepath%>"/>
                                <table><tr>
                                    <td width="40px" align="center"><input type='file' id='uploadfile1' name='uploadfile1' onChange='$("#filepath1").val($("#uploadfile1").val());' /></td>
                                    <td><a href='javascript:void(0)' class='update_cancel' onclick='$("#filepath1").val(""); $("#uploadfile1").val("");'>撤销</a>                                    </td>
                                </tr></table>
                            </div>
                        </td>
                    </tr>
                    
                    <tr>
                        <td width="110" align="right" valign="top">描述：</td>
                        <td colspan="2">
                            <textarea name="info_body" class="upadate_area"><%=body%></textarea>
                        </td>
                    </tr>
                
                </table>
                </form>
                <div class="faqansbtn" style="margin-left:125px;"><input type="button" onClick="do_submit();" value="上传资料" class="vipbtn01" /></div>
            </div>
        </div>
        <div class="bigbot"></div>
    </div>
</div>
<div class="includeDom" include="inc/footer.jsp"></div>
<script type="text/javascript">
    $(function() {
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
        
        $('#uploadfile').fileUploadButton({
            height: '24px',
            width: '24px',
            image: 'img/load.png'
        })
        
        $('#uploadfile1').fileUploadButton({
            height: '24px',
            width: '24px',
            image: 'img/load.png'
        })
    })
    
    function do_submit()
    {
        $("#info_type").val($(".postvideoselect div").html());
          if ($("#title").val().length == 0)
            {
                alert("请输入您的标题");
                return;
            }
       
            if  ($("#info_type").val() == "请选择分类") {
                alert("请选择分类");
                return;
            }
			var nIntegral = parseInt($("#info_integral").val());
             if (isNaN(nIntegral) || isNaN($("#info_integral").val()) || $("#info_integral").val() == "") {
                alert("请输入正确积分");
                return;
             }

			 /*
             if ($("#integral").val() > parseInt('<%=max_integral%>', 10)) {
                 alert("您已超量输入了积分");
               
				 return;
             }
			 */
			 if ($("#filepath").val().length == 0) {
                alert("请输入正确资料");
					 return;
				 }
            if ($("#filepath1").val().length != 0) {
				 var idx = $("#filepath1").val().lastIndexOf('.');     
				 var ext = $("#filepath1").val().substr(idx + 1, $("#filepath1").val().length).toLowerCase();
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