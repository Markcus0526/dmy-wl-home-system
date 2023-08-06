package com.damy.wljy;


import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;

import org.apache.http.Header;
import org.apache.http.message.BasicHeader;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;



import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;
import com.damy.Utils.AutoSizeEditText;
import com.damy.Utils.AutoSizeTextView;
import com.damy.common.Global;

import android.os.Bundle;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;

import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListView;


public class PasswordChangeActivity extends Activity {

	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_password_change);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_password_change_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout fl_submitbtn = (FrameLayout)findViewById(R.id.fl_password_change_submitbtn);
		fl_submitbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSubmit();
        	}
        });
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickSubmit()
	{
		AutoSizeEditText txt_old = (AutoSizeEditText)findViewById(R.id.txt_password_change_old);
		AutoSizeEditText txt_new = (AutoSizeEditText)findViewById(R.id.txt_password_change_new);
		AutoSizeEditText txt_new1 = (AutoSizeEditText)findViewById(R.id.txt_password_change_new1);
		
		if ( !txt_new.getText().toString().equals(txt_new1.getText().toString()) )
		{
			onFailSubmit(getResources().getString(R.string.password_change_inputerror));
			return;
		}
		
		handler = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog.dismiss();

                try {
                	int isSuccess = object.getInt("success");
        			if ( isSuccess == 1 )
        				onSuccessSubmit();
        			else if ( isSuccess == 2 )
        				onFailSubmit(getResources().getString(R.string.password_change_olderror));
        			else
        				onFailSubmit(getResources().getString(R.string.submitfail));
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog.dismiss();
            	onFailSubmit(getResources().getString(R.string.submitfail));
            	
            }

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(PasswordChangeActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "pass_change.jsp";
        	param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("old_pass", txt_old.getText().toString());
            param.put("new_pass", txt_new.getText().toString());
                        
            client.post(str_url, param, handler);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onSuccessSubmit()
	{
        Global.showToast(PasswordChangeActivity.this, getString(R.string.msg_success));
		finish();
	}
	
	private void onFailSubmit(String message)
	{
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(message)
		.setNegativeButton(R.string.confirm, null)
		.show();
	}
	
}
