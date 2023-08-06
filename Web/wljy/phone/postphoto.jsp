<%-- 
    Document   : postphoto
    Created on : 2014/2/3, 下午 04:32:50
    Author     : kimsui
--%>

<%@page import="org.json.simple.JSONObject"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Date"%>
<%@page import = "org.apache.commons.fileupload.FileUpload" %>
<%@page import = "org.apache.commons.fileupload.DiskFileUpload" %>
<%@page import = "org.apache.commons.fileupload.FileItem" %>
<%@page import = "java.io.File" %>
<%@page import = "java.io.BufferedInputStream" %>
<%@page import = "java.io.BufferedOutputStream" %>
<%@page import = "java.io.IOException" %>

<%@ include file="../connection.jsp" %>
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

        if (extension.equals("flv")) {
            return true;
        }
        if (extension.equals("mp4")) {
            return true;
        }

        return false;
    }
%>
<%

    request.setCharacterEncoding("UTF-8");

    Statement stmt = conn.createStatement();
    String userid = "0";
    JSONObject obj = new JSONObject();

    String sql = "select MAX(ID) from MEMBER_DATA";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;

    if (rs.next()) {
        newID = rs.getInt(1);
    }

    rs.close();

    newID++;

    String info_title = "photo_title";
    String info_body = "photo_body";
    String filePath = "upload_data/member_data/";
    String fileName = "";

    java.sql.NClob nclob_body = conn.createNClob();
    byte[] utf8bytes;

    boolean haveMultimedia = false;
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
                if (fieldName.equals(info_title)) {
                    info_title = fileItem.getString("UTF-8");
                } else if (fieldName.equals(info_body)) {
                    info_body = fileItem.getString("UTF-8");
                    utf8bytes = info_body.getBytes("UTF8");
                    nclob_body.setString(1, new String(utf8bytes, "UTF8"));
                } else if (fieldName.equals("userid")) {
                    userid = fileItem.getString("UTF-8");
                }
            } else {
                if (fileItem.getSize() > 0) {
                    filePath = "upload_data/member_data/" + makeUploadDirName() + "/";
                    fileName = newID + "_" + makeUploadFileNamePrefix(fileItem.getName());

                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                        fileItem.write(uploadedFile);
                        imageresize(uploadedFile.getPath());
                        haveMultimedia = true;
                    } catch (IOException ex) {
                    }
                    fileIdx++;
                }
            }
        }
    }
    stmt = conn.createStatement();
    sql = "select * from memberinfo where deleted = 0 and id=" + Integer.parseInt(userid, 10);
    rs = stmt.executeQuery(sql);
    if (rs.next()) {
        if (haveMultimedia == true) {
            Date tmp = new Date();
            java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

            sql = "Insert into MEMBER_DATA (ID, MID, TITLE, TYPE, DATAPATH, BODY, POSTDATE) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, newID);
            pstmt.setInt(2, Integer.parseInt(userid, 10));
            pstmt.setString(3, info_title);
            pstmt.setInt(4, 0);
            pstmt.setString(5, filePath + fileName);
            //pstmt.setString(6, info_body);
            pstmt.setNClob(6, nclob_body);
            pstmt.setTimestamp(7, d);

            pstmt.execute();
            rs.close();
            pstmt.close();
            obj.put("success", 1);
        } else {
            obj.put("success", 0);
        }
    } else {
        obj.put("success", 0);
    }
    conn.close();
    out.println(obj.toJSONString());
%>

