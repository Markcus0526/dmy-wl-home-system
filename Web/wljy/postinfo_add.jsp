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

    Integer stype = Integer.parseInt(((request.getParameter("type") == null) ? "1" : request.getParameter("type")), 10);

    Statement stmt = conn.createStatement();

    String sql = "select MAX(ID) from STUDY_QINFO";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;

    if (rs.next()) {
        newID = rs.getInt(1);
    }

    rs.close();
    
    newID++;

    String info_id = "info_id";
    String info_title = "info_title";
    String info_typestr = "info_type";
    String info_body = "info_body";
    String info_data = "uploadfile";
    String info_integral = "info_integral";
    String filePath = "upload_data/study/";
    String fileName = "";
    String fileName1 = "";
    String curfile = "";

    java.sql.NClob nclob_body = conn.createNClob();
    byte[] utf8bytes;

    boolean haveData = false;
    boolean haveImage = false;
    if (FileUpload.isMultipartContent(request)) {

        String temporaryDir = "C:\\";

        org.apache.commons.fileupload.DiskFileUpload fileUpload = new org.apache.commons.fileupload.DiskFileUpload();
        fileUpload.setRepositoryPath(temporaryDir);

        fileUpload.setSizeMax(1024 * 1024 * 1024);
        fileUpload.setSizeThreshold(1024 * 100);

        int fileIdx = 0;

        java.util.List fileItemList = fileUpload.parseRequest(request);
        for (int i = 0; i < fileItemList.size(); i++) {

            FileItem fileItem = (FileItem) fileItemList.get(i);
            if (fileItem.isFormField()) {
                String fieldName = fileItem.getFieldName();
                if (fieldName.equals(info_title)) {
                    info_title = fileItem.getString("UTF-8");
                } else if (fieldName.equals(info_typestr)) {
                    info_typestr = fileItem.getString("UTF-8");
                } else if (fieldName.equals(info_body)) {
                    info_body = fileItem.getString("UTF-8");
                    utf8bytes = info_body.getBytes("UTF8");
                    nclob_body.setString(1, new String(utf8bytes, "UTF8"));
                } else if (fieldName.equals(info_id)) {
                    info_id = fileItem.getString("UTF-8");
                } else if (fieldName.equals(info_integral)) {
                    info_integral = fileItem.getString("UTF-8");
                }
            } else {
                if (fileItem.getSize() > 0) {

                    filePath = "upload_data/study/" + makeUploadDirName() + "/";

                    if (fileItem.getFieldName().equals(info_data)) {
                        fileName = newID + "_dat_" + makeUploadFileNamePrefix(fileItem.getName());
                        curfile = fileName;
                    } else {
                        int idx2 = fileItem.getName().lastIndexOf(".");
                        String fileExtension = fileItem.getName().substring(idx2 + 1);
                        if (!isImageFormat(fileExtension)) {
                            out.println("<script>alert('图品格式错误');</script>");
                            continue;
                        }
                        fileName1 = newID + "_img_" + makeUploadFileNamePrefix(fileItem.getName());
                        curfile = fileName1;
                    }

                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, curfile);
                        fileItem.write(uploadedFile);

                        if (fileItem.getFieldName().equals(info_data)) {
                            haveData = true;
                        } else {
                            haveImage = true;
                        }

                        if (fileIdx != 0) {
                            imageresize(uploadedFile.getPath());
                        }
                    } catch (IOException ex) {
                    }
                    fileIdx++;
                }
            }
        }
    }


    int info_type = 0;

    sql = "select ID, NAME from STUDY_TYPE";
    rs = stmt.executeQuery(sql);
    String tmpstr;
    while (rs.next()) {
        tmpstr = rs.getString("NAME");
        if (tmpstr.equals(info_typestr)) {
            info_type = rs.getInt("ID");
            break;
        }
    }
    rs.close();
    stmt.close();


    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
    if (info_id.equals("0")) {
        sql = "Insert into STUDY_QINFO (ID, MID, TITLE, TYPE, DATAPATH, IMAGEPATH, BODY, POSTDATE, INTEGRAL, ISVISIBLE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, UserId);
        pstmt.setString(3, info_title);
        pstmt.setInt(4, info_type);
        pstmt.setString(5, filePath + fileName);
        pstmt.setString(6, filePath + fileName1);
        pstmt.setNClob(7, nclob_body);
        pstmt.setTimestamp(8, d);
        pstmt.setInt(9, Integer.parseInt(info_integral));
        pstmt.setInt(10, 1);

        pstmt.execute();
        rs.close();
        pstmt.close();

    } else {
        if (haveData == true && haveImage == true) {
            sql = "UPDATE STUDY_QINFO SET TITLE = ?, TYPE = ?, DATAPATH = ?, IMAGEPATH = ?, INTEGRAL = ?, BODY = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, info_title);
            pstmt.setInt(2, info_type);
            pstmt.setString(3, filePath + fileName);
            pstmt.setString(4, filePath + fileName1);
            pstmt.setInt(5, Integer.parseInt(info_integral));
            pstmt.setNClob(6, nclob_body);
            pstmt.setTimestamp(7, d);

            pstmt.execute();
            pstmt.close();
        } else if (haveData == true && haveImage == false) {
            sql = "UPDATE STUDY_QINFO SET TITLE = ?, TYPE = ?, IMAGEPATH = ?, INTEGRAL = ?, BODY = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, info_title);
            pstmt.setInt(2, info_type);
            pstmt.setString(3, filePath + fileName);
            pstmt.setInt(4, Integer.parseInt(info_integral));
            pstmt.setNClob(5, nclob_body);
            pstmt.setTimestamp(6, d);

            pstmt.execute();
            pstmt.close();
        } else if (haveData == false && haveImage == true) {
            sql = "UPDATE STUDY_QINFO SET TITLE = ?, TYPE = ?, IMAGEPATH = ?, INTEGRAL = ?, BODY = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, info_title);
            pstmt.setInt(2, info_type);
            pstmt.setString(3, filePath + fileName1);
            pstmt.setInt(4, Integer.parseInt(info_integral));
            pstmt.setNClob(5, nclob_body);
            pstmt.setTimestamp(6, d);

            pstmt.execute();
            pstmt.close();
        } else {
            sql = "UPDATE STUDY_QINFO SET TITLE = ?, TYPE = ?, INTEGRAL = ?, BODY = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, info_title);
            pstmt.setInt(2, info_type);
            pstmt.setInt(3, Integer.parseInt(info_integral));
            pstmt.setNClob(4, nclob_body);
            pstmt.setTimestamp(5, d);

            pstmt.execute();
            pstmt.close();
        }
    }


    conn.close();

    out.println("<script>window.location.href='myinfo.jsp?type=" + stype + "';</script>");
%>
