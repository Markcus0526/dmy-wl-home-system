<%@page import="org.json.simple.JSONObject"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Date"%>
<%@ include file="../connection.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");
    String userid = (request.getParameter("userid") == null) ? "" : request.getParameter("userid");
    String password = (request.getParameter("password") == null) ? "" : request.getParameter("password");
    String strIPAddress = request.getRemoteAddr();
    int login = -1;
    int privilege = 0;
    String username = new String();
	String photo = new String();
    int integral = 0;
    Date lastLoginDate = new Date(1, 11, 1);
    Statement stmt = conn.createStatement();
    String sql;
    ResultSet rs, rs1;
    /*
    sql = "select * from memberinfo where nickname ='" + userid + "' and password='" + password + "'";
    rs = stmt.executeQuery(sql);
    while (rs.next()) {
    login = rs.getInt("id");
    privilege = rs.getInt("privilege");
    username = rs.getString("NAME");
    integral = rs.getInt("INTEGRAL");
    lastLoginDate = rs.getDate("LASTLOGINDATE");
    }
    rs.close();
     * */
    //   if (login == -1) {
    sql = "select * from memberinfo where deleted = 0 and userid ='" + userid + "' and password='" + password + "'";
    rs = stmt.executeQuery(sql);
    if (rs.next()) {
        login = rs.getInt("id");
        privilege = rs.getInt("privilege");
        username = rs.getString("NAME");
        integral = rs.getInt("INTEGRAL");
        lastLoginDate = rs.getDate("LASTLOGINDATE");
		photo = rs.getString("photo");
    }
    rs.close();

    if (login > 0) {
        sql = "select lastlogindate from memberinfo where id=" + login;
        Date tmp = new Date();
        java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
        rs = stmt.executeQuery(sql);
        boolean first = false;
        if (rs.next()) {
            Date today = rs.getDate("lastlogindate");
            if (today.getYear() != d.getYear() || today.getMonth() != d.getMonth() || today.getDate() != d.getDate()) {
                first = true;
            }
        }
        rs.close();

        sql = "update memberinfo set lastlogindate = ?, registipaddress = ?  where id=" + login;
        PreparedStatement pstmt = conn.prepareStatement(sql);

        pstmt.setTimestamp(1, d);
        pstmt.setString(2, strIPAddress);
        pstmt.execute();
        pstmt.close();

        sql = "select max(id) from memberloginlist";
        rs = stmt.executeQuery(sql);
        int maxloginid = 0;
        if (rs.next()) {
            maxloginid = rs.getInt(1);
        }
        maxloginid++;

        sql = "insert into memberloginlist (id, mid, logintime) values (?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, maxloginid);
        pstmt.setInt(2, login);
        java.sql.Timestamp now = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);
        pstmt.setTimestamp(3, now);
        pstmt.execute();
        pstmt.close();

        int logincount = 0;
        Statement u_stmt = conn.createStatement();
        Statement u_stmt1 = conn.createStatement();
        sql = "select logincount, integral from MEMBERINFO where id = " + login;
        rs = u_stmt.executeQuery(sql);
        
        if (rs.next()) {
            logincount = rs.getInt("logincount");
        }
        rs.close();
        u_stmt.close();
        if (first) {
            logincount = 0;
        }
        
        if (logincount < 5) {
            logincount++;

            int reason_id = 1;
            int def_reason = 1;
            u_stmt1 = conn.createStatement();
            sql = "select DEFAULTINTEGRAL from INTEGRALREASON where id = " + reason_id;
            rs1 = u_stmt1.executeQuery(sql);
            if (rs1.next()) {
                def_reason = rs1.getInt("DEFAULTINTEGRAL");
            }
            rs1.close();
            u_stmt1.close();
            sql = "update memberinfo set logincount = ?, integral = integral + " + def_reason + " where id=" + login;
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, logincount);
            pstmt.execute();
            pstmt.close();

            int max_id = 0;
            u_stmt1 = conn.createStatement();
            sql = "select MAX(id) as maxid from INTEGRALLOG";
            rs1 = u_stmt1.executeQuery(sql);
            if (rs1.next()) {
                max_id = rs1.getInt("maxid");
            }
            rs1.close();
            u_stmt1.close();

            sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, max_id + 1);
            pstmt.setInt(2, login);
            pstmt.setTimestamp(3, d);
            pstmt.setInt(4, def_reason);
            pstmt.setInt(5, reason_id);
            pstmt.setInt(6, 1);
            pstmt.execute();
            pstmt.close();

        }
    }
    //   }
    JSONObject obj = new JSONObject();
    Date today = new Date();

    obj.put("userid", login);
    obj.put("privilege", privilege);
    obj.put("username", username);
    obj.put("integral", integral);
	obj.put("photo", photo);
    obj.put("lastlogindate", lastLoginDate.toString());
    obj.put("today", (1900 + today.getYear()) + "." + (today.getMonth() + 1) + "." + today.getDate());
    int time = (today.getHours() < 12) ? 0 : 1;
    obj.put("time", time);
    obj.put("week", today.getDay());
    out.println(obj.toJSONString());
    conn.close();
%>


