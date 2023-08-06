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


<%!     public boolean isImageFormat(String fileExtension) {
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
    int mid = Integer.parseInt(tmp_str, 10);

    request.setCharacterEncoding("UTF-8");
	Integer shareID = Integer.parseInt(((request.getParameter("id")== null)?"0":request.getParameter("id")), 10);
	if (shareID > 0)
	{
		String query = "update share_data set deleted = 1 where rid = ? and mid = ?";
		PreparedStatement pstmtQuery = conn.prepareStatement(query);
		pstmtQuery.setInt(1, shareID);
		pstmtQuery.setInt(2, mid);
		pstmtQuery.execute();
		pstmtQuery.close();
	}

    int sType = 1;
    Statement stmt = conn.createStatement();

	String sql = "select MAX(ID) from SHARE_INFO";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;

    while (rs.next()) {
        newID = rs.getInt(1);
        break;
    }

    newID++;

    String share_title = "share_title";
    String share_body = "share_body";
	String share_type = "type";
    String videopath = "videopath";
	String imagepath = "imgfilepath_";

	java.sql.NClob nclob_title = conn.createNClob();
    java.sql.NClob nclob_body = conn.createNClob();
    byte[] utf8bytes;

    boolean haveMultimedia = false;
    if (FileUpload.isMultipartContent(request)) 
	{
        String temporaryDir = "C:\\";

        org.apache.commons.fileupload.DiskFileUpload fileUpload = new org.apache.commons.fileupload.DiskFileUpload();
        fileUpload.setRepositoryPath(temporaryDir);

        fileUpload.setSizeMax(1024 * 1024 * 1024);
        fileUpload.setSizeThreshold(1024 * 512 * 1024);

        int fileIdx = 0;
		String fieldName = "";
        java.util.List fileItemList = fileUpload.parseRequest(request);
        for (int i = 0; i < fileItemList.size(); i++) 
		{
            FileItem fileItem = (FileItem) fileItemList.get(i);
            fieldName = fileItem.getFieldName();
            if (fileItem.isFormField()) 
			{
                if (fieldName.equals(share_title)) 
				{
                    share_title = fileItem.getString("UTF-8");
					utf8bytes = share_title.getBytes("UTF-8");
                    nclob_title.setString(1, new String(utf8bytes, "UTF-8"));
                } 
				else if (fieldName.equals(share_body)) 
				{
                    share_body = fileItem.getString("UTF-8");
                    utf8bytes = share_body.getBytes("UTF-8");
                    nclob_body.setString(1, new String(utf8bytes, "UTF-8"));
                }
				else if (fieldName.equals(share_type)) 
				{
					share_type = fileItem.getString("UTF-8");
                }
				else if (fieldName.contains(videopath)) 
				{
                    sql = "select MAX(ID) from SHARE_DATA";
                    rs = stmt.executeQuery(sql);

                    int sdID = 0;

                    while (rs.next()) 
					{
                        sdID = rs.getInt(1);
                        break;
                    }
                    sdID++;

                    videopath = fileItem.getString("UTF-8");
                    if (videopath != null && videopath.trim().length() > 0) 
					{
						String query = "select * from share_data where TYPE = 1 and rid = " + shareID +  " and mid = " + mid + " and datapath like '%" + videopath + "%'";
						Statement stmtQuery = conn.createStatement();						
						ResultSet rsquery1 = stmtQuery.executeQuery(query);
						if (rsquery1.next())
						{
							String oldPath = fileItem.getString("UTF-8");
							String query1 = "update share_data set deleted = 0 where rid = " + shareID + " and type = 1 and mid = " + mid + " and datapath like '%" + videopath + "%'";
							Statement stmtQuery1 = conn.createStatement();
							stmtQuery1.execute(query1);
							stmtQuery1.close();
						}
						else
						{
							sql = "Insert into SHARE_DATA (ID, RID, MID, TYPE, DATAPATH) VALUES (?, ?, ?, ?, ?)";
							PreparedStatement ps = conn.prepareStatement(sql);
							ps.setInt(1, sdID);
							ps.setInt(2, shareID);
							ps.setInt(3, mid);
							ps.setInt(4, 1);
							ps.setString(5, videopath.trim());
							ps.execute();
							ps.close();
						}
                        
						rsquery1.close();
						stmtQuery.close();
                    }
                }
				else if (fieldName.contains(imagepath))
				{
					String oldPath = fileItem.getString("UTF-8");
					String query = "update share_data set deleted = 0 where rid = " + shareID + " and type = 0 and mid = " + mid + " and datapath like '%" + oldPath + "%'";
					Statement stmtQuery = conn.createStatement();
					stmtQuery.execute(query);
					stmtQuery.close();
				}
            } 
			else 
			{
                if (fileItem.getSize() > 0) 
				{
					int idx2 = fileItem.getName().lastIndexOf(".");

                    String fileExtension = fileItem.getName().substring(idx2 + 1);

                    if (!isImageFormat(fileExtension)) 
					{
                        out.println("<script>alert('图品格式错误');</script>");
                        continue;
                    }

                    String filePath = "upload_data/share/" + makeUploadDirName() + "/";
                    String fileName = newID + "_" + fileIdx + "_" + makeUploadFileNamePrefix(fileItem.getName());

                    try 
					{
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) 
						{
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                        fileItem.write(uploadedFile);
                        imageresize(uploadedFile.getPath());

						String strPath = filePath + fileName;

                        sql = "select MAX(ID) from SHARE_DATA";
                        rs = stmt.executeQuery(sql);

                        int imgID = 0;
                        if (rs.next()) 
						{
                            imgID = rs.getInt(1);
                        }

                        rs.close();

                        imgID++;

						if (strPath != null && strPath.length() > 0) 
						{
							sql = "Insert into SHARE_DATA (ID, RID, MID, TYPE, DATAPATH) VALUES (?, ?, ?, ?, ?)";
							PreparedStatement ps = conn.prepareStatement(sql);
							ps.setInt(1, imgID);
							ps.setInt(2, shareID);
							ps.setInt(3, mid);
							ps.setInt(4, 0);
							ps.setString(5, strPath);
							ps.execute();
							ps.close();
							haveMultimedia = true;
						}
                    }
					catch (IOException ex) {}

                    fileIdx++;
                }
            }
        }
    }

    if (shareID > 0) 
	{
        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

		String sqlType = "select ID, NAME from SHARE_TYPE";
		Statement stmtType = conn.createStatement();
		ResultSet rsType = stmtType.executeQuery(sqlType);

		rsType = stmtType.executeQuery(sqlType);
		String tmpstr;
		while (rsType.next()) {
			tmpstr = rsType.getString("NAME");
			if (tmpstr.equals(share_type)) {
				sType = rsType.getInt("ID");
				break;
			}
		}
		rsType.close();
		stmtType.close();

        sql = "UPDATE SHARE_INFO SET TITLE = ?, TYPE = ?, BODY = ?, POSTDATE = ? where id = ?";

        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setNClob(1, nclob_title);
		pstmt.setInt(2, sType);
        pstmt.setNClob(3, nclob_body);
        pstmt.setTimestamp(4, d);
        pstmt.setInt(5, shareID);

        pstmt.execute();
        pstmt.close();
    } 
	else 
	{
        out.println("<script>alert('图片或视频格式错误');</script>");
    }
    conn.close();

    out.println("<script>window.location.href='myvideo.jsp';</script>");
%>
