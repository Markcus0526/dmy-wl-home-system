<%-- 
    Document   : contact
    Created on : 10-Dec-2013, 10:01:33
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.DataInputStream"%>
<%@page import="java.util.Enumeration"%>
<%@page import = "org.apache.commons.fileupload.FileUpload" %>
<%@page import = "org.apache.commons.fileupload.DiskFileUpload" %>
<%@page import = "org.apache.commons.fileupload.FileItem" %>
<%@page import = "java.io.File" %>
<%@page import = "java.io.BufferedInputStream" %>
<%@page import = "java.io.BufferedOutputStream" %>
<%@page import = "java.io.IOException" %>
<%@page import="java.util.Date" %>


<%!
    public boolean isVideoFormat(String fileExtension) {
        String extension = fileExtension.toLowerCase();

        if (extension.equals("flv") || extension.equals("mp4") || extension.equals("avi") || extension.equals("mpg") || extension.equals("mpeg") || extension.equals("f4v") || extension.equals("rm") || extension.equals("rmvb")) {
            return true;
        }

        return false;
    }

%>
<%

    byte[] utf8bytes;

    boolean haveMultimedia = false;
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
            String fieldName = fileItem.getFieldName();
            if (fileItem.getSize() > 0) {
                if (fileItem.getName() == null) {
                    continue;
                }
                int idx2 = fileItem.getName().lastIndexOf(".");
                String fileExtension = fileItem.getName().substring(idx2 + 1);

                if (fieldName.contains("uploadfile")) {
                    if (!isVideoFormat(fileExtension)) {
                        continue;
                    }

                    Date today = new Date();
                    String tmpStr = today.toString();
                    String tmpfname = (tmpStr.substring(24, 28)) + (tmpStr.substring(4, 7)) + (tmpStr.substring(8, 10)) + "_" + today.getTime() + "." + fileExtension;

                    String regPath = "upload_data/share/" + (tmpStr.substring(24, 28)) + (tmpStr.substring(4, 7)) + "/";

                    try {
                        File tmpDir = new File("webapps/wljy/" + regPath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + regPath, tmpfname);
                        fileItem.write(uploadedFile);
                        String new_file = new String();
                        String snapshot = new String();
                        new_file = "";
                        if (fileExtension.equals("avi") || fileExtension.equals("rm") || fileExtension.equals("rmvb")
                                || fileExtension.equals("mpg")) {
                            new_file = uploadedFile.getPath().replace(fileExtension, "flv");
                            Runtime.getRuntime().exec("webapps\\wljy\\ffmpeg\\ffmpeg.exe -i " + uploadedFile.getPath() + " -ar 22050 " + new_file);
                            new_file = regPath + tmpfname.replace(fileExtension, "flv");
                        } else {
                            new_file = regPath + tmpfname;
                        }

                        snapshot = uploadedFile.getPath().replace(fileExtension, "jpg");
                        if (fileExtension.equals("flv")) {
                            Runtime.getRuntime().exec("webapps\\wljy\\ffmpeg\\ffmpeg.exe -i " + uploadedFile.getPath() + " -ss 00:00:00 -vframes 1 -f image2 " + snapshot);
                        } else if (fileExtension.equals("mp4")) {
                            Runtime.getRuntime().exec("webapps\\wljy\\ffmpeg\\ffmpeg.exe -i " + uploadedFile.getPath() + " -vcodec mjpeg -vframes 1 -an -f rawvideo " + snapshot);
                        } else if (fileExtension.equals("avi")) {
                            Runtime.getRuntime().exec("webapps\\wljy\\ffmpeg\\ffmpeg.exe -i " + uploadedFile.getPath() + " -ss 00:20:00 -vframes 1 -y -f image2 " + snapshot);
                        } else if (fileExtension.equals("mpg") || fileExtension.equals("mpeg")) {
                            Runtime.getRuntime().exec("webapps\\wljy\\ffmpeg\\ffmpeg.exe -i " + uploadedFile.getPath() + " -an -ss 00:00:00 -r 1 -vframes 1 -f mjpeg -y " + snapshot);
                        } else {
                            Runtime.getRuntime().exec("webapps\\wljy\\ffmpeg\\ffmpeg.exe -i " + uploadedFile.getPath() + " -ss 00:00:00 -vframes 1 -f image2 " + snapshot);
                        }

                        out.print(new_file);
                        return;
                    } catch (IOException ex) {
                    }
                }
            }
        }
    }
    out.println("");
%>
