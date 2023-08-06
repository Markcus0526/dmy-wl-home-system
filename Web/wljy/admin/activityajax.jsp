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
    
    String sql = "select * from activity_info where deleted = 0 and id = " + Integer.parseInt(strID);
	JSONObject obj = new JSONObject();
            
    Statement stmt = conn.createStatement();
	ResultSet rs = stmt.executeQuery(sql);
	
	if (rs.next())
	{
		String strPath = "";
		String query = "select * from activity_image where deleted = 0 and aid = " + Integer.parseInt(strID);
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
        obj.put("title", rs.getString("title"));
        obj.put("isselect", rs.getInt("isselected"));
		obj.put("isvisible", rs.getInt("isvisible"));
		obj.put("body", rs.getString("body"));
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