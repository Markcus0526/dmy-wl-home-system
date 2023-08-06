<%-- 
    Document   : ajax
    Created on : Dec 25, 2013, 5:45:32 PM
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="org.json.simple.*" %>
<%@ include file="../connection.jsp" %>
<%@include file="cookie_check.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

	String strID = (request.getParameter("id")== null)?"0":request.getParameter("id");
	String strMID = (request.getParameter("mid")== null)?"0":request.getParameter("mid");
    
    String sql = "select * from share_info where deleted = 0 and id = " + Integer.parseInt(strID) + " and mid = " + Integer.parseInt(strMID);
	JSONObject obj = new JSONObject();
            
    Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery(sql);
	
	if (rs.next())
	{
		String strPath = "";
		String query = "select * from share_data where deleted = 0 and type = 0 and rid = " + Integer.parseInt(strID) + " and mid = " + Integer.parseInt(strMID);
		Statement stmtQuery = conn.createStatement();
		ResultSet rsQuery = stmtQuery.executeQuery(query);
		while(rsQuery.next())
		{
			strPath = strPath + rsQuery.getString("datapath") + "#";
		}

		rsQuery.close();
		stmtQuery.close();
		
		obj.put("success", 1);
		obj.put("id", rs.getInt("id"));
		obj.put("mid", rs.getInt("mid"));
        obj.put("title", rs.getString("title"));
        obj.put("type", rs.getInt("type"));
		obj.put("body", rs.getString("body"));
		obj.put("isvisible", rs.getInt("isvisible"));
		obj.put("ispublic", rs.getInt("ispublic"));
		obj.put("path", strPath);
        out.println(obj.toJSONString());
	}

	rs.close();
    stmt.close();
    conn.close();
%>

<%!
private String getError(String message) {
	JSONObject obj = new JSONObject();
	obj.put("error", 1);
	obj.put("message", message);
	return obj.toJSONString();
}
%>