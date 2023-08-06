<%-- 
    Document   : feedback
    Created on : 2014/1/21, 下午 01:34:21
    Author     : kimsui
--%>

<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.util.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%@page import = "org.apache.commons.fileupload.FileUpload" %>
<%@page import = "org.apache.commons.fileupload.DiskFileUpload" %>
<%@page import = "org.apache.commons.fileupload.FileItem" %>
<%@page import = "java.io.File" %>
<%@page import = "java.io.BufferedInputStream" %>
<%@page import = "java.io.BufferedOutputStream" %>
<%@page import = "java.io.IOException" %>
<%
    request.setCharacterEncoding("UTF-8");
    JSONObject obj = new JSONObject();
    String sql = ";";
    Statement stmt = conn.createStatement();
    ResultSet rs, rs1;
    java.sql.NClob nclob_body = conn.createNClob();
    byte[] utf8bytes;
    String userid = "0";
    String feed_title = "feed_title";
    String feed_body = "feed_body";
    String filePath = "upload_data/feedback/";
    String fileName = "";

    sql = "select MAX(ID) from OPINION";
    rs = stmt.executeQuery(sql);

    int newID = 0;
    rs.next();
    newID = rs.getInt(1);
    newID++;
    rs.close();

    if (FileUpload.isMultipartContent(request)) {

        String temporaryDir = "C:\\";

        org.apache.commons.fileupload.DiskFileUpload fileUpload = new org.apache.commons.fileupload.DiskFileUpload();
        fileUpload.setRepositoryPath(temporaryDir);

        fileUpload.setSizeMax(15 * 1024 * 1024);
        fileUpload.setSizeThreshold(1024 * 100);

        int fileIdx = 0;

        userid = "0";
        feed_title = "feed_title";
        feed_body = "feed_body";
        filePath = "upload_data/feedback/";
        fileName = "";

        java.util.List fileItemList = fileUpload.parseRequest(request);
        for (int i = 0; i < fileItemList.size(); i++) {

            FileItem fileItem = (FileItem) fileItemList.get(i);
            if (fileItem.isFormField()) {
                String fieldName = fileItem.getFieldName();
                if (fieldName.equals("title")) {
                     feed_title = fileItem.getString("UTF-8");
                } else if (fieldName.equals("body")) {
                    feed_body = fileItem.getString("UTF-8");
                    utf8bytes = feed_body.getBytes("UTF8");
                    nclob_body.setString(1, new String(utf8bytes, "UTF8"));
                } else if (fieldName.equals("userid")) {
                    userid = fileItem.getString("UTF-8");
                }
            } else {
                if (fileItem.getSize() > 0) {
                    filePath = "upload_data/feedback/" + makeUploadDirName() + "/";
                    fileName = newID + "_" + makeUploadFileNamePrefix(fileItem.getName());

                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                        fileItem.write(uploadedFile);
                    } catch (IOException ex) {
                    }
                    fileIdx++;
                }
            }
        }
    } else {
        feed_title = (request.getParameter("title") == null) ? "" : request.getParameter("title");
        userid = (request.getParameter("userid") == null) ? "0" : request.getParameter("userid");
        feed_body = (request.getParameter("body") == null) ? "" : request.getParameter("body");

    }
    stmt = conn.createStatement();
    sql = "select * from memberinfo where deleted = 0 and id=" + Integer.parseInt(userid, 10);
    rs = stmt.executeQuery(sql);
    if (rs.next()) {

        utf8bytes = feed_body.getBytes("UTF8");
        nclob_body.setString(1, new String(utf8bytes, "UTF8"));

        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        sql = "Insert into OPINION (ID, MID, TITLE, BODY, DATAPATH, STATE, GAININTEGRAL, POSTDATE) VALUES (?, ?, ?, ?, ?, 0, -1, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, Integer.parseInt(userid, 10));
        pstmt.setString(3, feed_title);
        //pstmt.setString(4, feed_body);
        pstmt.setNClob(4, nclob_body);
        pstmt.setString(5, filePath + fileName);
        pstmt.setTimestamp(6, d);

        pstmt.execute();
        pstmt.close();

        int reason_id = 11;
        int def_reason = 1;
        Statement u_stmt1 = conn.createStatement();
        sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = " + reason_id;
        rs1 = u_stmt1.executeQuery(sql);
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
        pstmt.setInt(2, Integer.parseInt(userid));
        pstmt.setTimestamp(3, d);
        pstmt.setInt(4, def_reason);
        pstmt.setInt(5, reason_id);
        pstmt.setInt(6, 1);
        pstmt.execute();
        pstmt.close();

        u_stmt1 = conn.createStatement();
        sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + def_reason + " WHERE ID = " + userid;
        u_stmt1.execute(sql);
        u_stmt1.close();
        obj.put("success", 1);

    } else {
        obj.put("success", 0);
    }
    out.println(obj.toJSONString());
    conn.close();
%>
