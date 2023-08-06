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

    Statement stmt = conn.createStatement();

    String sql = "select MAX(ID) from MEMBER_DATA";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;

    if (rs.next()) {
        newID = rs.getInt(1);
    }

    rs.close();

    newID++;

	String info_id = "photo_id";
    String info_title = "photo_title";
    String info_body = "photo_body";
	String info_path = "filepath_";
    String filePath = "upload_data/member_data/";
    String fileName = "";
	int nID = 0;

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
				if (fieldName.equals(info_id)) 
				{
                    info_id = fileItem.getString("UTF-8");

					nID = Integer.parseInt(info_id);
					if (nID > 0)
					{
						String query = "update member_image set deleted = 1 where rid = ?";
						PreparedStatement pstmtQuery = conn.prepareStatement(query);
						pstmtQuery.setInt(1, nID);
						pstmtQuery.execute();
						pstmtQuery.close();
					}
                }
                else if (fieldName.equals(info_title)) 
				{
                    info_title = fileItem.getString("UTF-8");
                } 
				else if (fieldName.equals(info_body)) 
				{
                    info_body = fileItem.getString("UTF-8");
                    utf8bytes = info_body.getBytes("UTF8");
                    nclob_body.setString(1, new String(utf8bytes, "UTF8"));
                }
				else if (fieldName.contains(info_path))
				{
					String oldPath = fileItem.getString("UTF-8");
					String query = "update member_image set deleted = 0 where rid = " + nID + " and datapath like '%" + oldPath + "%'";
					Statement stmtQuery = conn.createStatement();
					stmtQuery.execute(query);
					stmtQuery.close();
				}
            }
			else 
			{
                if (fileItem.getSize() > 0) {

                    int idx2 = fileItem.getName().lastIndexOf(".");
                    String fileExtension = fileItem.getName().substring(idx2 + 1);
                    if (!isImageFormat(fileExtension)) {
                        out.println("<script>alert('照片格式错误');</script>");
                        continue;
                    }

                    filePath = "upload_data/member_data/" + makeUploadDirName() + "/";
                    fileName = makeUploadFileNamePrefix(fileItem.getName());

                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                        fileItem.write(uploadedFile);
                        imageresize(uploadedFile.getPath());

						String queryImage = "select MAX(ID) from MEMBER_IMAGE";
						Statement queryStmt = conn.createStatement();
                        ResultSet queryRS = queryStmt.executeQuery(queryImage);

                        int imgID = 0;
                        if (queryRS.next()) {
                            imgID = queryRS.getInt(1);
                        }

                        queryRS.close();
						queryStmt.close();

                        imgID++;

						if (nID == 0)
						{
							sql = "Insert into member_image (ID, RID, DATAPATH) VALUES (?, ?, ?)";
							PreparedStatement ps = conn.prepareStatement(sql);
							ps.setInt(1, imgID);
							ps.setInt(2, newID);
							ps.setString(3, filePath + fileName);
							ps.execute();
							ps.close();
						}
						else
						{
							sql = "Insert into member_image (ID, RID, DATAPATH) VALUES (?, ?, ?)";
							PreparedStatement ps = conn.prepareStatement(sql);
							ps.setInt(1, imgID);
							ps.setInt(2, nID);
							ps.setString(3, filePath + fileName);
							ps.execute();
							ps.close();
						}
                    } catch (IOException ex) {
                        out.println("<script>alert('上传照片失败');</script>");
                        continue;
                    }
                    fileIdx++;
                }
            }
        }
    }


    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

	if (nID == 0) {
		sql = "Insert into MEMBER_DATA (ID, MID, TITLE, TYPE, DATAPATH, BODY, POSTDATE) VALUES (?, ?, ?, ?, ?, ?, ?)";
		PreparedStatement pstmt = conn.prepareStatement(sql);
		pstmt.setInt(1, newID);
		pstmt.setInt(2, UserId);
		pstmt.setString(3, info_title);
		pstmt.setInt(4, 0);
		pstmt.setString(5, filePath + fileName);
		pstmt.setNClob(6, nclob_body);
		pstmt.setTimestamp(7, d);

		pstmt.execute();
		pstmt.close();
	}
	else 
	{
		sql = "UPDATE MEMBER_DATA SET TITLE = ?, BODY = ?, POSTDATE = ? where id = ?";
		PreparedStatement pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, info_title);
		pstmt.setNClob(2, nclob_body);
		pstmt.setTimestamp(3, d);
		pstmt.setInt(4, nID);
		pstmt.execute();
		pstmt.close();
    }

    conn.close();

    out.println("<script>window.location.href='myphoto.jsp';</script>");
%>
