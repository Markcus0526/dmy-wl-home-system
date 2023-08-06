<%-- 
    Document   : share_addinfo
    Created on : Jan 4, 2014, 7:06:08 PM
    Author     : Hercules
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page language="Java" import="java.util.Date"%>
<%@page import = "org.apache.commons.fileupload.FileUpload" %>
<%@page import = "org.apache.commons.fileupload.DiskFileUpload" %>
<%@page import = "org.apache.commons.fileupload.FileItem" %>
<%@page import = "java.io.File" %>
<%@page import = "java.io.BufferedInputStream" %>
<%@page import = "java.io.BufferedOutputStream" %>
<%@page import = "java.io.IOException" %>
<%@include file="cookie_check.jsp" %>
<%@include file="../connection.jsp" %>
<%!    
	public boolean isImageFormat(String fileExtension) {
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
            if (name.substring(0, pos).equals("wljyadminid")) {
                tmp_str = name.substring(pos + 1);
                break;
            }
        }
    }
    int UserId = Integer.parseInt(tmp_str, 10);

    request.setCharacterEncoding("UTF-8");

	Statement stmtQuery = conn.createStatement();
	String sql = "select MAX(ID) from SHARE_INFO";
	ResultSet rsQuery = stmtQuery.executeQuery(sql);

	int newID = 0;

	if (rsQuery.next()) {
		newID = rsQuery.getInt(1);
	}

	rsQuery.close();
	stmtQuery.close();

	newID++;

    String act = "act";
	String ids = "ids";
    String strId = "id";
    String smid = "mid";
    String title = "increase_title";
	java.sql.NClob nclobTitle = conn.createNClob();
	byte[] utf8bytesTitle = null;
    String stype = "increase_page";
    String sispublic = "select_ispublic";
	String isVisible="visible_val";
    String body = "form_edit_body";
    java.sql.NClob nclob = conn.createNClob();
    byte[] utf8bytes = null;
    String imagepath = "filepath_";
	String videopath = "videopath";
	String realVideoPath = "";

	int nID = 0;
	int nMID = 0;
	String filePath = "";
	String fileName = "";

	if (FileUpload.isMultipartContent(request)) 
	{
        String temporaryDir = "C:\\";

        org.apache.commons.fileupload.DiskFileUpload fileUpload = new org.apache.commons.fileupload.DiskFileUpload();
        fileUpload.setRepositoryPath(temporaryDir);

        fileUpload.setSizeMax(500 * 1024 * 1024);
        fileUpload.setSizeThreshold(1024 * 100);

        int fileIdx = 0;		
        java.util.List fileItemList = fileUpload.parseRequest(request);
        for (int i = 0; i < fileItemList.size(); i++) 
		{
            FileItem fileItem = (FileItem) fileItemList.get(i);			
            if (fileItem.isFormField()) {
                String fieldName = fileItem.getFieldName();				
				if (fieldName.equals(strId)) 
				{
                    strId = fileItem.getString("UTF-8");
					nID = Integer.parseInt(strId);					
                }
				else if (fieldName.equals(smid)) 
				{
                    smid = fileItem.getString("UTF-8");	
					nMID = Integer.parseInt(smid);
					if (nID > -1)
					{
						String query = "update share_data set deleted = 1 where rid = ? and mid = ?";
						PreparedStatement pstmtQuery = conn.prepareStatement(query);
						pstmtQuery.setInt(1, nID);
						pstmtQuery.setInt(2, nMID);
						pstmtQuery.execute();
						pstmtQuery.close();
					}
                }
				else if (fieldName.equals(title)) 
				{
                    title = fileItem.getString("UTF-8");	
					utf8bytesTitle = title.getBytes("UTF8");
                    nclobTitle.setString(1, new String(utf8bytesTitle, "UTF8"));
                }
                else if (fieldName.equals(sispublic)) 
				{
                    sispublic = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(stype)) 
				{
                    stype = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(isVisible)) 
				{
                    isVisible = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(act)) 
				{
                    act = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(ids)) 
				{
                    ids = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(videopath)) 
				{
                    realVideoPath = fileItem.getString("UTF-8").trim();					
					if (realVideoPath != null && realVideoPath.length() > 0)
					{
						String queryImage = "select MAX(ID) from SHARE_DATA";
						Statement queryStmt = conn.createStatement();
                        ResultSet queryRS = queryStmt.executeQuery(queryImage);

						int imgID = 0;
                        if (queryRS.next()) {
                            imgID = queryRS.getInt(1);
                        }

                        queryRS.close();
						queryStmt.close();

                        imgID++;

						if (act.equals("add") || act.equals("edit")) 
						{
							if (nID == 0)
							{
								sql = "Insert into SHARE_DATA (ID, RID, MID, TYPE, DATAPATH) VALUES (?, ?, ?, ?, ?)";
								PreparedStatement ps1 = conn.prepareStatement(sql);
								ps1.setInt(1, imgID);
								ps1.setInt(2, newID);
								ps1.setInt(3, 0);
								ps1.setInt(4, 1);
								ps1.setString(5, realVideoPath);
								ps1.execute();
								ps1.close();
							}
							else
							{
								sql = "Insert into SHARE_DATA (ID, RID, MID, TYPE, DATAPATH) VALUES (?, ?, ?, ?, ?)";
								PreparedStatement ps1 = conn.prepareStatement(sql);
								ps1.setInt(1, imgID);
								ps1.setInt(2, nID);
								ps1.setInt(3, nMID);
								ps1.setInt(4, 1);
								ps1.setString(5, realVideoPath);
								ps1.execute();
								ps1.close();
							}
						}
					}
                }
				else if (fieldName.equals(body)) 
				{
                    body = fileItem.getString("UTF-8");
                    utf8bytes = body.getBytes("UTF8");
                    nclob.setString(1, new String(utf8bytes, "UTF8"));
                }
				else if (fieldName.contains(imagepath))
				{
					String oldPath = fileItem.getString("UTF-8");
					String query1 = "update share_data set deleted = 0 where rid = " + nID + " and datapath like '%" + oldPath + "%'" + " and mid = " + nMID;
					Statement stmtQuery1 = conn.createStatement();
					stmtQuery1.execute(query1);
					stmtQuery1.close();
				}
            }
			else 
			{
                if (fileItem.getSize() > 0) {

                    int idx2 = fileItem.getName().lastIndexOf(".");
                    String fileExtension = fileItem.getName().substring(idx2 + 1);
                    if (!isImageFormat(fileExtension)) {
                        out.println("<script>alert('’’∆¨∏Ò Ω¥ÌŒÛ');</script>");
                        continue;
                    }

                    filePath = "upload_data/share/" + makeUploadDirName() + "/";
                    fileName = makeUploadFileNamePrefix(fileItem.getName());

                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                        fileItem.write(uploadedFile);
                        imageresize(uploadedFile.getPath());

						String queryImage = "select MAX(ID) from SHARE_DATA";
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
							sql = "Insert into SHARE_DATA (ID, RID, MID, TYPE, DATAPATH) VALUES (?, ?, ?, ?, ?)";
							PreparedStatement ps = conn.prepareStatement(sql);
							ps.setInt(1, imgID);
							ps.setInt(2, newID);
							ps.setInt(3, 0);
							ps.setInt(4, 0);
							ps.setString(5, filePath + fileName);
							ps.execute();
							ps.close();							
						}
						else
						{
							sql = "Insert into SHARE_DATA (ID, RID, MID, TYPE, DATAPATH) VALUES (?, ?, ?, ?, ?)";
							PreparedStatement ps = conn.prepareStatement(sql);
							ps.setInt(1, imgID);
							ps.setInt(2, nID);
							ps.setInt(3, nMID);
							ps.setInt(4, 0);
							ps.setString(5, filePath + fileName);
							ps.execute();
							ps.close();
						}
                    } catch (IOException ex) {
                        out.println("<script>alert('…œ¥´’’∆¨ ß∞‹');</script>");
                        continue;
                    }
                    fileIdx++;
                }
            }
        }
    }

    if (act.equals("add")) 
	{
        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        sql = "Insert into SHARE_INFO (ID, MID, TITLE, TYPE, BODY, POSTDATE, READCOUNT, ISVISIBLE, DELETED, ISPUBLIC) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?)";

        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, 0);
        pstmt.setNClob(3, nclobTitle);
        pstmt.setInt(4, Integer.parseInt(stype));
        pstmt.setNClob(5, nclob);
        pstmt.setTimestamp(6, d);
        pstmt.setInt(7, 0);
        pstmt.setInt(8, Integer.parseInt(isVisible));
        pstmt.setInt(9, Integer.parseInt(sispublic));
        pstmt.execute();

        pstmt.close();
    } 
	else if (act.equals("delete")) {
		Statement stmt = conn.createStatement();
		Statement u_stmt = conn.createStatement();
		Statement u_stmt1 = conn.createStatement();
		//String sql = "delete from SHARE_INFO where id = " + id;
		sql = "update SHARE_INFO set deleted = 1 where id = " + nID;
		ResultSet rs = stmt.executeQuery(sql);
		rs.close();

		//sql = "delete from SHARE_EVAL where rid = " + id;
		sql = "update SHARE_EVAL set deleted = 1 where rid = " + nID;
		rs = u_stmt.executeQuery(sql);
		rs.close();

		//sql = "delete from SHARE_DATA where rid = " + id;
		sql = "update SHARE_DATA set deleted = 1 where rid = " + nID;
		rs = u_stmt1.executeQuery(sql);
		rs.close();

		stmt.close();
		u_stmt.close();
		u_stmt1.close();
    } 	
	else if (act.equals("deleteall")) {        
        if (ids.length() > 0) {
            String[] id_data = ids.split(",");
            if (id_data.length > 0) {
                Statement stmt = conn.createStatement();
                Statement u_stmt = conn.createStatement();
                Statement u_stmt1 = conn.createStatement();
                for (int i = 0; i < id_data.length; i++) {
                    if (!id_data[i].equals("0")) {
                        sql = "update SHARE_INFO set deleted = 1 where id = " + id_data[i];
                        ResultSet rs = stmt.executeQuery(sql);
                        rs.close();

                        //sql = "delete from SHARE_EVAL where rid = " + id;
                        sql = "update SHARE_EVAL set deleted = 1 where rid = " + id_data[i];
                        rs = u_stmt.executeQuery(sql);
                        rs.close();

                        //sql = "delete from SHARE_DATA where rid = " + id;
                        sql = "update SHARE_DATA set deleted = 1 where rid = " + id_data[i];
                        rs = u_stmt1.executeQuery(sql);
                        rs.close();
                    }

                }
                stmt.close();
                u_stmt.close();
                u_stmt1.close();
            }
        }
    } 
	else if (act.equals("edit")) {
        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
        sql = "update SHARE_INFO set TITLE = ?, TYPE = ?, BODY = ?, POSTDATE = ?, ISVISIBLE = ?, ISPUBLIC = ? where id = ? and mid = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);

        pstmt.setString(1, title);
        pstmt.setInt(2, Integer.parseInt(stype));
        pstmt.setNClob(3, nclob);
        pstmt.setTimestamp(4, d);
        pstmt.setInt(5, Integer.parseInt(isVisible));
        pstmt.setInt(6, Integer.parseInt(sispublic));
        pstmt.setInt(7, nID);
		pstmt.setInt(8, nMID);

        pstmt.execute();

        pstmt.close();
    }

    conn.close();

    out.println("<script>window.location.href='share.jsp';</script>");
%>

