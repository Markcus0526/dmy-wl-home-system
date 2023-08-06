
<%@page import="java.io.OutputStream"%>
<%@page import="java.awt.Graphics2D"%>
<%@page import="java.awt.image.BufferedImage"%>
<%@page import="java.io.File"%>
<%@page import="javax.imageio.ImageIO"%>

<%
  String cmd_str = new String();
  cmd_str = "ipconfig";
  Runtime.getRuntime().exec("webapps\\wljy\\ffmpeg\\ffmpeg.exe -i wljy\\ffmpeg\\test.avi -ar 22050 wljy\\ffmpeg\\test.flv ");
%>

