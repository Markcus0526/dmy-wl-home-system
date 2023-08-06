<%-- 
    Document   : faq_addinfo
    Created on : Jan 4, 2014, 2:36:25 PM
    Author     : Hercules
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page language="Java" import="java.util.Date"%>
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
    
    String sispublic = request.getParameter("ispublic");
    
    String body = request.getParameter("body");
    java.sql.NClob nclob = conn.createNClob();
    byte[] utf8bytes = body.getBytes("UTF8");
    nclob.setString(1, new String(utf8bytes, "UTF8"));  
    
    String srewardintegral = request.getParameter("rewardintegral");
    String sreadcount = request.getParameter("readcount");
    String sisVisible = request.getParameter("isVisible");
        
    if(action.equals("add")) {
        Statement stmt = conn.createStatement();

        String sql = new String();
        ResultSet rs = null;

        sql = "select max(id) from PROBLEM_QINFO";
        rs = stmt.executeQuery(sql);
        int max_id = 1;
        if (rs.next()) 
            max_id = rs.getInt(1);
        rs.close();
        stmt.close();

        Date tmp = new Date();
java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        sql = "Insert into PROBLEM_QINFO (ID, MID, TITLE, TYPE, BODY, POSTDATE, REWARDINTEGRAL, READCOUNT, ISVISIBLE, ISPUBLIC) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql); 

        pstmt.setInt(1, max_id + 1);
        pstmt.setInt(2, 0);
        pstmt.setString(3, title);
        pstmt.setInt(4, Integer.parseInt(stype));
        pstmt.setNClob(5, nclob);    
        pstmt.setTimestamp(6, d);
        pstmt.setInt(7, Integer.parseInt(srewardintegral));   
        pstmt.setInt(8, 0);
        pstmt.setInt(9, Integer.parseInt(sisVisible));
        
        pstmt.setInt(10, Integer.parseInt(sispublic));

        pstmt.execute();

        pstmt.close();
    } else if(action.equals("delete")) {
        if(strId != null) {
            int id = Integer.parseInt(strId);
            
            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();
            //String sql = "delete from PROBLEM_QINFO where id = " + id;
			String sql = "update PROBLEM_QINFO set deleted = 1 where id = " + id;
            ResultSet rs = stmt.executeQuery(sql);
            rs.close();
            
            //sql = "delete from PROBLEM_AINFO where pid = " + id;
			sql = "update PROBLEM_AINFO set deleted = 1 where id = " + id;
            rs = u_stmt.executeQuery(sql);
            stmt.close();
            u_stmt.close();
        }
    }
     else if (action.equals("deleteall")) {
        String ids = request.getParameter("ids") == null ? "" : request.getParameter("ids");
        if (ids.length() > 0) {
            String[] id_data = ids.split(",");
            if (id_data.length > 0) {
                            Statement stmt = conn.createStatement();
            Statement u_stmt = conn.createStatement();
            String sql = "";
                for (int i = 0; i < id_data.length; i++) {
                    if (!id_data[i].equals("0")) {
                        sql = "update PROBLEM_QINFO set deleted = 1 where id = " + id_data[i];
            ResultSet rs = stmt.executeQuery(sql);
            rs.close();
            
            //sql = "delete from PROBLEM_AINFO where pid = " + id;
			sql = "update PROBLEM_AINFO set deleted = 1 where id = " + id_data[i];
            rs = u_stmt.executeQuery(sql);
                    }

                }
                    stmt.close();
            u_stmt.close();
            }
        }
    }
    else if(action.equals("edit")) {
        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

        String sql = "update PROBLEM_QINFO set MID = ?, TITLE = ?, TYPE = ?, BODY = ?, POSTDATE = ?, REWARDINTEGRAL = ?, READCOUNT = ?, ISVISIBLE = ?, ISPUBLIC = ? where ID = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        
        pstmt.setInt(1, UserId);
        pstmt.setString(2, title);
        pstmt.setInt(3, Integer.parseInt(stype));
        pstmt.setNClob(4, nclob);    
        pstmt.setTimestamp(5, d);
        pstmt.setInt(6, Integer.parseInt(srewardintegral));
        pstmt.setInt(7, Integer.parseInt(sreadcount));   
        pstmt.setInt(8, Integer.parseInt(sisVisible));
        
        pstmt.setInt(9, Integer.parseInt(sispublic));
        pstmt.setInt(10, Integer.parseInt(strId));

        pstmt.execute();

        pstmt.close();
    }
        
    conn.close();
      
    out.println("<script>window.location.href='faq.jsp?page=" + spage + "&count=" + scount + "';</script>");
%>
