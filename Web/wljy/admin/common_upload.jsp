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
<%!
public boolean isImageFormat(String fileExtension){
	String extension = fileExtension.toLowerCase();

	if (extension.equals("jpg"))
		return true;
	if (extension.equals("bmp"))
		return true;
	if (extension.equals("png"))
		return true;
	if (extension.equals("gif"))
		return true;
        
	return false;
}

public boolean isVideoFormat(String fileExtension){
	String extension = fileExtension.toLowerCase();
	
	if (extension.equals("flv"))
		return true;
	if (extension.equals("mp4"))
		return true;
        
	return false;
}
public boolean isExcelFormat(String fileExtension){
	String extension = fileExtension.toLowerCase();
	
	if (extension.equals("xls"))
		return true;
        
	return false;
}
%>
<%
    request.setCharacterEncoding("UTF-8");

    String imagepath = "imagefilename";
    String filePath = "imagefilepath";
    String fileType = "fileType";
    String fileName = "";
    
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
                String fieldName = fileItem.getFieldName();
                if (fieldName.equals(imagepath))
				{					           
                    imagepath = fileItem.getString("UTF-8");
				}
                else if (fieldName.equals(filePath))
				{
                    filePath = fileItem.getString("UTF-8");					
				}
                else if (fieldName.equals(fileType))
                    fileType = fileItem.getString("UTF-8");				
            }
            else
            {
                if ( fileItem.getSize() > 0) {
                  
                    int idx = fileItem.getName().lastIndexOf("\\");
                    if (idx==-1)
                    {
                        idx = fileItem.getName().lastIndexOf("/");
                    }

					fileName = imagepath;
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
    }

%>
