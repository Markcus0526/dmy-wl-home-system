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

    String sql = "select MAX(ID) from MEMBER_DATA";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;

    if (rs.next()) {
        newID = rs.getInt(1);
    }

    rs.close();

    newID++;

    String info_id = "video_id";
    String video_title = "video_title";
    String video_otherpath = "video_otherpath";
    String video_image = "video_image";
    String video_body = "video_body";
    String filePath = "upload_data/member_data/";
    String fileName1 = "";
    String fileName2 = "";

    java.sql.NClob nclob_body = conn.createNClob();
    byte[] utf8bytes;

    boolean haveMultimedia = false;
    boolean haveImage = false;
    boolean errorAlert = false;
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
                if (fieldName.equals(video_title)) {
                    video_title = fileItem.getString("UTF-8");
                } else if (fieldName.equals(video_otherpath)) {
                    video_otherpath = fileItem.getString("UTF-8");
                } else if (fieldName.equals(video_body)) {
                    video_body = fileItem.getString("UTF-8");
                    utf8bytes = video_body.getBytes("UTF8");
                    nclob_body.setString(1, new String(utf8bytes, "UTF8"));
                } else if (fieldName.equals(info_id)) {
                    info_id = fileItem.getString("UTF-8");
                }
            } else {
                if (fileItem.getSize() > 0) {
                    int idx2 = fileItem.getName().lastIndexOf(".");
                    String fileExtension = fileItem.getName().substring(idx2 + 1);

                    filePath = "upload_data/member_data/" + makeUploadDirName() + "/";
                    String prefixFile = "";
                    if (info_id.equals("0")) {
                        prefixFile = newID + "_";
                    } else {
                        prefixFile = info_id + "_";
                    }

                    String tmpfilename = "";

                    if (fileItem.getFieldName().equals(video_image)) {
                        if (!isImageFormat(fileExtension)) {
                            out.println("<script>alert('图品格式错误');</script>");
                            continue;
                        }
                        fileName1 = prefixFile + "img_" + makeUploadFileNamePrefix(fileItem.getName());
                        tmpfilename = fileName1;
                    } else {
                        if (!isVideoFormat(fileExtension)) {
                            out.println("<script>alert('视频格式错误');</script>");
                            continue;
                        }
                        fileName2 = prefixFile + "vid_" + makeUploadFileNamePrefix(fileItem.getName());
                        tmpfilename = fileName2;
                    }
                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }
                        File uploadedFile = new File("webapps/wljy/" + filePath, tmpfilename);
                        fileItem.write(uploadedFile);
                        if (fileItem.getFieldName().equals(video_image)) 
                            haveImage = true;
                        else
                            haveMultimedia = true;
                        if (fileItem.getFieldName().equals(video_image)) {
                            imageresize(uploadedFile.getPath());
                        } else {
                            String new_file = new String();
                            if (fileExtension.equals("avi") || fileExtension.equals("rm") || fileExtension.equals("rmvb")) {
                                new_file = uploadedFile.getPath().replace(fileExtension, "flv");

                                Runtime.getRuntime().exec("webapps\\wljy\\ffmpeg\\ffmpeg.exe -i " + uploadedFile.getPath() + " -ar 22050 " + new_file);
                                fileName2 = fileName2.replace(fileExtension, "flv");
                            }

                        }

                    } catch (IOException ex) {
                        if ( !errorAlert ) {
                            out.println("<script>alert('上传视频失败');</script>");
                            errorAlert = true;
                        }
                        continue;
                    }
                    fileIdx++;
                }
            }
        }
    }
    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
    if (info_id.equals("0")) {
        if (haveMultimedia == true) {
            sql = "Insert into MEMBER_DATA (ID, MID, TITLE, TYPE, DATAPATH, BODY, OTHERPATH, DEFIMAGE, POSTDATE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, newID);
            pstmt.setInt(2, UserId);
            pstmt.setString(3, video_title);
            pstmt.setInt(4, 1);
            pstmt.setString(5, filePath + fileName2);
            pstmt.setNClob(6, nclob_body);
            pstmt.setString(7, video_otherpath);
            pstmt.setString(8, filePath + fileName1);
            pstmt.setTimestamp(9, d);

            pstmt.execute();
            rs.close();
            pstmt.close();
        }
    } else {
        if (haveMultimedia == true && haveImage == true) {
            sql = "UPDATE MEMBER_DATA SET TITLE = ?, DATAPATH = ?, BODY = ?, OTHERPATH = ?, DEFIMAGE = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, video_title);
            pstmt.setString(2, filePath + fileName2);
            pstmt.setNClob(3, nclob_body);
            pstmt.setString(4, video_otherpath);
            pstmt.setString(5, filePath + fileName1);
            pstmt.setTimestamp(6, d);

            pstmt.execute();
            pstmt.close();
        } else if (haveMultimedia == true && haveImage == false) {
            sql = "UPDATE MEMBER_DATA SET TITLE = ?, DATAPATH = ?, BODY = ?, OTHERPATH = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, video_title);
            pstmt.setString(2, filePath + fileName2);
            pstmt.setNClob(3, nclob_body);
            pstmt.setString(4, video_otherpath);
            pstmt.setTimestamp(5, d);

            pstmt.execute();
            pstmt.close();
        } else if (haveMultimedia == false && haveImage == true) {
            sql = "UPDATE MEMBER_DATA SET TITLE = ?, BODY = ?, OTHERPATH = ?, DEFIMAGE = ?, POSTDATE = ? where id = " + info_id;
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, video_title);
            pstmt.setNClob(2, nclob_body);
            pstmt.setString(3, video_otherpath);
            pstmt.setString(4, filePath + fileName1);
            pstmt.setTimestamp(5, d);

            pstmt.execute();
            pstmt.close();
        } else {
            sql = "UPDATE MEMBER_DATA SET TITLE = ?, BODY = ?, OTHERPATH = ?, POSTDATE = ? where id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, video_title);
            pstmt.setNClob(2, nclob_body);
            pstmt.setString(3, video_otherpath);
            pstmt.setTimestamp(4, d);
            pstmt.setInt(5, Integer.parseInt(info_id, 10));

            pstmt.execute();
            pstmt.close();
        }
    }

    conn.close();

    out.println("<script>window.location.href='myvideo.jsp';</script>");
%>
