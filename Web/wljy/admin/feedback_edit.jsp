<%-- 
    Document   : activity_add
    Created on : Dec 25, 2013, 6:27:19 PM
    Author     : KIMSUI
--%>

<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%@page import="java.util.Date"%>
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

    Statement stmt = conn.createStatement();
    String sql = new String();
    ResultSet rs;

    String act = (request.getParameter("act") == "") ? "add" : request.getParameter("act");
    int id = Integer.parseInt((request.getParameter("feedback_id") == "") ? "0" : request.getParameter("feedback_id"), 10);
    //int integral = Integer.parseInt((request.getParameter("feedback_integral") == "") ? "0" : request.getParameter("feedback_integral"), 10);
	int integral = 0;
    int mid = Integer.parseInt((request.getParameter("feedback_mid") == "") ? "0" : request.getParameter("feedback_mid"), 10);
    String page_num = (request.getParameter("tmp_pagenum") == null) ? "0" : request.getParameter("tmp_pagenum");
    String page_count = (request.getParameter("tmp_pagecount") == null) ? "10" : request.getParameter("tmp_pagecount");
    String state = (request.getParameter("tmp_state") == null) ? "10" : request.getParameter("tmp_state");

	Statement mystmt = conn.createStatement();
    sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = 12";
    ResultSet myrs = mystmt.executeQuery(sql);
    if(myrs.next())
 	    integral = myrs.getInt("DEFAULTINTEGRAL");
    myrs.close();
    mystmt.close();

    if (act.equals("evaluate")) {

        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        sql = "UPDATE OPINION set STATE=?, EVALDATE=?, GAININTEGRAL=?, EID=? where deleted = 0 and ID=?";
        PreparedStatement pstmt = conn.prepareStatement(sql);

        pstmt.setInt(1, 1);
        pstmt.setTimestamp(2, d);
        pstmt.setInt(3, integral);
        pstmt.setInt(4, UserId);
        pstmt.setInt(5, id);

        pstmt.execute();
        stmt.close();

        int reason_id = 12;
        Statement u_stmt1 = conn.createStatement();

        int max_id = 0;
        u_stmt1 = conn.createStatement();
        sql = "select MAX(id) as maxid from INTEGRALLOG";
        ResultSet rs1 = u_stmt1.executeQuery(sql);
        if (rs1.next()) {
            max_id = rs1.getInt("maxid");
        }
        rs1.close();
        u_stmt1.close();

        sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, max_id + 1);
        pstmt.setInt(2, mid);
        pstmt.setTimestamp(3, d);
        pstmt.setInt(4, integral);
        pstmt.setInt(5, reason_id);
        pstmt.setInt(6, 1);
        pstmt.execute();
        pstmt.close();

        u_stmt1 = conn.createStatement();
        sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + integral + " WHERE deleted = 0 and ID = " + mid;
        u_stmt1.execute(sql);
        u_stmt1.close();
    } else if (act.equals("edit")) {
        /*
        sql = "update PRODUCT_INFO set NAME = ?, MARKET_PRICE = ?, INTEGRAL_PRICE = ?, TOTAL_SECURE = ?, PROPERTY = ?, DETAIL = ? where id=" + id;
        PreparedStatement pstmt = conn.prepareStatement(sql); 
        pstmt.setString(1, product_name);
        pstmt.setInt(2, product_marketprice);
        pstmt.setInt(3, product_integralprice);
        pstmt.setInt(4, product_totalsecure);
        pstmt.setNClob(5, nclob1);
        pstmt.setNClob(6, nclob2);
        
        pstmt.execute();
        
        if ( imagechanged == 1 ) {
        
        sql = "select MAX(ID) from PRODUCT_IMAGE";
        rs = stmt.executeQuery(sql);
        int nextID = 0;
        if (rs.next())
        nextID = rs.getInt(1);
        nextID++;
        rs.close();
        
        int xxx = 0;
        int[] image_ids = new int[7];
        
        sql = "select ID from PRODUCT_IMAGE where PID="+id+" order by id";
        rs = stmt.executeQuery(sql);
        while ( rs.next() )
        {
        image_ids[xxx] = rs.getInt("ID");
        xxx++;
        }
        
        for ( i = 0; i < 7; i++ )
        {
        if ( !imagepath[i].equals("") )
        {
        if ( i == 0 )
        tmpmain = 1;
        else
        tmpmain = 0;
        File fileTo = new File("webapps/wljy/upload_data/product/" + id + "_" + imagepath[i].substring(4));
        File fileFrom = new File("webapps/wljy/upload_data/product/" + imagepath[i]);
        fileTo.delete();
        File fileTo1 = new File("webapps/wljy/upload_data/product/" + id + "_" + imagepath[i].substring(4));
        fileFrom.renameTo(fileTo1);
        
        sql = "update PRODUCT_IMAGE set DATAPATH = 'upload_data/product/" + id + "_" + imagepath[i].substring(4)+"' where ID="+image_ids[i];
        stmt.executeQuery(sql);
        }
        }
        }
        
        
        pstmt.close();       
         */
    } else if (act.equals("delete")) {

        if (id != 0) {
            //sql = "delete from OPINION where id = " + id;
            sql = "update OPINION set deleted = 1 where id = " + id;
            stmt.executeQuery(sql);

        }
        stmt.close();
    } else if (act.equals("deleteall")) {
        String ids = request.getParameter("ids") == null ? "" : request.getParameter("ids");
        if (ids.length() > 0) {
            String[] id_data = ids.split(",");
            if (id_data.length > 0) {
                for (int i = 0; i < id_data.length; i++) {
                    if (!id_data[i].equals("0")) {
                        sql = "update OPINION set deleted = 1 where id = " + id_data[i];
                        stmt.executeQuery(sql);

                    }

                }
            }
        }
    }
    out.println("<script>window.location.href='feedback.jsp?state=" + state + "&page=" + page_num + "&count=" + page_count + "';</script>");
    conn.close();



%>
