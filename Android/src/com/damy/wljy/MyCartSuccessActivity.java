package com.damy.wljy;

import org.json.JSONObject;

import android.os.Bundle;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;

import com.damy.wljy.Main;
import com.damy.Utils.*;
import com.damy.common.Global; 


public class MyCartSuccessActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_mycart_success);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_mycart_success_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		LinearLayout ll_returnbtn = (LinearLayout)findViewById(R.id.ll_mycart_success_return);
		ll_returnbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickReturn();
        	}
        });
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickReturn()
	{		
		Intent mycash_activity = new Intent(this, MyCashActivity.class);
		startActivity(mycash_activity);
		finish();
	}
}
