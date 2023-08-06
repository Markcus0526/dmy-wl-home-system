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
    String type = (request.getParameter("type")== null)?"":request.getParameter("type");
    String act = (request.getParameter("act")== null)?"":request.getParameter("act");
    String name = "";
    String visible = (request.getParameter("visible")== null)?"":request.getParameter("visible");
    String value = (request.getParameter("value")== null)?"0":request.getParameter("value");
    String id = (request.getParameter("id")== null)?"0":request.getParameter("id");
    
    String sql = "";
            JSONObject obj = new JSONObject();
            
    Statement stmt = conn.createStatement();
    
    if (type.equals("activity") )
    {
        name = "activity_info";        
    }
   else if (type.equals("faq")) {
	   name = "problem_qinfo";
   }
   else if (type.equals("study")) {
	   name = "study_qinfo";
   }
   else if (type.equals("share")) {
	   name = "share_info";
   }
   else if (type.equals("commodity")) {
	   name = "product_info";
   }
   else if (type.equals("member")) {
	   name = "memberinfo";
   }
    if (act.equals("visible")) {
        sql = "update " + name + " set isvisible=" +value + " where id=" + id;
        stmt.executeQuery(sql);
        obj.put("success", 1);
        obj.put("id", id);
        obj.put("visible", value);
        out.println(obj.toJSONString());
        stmt.close();
        conn.close();
     }
       else if (act.equals("select")) {
			sql = "update " + name + " set isselected=" +value + " where id=" + id;
			stmt.executeQuery(sql);
			
			if (type.equals("activity") )
			{
				int nValue = Integer.parseInt(value, 10);
				int nID = Integer.parseInt(id, 10);
				if (nValue == 1)
				{
					int MID = 0;
					Statement stmtMID = conn.createStatement();
					sql = "SELECT * FROM activity_info WHERE ID = " + nID;
					ResultSet rsMID = stmtMID.executeQuery(sql);
					if ( rsMID != null && rsMID.next() )
					{
						MID = rsMID.getInt("MID");
					}
					rsMID.close();
					stmtMID.close();

					if (MID != 0 )				
					{
						Date tmp = new Date();
						java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

						int JingHuaIntegral = 0;
						Statement mystmt = conn.createStatement();
						sql = "SELECT * FROM integralreason WHERE ID = 4";
						ResultSet myrs = mystmt.executeQuery(sql);
						if ( myrs != null && myrs.next() )
						{
							JingHuaIntegral = myrs.getInt("DEFAULTINTEGRAL");
						}
						myrs.close();
						mystmt.close();

						int logCount = 0;
						Statement stmtCount = conn.createStatement();
						sql = "select MAX(id) as maxid from INTEGRALLOG";
						ResultSet rsCount = stmtCount.executeQuery(sql);
						if (rsCount.next()) {
							logCount = rsCount.getInt("maxid");
						}
						rsCount.close();
						stmtCount.close();

						sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
						PreparedStatement pstmtInsert = conn.prepareStatement(sql);
						pstmtInsert.setInt(1, logCount + 1);
						pstmtInsert.setInt(2, MID);
						pstmtInsert.setTimestamp(3, d);
						pstmtInsert.setInt(4, JingHuaIntegral);
						pstmtInsert.setInt(5, 4);
						pstmtInsert.setInt(6, 1);
						pstmtInsert.execute();
						pstmtInsert.close();

						Statement stmtMember = conn.createStatement();
						sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + Math.abs(JingHuaIntegral) + " WHERE ID = " + MID;
						stmtMember.execute(sql);
						stmtMember.close();
					}
				}
			}

			obj.put("success", 1);
			obj.put("id", id);
			obj.put("select", value);
			out.println(obj.toJSONString());
			stmt.close();
			conn.close();
       }
       else if (act.equals("public")) {
			sql = "update " + name + " set ispublic=" +value + " where id=" + id;
			stmt.executeQuery(sql);
			obj.put("success", 1);
			obj.put("id", id);
			obj.put("public", value);
			out.println(obj.toJSONString());
			stmt.close();
			conn.close();
       }
    
    if ( type.equals("commodity") && act.equals("edit") )
    {   
        sql = "select * from PRODUCT_INFO where ID="+id;
        ResultSet rs = stmt.executeQuery(sql);

        if ( rs.next() )
        {
            obj.put("error", 0);
            obj.put("product_id", rs.getInt("ID"));
            obj.put("product_name", rs.getString("NAME"));
            obj.put("product_marketprice", rs.getInt("MARKET_PRICE"));
            obj.put("product_integralprice", rs.getInt("INTEGRAL_PRICE"));
            obj.put("product_totalsecure", rs.getInt("TOTAL_SECURE"));
            obj.put("product_isvisible", rs.getInt("ISVISIBLE"));
            obj.put("product_comprice", rs.getInt("COMPRICE"));            
            
            obj.put("ispublic", rs.getInt("ISPUBLIC"));
            
            int clob_length = 0;
            Clob clob = null;
            String product_property = "";
            String product_detail = "";
            
            clob = rs.getClob("PROPERTY");
            clob_length = (clob == null)?-1:(int)clob.length();

            if (clob_length < 0)
                product_property = "";
             else 
                product_property = clob.getSubString(1, clob_length);    


            clob = rs.getClob("DETAIL");
            clob_length = (clob == null)?-1:(int)clob.length();

            if (clob_length < 0)
                product_detail = "";
             else 
                product_detail = clob.getSubString(1, clob_length);
            
            obj.put("product_property", product_property);
            obj.put("product_detail", product_detail);
            rs.close();
            
            sql = "select * from PRODUCT_IMAGE where PID="+id+" order by id";
            rs = stmt.executeQuery(sql);
            
            int xx = 0;
            
            while (rs.next())
            {
                obj.put("product_image_"+xx, rs.getString("DATAPATH"));
                xx++;
            }
            
            out.println(obj.toJSONString());
        }
        else
        {
            out.println(getError("Error ID!"));
        }
        
        
        stmt.close();
        conn.close();
    }

	if ( type.equals("member") && act.equals("privilege") )
    {   
        sql = "update memberinfo set privilege = " + Integer.parseInt(value) + " where ID="+id;
        stmt.executeQuery(sql);
		obj.put("success", 1);
        obj.put("privilege", value);
		obj.put("id", id);
            
		out.println(obj.toJSONString());
        
        
        stmt.close();
        conn.close();
    }
    
    if ( type.equals("feedback") && act.equals("edit") )
    {
        sql = "select * from OPINION where ID="+id;
        ResultSet rs = stmt.executeQuery(sql);
        

        if ( rs.next() )
        {
            obj.put("error", 0);
            obj.put("feedback_id", rs.getInt("ID"));
            obj.put("feedback_title", rs.getString("TITLE"));
            obj.put("product_marketprice", rs.getInt("MARKET_PRICE"));
            obj.put("product_integralprice", rs.getInt("INTEGRAL_PRICE"));
            obj.put("product_totalsecure", rs.getInt("TOTAL_SECURE"));
            
            int clob_length = 0;
            Clob clob = null;
            String product_property = "";
            String product_detail = "";
            
            clob = rs.getClob("PROPERTY");
            clob_length = (clob == null)?-1:(int)clob.length();

            if (clob_length < 0)
                product_property = "";
             else 
                product_property = clob.getSubString(1, clob_length);    


            clob = rs.getClob("DETAIL");
            clob_length = (clob == null)?-1:(int)clob.length();

            if (clob_length < 0)
                product_detail = "";
             else 
                product_detail = clob.getSubString(1, clob_length);
            
            obj.put("product_property", product_property);
            obj.put("product_detail", product_detail);
            rs.close();
            
            sql = "select * from PRODUCT_IMAGE where PID="+id+" order by id";
            rs = stmt.executeQuery(sql);
            
            int xx = 0;
            
            while (rs.next())
            {
                obj.put("product_image_"+xx, rs.getString("DATAPATH"));
                xx++;
            }
            
            out.println(obj.toJSONString());
        }
        else
        {
            out.println(getError("Error ID!"));
        }
        
        
        stmt.close();
        conn.close();
    }

%>

<%!
private String getError(String message) {
	JSONObject obj = new JSONObject();
	obj.put("error", 1);
	obj.put("message", message);
	return obj.toJSONString();
}
%>