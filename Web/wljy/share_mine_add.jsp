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

    Statement stmt = conn.createStatement();

    String sql = "select MAX(ID) from SHARE_INFO";
    ResultSet rs = stmt.executeQuery(sql);

    int newID = 0;
    int sType = 1;

    while (rs.next()) {
        newID = rs.getInt(1);
        break;
    }

    newID++;

    String share_title = "share_title";
    String share_body = "share_body";
	String share_type = "type";
    String videopath = "videopath";
	String imagepath = "imgfilepath";

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
				else if (fieldName.equals(videopath)) 
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
                        sql = "Insert into SHARE_DATA (ID, RID, MID, TYPE, DATAPATH) VALUES (?, ?, ?, ?, ?)";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        ps.setInt(1, sdID);
                        ps.setInt(2, newID);
                        ps.setInt(3, mid);
                        ps.setInt(4, 1);
                        ps.setString(5, videopath.trim());
                        ps.execute();
                        ps.close();
                        haveMultimedia = true;
                    }
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
							ps.setInt(2, newID);
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

    if (haveMultimedia == true) 
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

        sql = "Insert into SHARE_INFO (ID, MID, TITLE, TYPE, BODY, POSTDATE, ISVISIBLE) VALUES (?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, mid);
        pstmt.setNClob(3, nclob_title);
        pstmt.setInt(4, sType);
        //pstmt.setString(5, share_body);
        pstmt.setNClob(5, nclob_body);
        pstmt.setTimestamp(6, d);
        pstmt.setInt(7, 1);

        pstmt.execute();
        pstmt.close();

        int reason_id = 8;
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
        pstmt.setInt(2, mid);
        pstmt.setTimestamp(3, d);
        pstmt.setInt(4, def_reason);
        pstmt.setInt(5, reason_id);
        pstmt.setInt(6, 1);
        pstmt.execute();
        pstmt.close();

        u_stmt1 = conn.createStatement();
        sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + def_reason + " WHERE deleted = 0 and ID = " + mid;
        u_stmt1.execute(sql);
        u_stmt1.close();
    } 
	else 
	{
        out.println("<script>alert('图片或视频格式错误');</script>");
    }
    conn.close();

    out.println("<script>window.location.href='share.jsp?type=" + sType + "';</script>");
%>
