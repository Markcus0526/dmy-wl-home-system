<%-- 
    Document   : contact
    Created on : 10-Dec-2013, 10:01:33
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@page import="java.util.Date"%>
<%@page import = "org.apache.commons.fileupload.FileUpload" %>
<%@page import = "org.apache.commons.fileupload.DiskFileUpload" %>
<%@page import = "org.apache.commons.fileupload.FileItem" %>
<%@page import = "java.io.File" %>
<%@page import = "java.io.BufferedInputStream" %>
<%@page import = "java.io.BufferedOutputStream" %>
<%@page import = "java.io.IOException" %>
<%@ include file="connection.jsp" %>
<%!    public boolean isImageFormat(String fileExtension) {
        String extension = fileExtension.toLowerCase();

        if (extension.equals("jpg")) {
            return true;
        }
        if (extension.equals("bmp")) {
            return true;
        }
        if (extension.equals("png")) {
            return true;
        }
        if (extension.equals("gif")) {
            return true;
        }

        return false;
    }

    public boolean isVideoFormat(String fileExtension) {
        String extension = fileExtension.toLowerCase();

        if (extension.equals("flv") || extension.equals("mp4") || extension.equals("avi") || extension.equals("mpg") || extension.equals("mpeg") || extension.equals("f4v") || extension.equals("rm") || extension.equals("rmvb")) {
            return true;
        }

        return false;
    }

%>
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

    Statement stmt = conn.createStatement();

    String sql = "select MAX(ID) from ACTIVITY_INFO";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;

    if (rs.next()) {
        newID = rs.getInt(1);
    }

    rs.close();

    newID++;

    String play_title = "play_title";
    String play_body = "play_body";
    String play_start = "12/15/2013";

    java.sql.NClob nclob_title = conn.createNClob();
    java.sql.NClob nclob_body = conn.createNClob();
    byte[] utf8bytes;

    if (FileUpload.isMultipartContent(request)) {

        String temporaryDir = "C:\\";

        org.apache.commons.fileupload.DiskFileUpload fileUpload = new org.apache.commons.fileupload.DiskFileUpload();
        fileUpload.setRepositoryPath(temporaryDir);

        fileUpload.setSizeMax(500 * 1024 * 1024);
        fileUpload.setSizeThreshold(1024 * 4);

        int fileIdx = 0;

        java.util.List fileItemList = fileUpload.parseRequest(request);
        for (int i = 0; i < fileItemList.size(); i++) {

            FileItem fileItem = (FileItem) fileItemList.get(i);
            if (fileItem.isFormField()) {
                String fieldName = fileItem.getFieldName();
                if (fieldName.equals(play_title)) {
                    play_title = fileItem.getString("UTF-8");
                    utf8bytes = play_title.getBytes("UTF-8");
                    nclob_title.setString(1, new String(utf8bytes, "UTF-8"));
                } else if (fieldName.equals(play_body)) {
                    play_body = fileItem.getString("UTF-8");
                    utf8bytes = play_body.getBytes("UTF-8");
                    nclob_body.setString(1, new String(utf8bytes, "UTF-8"));
                } else if (fieldName.equals(play_start)) {
                    play_start = fileItem.getString("UTF-8");
                }
            } else {
                if (fileItem.getSize() > 0) {
                    int idx2 = fileItem.getName().lastIndexOf(".");

                    String fileExtension = fileItem.getName().substring(idx2 + 1);

                    if (!isImageFormat(fileExtension)) {
                        out.println("<script>alert('图品格式错误');</script>");
                        continue;
                    }

                    String filePath = "upload_data/activity/" + makeUploadDirName() + "/";
                    String fileName = newID + "_" + fileIdx + "_" + makeUploadFileNamePrefix(fileItem.getName());

                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                        fileItem.write(uploadedFile);
                        imageresize(uploadedFile.getPath());

                        sql = "select MAX(ID) from ACTIVITY_IMAGE";
                        rs = stmt.executeQuery(sql);

                        int imgID = 0;
                        if (rs.next()) {
                            imgID = rs.getInt(1);
                        }

                        rs.close();

                        imgID++;

                        sql = "Insert into ACTIVITY_IMAGE (ID, AID, DATAPATH) VALUES (?, ?, ?)";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setInt(1, imgID);
                        ps.setInt(2, newID);
                        ps.setString(3, filePath + fileName);
                        ps.execute();
                        ps.close();

                    } catch (IOException ex) {
                    }
                    fileIdx++;
                }
            }
        }

    }



    int mon = Integer.parseInt(play_start.substring(0, 2), 10) - 1;
    int day = Integer.parseInt(play_start.substring(3, 5), 10);
    int year = Integer.parseInt(play_start.substring(6, 10), 10) - 1900;

    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

    sql = "Insert into ACTIVITY_INFO (ID, MID, TITLE, TYPE, BODY, POSTDATE) VALUES (?, ?, ?, ?, ?, ?)";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, newID);
    pstmt.setInt(2, UserId);
    //pstmt.setString(3, play_title);
    pstmt.setNClob(3, nclob_title);
    pstmt.setInt(4, 1);
    //pstmt.setString(5, play_body);
    pstmt.setNClob(5, nclob_body);
    pstmt.setTimestamp(6, d);

    pstmt.execute();
    rs.close();
    pstmt.close();

    int reason_id = 2;
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

    out.println("<script>window.location.href='single.jsp';</script>");
%>
