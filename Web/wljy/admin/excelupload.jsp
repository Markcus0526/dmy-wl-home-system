<%-- 
    Document   : contact
    Created on : 10-Dec-2013, 10:01:33
    Author     : KIMSUI
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%@include file="cookie_check.jsp" %>
<%@page import="java.util.Date"%>
<%@page import="jxl.Cell"%>
<%@page import="jxl.write.WritableWorkbook"%>
<%@page import="jxl.write.WritableSheet"%>
<%@page import="jxl.write.Label"%>
<%@page import="jxl.Sheet"%>
<%@page import="jxl.Workbook"%>
<%@page import = "org.apache.commons.fileupload.FileUpload" %>
<%@page import = "org.apache.commons.fileupload.DiskFileUpload" %>
<%@page import = "org.apache.commons.fileupload.FileItem" %>
<%@page import = "java.io.File" %>
<%@page import = "java.io.BufferedInputStream" %>
<%@page import = "java.io.BufferedOutputStream" %>
<%@page import = "java.io.IOException" %>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.io.File"%>

<%!
public boolean isExcelFormat(String fileExtension){
	String extension = fileExtension.toLowerCase();
	
	if (extension.equals("xls"))
		return true;
        
	return false;
}
%>
<%
    request.setCharacterEncoding("UTF-8");

    String filePath = "excelpath";
    String fileName = "excelname";

	String xlspath = "";
    
    if (FileUpload.isMultipartContent(request)) {
        
        String temporaryDir = "C:\\";

        org.apache.commons.fileupload.DiskFileUpload fileUpload = new org.apache.commons.fileupload.DiskFileUpload();
        fileUpload.setRepositoryPath(temporaryDir);

        fileUpload.setSizeMax(1024*1024*1024);
        fileUpload.setSizeThreshold(1024*100);

        java.util.List fileItemList = fileUpload.parseRequest(request);
		
        for (int i = 0; i < fileItemList.size(); i++) {
            FileItem fileItem = (FileItem) fileItemList.get(i);
            if (fileItem.isFormField())
            {
                String strName = fileItem.getFieldName();				
                if (strName.equals(filePath))
				{					           
                    filePath = fileItem.getString("UTF-8");
				}
                else if (strName.equals(fileName))
				{
                    fileName = fileItem.getString("UTF-8");
				}
            }
            else
            {
                if ( fileItem.getSize() > 0) {
                  
                    int idx = fileItem.getName().lastIndexOf("\\");
                    if (idx==-1)
                    {
                        idx = fileItem.getName().lastIndexOf("/");
                    }

					try {
                        File uploadedFile = new File("webapps/wljy/"+filePath, fileName);
						if (uploadedFile.exists())
						{
							uploadedFile.delete();
							uploadedFile = new File("webapps/wljy/"+filePath, fileName);
						}
                        fileItem.write(uploadedFile);

                    } catch(IOException ex) {
                        out.println("<script>alert('不能上传');</script>"); 
                    }
                }
            }
        }

		Date tmp = new Date();
		java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

		Statement stmt = conn.createStatement();
		String sql = new String();
		ResultSet rs;
		sql = "select MAX(ID) from MEMBERINFO";
        rs = stmt.executeQuery(sql);

        int newID = 0;
        if (rs.next())
            newID = rs.getInt(1);
        rs.close();
        stmt.close();

        newID++;

		boolean bDuplex = false;
        if(fileName != null && fileName.length() > 0) 
		{
            File file = new File("webapps/wljy/upload_data/member_info/" + fileName);       
            if (file.exists()) 
			{
				WritableWorkbook wwb = null;
				WritableSheet ws = null;
				int nInsertPos = 1;
				try {
					wwb = Workbook.createWorkbook(new File("C:\\Result.xls"));  
				}
				catch (Exception ex) {}

				if(wwb!=null)
				{
					ws = wwb.createSheet("导入结果", 0);
					if (ws != null)
					{
						try {
							Label labelC1 = new Label(0, 0, "工号");
							Label labelC2 = new Label(1, 0, "姓名");
							Label labelC3 = new Label(2, 0, "用户名");
							Label labelC4 = new Label(3, 0, "昵称");
							ws.addCell(labelC1);
							ws.addCell(labelC2);
							ws.addCell(labelC3);
							ws.addCell(labelC4);
						}catch (Exception ex) {}
					}
				}

                Workbook w;
                try 
				{
                    w = Workbook.getWorkbook(file);
                    Sheet sheet = w.getSheet(0);

                    int nRows = sheet.getRows();
                    int nCols = sheet.getColumns();

                    for (int  row = 1; row < nRows; row++ )
                    {			
						String strBuf = "";
						String strUserID = "";
						String strGongHao = "";
						int nBuf = 0;

                        sql = "Insert into MEMBERINFO (ID, NAMEPASSWORD, USERID, PASSWORD, PHOTO, INTEGRAL, REGISTDATE, LASTLOGINDATE, PHONENUM, EMAILADDRESS, REGISTIPADDRESS, PRIVILEGE, PART, SECTION, NICKNAME, NAME, DELETED, FIRSTLOGIN) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0)";

                        PreparedStatement pstmt = conn.prepareStatement(sql); 
                        pstmt.setInt(1, newID);
                        Cell cell = sheet.getCell(0, row);
						strGongHao = cell.getContents().toString();
						if ( strGongHao == null || strGongHao.length() == 0 )
							continue;
						pstmt.setString(2, strGongHao);

						cell = sheet.getCell(4, row);
						strUserID = cell.getContents().toString();
						pstmt.setString(3, strUserID);
						cell = sheet.getCell(11, row);
						pstmt.setString(4, "123456");
                        pstmt.setString(5, "img/defimg.png");
						pstmt.setInt(6, 0);
                        pstmt.setTimestamp(7, d);
                        pstmt.setTimestamp(8, null);
						cell = sheet.getCell(7, row);
						pstmt.setString(9, cell.getContents().toString());
						cell = sheet.getCell(8, row);
						pstmt.setString(10, cell.getContents().toString());
                        pstmt.setString(11, "");
						cell = sheet.getCell(9, row);
						strBuf = cell.getContents().toString();
						try {
							nBuf = Integer.parseInt(strBuf, 10);
							if (nBuf > 1)
								nBuf = 1;
						}catch(Exception ex) {
							nBuf = 1;						}
						pstmt.setInt(12, nBuf);

                        cell = sheet.getCell(2, row);
                        pstmt.setString(13, cell.getContents().toString());

                        cell = sheet.getCell(3, row);                        
						strBuf = cell.getContents().toString();
						pstmt.setString(14, strBuf);

                        cell = sheet.getCell(1, row);
						strBuf = cell.getContents().toString();
						if (strBuf == null || strBuf.length() == 0)
							continue;
                        pstmt.setString(15, strBuf);

						cell = sheet.getCell(5, row);
						strBuf = cell.getContents().toString();
						if ( strBuf == null || strBuf.length() == 0)
	                        pstmt.setString(16, " ");
						else
							pstmt.setString(16, cell.getContents().toString());

						Statement stmt1 = conn.createStatement();
						String sql1 = new String();
						ResultSet rs1;
						sql1 = "select count(*) as count from MEMBERINFO WHERE NAMEPASSWORD = '" + strGongHao + "' AND DELETED = 0";
						if ( strUserID != null && strUserID.length() > 0 )
							sql1 = "select count(*) as count from MEMBERINFO WHERE (NAMEPASSWORD = '" + strGongHao + "' OR USERID = '" + strUserID + "') AND DELETED = 0";
						rs1 = stmt1.executeQuery(sql1);
						
						if(rs1.next())
						{
							if ( rs1.getInt("count") == 0 )
							{
								pstmt.execute();
								pstmt.close();
								newID ++;
							}
							else
							{
								if (ws != null)
								{
									try {
										bDuplex = true;
										Label labelC1 = new Label(0, nInsertPos, sheet.getCell(0, row).getContents().toString());
										Label labelC2 = new Label(1, nInsertPos, sheet.getCell(1, row).getContents().toString());
										Label labelC3 = new Label(2, nInsertPos, sheet.getCell(4, row).getContents().toString());
										Label labelC4 = new Label(3, nInsertPos, sheet.getCell(5, row).getContents().toString());
										ws.addCell(labelC1);
										ws.addCell(labelC2);
										ws.addCell(labelC3);
										ws.addCell(labelC4);
										nInsertPos++;									
									}catch (Exception ex) {}
								}

								pstmt.close();
							}
						}
						rs1.close();
						stmt1.close();
                    }

					try {     
						wwb.write();
						wwb.close();

						if (bDuplex == false)
							out.println("<script>alert('批量导入会员成功！')</script>");
						else
						{
							response.setDateHeader("Expires", 0);
							response.setHeader("Pragma", "no-cache");
							response.setHeader("Cache-Control", "no-cache,must-revalidate");

							String fPath = "C:\\Result.xls";
							File f = new File(fPath);
							long l = f.length();
							String mtitle = "导入失败资料";
							char ch = '\\';
							String fName = fPath.substring(fPath.lastIndexOf(ch) + 1);
							int idx2 = fName.lastIndexOf(".");
							String fileExtension = fName.substring(idx2 + 1);
							mtitle = mtitle + "." + fileExtension;

							String encName = URLEncoder.encode(mtitle, "utf-8");

							response.setContentType("application/octet-stream");
							response.setHeader("Content-charset", "utf-8; filename=" + encName);
							response.setHeader("Content-type", "application/octet-stream; filename=" + encName);
							response.setHeader("Content-Disposition", "attachment; filename=" + encName);
							response.setHeader("Refresh", "URL=http://localhost:8084/wljy/main.jsp");
							response.setContentLength((int) l);

							FileInputStream fis = new FileInputStream(f);
							ServletOutputStream os = response.getOutputStream();
							int len = 10 * 1024 * 1024;
							byte[] b = new byte[len];
							while (fis.read(b) != -1) {
								os.write(b);
								os.flush();
							}
							os.close();
							fis.close();
						}
					} catch (IOException e) {}
					
                } catch (Exception e) {
                    out.println("<script>alert('文件格式错误')</script>");
                }

				out.println("<script>window.location.href='user.jsp?row=10&page=1'</script>");
            }
		}
    }

%>
