package com.damy.common;

import android.content.Context;
import android.content.SharedPreferences;
import android.view.View;
import android.widget.Toast;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;

public class Global {
	public static String STR_SERVER_URL1 = "http://sypic.oicp.net:10100/wljy/";
	public static String STR_SERVER_URL = STR_SERVER_URL1 + "phone/";

	public static int Cur_UserId = 0;
	public static int Cur_Privilege = 0;
	public static String Cur_Date = "";
	public static String Cur_Weekday = "";
	public static String[] Weekday_Str = new String[7];
	public static int Page_Cnt = 8;
	public static int Search_Page_Cnt = 20;
	public static int Display_Mode = 1;
	
	public static String Cur_UserName = "";
	public static String Cur_UserLastLogin = "";
	public static int Cur_UserIntegral = 0;
	public static String Cur_UserPhoto = "";
	
	public static int Cur_FaqMaxIntegral = 0;
	
	public static String Cur_FileExplorer_SelFile = "";
	
	public static ImageLoader imageLoader = ImageLoader.getInstance();
	
    public static DisplayImageOptions options;

    private static Toast g_Toast = null;
    public static void showToast(Context context, String toastStr)
    {
        if ((g_Toast == null) || (g_Toast.getView().getWindowVisibility() != View.VISIBLE))
        {
            g_Toast = Toast.makeText(context, toastStr, Toast.LENGTH_SHORT);
            g_Toast.show();
        }

        return;
    }

    public static void SaveAccount(Context ctx, String name, String pwd, String ipaddr)
    {
        try
        {
            SharedPreferences sharePref = ctx.getSharedPreferences("maininfo", ctx.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharePref.edit();
            editor.putString("username", name);
            editor.putString("userpwd", pwd);
            editor.putString("ipaddr", ipaddr);
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }
    }

    public static String LoadAccountName(Context ctx)
    {
        String name = "";

        try
        {
            SharedPreferences sharePref = ctx.getSharedPreferences("maininfo", ctx.MODE_PRIVATE);
            name = sharePref.getString("username", "");
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }

        return name;
    }

    public static String LoadAccountPwd(Context ctx)
    {
        String password = "";

        try
        {
            SharedPreferences sharePref = ctx.getSharedPreferences("maininfo", ctx.MODE_PRIVATE);
            password = sharePref.getString("userpwd", "");
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }

        return password;
    }

    public static String LoadMainIpAddr(Context ctx)
    {
        String ipaddr = "";

        try
        {
            SharedPreferences sharePref = ctx.getSharedPreferences("maininfo", ctx.MODE_PRIVATE);
            ipaddr = sharePref.getString("ipaddr", "");
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }

        return ipaddr;
    }
}

