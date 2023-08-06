<%-- 
    Document   : activity_add
    Created on : Dec 25, 2013, 6:27:19 PM
    Author     : KIMSUI
--%>

<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@ include file="connection.jsp" %>
<%@page import="java.util.Date"%>
<%
    request.setCharacterEncoding("UTF-8");

	Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyid"))
           {
                 tmp_str=name.substring(pos+1);
                 break;
           }
       }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
  
	String pids = request.getParameter("pid");
	String ids[];
	ids = pids.split(",");

	int id = 0;
	int total_jifen = 0;
	int current_jifen = 0;
    String sql = new String();
	String updatequery = "";
    Statement stmt = conn.createStatement();

	for(int i=0; i< ids.length; i++)
	{
		if (ids[i] == null || ids[i] == "")
			continue;

		id = Integer.parseInt(ids[i], 10);
		//Get the order product info from order table.
		sql = "select * from ORDER_PRODUCT where id = " + id;
		ResultSet rs1 = stmt.executeQuery(sql);
		if (rs1.next()) {
			total_jifen += rs1.getInt("count") * rs1.getInt("price");
		}
		rs1.close();

		if (updatequery != "") {
			updatequery += " OR ";
		}
		updatequery += "id = " + ids[i];
	}

	//Get the order product info from order table.
	sql = "select * from MEMBERINFO where id = " + UserId;
	ResultSet rs2 = stmt.executeQuery(sql);

	if (rs2.next()) {
		current_jifen = rs2.getInt("integral");
	}
	rs2.close();

	//Check if current jifen is not enough to buy the product.
	if (current_jifen < total_jifen) {
		out.println("<script>alert('积分不够!');window.history.go(-1);</script>");
		return;
	}
	
	//Update ordered product state as "ordered"
    ResultSet rs;

    if (ids.length != 0) {
        sql = "UPDATE ORDER_PRODUCT SET state = 0 where " + updatequery;
        stmt.executeQuery(sql);
    }

	sql = "select * from order_product where " + updatequery;
	ResultSet myrs = stmt.executeQuery(sql);

	int mid = 0;
	int user_integral = 0, price = 0, count = 0;
	Statement mystmt = conn.createStatement();
	while (myrs.next()) {
		mid = myrs.getInt("mid");
		sql = "select * from memberinfo where deleted = 0 and id=" + mid;
		ResultSet myrs1 = mystmt.executeQuery(sql);

		while (myrs1.next()) {
			user_integral = myrs1.getInt("integral");
		}
		myrs1.close();

		price = myrs.getInt("price");
		count = myrs.getInt("count");
		user_integral = user_integral - price * count;
		sql = "update memberinfo set integral = " + user_integral + " where deleted = 0 and id = " + mid;
		mystmt.execute(sql);

		Date tmp = new Date();
		java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

		int reason_id = 15;
		PreparedStatement pstmt = conn.prepareStatement(sql);

		int max_id = 0;
		Statement u_stmt1 = conn.createStatement();
		u_stmt1 = conn.createStatement();
		sql = "select MAX(id) as maxid from INTEGRALLOG";
		ResultSet rs3 = u_stmt1.executeQuery(sql);
		if (rs3.next()) {
			max_id = rs3.getInt("maxid");
		}
		rs3.close();
		u_stmt1.close();

		sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
		pstmt = conn.prepareStatement(sql);
		pstmt.setInt(1, max_id + 1);
		pstmt.setInt(2, mid);
		pstmt.setTimestamp(3, d);
		pstmt.setInt(4, (-1) * price * count);
		pstmt.setInt(5, reason_id);
		pstmt.setInt(6, 1);
		pstmt.execute();
		pstmt.close();		
	}
	myrs.close();
	mystmt.close();

	stmt.close();
    conn.close();
     
    out.println("<script>alert('兑换成功!');window.location.href='mycart.jsp';</script>");

%>
