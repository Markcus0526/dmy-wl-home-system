<%-- 
    Document   : user_add
    Created on : Jan 9, 2014, 2:52:03 PM
    Author     : KIMSUI
--%>

<%@page import="jxl.Cell"%>
<%@page import="jxl.Sheet"%>
<%@page import="jxl.Workbook"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.File"%>

<%@include file="cookie_check.jsp" %>
<%@ include file="../connection.jsp" %>
<%@page import="java.util.Date"%>
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

    Statement stmt = conn.createStatement();
    String sql = new String();
    ResultSet rs;

    String act = (request.getParameter("act") == null) ? "add" : request.getParameter("act");
    String name = (request.getParameter("name") == null) ? "" : request.getParameter("name");
    String namepassword = (request.getParameter("namepassword") == null) ? "" : request.getParameter("namepassword");
    String nickname = (request.getParameter("nickname") == null) ? "" : request.getParameter("nickname");
    String userid = (request.getParameter("userid") == null) ? "" : request.getParameter("userid");
    String password = (request.getParameter("password") == null) ? "123456" : request.getParameter("password");
    String sintegral = (request.getParameter("integral") == null) ? "0" : request.getParameter("integral");
    if (sintegral == null || sintegral.length() == 0) {
        sintegral = "0";
    }
    //int integral = Integer.parseInt(sintegral, 10);
    String phonenum = (request.getParameter("phonenum") == null) ? "" : request.getParameter("phonenum");
    String email = (request.getParameter("email") == null) ? "" : request.getParameter("email");
    String registip = (request.getParameter("registip") == null) ? "" : request.getParameter("registip");
    String privilege = (request.getParameter("tmp_privilege") == null) ? "0" : request.getParameter("tmp_privilege");
    String part = (request.getParameter("part") == null) ? "" : request.getParameter("part");
    String section = (request.getParameter("section") == null) ? "" : request.getParameter("section");
    String fileimagepath = (request.getParameter("tmp_image") == null) ? "" : request.getParameter("tmp_image");
    String page_num = (request.getParameter("tmp_pagenum") == "") ? "0" : request.getParameter("tmp_pagenum");
    String page_count = (request.getParameter("tmp_pagecount") == "") ? "10" : request.getParameter("tmp_pagecount");
    String xlspath = request.getParameter("realxlsfile");

    int id = Integer.parseInt((request.getParameter("id") == null) ? "0" : request.getParameter("id"), 10);

    if (fileimagepath.length() > 3) {
        fileimagepath = fileimagepath.substring(3);
    }
    String imagepath = new String();

    String imageChanged = request.getParameter("imageChanged");

    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

    if (act.equals("add")) {
        sql = "select MAX(ID) from MEMBERINFO";
        rs = stmt.executeQuery(sql);
        int newID = 0;
        if (rs.next()) {
            newID = rs.getInt(1);
        }
        rs.close();
        stmt.close();

        newID++;

        if (xlspath != null && xlspath.length() > 0) {
            File file = new File("webapps/wljy/upload_data/member_info/" + xlspath);
            if (file.exists()) {
                Workbook w;
                try {
                    w = Workbook.getWorkbook(file);
                    Sheet sheet = w.getSheet(0);

                    int nRows = sheet.getRows();
                    int nCols = sheet.getColumns();

                    for (int row = 1; row < nRows - 1; row++) {
                        sql = "Insert into MEMBERINFO (ID, NAMEPASSWORD, USERID, PASSWORD, PHOTO, INTEGRAL, REGISTDATE, LASTLOGINDATE, PHONENUM, EMAILADDRESS, REGISTIPADDRESS, PRIVILEGE, PART, SECTION, NICKNAME, NAME, DELETED, FIRSTLOGIN) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0)";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, newID);

                        Cell cell = sheet.getCell(0, row);
                        pstmt.setString(2, cell.getContents().toString());

                        pstmt.setString(3, "");
                        pstmt.setString(4, "123456");
                        pstmt.setString(5, "img/defimg.png");
                        pstmt.setInt(6, 0);
                        pstmt.setTimestamp(7, d);
                        pstmt.setTimestamp(8, d);
                        pstmt.setString(9, "");
                        pstmt.setString(10, "");
                        pstmt.setString(11, "");
                        pstmt.setInt(12, 1);

                        cell = sheet.getCell(2, row);
                        pstmt.setString(13, cell.getContents().toString());

                        cell = sheet.getCell(3, row);
                        pstmt.setString(14, cell.getContents().toString());

                        cell = sheet.getCell(1, row);
                        pstmt.setString(15, cell.getContents().toString());

                        pstmt.setString(16, "xxx");

                        pstmt.execute();
                        pstmt.close();

                        newID++;
                    }
                } catch (Exception e) {
                    out.println("<script>alert('文件格式错误')</script>");
                }
            }
        } else {
            if (fileimagepath != null && fileimagepath.length() > 0) {
                int ind = fileimagepath.indexOf("_tmp_") + 5;
                imagepath = "upload_data/member_info/" + UserId + "_" + newID + "_" + makeUploadFileNamePrefix(fileimagepath);//fileimagepath.substring(ind);
                File fileTo = new File("webapps/wljy/" + imagepath);
                File fileFrom = new File("webapps/wljy/" + fileimagepath);
                fileFrom.renameTo(fileTo);
                imageresize(fileTo.getPath());
            }

            Statement mystmt = conn.createStatement();
            sql = "select count(*) as count from memberinfo where namepassword = '" + namepassword + "' and deleted = 0";
            if (userid != null && userid.length() > 0) {
                sql = sql + " and userid = '" + userid + "'";
            }
            ResultSet myrs = mystmt.executeQuery(sql);
            if (!myrs.next() || myrs.getInt("count") == 0) {
                stmt = conn.createStatement();
                sql = "select count(*) as count from MEMBERINFO where userid = '" + userid + "'";
                rs = stmt.executeQuery(sql);
                if (!rs.next() || rs.getInt("count") == 0) {
                    sql = "Insert into MEMBERINFO (ID, NAME, USERID, PASSWORD, PHOTO, INTEGRAL, REGISTDATE, LASTLOGINDATE, PHONENUM, EMAILADDRESS, REGISTIPADDRESS, PRIVILEGE, PART, SECTION, NICKNAME, NAMEPASSWORD, DELETED, FIRSTLOGIN) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0)";
                    PreparedStatement pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, newID);
                    pstmt.setString(2, name);
                    pstmt.setString(3, userid);
                    pstmt.setString(4, "123456");
                    if (imagepath == null || imagepath.length() == 0 || imagepath.equals("null")) {
                        pstmt.setString(5, "img/defimg.png");
                    } else {
                        pstmt.setString(5, imagepath);
                    }
                    //pstmt.setInt(6, Integer.parseInt(sintegral, 10));
                    pstmt.setInt(6, 0);
                    pstmt.setTimestamp(7, d);
                    pstmt.setTimestamp(8, null);
                    pstmt.setString(9, phonenum);
                    pstmt.setString(10, email);
                    pstmt.setString(11, registip);
                    pstmt.setInt(12, Integer.parseInt(privilege, 10));
                    pstmt.setString(13, part);
                    pstmt.setString(14, section);
                    pstmt.setString(15, nickname);
                    pstmt.setString(16, namepassword);
                    pstmt.execute();
                    pstmt.close();
                } else {
                    out.println("<script>alert('账号已经存在.');</script>");
                }
            } else {
                out.println("<script>alert('账号已经存在.');</script>");
                myrs.close();
                mystmt.close();
            }
        }
    } else if (act.equals("edit")) {
        Statement mystmt = conn.createStatement();
        sql = "select count(*) as count from memberinfo where namepassword = '" + namepassword + "' and deleted = 0 and id != " + id;
        if (userid != null && userid.length() > 0) {
            sql = sql + " and userid = '" + userid + "'";
        }
        ResultSet myrs = mystmt.executeQuery(sql);
        if (!myrs.next() || myrs.getInt("count") == 0) {
            stmt = conn.createStatement();
            sql = "select count(*) as count from MEMBERINFO where userid = '" + userid + "' and deleted = 0 and id != " + id;
            rs = stmt.executeQuery(sql);
            if (!rs.next() || rs.getInt("count") == 0) {
                if (imageChanged.equals("1")) {
                    int ind = fileimagepath.indexOf("_tmp_") + 5;
                    imagepath = "upload_data/member_info/" + UserId + "_" + id + "_" + makeUploadFileNamePrefix(fileimagepath);//fileimagepath.substring(ind);
                    File fileTo = new File("webapps/wljy/" + imagepath);
                    File fileFrom = new File("webapps/wljy/" + fileimagepath);
                    fileFrom.renameTo(fileTo);
                    imageresize(fileTo.getPath());
                } else {
                    imagepath = fileimagepath;
                }


                sql = "update MEMBERINFO set name = ? , userid = ?, password = ?, photo = ? , integral = ?, phonenum = ?, emailaddress = ?, registipaddress = ?, privilege = ?, part = ?, section = ?, nickname = ?, namepassword = ? where id=" + id;
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name);
                pstmt.setString(2, userid);
                pstmt.setString(3, password);
                if (imagepath != null && imagepath.equals("upload_data/member_info/")) {
                    pstmt.setString(4, "");
                } else {
                    pstmt.setString(4, imagepath);
                }
                pstmt.setInt(5, Integer.parseInt(sintegral, 10));
                pstmt.setString(6, phonenum);
                pstmt.setString(7, email);
                pstmt.setString(8, registip);
                pstmt.setInt(9, Integer.parseInt(privilege, 10));
                pstmt.setString(10, part);
                pstmt.setString(11, section);
                pstmt.setString(12, nickname);
                pstmt.setString(13, namepassword);


                pstmt.execute();
                pstmt.close();
            } else {
                out.println("<script>alert('账号已经存在.');</script>");
            }

        } else {
            out.println("<script>alert('账号已经存在.');</script>");
            myrs.close();
            mystmt.close();
        }
    } else if (act.equals("delete")) {
        if (id != 0) {
            sql = "update MEMBERINFO set DELETED = 1 where id = " + id;
            stmt.executeQuery(sql);
        }

        stmt.close();
    } else if (act.equals("deleteall")) {
        String ids = request.getParameter("ids") == null ? "" : request.getParameter("ids");
        if (ids.length() > 0) {
            String[] id_data = ids.split(",");
            if (id_data.length > 0) {
                for (int i = 0; i < id_data.length; i++) {
                    if (!id_data[i].equals("0")) {
                        sql = "update MEMBERINFO set DELETED = 1 where id = " + id_data[i];
                        stmt.executeQuery(sql);
                    }

                }
            }
        }
        stmt.close();
    }

    conn.close();

    out.println("<script>window.location.href='user.jsp?row=" + page_count + "&page=" + page_num + "';</script>");

%>
