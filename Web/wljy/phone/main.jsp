<%-- 
    Document   : main
    Created on : 2014/1/15, 下午 02:06:46
    Author     : kimsui
--%>

<%@page import="org.json.simple.JSONObject"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../connection.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    JSONObject obj = new JSONObject();

    String userid = (request.getParameter("userid") == null) ? "0" : request.getParameter("userid");

    Statement stmt = conn.createStatement();
    String sql = "select * from memberinfo where deleted = 0 and id=" + Integer.parseInt(userid, 10);
    ResultSet rs = stmt.executeQuery(sql), rs1;

    if (!rs.next()) {
        obj.put("success", 0);
    } else {
        obj.put("success", 1);
        rs.close();

        Statement stmt1 = conn.createStatement();

        sql = "select * from (select * from ACTIVITY_INFO where deleted = 0 and type = 2 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') ORDER BY ID DESC) where ROWNUM <= 1";
        String sql1;
        rs = stmt.executeQuery(sql);
        int id = 0;
        String username = new String(), title = new String(), imagepath = new String();
        int readcount = 0;
        int mid = 0;
        while (rs.next()) {
            id = rs.getInt("id");
            mid = rs.getInt("mid");

            sql1 = "select * from memberinfo where id = " + mid;
            rs1 = stmt1.executeQuery(sql1);

            if (rs1.next()) {
                username = rs1.getString("name");
            }
            rs1.close();

            title = rs.getString("title");
            if (title.length() > 23) {
                title = title.substring(0, 20) + "...";
            }

            sql1 = "select DATAPATH from ACTIVITY_IMAGE where AID='" + id + "'";
            rs1 = stmt1.executeQuery(sql1);

            if (rs1.next()) {
                imagepath = rs1.getString("DATAPATH");
            } else {
                imagepath = "";
            }
            rs1.close();
            readcount = rs.getInt("readcount");

        }
        rs.close();

        JSONObject obj1 = new JSONObject(), obj2 = new JSONObject(), obj3 = new JSONObject(), obj4 = new JSONObject(), obj5 = new JSONObject();
        obj1.put("activity_id", id);
        obj1.put("activity_title", title);
        obj1.put("activity_user", username);
        obj1.put("activity_image", phoneImageSrc(imagepath));
        obj1.put("activity_readcount", readcount);
        obj.put("activity", obj1);

        sql = "select * from (select * from PROBLEM_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') ORDER BY ID DESC) where ROWNUM <= 1";
        rs = stmt.executeQuery(sql);


        while (rs.next()) {
            id = rs.getInt("ID");
            title = rs.getString("TITLE") == null ? "" : rs.getString("TITLE");

            if (title.length() > 23) {
                title = title.substring(0, 20) + "...";
            }
            mid = rs.getInt("mid");

            sql1 = "select * from memberinfo where id = " + mid;
            rs1 = stmt1.executeQuery(sql1);

            if (rs1.next()) {
                username = rs1.getString("name");
            }
            rs1.close();

            sql1 = "select PHOTO from MEMBERINFO where ID='" + rs.getInt("MID") + "'";
            rs1 = stmt1.executeQuery(sql1);

            if (rs1.next()) {
                imagepath = rs1.getString("PHOTO");
            } else {
                imagepath = "";
            }
            readcount = rs.getInt("readcount");
            rs1.close();
        }
        rs.close();

        obj2.put("faq_id", id);
        obj2.put("faq_title", title);
        obj2.put("faq_user", username);
        obj2.put("faq_image", phoneImageSrc(imagepath));
        obj2.put("faq_readcount", readcount);
        obj.put("faq", obj2);

        sql = "select * from (select * from SHARE_INFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') ORDER BY ID DESC) where ROWNUM <= 1";
        rs = stmt.executeQuery(sql);

        while (rs.next()) {
            id = rs.getInt("ID");
            mid = rs.getInt("mid");

            sql1 = "select * from memberinfo where id = " + mid;
            rs1 = stmt1.executeQuery(sql1);

            if (rs1.next()) {
                username = rs1.getString("name");
            }
            rs1.close();

            title = rs.getString("TITLE") == null ? "" : rs.getString("TITLE");

            if (title.length() > 23) {
                title = title.substring(0, 20) + "...";
            }

            sql1 = "select DATAPATH from SHARE_DATA where RID='" + id + "' and TYPE=0";
            rs1 = stmt1.executeQuery(sql1);

            if (rs1.next()) {
                imagepath = rs1.getString("DATAPATH");
            } else {
                imagepath = "";
            }

            rs1.close();

            readcount = rs.getInt("readcount");

        }
        rs.close();

        obj3.put("share_id", id);
        obj3.put("share_title", title);
        obj3.put("share_user", username);
        obj3.put("share_image", phoneImageSrc(imagepath));
        obj3.put("share_readcount", readcount);
        obj.put("share", obj3);

        sql = "select * from (select * from PRODUCT_INFO where deleted = 0 and ISVISIBLE=1 ORDER BY ID DESC) where ROWNUM <= 1";
        rs = stmt.executeQuery(sql);


        while (rs.next()) {
            id = rs.getInt("ID");
            title = rs.getString("NAME") == null ? "" : rs.getString("NAME");


            if (title.length() > 23) {
                title = title.substring(0, 20) + "...";
            }

            sql1 = "select DATAPATH from PRODUCT_IMAGE where PID='" + id + "'";
            rs1 = stmt1.executeQuery(sql1);

            if (rs1.next()) {
                imagepath = rs1.getString("DATAPATH");
            } else {
                imagepath = "";
            }

            rs1.close();


        }

        rs.close();

        obj4.put("exchange_id", id);
        obj4.put("exchange_title", title);
        obj4.put("exchange_user", "");
        obj4.put("exchange_image", phoneImageSrc(imagepath));
        obj.put("exchange", obj4);
        sql = "select * from (select * from STUDY_QINFO where deleted = 0 and ISVISIBLE=1 and TO_CHAR(postdate, 'YEAR') = TO_CHAR(sysdate, 'YEAR') ORDER BY ID DESC) where ROWNUM <= 1";
        rs = stmt.executeQuery(sql);


        while (rs.next()) {
            id = rs.getInt("ID");
            title = rs.getString("TITLE") == null ? "" : rs.getString("TITLE");
            imagepath = rs.getString("IMAGEPATH");
            mid = rs.getInt("mid");

            sql1 = "select * from memberinfo where id = " + mid;
            rs1 = stmt1.executeQuery(sql1);

            if (rs1.next()) {
                username = rs1.getString("name");
            }
            rs1.close();

            if (title.length() > 23) {
                title = title.substring(0, 20) + "...";
            }

            readcount = rs.getInt("readcount");
        }

        rs.close();

        obj5.put("study_id", id);
        obj5.put("study_title", title);
        obj5.put("study_user", username);
        obj5.put("study_image", phoneImageSrc(imagepath));
        obj5.put("study_readcount", readcount);
        obj.put("study", obj5);

        sql = "select count(*) from opinion where state = 0 and mid = " + Integer.parseInt(userid, 10);
        rs = stmt.executeQuery(sql);
        int feedback = 0;
        if (rs.next()) {
            feedback = rs.getInt(1);
        }
        obj.put("feedback", feedback);

    }
    out.println(obj.toJSONString());
    conn.close();

%>



