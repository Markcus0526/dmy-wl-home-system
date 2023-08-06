<%-- 
    Document   : activity_add
    Created on : Dec 25, 2013, 6:27:19 PM
    Author     : KIMSUI
--%>

<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="cookie_check.jsp" %>
<%@ include file="../connection.jsp" %>
<%@page import="java.util.Date"%>
<%@page import = "org.apache.commons.fileupload.FileUpload" %>
<%@page import = "org.apache.commons.fileupload.DiskFileUpload" %>
<%@page import = "org.apache.commons.fileupload.FileItem" %>
<%@page import = "java.io.File" %>
<%@page import = "java.io.BufferedInputStream" %>
<%@page import = "java.io.BufferedOutputStream" %>
<%@page import = "java.io.IOException" %>
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

	String sql = new String();
    int UserId = Integer.parseInt(tmp_str, 10);

    request.setCharacterEncoding("UTF-8");

	Statement stmtQuery = conn.createStatement();
	sql = "select MAX(ID) from ACTIVITY_INFO";
	ResultSet rsQuery = stmtQuery.executeQuery(sql);

	int newID = 0;

	if (rsQuery.next()) {
		newID = rsQuery.getInt(1);
	}

	rsQuery.close();
	stmtQuery.close();

	newID++;

    Statement stmt = conn.createStatement();    
    ResultSet rs;
    String act = "act";
    String play_title = "title";
    String play_body = "body";
    String sispublic = "select_ispublic";
    String isselect = "select_val";
    String isvisible = "visible_val";
    String fileimagepath = "filepath_";
	String id = "id";
	String ids = "ids";

    int nID = 0;
	String filePath = "";
	String fileName = "";

    java.sql.NClob nclob = conn.createNClob();
    byte[] utf8bytes = null;    

	if (FileUpload.isMultipartContent(request)) {

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
//				out.print("<script>alert('" + fileItem.getString("UTF-8") + "')</script>");
				if (fieldName.equals(id)) 
				{
                    id = fileItem.getString("UTF-8");
					nID = Integer.parseInt(id);
					if (nID > 0)
					{
						String query = "update activity_image set deleted = 1 where aid = ?";
						PreparedStatement pstmtQuery = conn.prepareStatement(query);
						pstmtQuery.setInt(1, nID);
						pstmtQuery.execute();
						pstmtQuery.close();
					}
                }
				else if (fieldName.equals(play_title)) 
				{
                    play_title = fileItem.getString("UTF-8");					
                }
                else if (fieldName.equals(sispublic)) 
				{
                    sispublic = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(isselect)) 
				{
                    isselect = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(isvisible)) 
				{
                    isvisible = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(act)) 
				{
                    act = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(ids)) 
				{
                    ids = fileItem.getString("UTF-8");
                }
				else if (fieldName.equals(play_body)) 
				{
                    play_body = fileItem.getString("UTF-8");
                    utf8bytes = play_body.getBytes("UTF8");
                    nclob.setString(1, new String(utf8bytes, "UTF8"));
                }
				else if (fieldName.contains(fileimagepath))
				{
					String oldPath = fileItem.getString("UTF-8");
					String query1 = "update activity_image set deleted = 0 where aid = " + nID + " and datapath like '%" + oldPath + "%'";
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

                    filePath = "upload_data/activity/" + makeUploadDirName() + "/";
                    fileName = makeUploadFileNamePrefix(fileItem.getName());

                    try {
                        File tmpDir = new File("webapps/wljy/" + filePath);
                        if (!tmpDir.exists()) {
                            tmpDir.mkdir();
                        }

                        File uploadedFile = new File("webapps/wljy/" + filePath, fileName);
                        fileItem.write(uploadedFile);
                        imageresize(uploadedFile.getPath());

						String queryImage = "select MAX(ID) from ACTIVITY_IMAGE";
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
							sql = "Insert into activity_image (ID, AID, DATAPATH) VALUES (?, ?, ?)";
							PreparedStatement ps = conn.prepareStatement(sql);
							ps.setInt(1, imgID);
							ps.setInt(2, newID);
							ps.setString(3, filePath + fileName);
							ps.execute();
							ps.close();
						}
						else
						{
							sql = "Insert into activity_image (ID, AID, DATAPATH) VALUES (?, ?, ?)";
							PreparedStatement ps = conn.prepareStatement(sql);
							ps.setInt(1, imgID);
							ps.setInt(2, nID);
							ps.setString(3, filePath + fileName);
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

    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

    if (act.equals("add")) {

        sql = "Insert into ACTIVITY_INFO (ID, MID, TITLE, TYPE, BODY, POSTDATE, ISVISIBLE, ISSELECTED, DELETED, ISPUBLIC) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setInt(2, 0);
        pstmt.setString(3, play_title);
        pstmt.setInt(4, 2);
        pstmt.setNClob(5, nclob);
        pstmt.setTimestamp(6, d);
        pstmt.setInt(7, Integer.parseInt(isvisible, 10));
        pstmt.setInt(8, Integer.parseInt(isselect, 10));
        pstmt.setInt(9, Integer.parseInt(sispublic));

        pstmt.execute();
    } 	
	else if (act.equals("edit")) {

        sql = "update ACTIVITY_INFO set title = ? , body = ?, ISVISIBLE = ?, ISSELECTED = ?, ISPUBLIC = ? where deleted = 0 and id=" + id;
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, play_title);
        pstmt.setNClob(2, nclob);
        pstmt.setInt(3, Integer.parseInt(isvisible, 10));
        pstmt.setInt(4, Integer.parseInt(isselect, 10));
        pstmt.setInt(5, Integer.parseInt(sispublic));
        pstmt.execute();
        pstmt.close();

    } 
	else if (act.equals("delete")) {
        if (nID != 0) {
            //sql = "delete from activity_info where id = " + id;
            sql = "update activity_info set deleted = 1 where id = " + nID;
            stmt.executeQuery(sql);

            //sql = "delete from activity_image where aid = " + id;
            sql = "update activity_image set deleted = 1 where aid = " + nID;
            stmt.executeQuery(sql);
        }

        stmt.close();
    } 
	else if (act.equals("deleteall")) {
        if (ids.length() > 0) {
            String[] id_data = ids.split(",");
            if (id_data.length > 0) {
                for (int i = 0; i < id_data.length; i++) {
                    if (!id_data[i].equals("0")) {
                        sql = "update activity_info set deleted = 1 where id = " + id_data[i];
                        stmt.executeQuery(sql);


                        sql = "update activity_image set deleted = 1 where aid = " + id_data[i];
                        stmt.executeQuery(sql);
                    }

                }
            }
        }
    }
    conn.close();

    out.println("<script>window.location.href='activity.jsp';</script>");

%>
