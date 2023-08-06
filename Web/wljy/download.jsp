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
    for (int i = 0; i < cookies.length; i++) 
	{
        String name = cookies[i].getName();
        int pos = name.indexOf('#');
        if (pos != -1) 
		{
            if (name.substring(0, pos).equals("wljyid")) {
                tmp_str = name.substring(pos + 1);
                break;
            }
        }
    }

	String sql;
    int UserId = Integer.parseInt(tmp_str, 10);
	int qid = Integer.parseInt((request.getParameter("qid") == null) ? "0" : request.getParameter("qid"), 10);

	long nVal = 5;
	
	int nDownloadIntegral = 0;
	Statement mystmt1 = conn.createStatement();
	sql = "select * from study_qinfo where ID = " + qid;
	ResultSet myrs1 = mystmt1.executeQuery(sql);
	if ( myrs1 != null && myrs1.next() )
	{
		nDownloadIntegral = myrs1.getInt("INTEGRAL");
	}
	myrs1.close();
	mystmt1.close();

	int nMemberIntegral = 0;
	Statement mystmt2 = conn.createStatement();
	sql = "select * from memberinfo where ID = " + UserId;
	ResultSet myrs2 = mystmt2.executeQuery(sql);
	if ( myrs2 != null && myrs2.next() )
	{
		nMemberIntegral = myrs2.getInt("INTEGRAL");
	}
	myrs2.close();
	mystmt2.close();

	if ( (nMemberIntegral - Math.abs(nDownloadIntegral)) < 0 )
	{
		out.println("<script>alert('您的积分不够.');window.location.href='study_info.jsp?id=" + qid + "';</script>");
	}
	else
	{
		request.setCharacterEncoding("UTF-8");

		Statement stmt = conn.createStatement();    
		String data_info = new String();
		String mtitle = "";
		sql = "select * from study_qinfo where id = " + qid;
		ResultSet rs = stmt.executeQuery(sql);
		if (rs.next()) {
			data_info = rs.getString("datapath");
			mtitle = rs.getString("title");
		}
		String fPath = "webapps/wljy/" + data_info;

		if (fPath != null && !fPath.equals("")) {
			File f = new File(fPath);
			if (!f.exists()) {
				out.println("<script>alert('" + fPath + " 文件不存在.');window.location.href='study_info.jsp?id=" + qid + "';</script>");
			} else {
				long l = f.length();
				long maxSize = 2 * 1024 * 1024 * 1024 - 1;
				sql = "select count(*) as count from data_download";
				rs = stmt.executeQuery(sql);
				int maxid = 0;
				if (rs.next()) {
					maxid = rs.getInt("count");
				}
				rs.close();
				if (maxid != 0) {
					sql = "select max(id) from data_download";
					rs = stmt.executeQuery(sql);


					if (rs.next()) {
						maxid = rs.getInt(1);
					}
					rs.close();

				}
				maxid++;			

				Date tmp = new Date();
				java.sql.Timestamp d = new java.sql.Timestamp(tmp.getYear(), tmp.getMonth(), tmp.getDate(), tmp.getHours(), tmp.getMinutes(), tmp.getSeconds(), 0);

				if (l < maxSize) {
					sql = "insert into data_download (id, mid, sqid, downloaddate, deleted) values (?,?,?,?,?)";
					PreparedStatement pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, maxid);
					pstmt.setInt(2, UserId);
					pstmt.setInt(3, qid);
					pstmt.setTimestamp(4, d);
					pstmt.setInt(5, 0);
					pstmt.execute();
					pstmt.close();

				}
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


					int mid = 0;
					Statement u_stmt1 = conn.createStatement();
					sql = "select mid from STUDY_QINFO where id = " + qid;
					ResultSet rs1 = u_stmt1.executeQuery(sql);
					if (rs1 != null && rs1.next()) {
						mid = rs1.getInt("mid");
					}
					rs1.close();
					u_stmt1.close();
					if (mid == UserId) {
						return;
					}				
/*
					int integral = 1, downcount = 0;
					u_stmt1 = conn.createStatement();
					sql = "select count(*) as count from data_download where sqid = " + qid;
					rs1 = u_stmt1.executeQuery(sql);
					if (rs1 != null && rs1.next()) {
						downcount = rs1.getInt("count");
					}
					if (downcount % 10 == 0) {
						nUploadIntegral = 2 * nUploadIntegral;
					}
					rs1.close();
					u_stmt1.close();
*/
					int reason_id = 5;
					PreparedStatement pstmt = conn.prepareStatement(sql);

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
					pstmt.setInt(2, mid);
					pstmt.setTimestamp(3, d);
					pstmt.setInt(4, nDownloadIntegral);
					pstmt.setInt(5, reason_id);
					pstmt.setInt(6, 1);
					pstmt.execute();
					pstmt.close();


					reason_id = 6;
					sql = "Insert into INTEGRALLOG (ID, MID, ADDDATE, GAININTEGRAL, REASON, ENABLED) VALUES (?, ?, ?, ?, ?, ?)";
					pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, max_id + 2);
					pstmt.setInt(2, UserId);
					pstmt.setTimestamp(3, d);
					pstmt.setInt(4, (-1) * Math.abs(nDownloadIntegral));
					pstmt.setInt(5, reason_id);
					pstmt.setInt(6, 1);
					pstmt.execute();
					pstmt.close();

					u_stmt1 = conn.createStatement();
					sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL - " + Math.abs(nDownloadIntegral) + " WHERE ID = " + UserId;
					u_stmt1.execute(sql);
					u_stmt1.close();

					u_stmt1 = conn.createStatement();
					sql = "UPDATE MEMBERINFO SET INTEGRAL = INTEGRAL + " + Math.abs(nDownloadIntegral) + " WHERE ID = " + mid;
					u_stmt1.execute(sql);
					u_stmt1.close();

				} else {
					out.println("<script>alert('无法下载.');window.location.href='study_info.jsp?id=" + qid + "';</script>");
				}
			}
		} else {
			out.println("<script>alert('无下载资料.');window.location.href='study_info.jsp?id=" + qid + "';</script>");
		}
	}
%>
