<%-- 
    Document   : activity_add
    Created on : Dec 25, 2013, 6:27:19 PM
    Author     : KIMSUI
--%>

<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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

    String act = (request.getParameter("act") == "") ? "add" : request.getParameter("act");
    int id = Integer.parseInt((request.getParameter("id") == "") ? "0" : request.getParameter("id"), 10);
    int imagechanged = Integer.parseInt((request.getParameter("imagechanged") == "") ? "0" : request.getParameter("imagechanged"), 10);
    String product_name = (request.getParameter("tmp_product_name") == "") ? "" : request.getParameter("tmp_product_name");
    int product_marketprice = Integer.parseInt((request.getParameter("tmp_product_marketprice") == "") ? "0" : request.getParameter("tmp_product_marketprice"), 10);
    int product_comprice = Integer.parseInt((request.getParameter("tmp_product_comprice") == "") ? "0" : request.getParameter("tmp_product_comprice"), 10);
    int product_integralprice = Integer.parseInt((request.getParameter("tmp_product_integralprice") == "") ? "0" : request.getParameter("tmp_product_integralprice"), 10);
    int product_totalsecure = Integer.parseInt((request.getParameter("tmp_product_totalsecure") == "") ? "0" : request.getParameter("tmp_product_totalsecure"), 10);
    int product_isvisible = Integer.parseInt((request.getParameter("tmp_product_isvisible") == "") ? "0" : request.getParameter("tmp_product_isvisible"), 10);
    String product_property = (request.getParameter("tmp_product_property") == "") ? "" : request.getParameter("tmp_product_property");
    String product_detail = (request.getParameter("tmp_product_detail") == "") ? "" : request.getParameter("tmp_product_detail");
    String page_num = (request.getParameter("tmp_pagenum") == "") ? "0" : request.getParameter("tmp_pagenum");
    String page_count = (request.getParameter("tmp_pagecount") == "") ? "10" : request.getParameter("tmp_pagecount");

    String sispublic = request.getParameter("ispublic");

    java.sql.NClob nclob1 = conn.createNClob();
    byte[] utf8bytes = product_property.getBytes("UTF8");
    nclob1.setString(1, new String(utf8bytes, "UTF8"));

    java.sql.NClob nclob2 = conn.createNClob();
    byte[] utf8bytes1 = product_detail.getBytes("UTF8");
    nclob2.setString(1, new String(utf8bytes1, "UTF8"));

    String[] imagepath = new String[7];

    int i;
    for (i = 0; i < 7; i++) {
        imagepath[i] = (request.getParameter("tmp_imagepath" + i) == null) ? "" : request.getParameter("tmp_imagepath" + i);
    }


    String tmpimagepath = "";

    Date tmp = new Date();
    java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
    int tmpmain = 0;
    int tmpiid = 0;

    if (act.equals("add")) {
        sql = "select MAX(ID) from PRODUCT_INFO";
        rs = stmt.executeQuery(sql);

        int newID = 0;

        if (rs.next()) {
            newID = rs.getInt(1);
        }

        rs.close();

        newID++;

        {
            sql = "select MAX(ID) from PRODUCT_IMAGE";
            rs = stmt.executeQuery(sql);
            int nextID = 0;
            if (rs.next()) {
                nextID = rs.getInt(1);
            }
            nextID++;
            rs.close();

            for (i = 0; i < 7; i++) {
                if (!imagepath[i].equals("")) {
                    if (i == 0) {
                        tmpmain = 1;
                    } else {
                        tmpmain = 0;
                    }

                    Date today = new Date();

                    String tmpStr = today.toString();

                    String tmpPath = "upload_data/product/" +  makeUploadDirName() + "/";

                    File tmpDir = new File("webapps/wljy/" + tmpPath);
                    if (!tmpDir.exists()) {
                        tmpDir.mkdir();
                    }

                    String tmpImgPath = tmpPath + newID + "_" + makeUploadFileNamePrefix(imagepath[i]);//(tmpStr.substring(24, 28)) + (tmpStr.substring(4, 7)) + (tmpStr.substring(8, 10)) + "_" + imagepath[i].substring(4);

                    File fileTo = new File("webapps/wljy/" + tmpImgPath);
                    File fileFrom = new File("webapps/wljy/upload_data/product/" + imagepath[i]);
                    fileFrom.renameTo(fileTo);
                    File fileFrom1 = new File("webapps/wljy/upload_data/product/" + imagepath[i]);
                    fileFrom1.delete();
                    imageresize(fileTo.getPath());

                    sql = "INSERT INTO PRODUCT_IMAGE(ID, PID, DATAPATH, ISMAIN) VALUES(" + nextID + ", " + newID + ", '" + tmpImgPath + "', " + tmpmain + ")";
                    stmt.executeQuery(sql);
                    if (tmpmain == 1) {
                        tmpiid = nextID;
                    }
                } else {
                    if (i == 0) {
                        sql = "INSERT INTO PRODUCT_IMAGE(ID, PID, DATAPATH, ISMAIN) VALUES(" + nextID + ", " + newID + ", '', 1)";
                    } else {
                        sql = "INSERT INTO PRODUCT_IMAGE(ID, PID, DATAPATH, ISMAIN) VALUES(" + nextID + ", " + newID + ", '', 0)";
                    }
                    stmt.executeQuery(sql);
                }
                nextID++;
            }
        }


        sql = "Insert into PRODUCT_INFO (ID, NAME, TYPE, IID, MARKET_PRICE, INTEGRAL_PRICE, TOTAL_SECURE, PROPERTY, DETAIL, ISVISIBLE, COMPRICE, ISPUBLIC) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, newID);
        pstmt.setString(2, product_name);
        pstmt.setInt(3, 1);
        pstmt.setInt(4, tmpiid);
        pstmt.setInt(5, product_marketprice);
        pstmt.setInt(6, product_integralprice);
        pstmt.setInt(7, product_totalsecure);
        pstmt.setNClob(8, nclob1);
        pstmt.setNClob(9, nclob2);
        pstmt.setInt(10, product_isvisible);
        pstmt.setInt(11, product_comprice);

        pstmt.setInt(12, Integer.parseInt(sispublic));

        pstmt.execute();
        rs.close();
        pstmt.close();
        stmt.close();
    } else if (act.equals("edit")) {

        sql = "update PRODUCT_INFO set NAME = ?, MARKET_PRICE = ?, INTEGRAL_PRICE = ?, TOTAL_SECURE = ?, PROPERTY = ?, DETAIL = ?, ISVISIBLE = ?, COMPRICE = ?, ISPUBLIC = ? where id=" + id;
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, product_name);
        pstmt.setInt(2, product_marketprice);
        pstmt.setInt(3, product_integralprice);
        pstmt.setInt(4, product_totalsecure);
        pstmt.setNClob(5, nclob1);
        pstmt.setNClob(6, nclob2);
        pstmt.setInt(7, product_isvisible);
        pstmt.setInt(8, product_comprice);

        pstmt.setInt(9, Integer.parseInt(sispublic));

        pstmt.execute();

        if (imagechanged == 1) {

            sql = "select MAX(ID) from PRODUCT_IMAGE";
            rs = stmt.executeQuery(sql);
            int nextID = 0;
            if (rs.next()) {
                nextID = rs.getInt(1);
            }
            nextID++;
            rs.close();

            int xxx = 0;
            int[] image_ids = new int[7];

            sql = "select ID from PRODUCT_IMAGE where PID=" + id + " order by id";
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                image_ids[xxx] = rs.getInt("ID");
                xxx++;
            }

            for (i = 0; i < 7; i++) {
                if (!imagepath[i].equals("")) {
                    if (i == 0) {
                        tmpmain = 1;
                    } else {
                        tmpmain = 0;
                    }


                    sql = "select DATAPATH from PRODUCT_IMAGE where ID=" + image_ids[i];
                    rs = stmt.executeQuery(sql);
                    String oldPath = "";
                    if (rs.next()) {
                        oldPath = rs.getString("datapath");
                    }
                    if (oldPath != "") {
                        File oldFile = new File("webapps/wljy/" + oldPath);
                        oldFile.delete();
                    }

                    String tmpPath = "upload_data/product/" +  makeUploadDirName() + "/";

                    File tmpDir = new File("webapps/wljy/" + tmpPath);
                    if (!tmpDir.exists()) {
                        tmpDir.mkdir();
                    }

                    String tmpImgPath = tmpPath + id + "_" + makeUploadFileNamePrefix(imagepath[i]);//(tmpStr.substring(24, 28)) + (tmpStr.substring(4, 7)) + (tmpStr.substring(8, 10)) + "_" + imagepath[i].substring(4);

                    File fileTo = new File("webapps/wljy/" + tmpImgPath);
                    File fileFrom = new File("webapps/wljy/upload_data/product/" + imagepath[i]);
                    fileFrom.renameTo(fileTo);
                    File fileFrom1 = new File("webapps/wljy/upload_data/product/" + imagepath[i]);
                    fileFrom1.delete();
                    imageresize(fileTo.getPath());

                    sql = "update PRODUCT_IMAGE set DATAPATH = '" + tmpImgPath + "' where ID=" + image_ids[i];
                    stmt.executeQuery(sql);
                }
            }
        }


        pstmt.close();

    } else if (act.equals("delete")) {

        if (id != 0) {
            //sql = "delete from PRODUCT_INFO where id = " + id;
            sql = "update PRODUCT_INFO set deleted = 1 where id = " + id;
            stmt.executeQuery(sql);

            //sql = "delete from PRODUCT_IMAGE where pid = " + id;
            sql = "update PRODUCT_IMAGE set deleted = 1 where pid = " + id;
            stmt.executeQuery(sql);
        }

        stmt.close();

    } else if (act.equals("deleteall")) {
        String ids = request.getParameter("ids") == null ? "" : request.getParameter("ids");
        if (ids.length() > 0) {
            String[] id_data = ids.split(",");
            if (id_data.length > 0) {
                for (i = 0; i < id_data.length; i++) {
                    if (!id_data[i].equals("0")) {
                        sql = "update PRODUCT_INFO set deleted = 1 where id = " + id_data[i];
                        stmt.executeQuery(sql);

                        //sql = "delete from PRODUCT_IMAGE where pid = " + id;
                        sql = "update PRODUCT_IMAGE set deleted = 1 where id = " + id_data[i];
                        stmt.executeQuery(sql);
                    }

                }
                stmt.close();
            }
        }
    }

    conn.close();

    out.println("<script>window.location.href='commodity.jsp?page=" + page_num + "&row=" + page_count + "';</script>");

%>
