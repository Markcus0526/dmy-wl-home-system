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


public class GroupActInfoDetailActivity extends Activity {
	
	public static final String GROUPACTINFODETAIL_ID = "GROUPACTINFODETAILID";
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private JsonHttpResponseHandler handler1;
    private ProgressDialog progDialog1;
    
    private int m_nGroupActid = 0;
    
    
    private AutoSizeTextView txt_body;
    private AutoSizeTextView txt_evalname;
    private AutoSizeTextView txt_evaldate;
    private AutoSizeTextView txt_evalbody;
    private AutoSizeTextView txt_good;
    private AutoSizeTextView txt_bad;
    private AutoSizeTextView txt_good1;
    private AutoSizeTextView txt_bad1;
    
    private ImageView img_memimg;
    
    private Bitmap bitmapNoImage;
    
    private int cur_good, cur_bad, cur_comment_type;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_group_act_infodetail);
		
		m_nGroupActid = getIntent().getIntExtra(GROUPACTINFODETAIL_ID, 0);
		
	    txt_body = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_body);
	    txt_evalname = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_evalname);
	    txt_evaldate = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_evaldate);
	    txt_evalbody = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_evalbody);
	    txt_good = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_good);
	    txt_bad = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_bad);
	    txt_good1 = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_good1);
	    txt_bad1 = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_bad1);

	    img_memimg = (ImageView)findViewById(R.id.img_group_act_infodetail_memimg);
		
	    bitmapNoImage = BitmapFactory.decodeResource(getResources(), R.drawable.noimage);
	    
	    AutoSizeTextView lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_group_act_infodetail_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_group_act_infodetail_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		LinearLayout ll_addevalbtn = (LinearLayout)findViewById(R.id.ll_group_act_infodetail_commentbtn);
		ll_addevalbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAddEval();
        	}
        });
		
		LinearLayout ll_showevalbtn = (LinearLayout)findViewById(R.id.ll_group_act_infodetail_showevalbtn);
		ll_showevalbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickShowEval();
        	}
        });
		
		LinearLayout ll_goodbtn = (LinearLayout)findViewById(R.id.ll_group_act_infodetail_upbtn);
		ll_goodbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAddComment(1);
        	}
        });
		
		LinearLayout ll_badbtn = (LinearLayout)findViewById(R.id.ll_group_act_infodetail_downbtn);
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
		Intent groupactansweradd_activity = new Intent(this, GroupActAnswerAddActivity.class);
		groupactansweradd_activity.putExtra(GroupActAnswerAddActivity.GROUPACTANSWERADD_ID, m_nGroupActid);
		startActivity(groupactansweradd_activity);
	}
	
	private void onClickShowEval()
	{
		Intent groupactanswer_activity = new Intent(this, GroupActAnswerActivity.class);
		groupactanswer_activity.putExtra(GroupActAnswerActivity.GROUPACTANSWER_ID, m_nGroupActid);
		startActivity(groupactanswer_activity);
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

        progDialog1 = ProgressDialog.show(GroupActInfoDetailActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	cur_comment_type = type;
        	
        	String str_url = Global.STR_SERVER_URL + "activity_addcomment.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("id", Integer.toString(m_nGroupActid));
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

        progDialog = ProgressDialog.show(GroupActInfoDetailActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "single_info.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("id", Integer.toString(m_nGroupActid));
            
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
				
			    txt_body.setText(order.getString("body"));
			    
			    cur_good = order.getInt("evalup_count");
			    cur_bad = order.getInt("evaldown_count");
			    
			    txt_good.setText(Integer.toString(cur_good));
			    txt_bad.setText(Integer.toString(cur_bad));
			    txt_good1.setText(Integer.toString(cur_good));
			    txt_bad1.setText(Integer.toString(cur_bad));
			    
			    LinearLayout ll_answerlayer = (LinearLayout)findViewById(R.id.ll_group_act_infodetail_answerlayer);
			    
			    if ( order.getInt("have_answer") == 1 )
			    {
			    	ll_answerlayer.setVisibility(android.view.View.VISIBLE);
				    txt_evalname.setText(order.getString("answerer_name"));
				    txt_evaldate.setText(order.getInt("answer_date") + getResources().getString(R.string.studyeval_timeago));
				    txt_evalbody.setText(order.getString("answer_body"));

		            try
		            {
		                Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + order.getString("imagepath"), img_memimg, Global.options);
		            }
		            catch (Exception ex)
		            {
		                ex.printStackTrace();
		            }
			    }
			    else
			    {
			    	ll_answerlayer.setVisibility(android.view.View.GONE);
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
