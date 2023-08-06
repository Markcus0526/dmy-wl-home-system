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

    String mem_other = "mem_other";
    String mem_phone = "mem_phone";
    String mem_oldpass = "mem_oldpass";
    String mem_newpass = "mem_newpass";
    String mem_userid = "member_userid_advanced";

    String filePath = "upload_data/member_info/";
    String fileName = "";
    int fileIdx = 0;

    request.setCharacterEncoding("UTF-8");


    if (FileUpload.isMultipartContent(request)) {

        String temporaryDir = "C:\\";

        org.apache.commons.fileupload.DiskFileUpload fileUpload = new org.apache.commons.fileupload.DiskFileUpload();
        fileUpload.setRepositoryPath(temporaryDir);

        fileUpload.setSizeMax(15 * 1024 * 1024);
        fileUpload.setSizeThreshold(1024 * 100);



        java.util.List fileItemList = fileUpload.parseRequest(request);
        for (int i = 0; i < fileItemList.size(); i++) {

            FileItem fileItem = (FileItem) fileItemList.get(i);
            if (fileItem.isFormField()) {
                String fieldName = fileItem.getFieldName();
                if (fieldName.equals(mem_other)) {
                    mem_other = fileItem.getString("UTF-8");
                } else if (fieldName.equals(mem_phone)) {
                    mem_phone = fileItem.getString("UTF-8");
                } else if (fieldName.equals(mem_oldpass)) {
                    mem_oldpass = fileItem.getString("UTF-8");
                } else if (fieldName.equals(mem_newpass)) {
                    mem_newpass = fileItem.getString("UTF-8");
                } else if (fieldName.equals(mem_userid)) {
                    mem_userid = fileItem.getString("UTF-8");
                }

            } else {
                try {
                    if (fileItem.getSize() > 0) {

                        int idx = fileItem.getName().lastIndexOf(".");
                        String fileExtension = fileItem.getName().substring(idx + 1);

                        if (!isImageFormat(fileExtension)) {
                            out.println("<script>alert('图品格式错误');</script>");
                            continue;
                        }

                        fileName = UserId + "_" + makeUploadFileNamePrefix(fileItem.getName());

                        try {
                            File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                            fileItem.write(uploadedFile);
                            imageresize(uploadedFile.getPath());
                        } catch (IOException ex) {
                        }

                    }
                    fileIdx++;
                } catch (Exception e) {
                }

            }
        }
    }

    Statement stmt = conn.createStatement();

    String sql;

	stmt = conn.createStatement();
	sql = "select count(*) as count from MEMBERINFO where userid = '" + mem_userid + "' and id != " + UserId;
	ResultSet rs = stmt.executeQuery(sql);
	if (!rs.next() || rs.getInt("count") == 0) 
	{
		String strPhotoPath = filePath + fileName;
		if (strPhotoPath != null && strPhotoPath.equals("upload_data/member_info/")) 
		{
			strPhotoPath = "";
		}
		if (fileName == null || fileName == "" || fileName.length() == 0)
		{
			strPhotoPath = "img/defimg.png";
		}
		if (fileIdx > 0) 
		{
			sql = "UPDATE MEMBERINFO SET FIRSTLOGIN=1, NAME='" + mem_other + "', USERID='" + mem_userid + "', PHONENUM='" + mem_phone + "', PHOTO='" + strPhotoPath + "' where ID=" + UserId;
		} 
		else 
		{
			sql = "UPDATE MEMBERINFO SET FIRSTLOGIN=1, NAME='" + mem_other + "', USERID='" + mem_userid + "', PHONENUM='" + mem_phone + "' where ID=" + UserId;
		}

		stmt.executeQuery(sql);

		sql = "UPDATE MEMBERINFO SET PASSWORD='" + mem_newpass + "' where ID=" + UserId;
		stmt.executeQuery(sql);
	} 
	else 
	{
		out.println("<script>alert('账号已经存在.');</script>");
	}   

    stmt.close();
    conn.close();

    out.println("<script>window.location.href='vip.jsp';</script>");
%>
