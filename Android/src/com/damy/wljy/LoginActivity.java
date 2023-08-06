package com.damy.wljy;

import org.json.JSONObject;

import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;

import com.damy.wljy.Main;
import com.damy.Utils.*;
import com.damy.common.Global; 


public class LoginActivity extends Activity {

    AutoSizeEditText edit_ipaddr;
    AutoSizeEditText edit_membername;
	AutoSizeEditText edit_password;
	ImageView img_loginbtn;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_login);
		
		Global.Weekday_Str = getResources().getString(R.string.weekday).split(",");

        edit_ipaddr = (AutoSizeEditText)findViewById(R.id.edit_mainipaddr);
		edit_membername = (AutoSizeEditText)findViewById(R.id.edit_membername);
		edit_password = (AutoSizeEditText)findViewById(R.id.edit_password);
		img_loginbtn = (ImageView)findViewById(R.id.img_login);

        // load saved account info
        edit_ipaddr.setText(Global.LoadMainIpAddr(LoginActivity.this));
        edit_membername.setText(Global.LoadAccountName(LoginActivity.this));
        edit_ipaddr.setText(Global.LoadAccountPwd(LoginActivity.this));

		/*
		edit_membername.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMemberName();
        	}
        });
		
		edit_password.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickPassword();
        	}
        });
		*/
		img_loginbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickLogin();
        	}
        });
	}
	/*
	void onClickMemberName()
	{
		edit_membername.setText("");
	}
	
	void onClickPassword()
	{
		edit_password.setText("");
		edit_password.setInputType(android.text.InputType.TYPE_CLASS_TEXT | android.text.InputType.TYPE_TEXT_VARIATION_PASSWORD);
	}
	*/
	
	void onClickLogin()
	{
		if ( !isOnline(this.getBaseContext()) )
		{
			onFailSubmit(R.string.login_error_network);
			return;
		}
		
		handler = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog.dismiss();

                try {
                	Global.Cur_UserId = object.getInt("userid");
        			Global.Cur_Privilege = object.getInt("privilege");
        			Global.Cur_Date = object.getString("today");
        			Global.Cur_Weekday = Global.Weekday_Str[object.getInt("week")];
        			Global.Cur_UserName = object.getString("username");
        			Global.Cur_UserLastLogin = object.getString("lastlogindate");
        			Global.Cur_UserIntegral = object.getInt("integral");
        			Global.Cur_UserPhoto = object.getString("photo");
        			//Global.Display_Setting = (object.getInt("time") > 0)?true:false;
        			if ( Global.Cur_UserId >= 0 )
        				onSuccessLogin();
        			else
        				onFailSubmit(R.string.login_error_password);
        			
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog.dismiss();
            	onFailSubmit(R.string.submitfail);
            }

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(LoginActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {

            // change main address
            Global.STR_SERVER_URL1 = "http://" + edit_ipaddr.getText() + "/wljy/";
        	Global.STR_SERVER_URL = Global.STR_SERVER_URL1 + "phone/";

        	String str_url = Global.STR_SERVER_URL + "login.jsp";
            param.put("userid", edit_membername.getText().toString());
            param.put("password", edit_password.getText().toString());
            
            client.get(str_url, param, handler);
        } catch (Exception e) {
            e.printStackTrace();
        }

	}
	
	private void onSuccessLogin()
	{
        // save account info
        String name = edit_membername.getText().toString();
        String pwd = edit_password.getText().toString();
        String ipaddr = edit_ipaddr.getText().toString();
        Global.SaveAccount(LoginActivity.this, name, pwd, ipaddr);

        // go to main activity
		Intent main_activity = new Intent(this, Main.class);
		startActivity(main_activity);
		finish();
	}
	
	private boolean isOnline(Context ctx) 
    {
        ConnectivityManager cm = (ConnectivityManager) ctx.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo netInfo = cm.getActiveNetworkInfo();
        if (netInfo != null && netInfo.isConnectedOrConnecting()) {
            return true;
        }
        return false;
    }

	private void onFailSubmit(int id)
	{
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(id)
		.setNegativeButton(R.string.confirm, null)
		.show();
	}
}
