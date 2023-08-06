<%-- 
    Document   : study_addinfo
    Created on : Dec 25, 2013, 5:28:33 PM
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
<%    
    Cookie[] cookies = request.getCookies();
    String tmp_str= "";
    for(int i = 0;i<cookies.length;i++) {
       String name=cookies[i].getName();
       int pos=name.indexOf('#');
       if(pos != -1) {
           if(name.substring(0, pos).equals("wljyadminid"))
           {
                 tmp_str=name.substring(pos+1);
                 break;
           }
       }
    }
    int UserId = Integer.parseInt(tmp_str, 10);
    
    request.setCharacterEncoding("UTF-8");
    
    String spage = request.getParameter("page"); if(spage == null) spage = "1";
    String scount = request.getParameter("count"); if(spage == null) scount = "10";
    
    String action = request.getParameter("action");
    
    String strId = request.getParameter("id");
    String smid = request.getParameter("mid");
    String title = request.getParameter("title");
    String stype = request.getParameter("type");
    String file_imagepath = request.getParameter("imagepath");
    
    String sispublic = request.getParameter("ispublic");
    
    String body = request.getParameter("body");
    java.sql.NClob nclob = conn.createNClob();
    byte[] utf8bytes = body.getBytes("UTF8");
    nclob.setString(1, new String(utf8bytes, "UTF8"));  
    
    String file_datapath = request.getParameter("datapath");
    String sreadcount = request.getParameter("readcount");
    String senabled = request.getParameter("enabled");
    String sisVisible = request.getParameter("isVisible");
    String sintegral = request.getParameter("integral");
    
    String imageChanged = request.getParameter("imageChanged");
    String dataChanged = request.getParameter("dataChanged");
    
    if(action.equals("add")) {
        Statement stmt = conn.createStatement();

        String sql = new String();
        ResultSet rs = null;

        sql = "select max(id) from study_qinfo";
        rs = stmt.executeQuery(sql);
        int max_id = 1;
        if (rs.next()) 
            max_id = rs.getInt(1);
        rs.close();
        stmt.close();

        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        sql = "Insert into study_qinfo (ID, MID, TITLE, TYPE, IMAGEPATH, BODY, POSTDATE, DATAPATH, READCOUNT, ENABLED, ISVISIBLE, INTEGRAL, ISPUBLIC) VALUES ("
                + "?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql); 

        pstmt.setInt(1, max_id + 1);
        pstmt.setInt(2, 0);
        pstmt.setString(3, title);
        pstmt.setInt(4, Integer.parseInt(stype));

        String imagepath = new String();
        if(file_imagepath != null && file_imagepath.length() > 0) {
            
            int ind = file_imagepath.indexOf("_tmp_") + 5;
            

            String tmpPath = "upload_data/study/"+ makeUploadDirName()+"/";
                
            File tmpDir = new File("webapps/wljy/"+tmpPath);
            if ( !tmpDir.exists() )
                tmpDir.mkdir();
            
            max_id = max_id +1;
            String tmpImgpath = tmpPath + UserId + "_" + max_id + "_" + makeUploadFileNamePrefix(file_imagepath);//(tmpStr.substring(24, 28))+(tmpStr.substring(4, 7))+(tmpStr.substring(8, 10))+"_"+file_imagepath.substring(ind);            
            imagepath = tmpImgpath;
            
            File fileTo = new File("webapps/wljy/" + tmpImgpath);
            File fileFrom = new File("webapps/wljy/upload_data/study/" + file_imagepath);
            fileFrom.renameTo(fileTo);
            File fileFrom1 = new File("webapps/wljy/upload_data/study/" + file_imagepath);
            fileFrom1.delete();
            imageresize(fileTo.getPath());
        }
        pstmt.setString(5, imagepath);

        pstmt.setNClob(6, nclob);    
        pstmt.setTimestamp(7, d);
        
        String datapath = new String();
        if(file_datapath != null && file_datapath.length() > 0) {

            int ind = file_imagepath.indexOf("_tmp_") + 5;
            
            Date today = new Date();

            String tmpStr = today.toString();

            String tmpPath = "upload_data/study/"+ makeUploadDirName()+"/";
                
            File tmpDir = new File("webapps/wljy/"+tmpPath);
            if ( !tmpDir.exists() )
                tmpDir.mkdir();

            String tmpImgpath = tmpPath + UserId + "_" + max_id + "_" + makeUploadFileNamePrefix(file_datapath);//(tmpStr.substring(24, 28))+(tmpStr.substring(4, 7))+(tmpStr.substring(8, 10))+"_"+file_datapath.substring(ind);            
            datapath = tmpImgpath;
                        
            File fileTo = new File("webapps/wljy/" + tmpImgpath);
            File fileFrom = new File("webapps/wljy/upload_data/study/" + file_datapath);
            fileFrom.renameTo(fileTo);            
            File fileFrom1 = new File("webapps/wljy/upload_data/study/" + file_datapath);
            fileFrom1.delete();

                                                        
        }
        pstmt.setString(8, datapath);

        pstmt.setInt(9, 0);   
        pstmt.setInt(10, 1);
        pstmt.setInt(11, Integer.parseInt(sisVisible, 10));
        pstmt.setInt(12, Integer.parseInt(sintegral, 10));
        
         pstmt.setInt(13, Integer.parseInt(sispublic));

        pstmt.execute();

        pstmt.close();
    } else if(action.equals("delete")) {
        if(strId != null) {
            int id = Integer.parseInt(strId);
            
            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();
            //String sql = "delete from STUDY_QINFO where id = " + id;
			String sql = "update STUDY_QINFO set deleted = 1 where id = " + id;
            ResultSet rs = stmt.executeQuery(sql);
            rs.close();
            //sql = "delete from STUDY_AINFO where sid = " + id;
			sql = "update STUDY_AINFO set deleted = 1 where id = " + id;
            rs = u_stmt.executeQuery(sql);
            stmt.close();
            u_stmt.close();
        }
               } else if (action.equals("deleteall")) {
        String ids = request.getParameter("ids") == null ? "" : request.getParameter("ids");
        if (ids.length() > 0) {
            String[] id_data = ids.split(",");
            if (id_data.length > 0) {
                        Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();
            String sql = "";
                for (int i = 0; i < id_data.length; i++) {
                    if (!id_data[i].equals("0")) {
                        sql = "update STUDY_QINFO set deleted = 1 where id = " + id_data[i];
            ResultSet rs = stmt.executeQuery(sql);
            rs.close();
            //sql = "delete from STUDY_AINFO where sid = " + id;
			sql = "update STUDY_AINFO set deleted = 1 where id = " + id_data[i];
            rs = u_stmt.executeQuery(sql);
                    }

                }
                        stmt.close();
            u_stmt.close();
            }
        }    
    } else if(action.equals("edit")) {
        Date tmp = new Date();
		java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        String sql = "update study_qinfo set TITLE = ?, TYPE = ?, IMAGEPATH = ?, BODY = ?, POSTDATE = ?, DATAPATH = ?, READCOUNT = ?, ENABLED = ?, ISVISIBLE = ?, INTEGRAL = ?, ISPUBLIC = ? where id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        
        String imagepath = new String();
        if(imageChanged.equals("0"))
            imagepath = file_imagepath;
        else {
            int ind = file_imagepath.indexOf("_tmp_") + 5;
            
            Date today = new Date();

            String tmpStr = today.toString();
                      
            String tmpPath = "upload_data/study/"+ makeUploadDirName()+"/";
            
            File tmpDir = new File("webapps/wljy/"+tmpPath);
            if ( !tmpDir.exists() )
                tmpDir.mkdir();
                   
            String tmpImgpath = tmpPath + UserId + "_" + strId + "_" + makeUploadFileNamePrefix(file_imagepath);//(tmpStr.substring(24, 28))+(tmpStr.substring(4, 7))+(tmpStr.substring(8, 10))+"_"+file_imagepath.substring(ind);            
            imagepath = tmpImgpath;
            
            File fileTo = new File("webapps/wljy/" + tmpImgpath);
            File fileFrom = new File("webapps/wljy/upload_data/study/" + file_imagepath);
            fileFrom.renameTo(fileTo);
            File fileFrom1 = new File("webapps/wljy/upload_data/study/" + file_imagepath);
            fileFrom1.delete();
            imageresize(fileTo.getPath());
            
            sql = "select imagepath from study_qinfo where deleted = 0 and id="+strId;
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            String oldPath = "";
            if (rs.next())
                oldPath = rs.getString("imagepath");
            if ( oldPath != "" )
            {
                File oldFile = new File("webapps/wljy/" + oldPath);
                oldFile.delete();
            }
        }

        pstmt.setString(1, title);
        pstmt.setInt(2, Integer.parseInt(stype));
        pstmt.setString(3, imagepath);
        pstmt.setNClob(4, nclob);    
        pstmt.setTimestamp(5, d);
        
        String datapath = new String();
        if(dataChanged.equals("0"))
            datapath = file_datapath;
        else {
            int ind = file_imagepath.indexOf("_tmp_") + 5;
            
            Date today = new Date();

            String tmpStr = today.toString();
                      
            String tmpPath = "upload_data/study/"+ makeUploadDirName() +"/";
            
            File tmpDir = new File("webapps/wljy/"+tmpPath);
            if ( !tmpDir.exists() )
                tmpDir.mkdir();
                   
            String tmpImgpath = tmpPath + UserId + "_" + strId + "_" + makeUploadFileNamePrefix(file_datapath);//(tmpStr.substring(24, 28))+(tmpStr.substring(4, 7))+(tmpStr.substring(8, 10))+"_"+file_datapath.substring(ind);            
            datapath = tmpImgpath;
            
            File fileTo = new File("webapps/wljy/" + datapath);
            File fileFrom = new File("webapps/wljy/upload_data/study/" + file_datapath);
            fileFrom.renameTo(fileTo); 
            File fileFrom1 = new File("webapps/wljy/upload_data/study/" + file_datapath);
            fileFrom1.delete();
            
            sql = "select datapath from study_qinfo where deleted = 0 and id="+strId;
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            String oldPath = "";
            if (rs.next())
                oldPath = rs.getString("datapath");
            if ( oldPath != "" )
            {
                File oldFile = new File("webapps/wljy/" + oldPath);
                oldFile.delete();
            }
        }
        pstmt.setString(6, datapath);
        pstmt.setInt(7, Integer.parseInt(sreadcount));   
        pstmt.setInt(8, Integer.parseInt(senabled));
        pstmt.setInt(9, Integer.parseInt(sisVisible));
        pstmt.setInt(10, Integer.parseInt(sintegral, 10));
        
        pstmt.setInt(11, Integer.parseInt(sispublic));
        pstmt.setInt(12, Integer.parseInt(strId));

        pstmt.execute();

        pstmt.close();
    }
        
    conn.close();
      
    out.println("<script>window.location.href='study.jsp?page=" + spage + "&count=" + scount + "';</script>");
%>
