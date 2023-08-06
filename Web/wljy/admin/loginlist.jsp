<%-- 
    Document   : loginlist
    Created on : 2014/3/1, 上午 09:46:17
    Author     : kimsui
--%>
<%-- 
    Document   : user
    Created on : Jan 9, 2014, 2:50:55 PM
    Author     : KIMSUI
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
<meta name="renderer" content="webkit"/>
<link href="favicon.ico" rel="shortcut icon"/>
<link href="css/reset.css" rel="stylesheet" type="text/css" />
<link href="css/style.css"  rel="stylesheet" type="text/css" />
<script type="text/javascript" src="js/jQuery.js"></script>
<link rel="stylesheet" href="../css/themes/base/jquery.ui.all.css" />
<script type="text/javascript" src="../js/jquery-1.9.0.min.js"></script>
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
<%@ include file="cookie_check.jsp" %>
<%@ include file="../connection.jsp" %>
<script type="text/javascript">
    $(function(){
	$(".includeDom").each(function(){
            var html = $(this).attr("include");
            $(this).load(html, function() {
                $(".nav a").eq(1).addClass("on");
                //$(".box3rcon li:lt(3)").find("span.num").addClass("on");
            });
	});
        
    })
</script>
<%!
    public String ConvertDateString(String dateStr){
        String ret;
        String[] tmp = {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"};
        
        try {
            ret = dateStr.substring(8, 10) + "-" + tmp[Integer.parseInt(dateStr.substring(5, 7), 10) - 1] + "-" + dateStr.substring(0, 4);
        }
        catch (Exception e)
        {
            ret = "";
        }
        return ret;
    }

%>
    <%
   Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyadminid"))
           {
                 tmp_str=name.substring(pos+1);
                 break;
           }
       }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
     request.setCharacterEncoding("UTF-8");

     
     String search_name = request.getParameter("search_name")== null?"":request.getParameter("search_name");
     String search_title = request.getParameter("search_title")== null?"":request.getParameter("search_title");
     String search_from = request.getParameter("from_datepicker")== null?"":request.getParameter("from_datepicker");
     String search_to = request.getParameter("to_datepicker")== null?"":request.getParameter("to_datepicker");
     
     String tmp_from = search_from;
     String tmp_to = search_to;
     
       String add_condition = "";
     Statement tmp_stmt = conn.createStatement();
     String tmp_sql;
     ResultSet tmp_rs;
     
     if ( !search_name.equals("") )
     {
         add_condition = "(name like '" + search_name + "%' or name like '%" + search_name + "' or name like '%" + search_name + "%')";
         tmp_sql = "select ID from memberinfo where " + add_condition;
         
         add_condition = "(";
         
         tmp_rs = tmp_stmt.executeQuery(tmp_sql);
         while ( tmp_rs.next() )
         {
            add_condition += "MID = " + Integer.toString(tmp_rs.getInt("ID"), 10) + " or ";
         }
         tmp_rs.close();
         tmp_stmt.close();
         
         if ( !add_condition.equals("(") )
             add_condition = add_condition.substring(0, add_condition.length() - 4) + ")";
         else if (search_name.equals("管理者"))
             add_condition = "(MID = 0)";
         else
             add_condition = "(1=0)";
     }
     
      if (!search_from.equals(""))
     {
         search_from = ConvertDateString(search_from);
     }
     
     if (!search_to.equals(""))
     {
         search_to = search_to.substring(0, 4)+search_to.substring(5, 7) + search_to.substring(8, 10);
     }

     if (!search_from.equals("") && search_to.equals("")) {
         if ( !add_condition.equals(""))
            add_condition += " and ";
         add_condition += " (logintime >= '" + search_from + "')";
     }
     else if(search_from.equals("") && !search_to.equals(""))
     {
         if ( !add_condition.equals(""))
            add_condition += " and ";
         add_condition += " (logintime <= TO_DATE('" + search_to + "', 'yyyymmdd') + 1)";
     }
     else if(!search_from.equals("") && !search_to.equals(""))
     {
         if ( !add_condition.equals(""))
            add_condition += " and ";
         add_condition += " (logintime >= '" + search_from+ "' and logintime <= TO_DATE('" + search_to + "', 'yyyymmdd')+1)";
     }
     
     
     String spage = request.getParameter("page")== null?"0":request.getParameter("page");
     int pagenum = Integer.parseInt(spage);
     int pagecount = Integer.parseInt(request.getParameter("row")== null?"10":request.getParameter("row"), 10);
    
     Statement stmt = conn.createStatement();   
     Statement u_stmt = conn.createStatement();
     String sql = "";
     String searchcontext ="";
    
    String groupsql = "SELECT id, mid,logintime FROM (SELECT a.id, a.mid, a.logintime, rank() over (partition by a.mid order by a.logintime desc) rnk FROM MEMBERLOGINLIST a, MEMBERINFO b where a.mid = b.id and b.DELETED = 0) WHERE rnk = 1";

	if ( add_condition.equals(""))
        sql = "select count(*) as count from (" + groupsql +")";
    else
        sql = "select count(*) as count from (" + groupsql + ") where " + add_condition;
         
     ResultSet rs = stmt.executeQuery(sql);
     
     int total_count = 0, total_page = 0;
    
     if (rs.next()) {
        total_count = rs.getInt("count");
        total_page = (total_count - 1) / pagecount + 1;
        if (pagenum == 0) pagenum = 1;
        else if (pagenum > total_page) pagenum = total_page;
    }
     
    rs.close();
    
    int prev_page = 1, next_page = total_page;
    if (pagenum > 1) prev_page = pagenum - 1;
    if (pagenum < total_page) next_page = pagenum + 1;
    
    ResultSet rs1 = null;    
    
    int last_index = total_count -  (pagenum - 1) * pagecount;
    int first_index = last_index - pagecount + 1;
    if (first_index <= 0) first_index = 1;
    int count = pagecount;  
     if (first_index == 1) count = last_index;
        
    if (first_index > total_count) {
        count = last_index;
    }
    
      if ( add_condition.equals(""))
        sql = "select * from (select * from (select * from (" + groupsql + ") order by id ASC)  where ID >= (select MAX(ID) from (select * from (select * from (" + groupsql + ") order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id DESC"; 
    else
        sql = "select * from (select * from (select * from (" + groupsql + ") where " + add_condition + " order by id ASC)  where ID >= (select MAX(ID) from (select * from (select * from (" + groupsql + ") where " + add_condition + " order by id ASC) where ROWNUM <= " + last_index + ") where rownum <= " + first_index + ") and ROWNUM <= " + count + ") order by id DESC"; 
     
      
    rs = stmt.executeQuery(sql);
    
    String userid = new String();
  
    String registdate = new String();
    String registip = new String();
    String name = new String();    
      
    String nickname = new String();
	String namepassword = new String();
    
    int id = 0, mid = 0;

    
%>
<script type="text/javascript">
    var flag = false;
    var pass = '';
    function pageselectCallback(page_index, jq){
      if (!flag) {
          flag = true;
          return false;
      }
      else
      {
          $("#search_row").val('<%=pagecount%>');
          $("#search_page").val(page_index + 1);
          
          $("#search_form").submit();
      }
    }
    
    $(document).ready(function() {
         var optInit = {callback: pageselectCallback};
        optInit['items_per_page'] = <%=pagecount%>;
        optInit['num_display_entries'] = 3;
		optInit['current_page'] = <%=pagenum%> - 1;

		var total_page_count = parseInt(<%=total_count%> / <%=pagecount%>) + 1;
		$("#TotalPages").val(total_page_count);
       
         $("#Pagination").pagination(<%=total_count%>, optInit);
              $("#from_datepicker").datepicker({
                dateFormat: "yy-mm-dd"
        });
        $("#to_datepicker").datepicker({
                dateFormat: "yy-mm-dd"
        });
        
    })
    function change_row(row)
    {
        $("#search_row").val(row);
        $("#search_page").val('<%=pagenum%>');

        $("#search_form").submit();
    }

	function select_page()
	{	
		var selPageno = parseInt($("#selectpageno").val());
		if (isNaN(selPageno))
		{
			$("#selectpageno").val('');
			return;
		}
		var pagetotalcount = parseInt($("#TotalPages").val());
		if (selPageno > pagetotalcount)
		{
			$("#selectpageno").val('');
			return;
		}
		
		$("#search_row").val(<%=pagecount%>);
		$("#search_page").val(selPageno);

		$("#search_form").submit();
	}

    function delete_list(id)
    {
        
        if (confirm("您确定要删除吗?"))
        {
          $("#form_edit_id").attr("value", id);        
          $("#form_edit").submit();
        }
    }
   
    function check_search()
    {
        if ( ($("#to_datepicker").val() != "") && ($("#from_datepicker").val() > $("#to_datepicker").val())) {
            alert("请输入正确期间");
            return;
        }
        
        $("#search_form").submit();
    }

    function clear_search()
    {
		$("#from_datepicker").val("");
		$("#to_datepicker").val("");
		$("#search_name").val("");
        
        $("#search_form").submit();
    }
   
</script>
<body>
	<div class="header">
            <div class="includeDom" include="top.jsp"></div>	
		<div class="nav-list">
			<ul>
                        	<li><a href="integral.jsp"><span>积分管理</span></a></li>
                                <li><a href="user.jsp"><span>会员管理</span></a></li>	
                                <li><a href="loginlist.jsp" class="on"><span>登录管理</span></a></li>
			</ul>
		</div>
		<div class="clear"></div>
	</div>
    <div class="main">
      <div class="side">
		<div class="side-list">
				<h2>登录管理</h2>				
			</div>
        <div class="copyright">
          <p>技术支持: <a href="http://www.bocweb.cn" target="_blank">博采网络</a></p>
        </div>
      </div>
      <div class="content">
        <div class="content-main">
          <div class="content-box">
            <div class="content-title">    
                  <table width="100%">
                    <tr>
                        <td>	
                            <h2>
                              登录管理                             
                            </h2>
                        </td>
                        <td>
                             <div style="align:center" align="center">
                                  <form action="loginlist.jsp" method="post" id="search_form">
                                       昵称: <input type="text" id="search_name" name="search_name" size="15" value="<%=search_name%>" />&nbsp;&nbsp;&nbsp;&nbsp;                                        
                                        期间: <input type="text" id="from_datepicker" readonly name="from_datepicker" size="10" value="<%=tmp_from%>" />&nbsp;~&nbsp;<input type="text" readonly id="to_datepicker" name="to_datepicker" size="10" value="<%=tmp_to%>"/>&nbsp;&nbsp;&nbsp;&nbsp;
                                        <input type="hidden" name="row" id="search_row" value="10" />
                                        <input type="hidden" name="page" id="search_page" value="1" />
                                        <input type="button" id="searchbtn" onclick="check_search();" value="查找" style="width:40px"/>
                                        <input type="button" id="clearbtn" onclick="clear_search();" value="清空" style="width:40px"/>
                                        </form>
                            </div>
                        </td>
                        <td>
                            <div class="page fr">
                                <div>
									<div id="Pagination" class="pagination" style="float:left;"></div>
									<div style="float: right;">
										到&nbsp;<input type="text" name="selectpageno" id="selectpageno" style="width: 40px; height: 20px; text-align: center;" onkeyup="this.value=this.value.replace(/[^\d]/,'')" />&nbsp;/&nbsp;<input type="text" name="TotalPages" id="TotalPages" style="width: 40px; height: 20px; text-align: center;" disabled/>&nbsp;页&nbsp;
										<input type="button" name="btnSelectPageNo" id="btnSelectPageNo" style="width: 45px;height: 25px;" value="确定" onclick="select_page();"/>
									</div>
								</div>                        
                            </div>
                        </td>
                    </tr>
                </table>
                  
                  
              <div class="clear"></div>
              <p><%=total_count%>个符合 |  每页 <a href="#" onclick="change_row('10');">10个</a> » <a href="#" onclick="change_row('25');">25个</a> » <a href="#" onclick="change_row('50')">50个</a></p>
            </div>
            <div class="content-table">
              <table width="100%">
                <tr>
                    <th>姓名</th>
                   <th>昵称</th>
				   <th>工号</th>
                  <th>登录时间</th>
                  <th>登录IP</th>                  
                  <th>操作</th>
                </tr>
                  <% 
                    String blank = new String();
                    blank = "blank";
                    int pos = 0;
                    while (rs.next()) {
                      if (blank.length() == 0) blank = "blank";
                      else blank = "";
                      
                      id = rs.getInt("id");
                      mid = rs.getInt("mid");
                      
                      registdate = rs.getString("logintime");
					  int nDotPos = 0;
					  nDotPos = registdate.lastIndexOf(".");
					  if (nDotPos > 0 )
						  registdate = registdate.substring(0, nDotPos);
                      
                       if ( mid > 0 )
                       {
                      sql = "select * from memberinfo where id=" + mid;
                      rs1 = u_stmt.executeQuery(sql);
                      if (rs1.next()) {
                          name = rs1.getString("name");
                          nickname = rs1.getString("nickname");
						  namepassword = rs1.getString("namepassword");
                        if (name == null || name.length() == 0)
                          name = "";
                      if (nickname == null || nickname.length() == 0)
                          nickname = "";
					  if (namepassword == null || namepassword.length() == 0)
                          namepassword = "";

                        registip = rs1.getString("registipaddress"); 
					  if (registip == null || registip.length() == 0)
                          registip = "-未知IP-";

                      }
                          
                      rs1.close();
                       }
                       else
                       {
                           name = "游客";
                           nickname = "游客";
                       }
                  %>
                <tr class="<%=blank%>">
                    <td><%=nickname%></td>
                  <td><%=name%></a></td>    
				  <td><%=namepassword%></a></td>
                  <td><%=registdate%></td>
                  <td><%=registip%></td>                  
                  <td><a href="logindetail.jsp?id=<%=mid%>">查看历史记录</a></td>
                </tr>
                  <%
                                   }
    rs.close();
    stmt.close();
	u_stmt.close();
    conn.close();
                  %>
               
              </table>
                  <form action="loginlist_delete.jsp" method="post" id="form_edit">
                                <input type="hidden" name="page" value="<%=pagenum%>" />
                                <input type="hidden" name="count" value="<%=pagecount%>" />
                                 <input type="hidden" id="form_edit_id" name="id" value="" />                                
                            </form>
            </div>
          </div>
        </div>
      </div>
    </div>
          
</body>
</html>




