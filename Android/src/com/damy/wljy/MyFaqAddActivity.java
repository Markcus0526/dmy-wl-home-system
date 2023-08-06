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


public class MyFaqAddActivity extends Activity {
	
	private LinearLayout ll_type1;
	private LinearLayout ll_type2;
	private LinearLayout ll_type3;
	private AutoSizeTextView lab_type1;
	private AutoSizeTextView lab_type2;
	private AutoSizeTextView lab_type3;
	
	private int m_nType;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_myfaq_add);
		
		m_nType = 1;
		
		ll_type1 = (LinearLayout)findViewById(R.id.ll_myfaq_add_type1);
		ll_type2 = (LinearLayout)findViewById(R.id.ll_myfaq_add_type2);
		ll_type3 = (LinearLayout)findViewById(R.id.ll_myfaq_add_type3);
		lab_type1 = (AutoSizeTextView)findViewById(R.id.lab_myfaq_add_type1);
		lab_type2 = (AutoSizeTextView)findViewById(R.id.lab_myfaq_add_type2);
		lab_type3 = (AutoSizeTextView)findViewById(R.id.lab_myfaq_add_type3);
		
		
		ll_type1.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type1.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		lab_type1.setTextColor(getResources().getColor(R.color.color_white));
        		
        		ll_type2.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_type2.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type3.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_type3.setTextColor(getResources().getColor(R.color.color_black));
        		
        		m_nType = 1;
        	}
        });
		ll_type2.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type2.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		lab_type2.setTextColor(getResources().getColor(R.color.color_white));
        		
        		ll_type1.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_type1.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type3.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_type3.setTextColor(getResources().getColor(R.color.color_black));

        		m_nType = 2;
        	}
        });
		ll_type3.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type3.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		lab_type3.setTextColor(getResources().getColor(R.color.color_white));
        		
        		ll_type1.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_type1.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type2.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_type2.setTextColor(getResources().getColor(R.color.color_black));

        		m_nType = 3;
        	}
        });
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_myfaq_add_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout fl_submitbtn = (FrameLayout)findViewById(R.id.fl_myfaq_add_submitbtn);
		fl_submitbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSubmit();
        	}
        });
		
		AutoSizeTextView lab_maxintegral = (AutoSizeTextView)findViewById(R.id.lab_myfaq_add_maxintegral);
		lab_maxintegral.setText(Integer.toString(Global.Cur_FaqMaxIntegral));
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickSubmit()
	{
		AutoSizeEditText txt_title = (AutoSizeEditText)findViewById(R.id.txt_myfaq_add_title);
		AutoSizeEditText txt_integral = (AutoSizeEditText)findViewById(R.id.txt_myfaq_add_integral);
		AutoSizeEditText txt_body = (AutoSizeEditText)findViewById(R.id.txt_myfaq_add_body);
		
		if (txt_title.getText().toString().length() == 0) {
			showErrorMessage(R.string.no_title);
			return;
		}
		
		if (txt_integral.getText().toString().length() == 0) {
			showErrorMessage(R.string.no_integral);
			return;
		}
		
		if (Integer.parseInt(txt_integral.getText().toString(), 10) > Global.Cur_FaqMaxIntegral ) {
			showErrorMessage(R.string.big_integral);
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
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog.dismiss();
            	showErrorMessage(R.string.submitfail);
            	
            }

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(MyFaqAddActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "postquestion.jsp";
        	param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("ques_title", txt_title.getText().toString());
            param.put("ques_type", Integer.toString(m_nType));
            param.put("ques_integral", txt_integral.getText().toString());
            param.put("ques_body", txt_body.getText().toString());
            
            client.post(str_url, param, handler);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onSuccessSubmit()
	{
        Global.showToast(MyFaqAddActivity.this, getString(R.string.msg_success));
		finish();
	}
	
	private void showErrorMessage(int id)
	{
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(id)
		.setNegativeButton(R.string.confirm, null)
		.show();
	}
	
}
