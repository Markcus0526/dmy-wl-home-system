package com.damy.wljy;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.View;
import android.view.View.OnClickListener;
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


public class ShareInfoActivity extends Activity {
	
	public static final String SHAREINFO_ID = "SHAREINFOID";
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private JsonHttpResponseHandler handler1;
    private ProgressDialog progDialog1;
    
    private int m_nShareid = 0;
    
    private AutoSizeTextView txt_title;
    private AutoSizeTextView txt_submitter;
    private AutoSizeTextView txt_body;
    private AutoSizeTextView txt_date;
    private AutoSizeTextView txt_answercnt;
    private AutoSizeTextView txt_type;
    private AutoSizeTextView txt_readcount;
    private AutoSizeTextView txt_ansname;
    private AutoSizeTextView txt_ansdate;
    private AutoSizeTextView txt_ansbody;
    private AutoSizeTextView txt_good;
    private AutoSizeTextView txt_bad;
    private AutoSizeTextView txt_good1;
    private AutoSizeTextView txt_bad1;
    
    private ImageView img_memimg;
    
    private LinearLayout ll_recentanswer;
    
    private Bitmap bitmapNoImage;
    
    private int cur_good, cur_bad, cur_comment_type;
    
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_share_info);
		
		m_nShareid = getIntent().getIntExtra(SHAREINFO_ID, 0);
		
		txt_title = (AutoSizeTextView)findViewById(R.id.lab_share_info_title);
	    txt_submitter = (AutoSizeTextView)findViewById(R.id.lab_share_info_submitter);
	    txt_body = (AutoSizeTextView)findViewById(R.id.lab_share_info_body);
	    txt_date = (AutoSizeTextView)findViewById(R.id.lab_share_info_date);
	    txt_answercnt = (AutoSizeTextView)findViewById(R.id.lab_share_info_answercnt);
	    txt_type = (AutoSizeTextView)findViewById(R.id.lab_share_info_type);
	    txt_readcount = (AutoSizeTextView)findViewById(R.id.lab_share_info_readcount);
	    txt_ansname = (AutoSizeTextView)findViewById(R.id.lab_share_info_ansname);
	    txt_ansdate = (AutoSizeTextView)findViewById(R.id.lab_share_info_ansdate);
	    txt_ansbody = (AutoSizeTextView)findViewById(R.id.lab_share_info_ansbody);
	    txt_good = (AutoSizeTextView)findViewById(R.id.lab_share_info_good);
	    txt_bad = (AutoSizeTextView)findViewById(R.id.lab_share_info_bad);
	    txt_good1 = (AutoSizeTextView)findViewById(R.id.lab_share_info_good1);
	    txt_bad1 = (AutoSizeTextView)findViewById(R.id.lab_share_info_bad1);
	    
	    img_memimg = (ImageView)findViewById(R.id.img_share_info_memimg);
		
	    ll_recentanswer = (LinearLayout)findViewById(R.id.ll_share_info_recentanswer);
	    
	    bitmapNoImage = BitmapFactory.decodeResource(getResources(), R.drawable.noimage);
	    
	    AutoSizeTextView lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_share_info_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_share_info_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		LinearLayout ll_showanswerbtn = (LinearLayout)findViewById(R.id.ll_share_info_showansbtn);
		ll_showanswerbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickShowAnswer();
        	}
        });
		
		LinearLayout ll_addevalbtn = (LinearLayout)findViewById(R.id.ll_share_info_addevalbtn);
		ll_addevalbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAddEval();
        	}
        });
		
		LinearLayout ll_goodbtn = (LinearLayout)findViewById(R.id.ll_share_info_upbtn);
		ll_goodbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAddComment(1);
        	}
        });
		
		LinearLayout ll_badbtn = (LinearLayout)findViewById(R.id.ll_share_info_downbtn);
		ll_badbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAddComment(0);
        	}
        });
	    
		//readContents();
		
	}
	
	@Override
	protected void onResume()
	{
		readContents();
		super.onResume();
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickAddEval()
	{
		Intent shareevaladd_activity = new Intent(this, ShareEvalAddActivity.class);
		shareevaladd_activity.putExtra(ShareEvalAddActivity.SHAREEVALADD_ID, m_nShareid);
		startActivity(shareevaladd_activity);
	}
	
	private void onClickShowAnswer()
	{
		Intent sharedetail_activity = new Intent(this, ShareEvalActivity.class);
		sharedetail_activity.putExtra(ShareEvalActivity.SHAREEVAL_ID, m_nShareid);
		startActivity(sharedetail_activity);
	}
	
	private void onClickAddComment(int type)
	{
		
		handler1 = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog1.dismiss();

                try {
                	
                	int isSucc = object.getInt("success");
                	
                	showCommentAlertDialog(isSucc);
                	
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog1.dismiss();
            	showCommentAlertDialog(0);
            }

            @Override
            public void onFinish()
            {
				progDialog1.dismiss();
            }
        };

        progDialog1 = ProgressDialog.show(ShareInfoActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	cur_comment_type = type;
        	
        	String str_url = Global.STR_SERVER_URL + "share_info_addcomment.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("id", Integer.toString(m_nShareid));
            param.put("type", Integer.toString(type));
            
            client.get(str_url, param, handler1);
        } catch (Exception e) {
            e.printStackTrace();
        }

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

        progDialog = ProgressDialog.show(ShareInfoActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "share_info.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("id", Integer.toString(m_nShareid));
            
            client.get(str_url, param, handler);
        } catch (Exception e) {
            e.printStackTrace();
        }

	}
	
	private void parseMainItems(JSONObject order)
	{
		try {
			
			JSONObject anItem = new JSONObject();
			JSONArray data = new JSONArray();
			int isSuccess;
			
			isSuccess = order.getInt("success");
			
			if ( isSuccess == 1 )
			{
				int anscnt = order.getInt("answer_count");
				txt_title.setText("  " + order.getString("title"));
			    txt_submitter.setText("  " + order.getString("provider_name"));
			    txt_body.setText(order.getString("body"));
			    txt_date.setText(order.getString("postdate"));
			    txt_answercnt.setText(Integer.toString(anscnt));
			    txt_type.setText(order.getString("type"));
			    txt_readcount.setText("  " + order.getInt("read_count"));
			    
			    cur_good = order.getInt("good_cnt");
			    cur_bad = order.getInt("bad_cnt");
			    txt_good.setText(Integer.toString(cur_good));
			    txt_bad.setText(Integer.toString(cur_bad));
			    txt_good1.setText(Integer.toString(cur_good));
			    txt_bad1.setText(Integer.toString(cur_bad));
			    
			    if ( anscnt > 0 )
			    {
			    	ll_recentanswer.setVisibility(android.view.View.VISIBLE);
				    txt_ansname.setText(order.getString("answerer_name"));
				    txt_ansdate.setText(order.getInt("answer_date") + getResources().getString(R.string.studyeval_timeago));
				    txt_ansbody.setText(order.getString("answer_body"));
				    
		            try
		            {
		                Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + order.getString("imagepath"), img_memimg, Global.options);
		            }
		            catch (Exception ex)
		            {
		                ex.printStackTrace();
		            }
		            		            
		            img_memimg.setScaleType(ImageView.ScaleType.FIT_START);
			    }
			    else
			    {
			    	ll_recentanswer.setVisibility(android.view.View.GONE);
			    }
			}


		} catch (JSONException e) {
			
		}
	}

	private void showCommentAlertDialog(int type)
	{
		String message = "";
		if ( type == 0 )
			message = getResources().getString(R.string.add_comment_submitfail);
		else if ( type == 1 )
		{
			message = getResources().getString(R.string.add_comment_submitsuccess);
			
			if (cur_comment_type == 1)
			{
				cur_good++;
			    txt_good.setText(Integer.toString(cur_good));
			    txt_good1.setText(Integer.toString(cur_good));
			}
			else
			{
				cur_bad++;
				txt_bad.setText(Integer.toString(cur_bad));
				txt_bad1.setText(Integer.toString(cur_bad));
			}
		}
		else if ( type == 2 )
			message = getResources().getString(R.string.add_comment_submitalreadydone);
		
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(message)
		.setNegativeButton(R.string.confirm, null)
		.show();
	}
}
