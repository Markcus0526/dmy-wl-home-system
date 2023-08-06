<%-- 
    Document   : share_info
    Created on : 10-Dec-2013, 10:18:10
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.DataInputStream"%>
<%@page import="java.util.Enumeration"%>
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
        <script src="js/jwplayer.js" type="text/javascript"></script>
        <%@ page language="Java" import="java.sql.*" %>
        <%@page import="java.util.Date"%>
        <!--[if IE 6]>
                <script src="js/IE6PNG.js"></script>
                <script type="text/javascript">
                        IE6PNG.fix('.png');
                </script>
        <![endif]-->
        <%
            request.setCharacterEncoding("UTF-8");

            String share_type = request.getParameter("type") == null ? "0" : request.getParameter("type");
            int type = Integer.parseInt(share_type);

            String sid = request.getParameter("id") == null ? "0" : request.getParameter("id");
            int share_id = Integer.parseInt(sid);

            String spage = request.getParameter("page");
            int pagenum = spage == null ? 0 : Integer.parseInt(spage);
        %>

    </head>
    <body>
        <%@ include file="connection.jsp" %>
        <%
            Cookie[] cookies1 = request.getCookies();
            String tmp_str1 = "";
			String str_IsActive = "";
            for (int i = 0; i < cookies1.length; i++) {
                String name1 = cookies1[i].getName();
                int pos1 = name1.indexOf('#');
                if (pos1 != -1) {
                    if (name1.substring(0, pos1).equals("wljyid")) {
                        tmp_str1 = name1.substring(pos1 + 1);
                    }
					if (name1.substring(0, pos1).equals("wljyisactive")) {
                        str_IsActive = name1.substring(pos1 + 1);
                    }
                }
            }
            if (tmp_str1.equals("")) {
                out.println("<script>window.location.href='login.jsp';</script>");
            }

            int UserId1 = Integer.parseInt(tmp_str1, 10);
			int IsActive = 0;
			String queryFirstLogin = "select firstlogin from memberinfo where id = " + UserId1;
			Statement stmtFirstLogin = conn.createStatement();
			ResultSet rsFirstLogin = stmtFirstLogin.executeQuery(queryFirstLogin);
			if (rsFirstLogin.next()) {
				IsActive = rsFirstLogin.getInt("firstlogin");
			}
			rsFirstLogin.close();
			stmtFirstLogin.close();

            ResultSet rs2;
            Statement stmt2 = conn.createStatement();
            String sql1 = "";
            String username1 = "";
            String vip = "vip.jsp";
            if (UserId1 == 0) {
                username1 = "游客";
                vip = "#";
            } else {
                sql1 = "select * from memberinfo where id =" + UserId1;
                rs2 = stmt2.executeQuery(sql1);
                if (rs2.next()) {
                    username1 = rs2.getString("name");
                }
                rs2.close();
            }

        %>
        <script type="text/javascript">
            $(function(){
                $(".video").click(function() {		
                    jwplayer().playlistItem($(this).attr("idx"));
                });
                $(".includeDom").each(function(){
                    var html = $(this).attr("include");
                    $(this).load(html,function() {
                        $(".menu li a").eq(2).css("color","#017ab2"                        );
                        $(".toptit span a").eq(<%= type%>).addClass("now");
                        $(".name").html("<%=username1%>");
                        $(".vip").attr("href", "<%=vip%>");
                    });
                })
            })
            function change_page(index                            ) {
                window.location.href = "share_info.jsp?id=<%=share_id%>&page=" + index;
            }
            function select_change() {
                change_page($("#page").val());
            }
            function submit_eval() {
                var eval = $("#eval_text").val();
                if(eval.length < 1 || eval == "输入文本...")
                    alert("请输入正确文本");
                else
                    $("#eval_form").submit();
            }
        </script>
        <%
            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();

            String sql = new String();
            ResultSet rs, rs1;
        %>
        <div class="w964">
            <div class="includeDom" include="inc/top.jsp"></div>
            <div class="toptit sharetit">
                <b>分享</b>
                <span><a href="share.jsp">全部</a>
                    <%
                        request.setCharacterEncoding("UTF-8");
                        sql = "Select * from SHARE_TYPE";
                        rs = stmt.executeQuery(sql);
                        String tname = new String();
                        int tid = 0;
                        while (rs.next()) {
                            tid = rs.getInt("ID");
                            tname = rs.getString("NAME");

                            out.println("<a href=\"share.jsp?type=" + tid + "\">" + tname + "</a>");
                        }
                        rs.close();

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

                        //String action = (String)request.getAttribute("action");
                        String action = request.getParameter("action");
                        if (action != null && action.equals("add")) {
                            String postdata = (request.getParameter("postdata") == null) ? "0" : request.getParameter("postdata");
                            sql = "select max(id) from share_eval";
                            rs = stmt.executeQuery(sql);
                            int max_id = 1;
                            if (rs.next()) {
                                max_id = rs.getInt(1);
                            }
                            sql = "Insert into SHARE_EVAL (ID, RID, MID, POSTDATE, BODY, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
                            PreparedStatement pstmt = conn.prepareStatement(sql);
                            pstmt.setInt(1, max_id + 1);
                            pstmt.setInt(2, share_id);
                            pstmt.setInt(3, UserId);
                            Date tmp = new Date();
                            java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
                            pstmt.setTimestamp(4, d);
                            pstmt.setString(5, postdata);
                            pstmt.setInt(6, 1);

                            pstmt.execute();
                            pstmt.close();
                            request.removeAttribute("action");
                        }

                        stmt.close();
                        stmt = conn.createStatement();
                        sql = "Select * from SHARE_INFO where deleted = 0 and ID = " + share_id;
                        rs = stmt.executeQuery(sql);

                        String title = "";
                        String body = "";
                        int mid = 0;
                        String mname = "";
                        Date postdate = new Date(1, 11, 1);
                        int read_count = 0;

                        while (rs.next()) {
                            mid = rs.getInt("MID");
                            title = rs.getString("TITLE");
                            type = rs.getInt("TYPE");
                            body = rs.getString("BODY");
                            postdate = rs.getDate("POSTDATE");
                            read_count = rs.getInt("READCOUNT");
                        }
                        rs.close();

                        if ((spage == null) && (action == null || !action.equals("add"))) {
                            //Update ReadCount
                            read_count++;
                            sql = "Update SHARE_INFO SET READCOUNT = " + read_count + "where ID = " + share_id;
                            stmt.close();
                            stmt = conn.createStatement();
                            rs = stmt.executeQuery(sql);
                            rs.close();
                        }
                        stmt.close();
                        stmt = conn.createStatement();
                        sql = "Select * from MEMBERINFO where ID = " + mid;
                        rs = stmt.executeQuery(sql);
                        while (rs.next()) {
                            mname = rs.getString("NAME");
                        }
                        rs.close();
                    %>
                </span>
            </div>
            <div class="site clear">
                <div class="content fle">
                    <div class="conttop"></div>
                    <div class="main">
                        <div class="single_tit">
                            <b><%=title%></b>
                            <h5><a href="person.jsp?id=<%=mid%>"><%=mname%></a></h5>
                            <p><span>发布时间：<%=postdate%></span><span>浏览：<%=read_count%> </span></p>
                        </div>
                        <%
                            stmt.close();
                            stmt = conn.createStatement();
                            sql = "Select * from SHARE_DATA where deleted = 0 and type = 0 and RID = " + share_id + " order by id asc";
                            rs = stmt.executeQuery(sql);

                            String path = null;
                            while (rs.next()) {
                                path = rs.getString("DATAPATH");
                        %>
                        <div class="playinfo_det border01">
                            <p><img src="<%=path%>" alt="" style="width: 100%;"></p>
                        </div>
                        <%
                            }
                            rs.close();
                            stmt.close();
                        %>
                        <%
                            stmt = conn.createStatement();
                            sql = "Select * from SHARE_DATA where deleted = 0 and type = 1 and RID = " + share_id + " order by id asc";
                            rs = stmt.executeQuery(sql);

                            path = null;
                            int j = 0;
                            String path1 = "";
                            String path2 = "";
                            String path3 = "";
                            while (rs.next()) {
                                path = rs.getString("DATAPATH");
                                if (j == 0) {
                                    path1 = path;
                                } else if (j == 1) {
                                    path2 = path;
                                } else if (j == 2) {
                                    path3 = path;
                                }
                        %>

                        <%
                                j++;
                            }
                            rs.close();
                        %>
                        <%
                            int idx2 = 0;
                            if (path1 != null) {
                                path1.lastIndexOf(".");
                                File uploadedFile = new File(path1);
                                idx2 = path1.lastIndexOf(".");

                                String fileExtension = path1.substring(idx2 + 1);
                                String imgpath = uploadedFile.getPath().replace(fileExtension, "jpg").replace("\\", "/");

                                if (imgpath != null && imgpath.length() != 3) {
                        %>
                        <div id="container" style="margin-left: 20px;margin-top:20px;">  
                            <div id="screen"></div>
                            <script type="text/javascript">
                                jwplayer("screen").setup({
                                    flashplayer: "${pageContext.request.contextPath}/js/player.swf",
                                    file: "${pageContext.request.contextPath}/<%=path1%>",
                                    image: "${pageContext.request.contextPath}/<%=imgpath%>",
                                    height: 360,
                                    width: 640
                                });
                            </script>

                        </div>

                        <%
                                }
                            }

                            int pagecount = 2;
                            stmt.close();
                            stmt = conn.createStatement();
                            sql = "select count(*) as count from share_eval where rid = '" + share_id + "'";
                            rs = stmt.executeQuery(sql);

                            int total_count = 0;
                            int total_page = 0;
                            int prev_page = 1, next_page = 1, first_index = 1, last_index = 1;

                            int clob_length = 0, eval_count = 0;
                            Clob clob = null;

                            if (rs.next()) {
                                total_count = rs.getInt("count");
                            }
                        %>

                        <div class="faqanstab">
                            <form action="share_info_addcrit.jsp" method="post" id ="eval_form">
                                <h4>发表评论 <span>（共<%=total_count%>条评论）</span></h4>
                                <div class="faqanseare">
                                    <textarea name="postdata" class="faqansinput" id="eval_text" onclick="if (this.value=='输入文本...') this.value=''">输入文本...</textarea>
                                </div>
                                <input type="hidden" id="action" name="id" value="<%=share_id%>"/>
                                <div class="faqansbtn" align="right">
                                    <% if (UserId != 0 && IsActive == 1) {%>
                                    <input type="button" value="提 交" class="faqansbtn01" onclick="submit_eval()"/>
                                    <% }%>
                                </div>
                            </form>
                        </div>	
                        <%
                            if (total_count != 0) {
                                total_page = (total_count - 1) / pagecount + 1;
                                if (pagenum == 0) {
                                    pagenum = total_page;
                                }
                                prev_page = 1;
                                next_page = total_page;
                                if (pagenum > 1) {
                                    prev_page = pagenum - 1;
                                }
                                if (pagenum < total_page) {
                                    next_page = pagenum + 1;
                                }

                                last_index = total_count - (total_page - pagenum) * pagecount;
                                first_index = last_index - pagecount + 1;
                                if (first_index <= 0) {
                                    first_index = 1;
                                }
                        %>
                        <div class="faqinfo_ans marT20">
                            <ul class="clear">
                                <%
                                    stmt.close();
                                    stmt = conn.createStatement();
                                    sql = "select * from (select * from (select * from SHARE_EVAL where deleted = 0 and rid = '" + share_id + "' order by id) where ID >= (select MAX(ID) from (select * from (select * from SHARE_EVAL where deleted = 0 and rid = '" + share_id + "' order by id) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + pagecount + ") order by ID DESC";
                                    rs = stmt.executeQuery(sql);

                                    String user_image = null, eval_name = null, eval_body = null;

                                    while (rs.next()) {
                                        user_image = null;
                                        eval_name = null;
                                        eval_body = null;
                                        mid = rs.getInt("mid");
                                        sql = "select * from memberinfo where id = " + mid;
                                        rs1 = u_stmt.executeQuery(sql);
                                        if (rs1.next()) {
                                            eval_name = rs1.getString("name");
                                            user_image = rs1.getString("Photo");
                                        }
                                        rs1.close();

                                        clob = rs.getClob("BODY");
                                        clob_length = (clob == null) ? -1 : (int) clob.length();
                                        if (clob_length < 0) {
                                            eval_body = "";
                                        } else {
                                            eval_body = clob.getSubString(1, clob_length).replaceAll("\r\n", "<br>");
                                            eval_body = eval_body.replaceAll("\n", "&<br>");
                                        }
                                        postdate = rs.getDate("postdate");
                                %>
                                <li>
                                    <div class="clear">
                                        <div class="faqansl fle"><img src="<%=user_image%>" width="64" height="64" alt=""></div>
                                        <div class="faqansr fri">

                                            <h3><%=eval_name%></h3>
                                            <p><%=eval_body%></p>
                                            <em><%=postdate%></em>
                                            <span></span>
                                        </div>
                                    </div>
                                </li>
                                <%
                                    }
                                %>
                        </div>
                        <div class="page mar15" align="center">
                            共 <%= total_count%>条数据（<%=total_page%>页）
                            <a href="javascript:void(0)" onclick="change_page(<%=prev_page%>);"><img src="img/page.jpg" alt=""></a> 
                            <select id="page" onchange="select_change();">
                                <%
                                    int i = 0;
                                    for (i = total_page; i > 0; i--) {
                                        if (i == pagenum) {
                                            out.println("<option value='" + i + "' selected>" + i + "</option>");
                                        } else {
                                            out.println("<option value='" + i + "'>" + i + "</option>");
                                        }
                                    }
                                %>
                            </select> 
                            <a href="javascript:void(0)" onclick="change_page(<%=next_page%>)"><img src="img/page01.jpg" alt=""></a>
                        </div>
                        <%
                            }
                        %>
                    </div>
                    <div class="contbot"></div>
                </div>
                <% if (UserId != 0) {%>
                <div class="includeDom" include="inc/shareright.jsp"></div>
                <% }%>
            </div>
        </div>
        <div class="includeDom" include="inc/footer.jsp"></div>
        <%
            u_stmt.close();
            stmt.close();
            conn.close();
        %>
    </body>
</html>