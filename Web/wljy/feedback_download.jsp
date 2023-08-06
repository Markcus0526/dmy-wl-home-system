<%-- 
    Document   : download
    Created on : Dec 26, 2013, 7:50:16 PM
    Author     : KIMSUI
--%>


<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.io.File"%>
<%@ include file="connection.jsp" %>
<%@page import="java.util.Date"%>
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
    int qid = Integer.parseInt((request.getParameter("id") == null) ? "" : request.getParameter("id"), 10);
    String data_info = new String();
    String mtitle = "";
    String sql = "select * from opinion where id = " + qid;
    ResultSet rs = stmt.executeQuery(sql);
    if (rs.next()) {
        data_info = rs.getString("datapath");
        mtitle = rs.getString("title");
    }
    String fPath = "webapps/wljy/" + data_info;

    if (fPath != null && !fPath.equals("")) {
        File f = new File(fPath);
        if (!f.exists()) {
            out.println("<script>alert('" + fPath + " 文件不存在.');window.location.href='feedback_info.jsp?id=" + qid + "';</script>");
        } else {
            long l = f.length();
            long maxSize = 2 * 1024 * 1024 * 1024 - 1;


            if (l < maxSize) {
                response.setDateHeader("Expires", 0);
                response.setHeader("Pragma", "no-cache");
                response.setHeader("Cache-Control", "no-cache,must-revalidate");

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

            } else {
                out.println("<script>alert('无法下载.');window.location.href='feedback_info.jsp?id=" + qid + "';</script>");
            }
        }
    } else {
        out.println("<script>alert('无下载文件.');window.location.href='feedback_info.jsp?id=" + qid + "';</script>");
    }

%>
