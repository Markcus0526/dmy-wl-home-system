<%-- 
    Document   : faq
    Created on : Jan 4, 2014, 1:35:04 PM
    Author     : Hercules
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
        <meta name="renderer" content="webkit" />
        <link href="favicon.ico" rel="shortcut icon" />
        <link href="css/reset.css" rel="stylesheet" type="text/css" />
        <link href="css/style.css"  rel="stylesheet" type="text/css" />
        <script type="text/javascript" src="js/jQuery.js"></script>
        <link rel="stylesheet" href="../css/themes/base/jquery.ui.all.css" />
        <script type="text/javascript" src="../js/jquery-1.9.0.min.js"></script>
        <script type="text/javascript" src="../js/jquery.ui.core.js"></script>
        <script type="text/javascript" src="../js/jquery.ui.datepicker.js"></script>
        <script type="text/javascript" src="../js/jquery.ui.widget.js"></script>
        <link rel="stylesheet" href="css/pagination.css" />
        <script type="text/javascript" src="js/jquery.min.js"></script>
        <script type="text/javascript" src="js/jquery.pagination.js"></script>
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->
        <%@ include file="../connection.jsp" %>
        <%@include file="cookie_check.jsp" %>
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

            String spage = request.getParameter("page") == null ? "1" : request.getParameter("page");
            String spagecount = request.getParameter("count") == null ? "10" : request.getParameter("count");
            String sstate = request.getParameter("state") == null ? "1" : request.getParameter("state");

            int pagenum = Integer.parseInt(spage);
            int pagecount = Integer.parseInt(spagecount);
            int state = Integer.parseInt(sstate);

            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();
            Statement u_stmt1 = conn.createStatement();
            Statement u_stmt2 = conn.createStatement();

            String sql = new String();
            sql = "select count(*) as count from OPINION where deleted = 0 and state=" + state;
            ResultSet rsforCount = u_stmt2.executeQuery(sql);
            int total_count = 0;
            int total_page = 0;
            if (rsforCount.next()) {
                total_count = rsforCount.getInt("count");
                total_page = (total_count - 1) / pagecount + 1;
                if (pagenum == 0) {
                    pagenum = 1;
                }
                if (pagenum > total_page) {
                    pagenum = total_page;
                }
            }
            rsforCount.close();

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

            sql = "select * from (select * from (select * from OPINION where deleted = 0 and state = " + state + " order by id) where ID >= (select MAX(ID) from (select * from (select * from OPINION where deleted = 0 and state=" + state + " order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id DESC";
            ResultSet rs = stmt.executeQuery(sql);

            int feedback_id[] = new int[pagecount];
            int[] feedback_mid = new int[pagecount];
			String[] feedback_realname = new String[pagecount];
            String[] feedback_mname = new String[pagecount];
			String[] feedback_namepassword = new String[pagecount];
            String[] feedback_title = new String[pagecount];
            String[] feedback_body = new String[pagecount];
            String[] feedback_datapath = new String[pagecount];
            int[] feedback_state = new int[pagecount];
            int[] feedback_integral = new int[pagecount];
            Date[] feedback_postdate = new Date[pagecount];
            Date[] feedback_evaldate = new Date[pagecount];
            int[] feedback_eid = new int[pagecount];
            String[] feedback_ename = new String[pagecount];

            int clob_length = 0;
            Clob clob = null;

            int i = 0;
            int cur_cnt = 0;
            while (rs.next()) {
                feedback_id[i] = rs.getInt("ID");
                feedback_mid[i] = rs.getInt("MID");
                feedback_title[i] = rs.getString("TITLE");
                feedback_datapath[i] = rs.getString("DATAPATH");
                if (feedback_datapath[i] == null) {
                    feedback_datapath[i] = "";
                }
                feedback_state[i] = rs.getInt("STATE");
                feedback_postdate[i] = rs.getDate("POSTDATE");
                feedback_evaldate[i] = rs.getDate("EVALDATE");
                feedback_eid[i] = rs.getInt("EID");
                feedback_integral[i] = rs.getInt("GAININTEGRAL");

                clob = rs.getClob("BODY");
                clob_length = (clob == null) ? -1 : (int) clob.length();

                if (clob_length < 0) {
                    feedback_body[i] = "";
                } else {
                    feedback_body[i] = clob.getSubString(1, clob_length);
                }
                feedback_body[i] = feedback_body[i].replaceAll("\r\n", "&<br>");
                feedback_body[i] = feedback_body[i].replaceAll("\n", "&<br>");

                sql = "select NAME, NICKNAME, NAMEPASSWORD from MEMBERINFO where deleted = 0 and ID=" + feedback_mid[i];
                rs1 = u_stmt.executeQuery(sql);
                if (rs1.next()) {
                    feedback_mname[i] = rs1.getString("NAME");
					feedback_realname[i] = rs1.getString("nickname");
					feedback_namepassword[i] = rs1.getString("namepassword");
                } else {
                    feedback_mname[i] = "";
					feedback_mname[i] = "";
					feedback_mname[i] = "";
                }

                rs1.close();

                sql = "select NAME from MANAGERINFO where deleted = 0 and ID=" + feedback_eid[i];
                rs1 = u_stmt.executeQuery(sql);
                if (rs1.next()) {
                    feedback_ename[i] = rs1.getString("NAME");
                } else {
                    feedback_ename[i] = "";
                }

                rs1.close();

                i++;
            }
            cur_cnt = i;
        %> 
        <script type="text/javascript">

    
            var flag = false;
    
            function pageselectCallback(page_index, jq){
                if (!flag) {
                    flag = true;
                    return false;
                }
                else window.location.href="feedback.jsp?state="+<%=state%>+"&page=" + (page_index + 1) + "&count=" + <%=pagecount%>;
            }
    
            $(document).ready(function() {
                var optInit = {callback: pageselectCallback};
                optInit['items_per_page'] = <%=pagecount%>;
                optInit['num_display_entries'] = 3;
                optInit['current_page'] = <%=pagenum%> - 1;
       
                $("#Pagination").pagination(<%=total_count%>, optInit);
         
                $("#group").click(function() {
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
                window.location.href = "feedback.jsp?state="+<%=state%>+"&count=" + row;
            }
            function edit(id, title, mname, postdate, body, path, integral)
            {
                $("#feedback_title").html(title);
                $("#feedback_mname").html(mname);
                $("#feedback_postdate").html(postdate);
                body = body.replace(/&<br>/g, "\r\n");
                $("#feedback_body").html(body);
                $("#feedback_integral").attr("value", integral);
        
                if ( path == "" )
                {
                    $("#download_btn").hide();
                    $("#download_atag").hide();
                }
                else
                {
                    $("#download_btn").show();
                    $("#download_atag").show();
                    $("#download_atag").attr("href", "feedback_download.jsp?datapath="+path);
                }
        
                $("#act").attr("value", "evaluate");
                $("#feedback_id").attr("value", id);
                $("#tmp_state").attr("value", "<%=state%>");
                $("#tmp_pagenum").attr("value", "<%=pagenum%>");
                $("#tmp_pagecount").attr("value", "<%=pagecount%>");
        
                $('.increase').show();
            }
    
            function evaluate_feedback(id, mid, title, mname, postdate, body, path)
            {
				var modifyTitle = title.replace("'", "");

                $("#feedback_title").html(modifyTitle);
                $("#feedback_mname").html(mname);
                $("#feedback_postdate").html(postdate);
                body = body.replace(/&<br>/g, "\r\n");
				body = body.replace("'", "");
                $("#feedback_body").html(body);
                $("#feedback_integral").attr("value", "");
        
                if ( path == "" )
                {
                    $("#download_btn").hide();
                    $("#download_atag").hide();
                }
                else
                {
                    $("#download_btn").show();
                    $("#download_atag").show();
                    $("#download_atag").attr("href", "feedback_download.jsp?datapath="+path);
                }
        
                $("#act").attr("value", "evaluate");
                $("#feedback_id").attr("value", id);
                $("#tmp_state").attr("value", "<%=state%>");
                $("#tmp_pagenum").attr("value", "<%=pagenum%>");
                $("#tmp_pagecount").attr("value", "<%=pagecount%>");
                $("#tmp_feedback_mid").attr("value", mid);
        
        
                $('.increase').show();
            }
    
            function delete_act(ind)
            {
                if (confirm("您要删除选择的献策吗?"))
                {
                    $("#feedback_id").attr("value", ind);
					$("#feedback_integral").attr("value", "");
                    $("#act").attr("value", "delete");
                    $("#tmp_state").attr("value", "<%=state%>");
                    $("#tmp_pagenum").attr("value", "<%=pagenum%>");
                    $("#tmp_pagecount").attr("value", "<%=pagecount%>");
                    $("#act_post").submit();
                }
            }
    
            function do_submit()
            {
				$("#act_post").submit();
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
                    if (confirm("您确定要把勾选的献策删除吗?"))
                    {
                        $("#ids").attr("value", ids);
						$("#feedback_integral").attr("value", "");
                        $("#act").attr("value", "deleteall");
                        $("#tmp_state").attr("value", "<%=state%>");
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
                        $(".nav a").eq(6).addClass("on");
                    });
                })
            })
        </script>

    </head>
    <body>
        <div class="header">
            <div class="includeDom" include="top.jsp"></div>
            <div class="nav-list">
                <ul>
                    <li><a href="feedback.jsp?state=1" class="<% if (state == 1) {
                            out.print("on");
                        } else {
                            out.print("off");
                        }%>"><span>已采纳</span></a></li>
                    <li><a href="feedback.jsp?state=0" class="<% if (state == 0) {
                            out.print("on");
                        } else {
                            out.print("off");
                        }%>"><span>未采纳</span></a></li>
                </ul>
            </div>
            <div class="clear"></div>
        </div>
        <div class="main">
            <div class="side">
                <div class="side-list">
                    <h2>献策管理</h2>
                </div>
                <div class="copyright"><p>技术支持: <a href="http://www.bocweb.cn" target="_blank">博采网络</a></p></div>
            </div>
            <div class="content">
                <div class="content-main">
                    <div class="content-box">
                        <div class="content-title">
                            <h2>献策管理<a id="del" href="#1" onclick="select_delete();">删除</a></h2>
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
                            <table width="100%" style="table-layout:fixed">
                                <tr>
                                    <th width="3%"><input type="checkbox" id="group" class="group-checkable"/></th>
                                    <% if (state == 1) {%>
									<th width="8%">姓名</th>
                                    <th width="8%">昵称</th>
									<th width="9%">工号</th>
                                    <th width="5%">获得积分</th>
                                    <th width="30%">标题</th>
                                    <th width="10%">献策日期</th>
                                    <th width="10%">采纳日期</th>
                                    <th width="10%">采纳名</th>
                                    <th width="10%">操作</th>
                                    <% } else {%>
									<th width="9%">姓名</th>
                                    <th width="9%">昵称</th>
									<th width="9%">工号</th>
                                    <th width="40%">标题</th>
                                    <th width="8%">附件</th>
                                    <th width="15%">献策日期</th>
                                    <th width="10%">操作</th>
                                    <% }%>
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
                                %>

                                <tr class="<%=blank%>">
                                    <td class="checkboxes" ><input type="checkbox" value="<%=feedback_id[i]%>"/></td>
                                    <% if (state == 1) {%>
									<td><%=feedback_realname[i]%></td>
                                    <td><%=feedback_mname[i]%></td>
									<td><%=feedback_namepassword[i]%></td>
                                    <td><%=feedback_integral[i]%></td>
                                    <td style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><%=feedback_title[i]%></td>
                                    <td><%=feedback_postdate[i]%></td>
                                    <td><%=feedback_evaldate[i]%></td>
                                    <td><%=feedback_ename[i]%></td>
                                    <td>
                                        <a href="#" onclick="edit('<%=feedback_id[i]%>', '<%=feedback_title[i]%>', '<%=feedback_mname[i]%>', '<%=feedback_evaldate[i]%>', '<%=feedback_body[i]%>', '<%=feedback_datapath[i]%>', '<%=feedback_integral[i]%>');">详细</a> | <a href="#" onclick="delete_act('<%=feedback_id[i]%>', '<%=feedback_title[i]%>');">删除</a>
                                    </td>
                                    <% } else {%>
									<td><%=feedback_realname[i]%></td>
                                    <td><%=feedback_mname[i]%></td>
									<td><%=feedback_namepassword[i]%></td>
                                    <td style="overflow:hidden;white-space:nowrap;text-overflow:ellipsis;"><%=feedback_title[i]%></td>
                                    <td><% if (!feedback_datapath[i].equals("")) {%><img src="../img/disk_blue.png" width="20" height="20" alt="" /> <% }%></td>
                                    <td><%=feedback_postdate[i]%></td>
                                    <td>
                                        <a href="#" onclick="evaluate_feedback('<%=feedback_id[i]%>', '<%=feedback_mid[i]%>', '<%=feedback_title[i]%>', '<%=feedback_mname[i]%>', '<%=feedback_postdate[i]%>', '<%=feedback_body[i]%>', '<%=feedback_datapath[i]%>');">采纳</a> | <a href="#" onclick="delete_act('<%=feedback_id[i]%>');">删除</a>
                                    </td>
                                    <% }%>
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
                            <div class="increase-title"><h2>采纳献策</h2>
                                <a href="javascript:void(0)" onclick="$('.increase').hide()">关闭 [X]</a>
                            </div>
                        </div>
                        <div class="increase-top" align="center">
                            <div class="feedbacktablenone">
                                <table width ="100%">
                                    <tr>
                                        <td width="20%" align="right">标题:&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                        <td colspan="3" style="margin-left:40px;"><p id="feedback_title"></p></td>
                                    </tr>
                                    <tr>
                                        <td align="right">献策名:&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                        <td><p id="feedback_mname"></p></td>
                                        <td align="right">献策日期:&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                        <td><p id="feedback_postdate"></p></td>
                                    </tr>
                                    <tr>
                                        <td width="20%" align="right">附件:&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                        <td colspan="3" style="margin-left:40px;"><a id="download_atag" href=""><img id="download_btn" src="../img/disk_blue.png" width="20" height="20" alt="" onclick="" /></a></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="feedbackimgtext">
                            <h2>献策内容</h2> 
                            <textarea id="feedback_body" name ="feedback_body" disabled="disabled" value=""></textarea>
                        </div>
                        <div class="imgtext">
                            <form action="feedback_edit.jsp" method="post" id="act_post">
                                <h2 style="visibility: hidden;">采纳积分:&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" id="feedback_integral" style="visibility: hidden;" name="feedback_integral" <% if (state == 1) {%> disabled <% }%>/>  </h2>
                                <input type="hidden" id="feedback_id" name="feedback_id" />
                                <input type="hidden" id="act" name="act" />
                                <input type="hidden" id="tmp_feedback_mid" name="feedback_mid" />
                                <input type="hidden" id="tmp_state" name="tmp_state" value=""/>
                                <input type="hidden" id="tmp_pagenum" name="tmp_pagenum" value=""/>
                                <input type="hidden" id="tmp_pagecount" name="tmp_pagecount" value=""/>
                                <input type="hidden" name="ids" id="ids" value=""/>
                            </form>
                        </div>
                        <center><input type="button" value="采纳" onclick="do_submit()" style="font-size:20px; width:100px; height:30px"/></center>
						<p>&nbsp;</p>
                    </td>
                    <td class="dlg-transl">&nbsp;</td>
                </tr>
                <tr>
                    <td colspan="3" class="dlg-trans">&nbsp;</td>                    
                </tr>
            </table>
        </div>    
    </body>
    <%
        rs.close();
        stmt.close();
        u_stmt.close();
        u_stmt1.close();
        u_stmt2.close();
        conn.close();
    %>
</html>
