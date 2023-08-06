package com.damy.wljy;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;

import com.damy.wljy.Main;
import com.damy.Utils.*;
import com.damy.common.Global; 
import com.damy.common.STFaqItemInfo;
import com.damy.common.wljyBinaryHttpResponseHandler;


public class MyPhotoInfoActivity extends Activity {
	
	public static final String MYPHOTO_ID = "MYPHOTOID";
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private int m_nPhotoid = 0;
    
    private AutoSizeTextView txt_title;
    private AutoSizeTextView txt_body;

    private ImageView img_memimg;
    
    private Bitmap bitmapNoImage;
    
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_myphoto_info);
		
		m_nPhotoid = getIntent().getIntExtra(MYPHOTO_ID, 0);
		
		txt_title = (AutoSizeTextView)findViewById(R.id.lab_myphoto_info_title);
	    txt_body = (AutoSizeTextView)findViewById(R.id.lab_myphoto_info_body);

	    img_memimg = (ImageView)findViewById(R.id.img_myphoto_info_img);
		
	    bitmapNoImage = BitmapFactory.decodeResource(getResources(), R.drawable.noimage);
	    
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_myphoto_info_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout fl_myphotoadd = (FrameLayout)findViewById(R.id.fl_myphoto_info_submitbtn);
		fl_myphotoadd.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMyPhotoAdd();
        	}
        });
	    
		readContents();
		
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickMyPhotoAdd()
	{
		Intent myphotoadd_activity = new Intent(this, MyPhotoAddActivity.class);
		startActivity(myphotoadd_activity);
	}
	
	private void readContents()
	{
		handler = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog.dismiss();

                try {
                	parseMainItems(object);
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

        progDialog = ProgressDialog.show(MyPhotoInfoActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "myphoto_info.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("id", Integer.toString(m_nPhotoid));
            
            client.get(str_url, param, handler);
        } catch (Exception e) {
            e.printStackTrace();
        }

	}
	
	private void parseMainItems(JSONObject order)
	{
		try {

			int isSuccess;
			
			isSuccess = order.getInt("success");
			
			if ( isSuccess == 1 )
			{
				txt_title.setText(order.getString("title"));
			    txt_body.setText(order.getString("body"));
			    
                try
                {
                    Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + order.getString("imagepath"), img_memimg, Global.options);
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }
                
			}


		} catch (JSONException e) {
			
		}
	}

}
