<%-- 
    Document   : single_addinfo
    Created on : Jan 5, 2014, 10:08:52 AM
    Author     : Hercules
--%>

<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
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

    String spage = request.getParameter("page");
    if (spage == null) {
        spage = "1";
    }
    String scount = request.getParameter("count");
    if (spage == null) {
        scount = "10";
    }

    Statement stmt = conn.createStatement();
    String sql = new String();
    ResultSet rs;
    String act = (request.getParameter("act") == null) ? "add" : request.getParameter("act");
    String play_title = (request.getParameter("tmp_title") == null) ? "" : request.getParameter("tmp_title");
    String play_body = (request.getParameter("body") == null) ? "" : request.getParameter("body");

    String sispublic = request.getParameter("ispublic");

    String isselect = (request.getParameter("tmp_select") == null) ? "0" : request.getParameter("tmp_select");
    String isvisible = (request.getParameter("tmp_visible") == null) ? "0" : request.getParameter("tmp_visible");
    String fileimagepath = (request.getParameter("tmp_image") == null) ? "0" : request.getParameter("tmp_image");
    int id = Integer.parseInt((request.getParameter("id") == null) ? "0" : request.getParameter("id"), 10);
    String page_num = (request.getParameter("tmp_pagenum") == "") ? "0" : request.getParameter("tmp_pagenum");
    String page_count = (request.getParameter("tmp_pagecount") == "") ? "10" : request.getParameter("tmp_pagecount");

    java.sql.NClob nclob = conn.createNClob();
    byte[] utf8bytes = play_body.getBytes("UTF8");
    nclob.setString(1, new String(utf8bytes, "UTF8"));

    if (fileimagepath.length() > 3) {
        fileimagepath = fileimagepath.substring(3);
    }
    String imagepath = new String();

    String imageChanged = request.getParameter("imageChanged");

    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

    if (act.equals("add")) {
        sql = "select MAX(ID) from ACTIVITY_INFO";
        rs = stmt.executeQuery(sql);

        int newID = 0;

        if (rs.next()) {
            newID = rs.getInt(1);
        }

        rs.close();

        newID++;

        if (fileimagepath != null && fileimagepath.length() > 0) {

            int ind = fileimagepath.indexOf("_tmp_") + 5;


            String tmpPath = "upload_data/activity/" + makeUploadDirName()  + "/";

            File tmpDir = new File("webapps/wljy/" + tmpPath);
            if (!tmpDir.exists()) {
                tmpDir.mkdir();
            }

            imagepath = tmpPath + UserId + "_" + newID + "_" + makeUploadFileNamePrefix(fileimagepath);//(tmpStr.substring(24, 28)) + (tmpStr.substring(4, 7)) + (tmpStr.substring(8, 10)) + "_" + fileimagepath.substring(ind);
            File fileTo = new File("webapps/wljy/" + imagepath);
            File fileFrom = new File("webapps/wljy/" + fileimagepath);
            fileFrom.renameTo(fileTo);
            File fileFrom1 = new File("webapps/wljy/" + fileimagepath);
            fileFrom1.delete();
            imageresize(fileTo.getPath());
        }

        sql = "Insert into ACTIVITY_INFO (ID, MID, TITLE, TYPE, BODY, POSTDATE, ISVISIBLE, ISSELECTED, DELETED, ISPUBLIC) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, 0);
        pstmt.setString(3, play_title);
        pstmt.setInt(4, 1);
        pstmt.setNClob(5, nclob);
        pstmt.setTimestamp(6, d);
        pstmt.setInt(7, Integer.parseInt(isvisible, 10));
        pstmt.setInt(8, Integer.parseInt(isselect, 10));

        pstmt.setInt(9, Integer.parseInt(sispublic));

        pstmt.execute();
        rs.close();
        //pstmt.close();

        sql = "select MAX(ID) from ACTIVITY_IMAGE";
        rs = stmt.executeQuery(sql);
        int nextID = 0;
        if (rs.next()) {
            nextID = rs.getInt(1);
        }
        nextID++;

        sql = "insert into activity_image (id, aid, datapath, DELETED) values (?,?,?,0)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, nextID);
        pstmt.setInt(2, newID);
        pstmt.setString(3, imagepath);
        pstmt.execute();
        rs.close();
        pstmt.close();
        stmt.close();
    } else if (act.equals("edit")) {

        sql = "update ACTIVITY_INFO set title = ? , body = ?, ISVISIBLE = ?, ISSELECTED = ?, ISPUBLIC = ? where deleted = 0 and id=" + id;
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, play_title);
        pstmt.setNClob(2, nclob);

        pstmt.setInt(3, Integer.parseInt(isvisible, 10));
        pstmt.setInt(4, Integer.parseInt(isselect, 10));

        pstmt.setInt(5, Integer.parseInt(sispublic));

        pstmt.execute();

			int nValue = Integer.parseInt(isselect, 10);
			if (nValue == 1)
			{
				int MID = 0;
				Statement stmtMID = conn.createStatement();
				sql = "SELECT * FROM activity_info WHERE ID = " + id;
				ResultSet rsMID = stmtMID.executeQuery(sql);
				if ( rsMID != null && rsMID.next() )
				{
					MID = rsMID.getInt("MID");
				}
				rsMID.close();
				stmtMID.close();

				if (MID != 0 )				
				{
					Date tmpToday = new Date();
					java.sql.Timestamp dToday = new java.sql.Timestamp(tmpToday.getYear(), tmpToday.getMonth(), tmpToday.getDate(), tmpToday.getHours(), tmpToday.getMinutes(), tmpToday.getSeconds(), 0);

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
					pstmtInsert.setTimestamp(3, dToday);
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

        if (imageChanged.equals("1")) {
            int ind = fileimagepath.indexOf("_tmp_") + 5;

            Date today = new Date();

            String tmpStr = today.toString();

            String tmpPath = "upload_data/activity/" + makeUploadDirName()  + "/";

            File tmpDir = new File("webapps/wljy/" + tmpPath);
            if (!tmpDir.exists()) {
                tmpDir.mkdir();
            }

            imagepath = tmpPath + UserId + "_" + id + "_" + makeUploadFileNamePrefix(fileimagepath);//(tmpStr.substring(24, 28)) + (tmpStr.substring(4, 7)) + (tmpStr.substring(8, 10)) + "_" + fileimagepath.substring(ind);
            File fileTo = new File("webapps/wljy/" + imagepath);
            File fileFrom = new File("webapps/wljy/" + fileimagepath);
            fileFrom.renameTo(fileTo);
            File fileFrom1 = new File("webapps/wljy/" + fileimagepath);
            fileFrom1.delete();
            imageresize(fileTo.getPath());

            sql = "select count(*) as cnt from activity_image where deleted = 0 and aid=" + id;
            rs = stmt.executeQuery(sql);
            int tmp_cnt = 0;
            if (rs.next()) {
                tmp_cnt = rs.getInt("cnt");
            }
            rs.close();

            if (tmp_cnt > 0) {
                sql = "select datapath from activity_image where deleted = 0 and aid=" + id;
                rs = stmt.executeQuery(sql);
                String oldPath = "";
                if (rs.next()) {
                    oldPath = rs.getString("datapath");
                }
                if (oldPath != "") {
                    File oldFile = new File("webapps/wljy/" + oldPath);
                    oldFile.delete();
                }


                sql = "update activity_image set datapath = ? where deleted = 0 and aid = " + id;
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, imagepath);
                pstmt.execute();
            } else {
                sql = "select MAX(ID) from ACTIVITY_IMAGE";
                rs = stmt.executeQuery(sql);
                int nextID = 0;
                if (rs.next()) {
                    nextID = rs.getInt(1);
                }
                nextID++;

                sql = "insert into activity_image (id, aid, datapath, deleted) values (?,?,?, 0)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, nextID);
                pstmt.setInt(2, id);
                pstmt.setString(3, imagepath);
                pstmt.execute();
                rs.close();
                pstmt.close();
                stmt.close();
            }
        }

        pstmt.close();

        if (Integer.parseInt(isselect, 10) == 1) {
            int mid = 0;
            sql = "select mid from ACTIVITY_INFO where deleted = 0 and id = " + id;
            Statement u_stmt1 = conn.createStatement();
            ResultSet rs1 = u_stmt1.executeQuery(sql);
            if (rs1.next()) {
                mid = rs1.getInt("mid");
            }
            rs1.close();
            u_stmt1.close();

            /* FixME
            int reason_id = 4;
            int def_reason = 1;
            u_stmt1 = conn.createStatement();
            sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = "+reason_id;
            rs1 = u_stmt1.executeQuery(sql);
            if(rs1.next())
            def_reason = rs1.getInt("DEFAULTINTEGRAL");
            rs1.close();
            u_stmt1.close();
            
            int max_id = 0;
            u_stmt1 = conn.createStatement();
            sql = "select MAX(id) as maxid from INTEGRALLOG";
            rs1 = u_stmt1.executeQuery(sql);
            if(rs1.next())
            max_id = rs1.getInt("maxid");
            rs1.close();
            u_stmt1.close();
            
            sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, max_id + 1);
            pstmt.setInt(2, mid);
            pstmt.setTimestamp(3, d);
            pstmt.setInt(4, def_reason);
            pstmt.setInt(5, reason_id);
            pstmt.setInt(6, 1);
            pstmt.execute();
            pstmt.close();
            
            u_stmt1 = conn.createStatement();
            sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + def_reason + " WHERE deleted = 0 ID = " + mid;
            u_stmt1.execute(sql);
            u_stmt1.close();
             */
        }

    } else if (act.equals("delete")) {
        if (id != 0) {
            //sql = "delete from activity_info where id = " + id;
            sql = "update activity_info set deleted = 1 where id = " + id;
            stmt.executeQuery(sql);

            //sql = "delete from activity_image where aid = " + id;
            sql = "update activity_image set deleted = 1 where id = " + id;
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
                        sql = "update activity_info set deleted = 1 where id = " + id_data[i];
                        stmt.executeQuery(sql);


                        sql = "update activity_image set deleted = 1 where id = " + id_data[i];
                        stmt.executeQuery(sql);
                    }

                }
            }
        }
    }

    conn.close();

    out.println("<script>window.location.href='single.jsp?page=" + spage + "&row=" + scount + "';</script>");

%>
