<%-- 
    Document   : contact
    Created on : 10-Dec-2013, 10:01:33
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Date"%>
<%@page import = "org.apache.commons.fileupload.FileUpload" %>
<%@page import = "org.apache.commons.fileupload.DiskFileUpload" %>
<%@page import = "org.apache.commons.fileupload.FileItem" %>
<%@page import = "java.io.File" %>
<%@page import = "java.io.BufferedInputStream" %>
<%@page import = "java.io.BufferedOutputStream" %>
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

    String info_id = "feed_id";
    String feed_title = "feed_title";
    String feed_body = "feed_body";
    String filePath = "upload_data/feedback/";
    String fileName = "";

    boolean haveData = false;

    Statement stmt = conn.createStatement();

    String sql = "select MAX(ID) from OPINION";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;

    rs.next();
    newID = rs.getInt(1);
    newID++;

    java.sql.NClob nclob_body = conn.createNClob();
    byte[] utf8bytes;

    if (FileUpload.isMultipartContent(request)) {

        String temporaryDir = "C:\\";

        org.apache.commons.fileupload.DiskFileUpload fileUpload = new org.apache.commons.fileupload.DiskFileUpload();
        fileUpload.setRepositoryPath(temporaryDir);

        fileUpload.setSizeMax(15 * 1024 * 1024);
        fileUpload.setSizeThreshold(1024 * 100);

        int fileIdx = 0;

        java.util.List fileItemList = fileUpload.parseRequest(request);
        for (int i = 0; i < fileItemList.size(); i++) {

            FileItem fileItem = (FileItem) fileItemList.get(i);
            if (fileItem.isFormField()) {
                String fieldName = fileItem.getFieldName();
                if (fieldName.equals(feed_title)) {
                    feed_title = fileItem.getString("UTF-8");
                } else if (fieldName.equals(feed_body)) {
                    feed_body = fileItem.getString("UTF-8");
                    utf8bytes = feed_body.getBytes("UTF8");
                    nclob_body.setString(1, new String(utf8bytes, "UTF8"));
                } else if (fieldName.equals(info_id)) {
                    info_id = fileItem.getString("UTF-8");
                }
            } else {
                if (fileItem.getSize() > 0) {

                    filePath = "upload_data/feedback/" + makeUploadDirName() + "/";
                    if (info_id.equals("0")) {
                        fileName = newID + "_" + makeUploadFileNamePrefix(fileItem.getName());
                    } else {
                        fileName = info_id + "_" + makeUploadFileNamePrefix(fileItem.getName());
                    }

                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                        fileItem.write(uploadedFile);
                        haveData = true;

                    } catch (IOException ex) {
                    }
                    fileIdx++;
                }
            }
        }
    }

    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

    if (info_id.equals("0")) {
        sql = "Insert into OPINION (ID, MID, TITLE, BODY, DATAPATH, STATE, GAININTEGRAL, POSTDATE) VALUES (?, ?, ?, ?, ?, 0, -1, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, UserId);
        pstmt.setString(3, feed_title);
        pstmt.setNClob(4, nclob_body);
        if (!haveData) {
            pstmt.setString(5, "");
        } else {
            pstmt.setString(5, filePath + fileName);
        }
        pstmt.setTimestamp(6, d);

        pstmt.execute();
        pstmt.close();

        int reason_id = 11;
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
        sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + def_reason + " WHERE ID = " + UserId;
        u_stmt1.execute(sql);
        u_stmt1.close();
    } else {
        if (haveData) {
            sql = "UPDATE OPINION SET TITLE = ?, BODY = ?, DATAPATH = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, feed_title);
            pstmt.setNClob(2, nclob_body);
            pstmt.setString(3, filePath + fileName);
            pstmt.setTimestamp(4, d);

            pstmt.execute();
            pstmt.close();
        } else {
            sql = "UPDATE OPINION SET TITLE = ?, BODY = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, feed_title);
            pstmt.setNClob(2, nclob_body);
            pstmt.setTimestamp(3, d);

            pstmt.execute();
            pstmt.close();
        }
    }

    conn.close();

    out.println("<script>window.location.href='myidea.jsp';</script>");
%>
