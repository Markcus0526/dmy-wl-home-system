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
import android.content.Intent;

import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListView;


public class FeedbackActivity extends Activity {

	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private String readfile_name = "";
    private AutoSizeTextView lab_curdate;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_feedback);
		
		FrameLayout fl_submit = (FrameLayout)findViewById(R.id.fl_feedback_submit);
		FrameLayout fl_filebtn = (FrameLayout)findViewById(R.id.fl_feedback_filebtn);
		
		fl_submit.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSubmit();
        	}
        });
		
		fl_filebtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickFilebtn();
        	}
        });
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_feedback_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		Global.Weekday_Str = getResources().getString(R.string.weekday).split(",");
		
		lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_feedback_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);

	}
	private void onClickFilebtn()
	{
		Intent fileexplorer_activity = new Intent(this, FileExplorer.class);
		startActivity(fileexplorer_activity);
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickSubmit()
	{
		AutoSizeEditText txt_title = (AutoSizeEditText)findViewById(R.id.txt_feedback_title);
		AutoSizeEditText txt_body = (AutoSizeEditText)findViewById(R.id.txt_feedback_body);
		
		if (txt_title.getText().toString().length() == 0) {
			new AlertDialog.Builder(this)
			.setTitle(R.string.app_name)
			.setMessage(R.string.no_title)
			.setNegativeButton(R.string.confirm, null)
			.show();
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
        				onSuccessUpdate();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog.dismiss();
            	
            }

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(FeedbackActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "feedback.jsp";
        	param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("title", txt_title.getText().toString());
            param.put("body", txt_body.getText().toString());
            
            
            if ( Global.Cur_FileExplorer_SelFile != "" )
            {
            	param.put("upload-file", new File(Global.Cur_FileExplorer_SelFile));
            	Global.Cur_FileExplorer_SelFile = "";
            }
            
            client.post(str_url, param, handler);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onSuccessUpdate()
	{
		finish();
		/*
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(R.string.submitsuccess)
		.setNegativeButton(R.string.confirm, null)
		.show();
		*/
	}

}
