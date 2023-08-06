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


public class StudyEvalAddActivity extends Activity {
	
	public static final String STUDYEVALADD_ID = "STUDYEVALADDID";

	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private int m_nStudyid = 0;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_evaluate);
		
		m_nStudyid = getIntent().getIntExtra(STUDYEVALADD_ID, 0);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_evaluate_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout fl_submitbtn = (FrameLayout)findViewById(R.id.fl_evaluate_submit);
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
		AutoSizeEditText txt_body = (AutoSizeEditText)findViewById(R.id.txt_evaluate_body);
		if (txt_body.getText().toString().length() == 0) {
			new AlertDialog.Builder(this)
			.setTitle(R.string.app_name)
			.setMessage(R.string.no_body)
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
        				onSuccessSubmit();
        			else
        				onFailSubmit();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog.dismiss();
            	onFailSubmit();
            }

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(StudyEvalAddActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "study_info_addans.jsp";
        	param.put("userid", Integer.toString(Global.Cur_UserId));
        	param.put("id", Integer.toString(m_nStudyid));
            param.put("postdata", txt_body.getText().toString());
            
            client.post(str_url, param, handler);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onSuccessSubmit()
	{
        Global.showToast(StudyEvalAddActivity.this, getString(R.string.msg_success));
		finish();
	}
	
	private void onFailSubmit()
	{
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(R.string.submitfail)
		.setNegativeButton(R.string.confirm, null)
		.show();
	}
	
}
