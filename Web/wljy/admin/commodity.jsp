<%-- 
    Document   : commodity
    Created on : Dec 25, 2013, 11:24:48 AM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%@include file="cookie_check.jsp" %>
<%@page import="java.util.Date"%>

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
    </head>
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

        int pagenum = Integer.parseInt(request.getParameter("page") == null ? "0" : request.getParameter("page"));
        int pagecount = Integer.parseInt(request.getParameter("row") == null ? "10" : request.getParameter("row"), 10);

        Statement stmt = conn.createStatement();
        Statement u_stmt = conn.createStatement();

        String sql = "select count(*) as count from PRODUCT_INFO where deleted = 0";
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

        sql = "select * from (select * from (select * from PRODUCT_INFO where deleted = 0 order by id) where ID >= (select MAX(ID) from (select * from (select * from PRODUCT_INFO  where deleted = 0  order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id DESC";
        rs = stmt.executeQuery(sql);

        int product_id[] = new int[pagecount];
        String[] product_name = new String[pagecount];
        String[] product_property = new String[pagecount];
        String[] product_image = new String[pagecount];
        String[] product_body = new String[pagecount];
        int[] product_integralprice = new int[pagecount];
        int[] product_marketprice = new int[pagecount];
        int[] product_comprice = new int[pagecount];
        int[] product_totalexchange = new int[pagecount];
        int[] product_totalsecure = new int[pagecount];
        int[] product_type = new int[pagecount];
        int[] product_piid = new int[pagecount];
        int[] product_isvisible = new int[pagecount];
        int[] is_public = new int[pagecount];
        String public_string = new String();

        int clob_length = 0;
        Clob clob = null;

        int i = 0;
        int cur_cnt = 0;
        while (rs.next()) {
            product_id[i] = rs.getInt("ID");
            product_name[i] = rs.getString("NAME");
            product_type[i] = rs.getInt("TYPE");
            product_piid[i] = rs.getInt("IID");
            product_integralprice[i] = rs.getInt("INTEGRAL_PRICE");
            product_marketprice[i] = rs.getInt("MARKET_PRICE");
            product_comprice[i] = rs.getInt("COMPRICE");
            product_totalexchange[i] = rs.getInt("TOTAL_EXCHANGE");
            product_totalsecure[i] = rs.getInt("TOTAL_SECURE");
            product_isvisible[i] = rs.getInt("ISVISIBLE");

            sql = "Select * from PRODUCT_IMAGE where ID = " + product_piid[i];
            rs1 = u_stmt.executeQuery(sql);
            if (rs1.next()) {
                product_image[i] = rs1.getString("DATAPATH");
            }
            rs1.close();

            clob = rs.getClob("PROPERTY");
            clob_length = (clob == null) ? -1 : (int) clob.length();

            if (clob_length < 0) {
                product_property[i] = "";
            } else {
                product_property[i] = clob.getSubString(1, clob_length);
            }


            clob = rs.getClob("DETAIL");
            clob_length = (clob == null) ? -1 : (int) clob.length();

            if (clob_length < 0) {
                product_body[i] = "";
            } else {
                product_body[i] = clob.getSubString(1, clob_length);
            }

            is_public[i] = rs.getInt("ISPUBLIC");

            i++;
        }
        cur_cnt = i;
    %>

    <script charset="utf-8" src="kindeditor/kindeditor-min.js"></script>
    <script type="text/javascript">
    
        var editor;
        KindEditor.ready(function(K) {

            editor = K.create('textarea[name="product_detail"]', {
                allowFileManager : true,
                langType : "zh_CN"
            });
        });
    
        function change_row(row)
        {
            window.location.href = "commodity.jsp?row=" + row;
        }
    
        var flag = false;
        function pageselectCallback(page_index, jq){
            if (!flag) {
                flag = true;
            return false;
            }
            else window.location.href="commodity.jsp?page=" + (page_index + 1) + "&row=" + <%=pagecount%>;
        }
    
        $(document).ready(function() {
            var optInit = {callback: pageselectCallback};
            optInit['items_per_page'] = <%=pagecount%>;
            optInit['num_display_entries'] = 3;
            optInit['current_page'] = <%=pagenum%> - 1;
       
            $("#Pagination").pagination(<%=total_count%>, optInit);
         
            $('#imagefile_0').fileUploadButton({
                height: '24px',
                width: '24px',
                image: '../img/load.png'
            });
        
            $('#imagefile_1').fileUploadButton({
                height: '24px',
                width: '24px',
                image: '../img/load.png'
            });
        
            $('#imagefile_2').fileUploadButton({
                height: '24px',
                width: '24px',
                image: '../img/load.png'
            });
        
            $('#imagefile_3').fileUploadButton({
                height: '24px',
                width: '24px',
                image: '../img/load.png'
            });
        
            $('#imagefile_4').fileUploadButton({
                height: '24px',
                width: '24px',
                image: '../img/load.png'
            });
        
            $('#imagefile_5').fileUploadButton({
                height: '24px',
                width: '24px',
                image: '../img/load.png'
            });
        
            $('#imagefile_6').fileUploadButton({
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
   
    
        var imagefile_submit_clicked = -1;
        var cur_img_path = "";
        var tmp_index = 0;
    
        function imagesetting_reset()
        {
            $("#imagechanged").attr("value", "0");
            $("#tmp_imagepath0").attr("value", "");
            $("#tmp_imagepath1").attr("value", "");
            $("#tmp_imagepath2").attr("value", "");
            $("#tmp_imagepath3").attr("value", "");
            $("#tmp_imagepath4").attr("value", "");
            $("#tmp_imagepath5").attr("value", "");
            $("#tmp_imagepath6").attr("value", "");
        
            $("#imgview_0").attr("src","");
            $("#imgview_1").attr("src","");
            $("#imgview_2").attr("src","");
            $("#imgview_3").attr("src","");
            $("#imgview_4").attr("src","");
            $("#imgview_5").attr("src","");
            $("#imgview_6").attr("src","");
        }
    
        function imagefile_submit(img_index)
        {
            imagefile_submit_clicked = 1;
            var tmpStr = $("#imagefile_"+img_index).val().toString();
            var ind = tmpStr.lastIndexOf(".");
            var ind1 = tmpStr.lastIndexOf("\\");
            var ext = tmpStr.substr(ind + 1, tmpStr.length).toLowerCase();
       
            if (ext != "jpg" && ext != "png" && ext != "bmp" && ext != "gif") {
                alert("图片格式错误");
                return;
            }
        
            tmp_index++;
            cur_img_path = "tmp_<%=UserId%>_" + img_index + "_" + tmp_index + tmpStr.substr(ind1+1);
        
            $("#imagefilename_"+img_index).attr("value", cur_img_path);
            $("#imageUploadForm_"+img_index).submit();
        }

        function imagefile_read(img_index)
        {
            if ( imagefile_submit_clicked < 0 )
                return;

            imagefile_submit_clicked = -1;
        
            var tmpStr = $("#imagefile_"+img_index).val().toString();
            var ind = tmpStr.lastIndexOf(".");
        
            $("#imgview_"+img_index).attr("src", "../upload_data/product/"+cur_img_path);
            $("#imagechanged").attr("value", "1");
            $("#tmp_imagepath"+img_index).attr("value", cur_img_path);
        }
    
        function select_change(type) {
            if(type=="ispublic")
                $("#form_edit_ispublic").attr("value", $("#select_ispublic").val());
        }
    
        function submit_add()
        {
            var product_marketprice = $("#product_marketprice").val();
            var product_comprice = $("#product_comprice").val();
            var product_integralprice = $("#product_integralprice").val();
            var product_totalsecure = $("#product_totalsecure").val();

            if ($("#product_name").val().length == 0) {
                alert("请输入商品名称");
                return;
            }
        
            if ( isNaN(product_marketprice) || product_marketprice=="" || parseInt(product_marketprice, 10)<0 ) {
                alert("请输入正确的市场售价");
                return;
            }

            if ( isNaN(product_comprice) || product_comprice=="" || parseInt(product_comprice, 10)<0 ) {
                alert("请输入正确的采购价");
                return;
            }
        
            if ( isNaN(product_integralprice) || product_integralprice=="" || parseInt(product_integralprice, 10)<0 ) {
                alert("请输入正确的积分");
                return;
            }
        
            if ( isNaN(product_totalsecure) || product_totalsecure=="" || parseInt(product_totalsecure, 10)<0 ) {
                alert("请输入正确的库存");
                return;
            }
        
            if( $("#act").val() == "add" && $("#tmp_imagepath0").val().length == 0) {
                alert("请选择正确的商品图");
                return;
            }
        
            $("#tmp_product_name").attr("value", $("#product_name").val());
            $("#tmp_product_marketprice").attr("value", $("#product_marketprice").val());
            $("#tmp_product_comprice").attr("value", $("#product_comprice").val());
            $("#tmp_product_integralprice").attr("value", $("#product_integralprice").val());
            $("#tmp_product_totalsecure").attr("value", $("#product_totalsecure").val());
            $("#tmp_product_property").val($("#product_property").val());
            $("#product_detail").html(editor.html());
            $("#tmp_product_detail").attr("value", editor.html());
            if ( $("#product_visible").attr("src") == "img/i-yes.gif" )
                $("#tmp_product_isvisible").attr("value", "1");
            else
                $("#tmp_product_isvisible").attr("value", "0");
            $("#tmp_pagenum").attr("value", "<%=pagenum%>");
            $("#tmp_pagecount").attr("value", "<%=pagecount%>");
        
            $("#form_edit_ispublic").attr("value", $("#select_ispublic").val()); 
        
            $("#act_post").submit();
        }
    
        function add()
        {
            imagesetting_reset();
            $("#act").attr("value", "add");
            $("#id").attr("value", "0");
        
            $("#product_name").attr("value", "");
            $("#product_marketprice").attr("value", "");
            $("#product_comprice").attr("value", "");
            $("#product_integralprice").attr("value", "");
            $("#product_totalsecure").attr("value", "");
            $("#product_property").html("");
            $("#product_detail").html("");
            $("#product_visible").attr("src", "img/i-yes.gif");
        
            $("#select_ispublic").val(1);  
        
            editor.html("");
        
            $('.increase').show();
        }
    
        function edit(ind)
        {
            $.ajax({
                url: "ajax.jsp",
                type: "POST",
                dataType: "json",
                data: {
                    type: "commodity",
                    act: "edit",
                    id: ind
                },
                success: edit_success,
                error: errorfunc1
            });
        }
    
        function edit_success(res)
        {
            $("#act").attr("value", "edit");
            $("#id").attr("value", res.product_id);
        
            $("#product_name").attr("value", res.product_name);
            $("#product_marketprice").attr("value", res.product_marketprice);
            $("#product_comprice").attr("value", res.product_comprice);
            $("#product_integralprice").attr("value", res.product_integralprice);
            $("#product_totalsecure").attr("value", res.product_totalsecure);
            $("#product_property").val(res.product_property);
            if ( res.product_isvisible == "1" )
                $("#product_visible").attr("src", "img/i-yes.gif");
            else
                $("#product_visible").attr("src", "img/i-no.gif");        
        
            $("#select_ispublic").val(res.ispublic);
        
            //$("#product_detail").html(res.product_detail);
            editor.html(res.product_detail);
        
            $("#imgview_0").attr("src","../"+res.product_image_0);
            $("#imgview_1").attr("src","../"+res.product_image_1);
            $("#imgview_2").attr("src","../"+res.product_image_2);
            $("#imgview_3").attr("src","../"+res.product_image_3);
            $("#imgview_4").attr("src","../"+res.product_image_4);
            $("#imgview_5").attr("src","../"+res.product_image_5);
            $("#imgview_6").attr("src","../"+res.product_image_6);
        
            $('.increase').show();
        }
    
        function errorfunc1(res)
        {
        
        }
    
        function delete_act(ind, name)
        {
            if (confirm("您要删除选择的商品吗?"))
            {
                $("#id").attr("value", ind);
	            $("#act").attr("value", "delete");
		        $("#tmp_pagenum").attr("value", "<%=pagenum%>");
                $("#tmp_pagecount").attr("value", "<%=pagecount%>");
                $("#act_post").submit();
            }
        }
    
        function visible_check_set()
        {
            if ( $("#product_visible").attr("src") == "img/i-yes.gif" )
                $("#product_visible").attr("src", "img/i-no.gif");
            else
                $("#product_visible").attr("src", "img/i-yes.gif");
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
                    type: "commodity",
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
                    type: "commodity",
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
                if (confirm("您确定要把勾选的商品删除吗?"))
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
    <script type="text/javascript">
        $(function(){
            $(".includeDom").each(function(){
                var html = $(this).attr("include");
                $(this).load(html, function() {
                    $(".nav a").eq(7).addClass("on");
                    //$(".box3rcon li:lt(3)").find("span.num").addClass("on");
                });
            })
        })
    </script>
    <body>
        <div class="header">
            <div class="includeDom" include="top.jsp"></div>
            <div class="nav-list">
                <ul>
                    <li><a href="exchange.jsp"><span>兑换记录</span></a></li>
                    <li><a href="commodity.jsp" class="on"><span>商品管理</span></a></li>
                </ul>
            </div>
            <div class="clear"></div>
        </div>
        <div class="main">
            <div class="side">
                <div class="side-list">
                    <h2>商品管理</h2>               
                </div>
                <div class="copyright"><p>技术支持: <a href="http://www.bocweb.cn" target="_blank">博采网络</a></p></div>
            </div>
            <div class="content">
                <div class="content-main">
                    <div class="content-box">
                        <div class="content-title">
                            <h2>商品管理<a href="#1" onclick="add();">添加</a><a id="del" href="#1" onclick="select_delete();">删除</a></h2>
                            <div class="page fr">
                                <div id="Pagination" class="pagination">
                                </div>
                            </div>
                            <div class="clear"></div>
                            <p><%=total_count%>个符合 |  每页 
                                <a href="#" onclick="change_row('10');">10个</a> » 
                                <a href="#" onclick="change_row('25');">25个</a> » 
                                <a href="#" onclick="change_row('50')">50个</a>
                            </p>
                        </div>
                        <div class="content-table">
                            <table width="100%">
                                <tr>
                                    <th style="width:3%"><input type="checkbox" class="group-checkable"/></th>
                                    <th width="15%">图片</th>
                                    <th width="10%">库存</th>
                                    <th width="35%">商品名称</th>
                                    <th width="10%">兑换价格</th>
                                    <th style="width:8%;">是否游客公开</th>
                                    <th style="width:8%;">显隐</th>
                                    <th style="width:14%;">操作</th>
                                </tr>

                                <%
                                    String blank = new String();
                                    blank = "blank";
                                    for (i = 0; i < cur_cnt; i++) {
                                        if (blank.length() == 0) {
                                            blank = "blank";
                                        } else {
                                            blank = "";
                                        }

                                        if (is_public[i] == 1) {
                                            public_string = "公开";
                                        } else {
                                            public_string = "不公开";
                                        }
                                %>

                                <tr class="<%=blank%>">
                                    <td class="checkboxes" ><input type="checkbox" value="<%=product_id[i]%>"/></td>
                                    <td><img src="../<%=product_image[i]%>" width="50" height="50" alt="" /></td>
                                    <td><%=product_totalsecure[i]%></td>
                                    <td style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><%=product_name[i]%></td>
                                    <td><%=product_integralprice[i]%>积分</td>
                                    <td><a href="#" id="public_<%=product_id[i]%>" onclick="change_public('<%=product_id[i]%>');"><%=public_string%></a></td>
                                    <td><a href="#"><img id="visible_<%=product_id[i]%>" onclick="change_visible('<%=product_id[i]%>');" src="<%if (product_isvisible[i] == 1) {
                                        out.print("img/i-yes.gif");
                                    } else {
                                        out.print("img/i-no.gif");
                                                                           }%>" alt="" /></a></td>
                                    <td>
                                        <a href="#" onclick="edit('<%=product_id[i]%>')">编辑</a> | <a href="#" onclick="delete_act('<%=product_id[i]%>', '<%=product_name[i]%>');">删除</a>
                                    </td>
                                </tr>
                                <% }%>
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
                            <div class="increase-title"><h2>商品管理</h2><a href="#1" onclick="$('.increase').hide()">关闭 [X]</a></div>
                        </div>
                        <div class="increase-top">
                            <div class="imgupload" align="center" style="margin-top:25px;">
                                <img id="imgview_0" src="" width="" height="" alt="" />
                                <iframe src='about:blank' name='hImageUpload' id='hImageUpload' style='display:none;' onload='imagefile_read(0);'></iframe>
                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload' id="imageUploadForm_0">
                                    <input type="hidden" id="imagefilename_0" name="imagefilename" />
                                    <input type="hidden" id="imagefilepath_0" name="imagefilepath" value="upload_data/product/" />
                                    <input type="file" id="imagefile_0" name="imagefile" onchange="imagefile_submit(0);" />
                                </form>
                            </div>
                            <div class="imgtable">
                                <table width="100%">
                                    <tr>
                                        <td>商品名称</td>
                                        <td><input id="product_name"  name="product_name" type="text" /></td>
                                    </tr>
                                    <tr>
                                        <td>市场售价</td>
                                        <td><input id="product_marketprice"  name="product_marketprice" type="text" /></td>
                                    </tr>
                                    <tr>
                                        <td>采购价</td>
                                        <td><input id="product_comprice"  name="product_comprice" type="text" /></td>
                                    </tr>
                                    <tr>
                                        <td>所需积分</td>
                                        <td><input id="product_integralprice"  name="product_integralprice" type="text" /></td>
                                    </tr>
                                    <tr>
                                        <td>库存</td>
                                        <td><input id="product_totalsecure"  name="product_totalsecure" type="text" /></td>
                                    </tr>

                                    <tr>
                                        <td>是否游客公开:</td>
                                        <td>
                                            <select id="select_ispublic" onchange="select_change('ispublic');">
                                                <option value="0">不公开</option>
                                                <option value="1" selected>公开</option>
                                            </select>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>显隐</td>
                                        <td><a href="#1" onclick="visible_check_set();"><img id="product_visible" src="img/i-yes.gif" alt="" /></a></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="imglist">
                            <div class="imglist-left">
                                <table>
                                    <tbody>
                                        <tr>
                                            <td align ="center">
                                                <div style="width:100px; height:62px; border:1px solid #cccccc;">
                                                    <img id="imgview_1" style="width:100px; height:62px;" src="" alt=""/>
                                                </div>
                                                <iframe src='about:blank' id='hImageUpload_1' name='hImageUpload_1' style='display:none;' onload='imagefile_read(1);'></iframe>
                                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload_1' id="imageUploadForm_1">
                                                    <input type="hidden" id="imagefilename_1" name="imagefilename" />
                                                    <input type="hidden" id="imagefilepath_1" name="imagefilepath" value="upload_data/product/" />
                                                    <input type="file" id="imagefile_1" name="imagefile"  onchange="imagefile_submit(1);"  />
                                                </form>
                                            </td>

                                            <td align ="center">
                                                <div style="width:100px; height:62px; border:1px solid #cccccc;">
                                                    <img id="imgview_2" style="width:100px; height:62px;" src="" alt=""/>
                                                </div>
                                                <iframe src='about:blank' id='hImageUpload_2' name='hImageUpload_2' style='display:none;' onload='imagefile_read(2);'></iframe>
                                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload_2' id="imageUploadForm_2">
                                                    <input type="hidden" id="imagefilename_2" name="imagefilename" />
                                                    <input type="hidden" id="imagefilepath_2" name="imagefilepath" value="upload_data/product/" />
                                                    <input type="file" id="imagefile_2" name="imagefile" onchange="imagefile_submit(2);"  />
                                                </form>
                                            </td>

                                            <td align ="center">
                                                <div style="width:100px; height:62px; border:1px solid #cccccc;">
                                                    <img id="imgview_3" style="width:100px; height:62px;" src="" alt=""/>
                                                </div>
                                                <iframe src='about:blank' id='hImageUpload_3' name='hImageUpload_3' style='display:none;' onload='imagefile_read(3);'></iframe>
                                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload_3' id="imageUploadForm_3">
                                                    <input type="hidden" id="imagefilename_3" name="imagefilename" />
                                                    <input type="hidden" id="imagefilepath_3" name="imagefilepath" value="upload_data/product/" />
                                                    <input type="file" id="imagefile_3" name="imagefile"  onchange="imagefile_submit(3);"  />
                                                </form>
                                            </td>
                                        </tr>

                                        <tr><td>&nbsp;</td></tr>

                                        <tr>
                                            <td align ="center">
                                                <div style="width:100px; height:62px; border:1px solid #cccccc;">
                                                    <img id="imgview_4" style="width:100px; height:62px;" src="" alt=""/>
                                                </div>
                                                <iframe src='about:blank' id='hImageUpload_4' name='hImageUpload_4' style='display:none;' onload='imagefile_read(4);'></iframe>
                                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload_4' id="imageUploadForm_4">
                                                    <input type="hidden" id="imagefilename_4" name="imagefilename" />
                                                    <input type="hidden" id="imagefilepath_4" name="imagefilepath" value="upload_data/product/" />
                                                    <input type="file" id="imagefile_4" name="imagefile"  onchange="imagefile_submit(4);"  />
                                                </form>
                                            </td>

                                            <td align ="center">
                                                <div style="width:100px; height:62px; border:1px solid #cccccc;">
                                                    <img id="imgview_5" style="width:100px; height:62px;" src="" alt=""/>
                                                </div>
                                                <iframe src='about:blank' id='hImageUpload_5' name='hImageUpload_5' style='display:none;' onload='imagefile_read(5);'></iframe>
                                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload_5' id="imageUploadForm_5">
                                                    <input type="hidden" id="imagefilename_5" name="imagefilename" />
                                                    <input type="hidden" id="imagefilepath_5" name="imagefilepath" value="upload_data/product/" />
                                                    <input type="file" id="imagefile_5" name="imagefile"  onchange="imagefile_submit(5);"  />
                                                </form>
                                            </td>

                                            <td align ="center">
                                                <div style="width:100px; height:62px; border:1px solid #cccccc;">
                                                    <img id="imgview_6" style="width:100px; height:62px;" src="" alt=""/>
                                                </div>
                                                <iframe src='about:blank' id='hImageUpload_6' name='hImageUpload_6' style='display:none;' onload='imagefile_read(6);'></iframe>
                                                <form action='common_upload.jsp' method='post' enctype='multipart/form-data' target='hImageUpload_6' id="imageUploadForm_6">
                                                    <input type="hidden" id="imagefilename_6" name="imagefilename" />
                                                    <input type="hidden" id="imagefilepath_6" name="imagefilepath" value="upload_data/product/" />
                                                    <input type="file" id="imagefile_6" name="imagefile"  onchange="imagefile_submit(6);"  />
                                                </form>
                                            </td>
                                        </tr>

                                        <tr><td>&nbsp;</td></tr>

                                    </tbody>
                                </table>

                            </div>
                            <div class="imglist-right">
                                <h2>产品介绍（产地、材料、颜色等）</h2>
                                <textarea id="product_property"  name="product_property" class="imglist"></textarea>
                            </div>
                            <div class="clear"></div>
                        </div>

                        <div class="imgtext">
                            <h2>商品详情</h2>
                            <form action="commodity_add.jsp" method="post" id="act_post">
                                <input type="hidden" id="tmp_product_name" name="tmp_product_name" value=""/>
                                <input type="hidden" id="tmp_product_marketprice" name="tmp_product_marketprice" value=""/>
                                <input type="hidden" id="tmp_product_comprice" name="tmp_product_comprice" value=""/>
                                <input type="hidden" id="tmp_product_integralprice" name="tmp_product_integralprice" value=""/>
                                <input type="hidden" id="tmp_product_totalsecure" name="tmp_product_totalsecure" value=""/>
                                <textarea style="display:none" id="tmp_product_property"  name="tmp_product_property" class="imglist"></textarea>
                                <input type="hidden" name="act" id="act" value="add"/>
                                <input type="hidden" name="id" id="id" value="0"/>
                                <input type="hidden" id="imagechanged" name="imagechanged" value="0"/>
                                <input type="hidden" name="ids" id="ids" value=""/>
                                <input type="hidden" id="form_edit_ispublic" name="ispublic" value="1"/>

                                <textarea id="product_detail"  name="product_detail" style="width:100%;height:200px;"></textarea>
                                <input type="hidden" id="tmp_product_detail" name="tmp_product_detail" value=""/>
                                <input type="hidden" id="tmp_product_isvisible" name="tmp_product_isvisible" value=""/>
                                <input type="hidden" id="tmp_imagepath0" name="tmp_imagepath0" value=""/>
                                <input type="hidden" id="tmp_imagepath1" name="tmp_imagepath1" value=""/>
                                <input type="hidden" id="tmp_imagepath2" name="tmp_imagepath2" value=""/>
                                <input type="hidden" id="tmp_imagepath3" name="tmp_imagepath3" value=""/>
                                <input type="hidden" id="tmp_imagepath4" name="tmp_imagepath4" value=""/>
                                <input type="hidden" id="tmp_imagepath5" name="tmp_imagepath5" value=""/>
                                <input type="hidden" id="tmp_imagepath6" name="tmp_imagepath6" value=""/>
                                <input type="hidden" id="tmp_pagenum" name="tmp_pagenum" value=""/>
                                <input type="hidden" id="tmp_pagecount" name="tmp_pagecount" value=""/>

                            </form>
                        </div>
                        <div style="font-size:14pt;height: 30px;"  align="center">
                            <input class="dialog_addbutton" type="button" value="保存" onclick="submit_add();"/>                                    
                        </div>
                    </td>
                    <td class="dlg-transl">&nbsp;</td>
                </tr>
                <tr>
                    <td colspan="3" class="dlg-trans">&nbsp;</td>
                </tr>
            </table>
        </div>
    </body>

</html>
