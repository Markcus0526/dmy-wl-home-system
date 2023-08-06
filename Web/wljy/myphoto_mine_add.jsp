<%-- 
    Document   : contact
    Created on : 10-Dec-2013, 10:01:33
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@page import="java.util.Date"%>
<%@page import = "java.io.File" %>
<%@page import = "java.io.IOException" %>
<%@ include file="connection.jsp" %>
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

    request.setCharacterEncoding("UTF-8");
	
	String strID = request.getParameter("id")== null?"0":request.getParameter("id");

	String strTitle = "";
	String querySql = "select * from member_data where id = " + Integer.parseInt(strID);
	Statement querySTMT = conn.createStatement();
	ResultSet queryRS = querySTMT.executeQuery(querySql);
	if (queryRS.next())
	{
		strTitle = queryRS.getString("title");
	}
	queryRS.close();
	querySTMT.close();

	int nImgDataID = Integer.parseInt(strID, 10);

	Statement stmt = conn.createStatement();

    String sql = "select MAX(ID) from SHARE_INFO";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;
    while (rs.next()) {
        newID = rs.getInt(1);
    }

	sql = "select MAX(ID) from SHARE_DATA";
	rs = stmt.executeQuery(sql);
	int sdID = 0;
	while (rs.next()) {
		sdID = rs.getInt(1);
		break;
	}

	rs.close();
	stmt.close();

	newID = newID + 1;
	sdID = sdID + 1;

	java.sql.NClob nclob_body = conn.createNClob();
	Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
	sql = "Insert into SHARE_INFO (ID, MID, TITLE, TYPE, BODY, POSTDATE, ISVISIBLE) VALUES (?, ?, ?, ?, ?, ?, ?)";
	PreparedStatement pstmt = conn.prepareStatement(sql);
	pstmt.setInt(1, newID);
	pstmt.setInt(2, UserId);
	pstmt.setString(3, strTitle);
	pstmt.setInt(4, 1);
	pstmt.setNClob(5, nclob_body);
	pstmt.setTimestamp(6, d);
	pstmt.setInt(7, 1);

	pstmt.execute();
	pstmt.close();

	querySql = "select * from member_image where rid = " + Integer.parseInt(strID);
	querySTMT = conn.createStatement();
	queryRS = querySTMT.executeQuery(querySql);
	while (queryRS.next())
	{		
		String strImgPath = "";
		strImgPath = queryRS.getString("datapath");

		sql = "Insert into SHARE_DATA (ID, RID, MID, TYPE, DATAPATH) VALUES (?, ?, ?, ?, ?)";
		PreparedStatement ps = conn.prepareStatement(sql);
		ps.setInt(1, sdID);
		ps.setInt(2, newID);
		ps.setInt(3, UserId);
		ps.setInt(4, 0);
		ps.setString(5, strImgPath);
		ps.execute();
		ps.close();

		sdID++;
	}
	
	queryRS.close();
	querySTMT.close();

	int reason_id = 8;
	int def_reason = 1;
	Statement u_stmt1 = conn.createStatement();
	sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = " + reason_id;
	ResultSet rs1 = u_stmt1.executeQuery(sql);
	if (rs1.next()) {
		def_reason = rs1.getInt("DEFAULTINTEGRAL");
	}
	rs1.close();
	u_stmt1.close();

	int max_id = 0;
	u_stmt1 = conn.createStatement();
	sql = "select MAX(id) as maxid from INTEGRALLOG";
	rs1 = u_stmt1.executeQuery(sql);
	if (rs1.next()) {
		max_id = rs1.getInt("maxid");
	}
	rs1.close();
	u_stmt1.close();

	sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
	pstmt = conn.prepareStatement(sql);
	pstmt.setInt(1, max_id + 1);
	pstmt.setInt(2, UserId);
	pstmt.setTimestamp(3, d);
	pstmt.setInt(4, def_reason);
	pstmt.setInt(5, reason_id);
	pstmt.setInt(6, 1);
	pstmt.execute();
	pstmt.close();

	u_stmt1 = conn.createStatement();
	sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + def_reason + " WHERE deleted = 0 and ID = " + UserId;
	u_stmt1.execute(sql);
	u_stmt1.close();
    conn.close();

	out.println("<script>alert('图片分享成功');</script>");
    out.println("<script>window.location.href='myphoto.jsp';</script>");
%>
