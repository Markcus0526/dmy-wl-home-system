package com.damy.wljy;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.os.Parcelable;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;

import com.damy.wljy.Main;
import com.damy.Utils.*;
import com.damy.common.Global; 
import com.damy.common.STFaqItemInfo;
import com.damy.common.wljyBinaryHttpResponseHandler;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;


public class GroupActInfoActivity extends Activity implements View.OnTouchListener {
	
	public static final String GROUPACTINFO_ID = "GROUPACTINFOID";
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private JsonHttpResponseHandler handler1;
    private ProgressDialog progDialog1;
    
    private int m_nGroupActid = 0;
    
    private AutoSizeTextView txt_title;
    private AutoSizeTextView txt_evalcount;
    private AutoSizeTextView txt_body;
    private AutoSizeTextView txt_date;

    private ImageView img_showevalimg;
    
    private Bitmap bitmapNoImage;
    
    private float mLastMotionX;
    private float mLastMotionY;

    private boolean mIsBeingDragged;

    private View mDownView;
    
    private int m_nImageCount = 0;
    private String[] m_sImagePath = new String[50];
    
    private ViewPager pager;
    
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_group_act_info);
		
		m_nGroupActid = getIntent().getIntExtra(GROUPACTINFO_ID, 0);
		
		txt_title = (AutoSizeTextView)findViewById(R.id.lab_group_act_info_title);
	    txt_body = (AutoSizeTextView)findViewById(R.id.lab_group_act_info_body);
	    txt_date = (AutoSizeTextView)findViewById(R.id.lab_group_act_info_postdate);
	    txt_evalcount = (AutoSizeTextView)findViewById(R.id.lab_group_act_info_eval);

	    bitmapNoImage = BitmapFactory.decodeResource(getResources(), R.drawable.noimage);
	    
	    AutoSizeTextView lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_group_act_info_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_group_act_info_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		LinearLayout ll_nav1 = (LinearLayout)findViewById(R.id.ll_group_act_info_nav1);
		ll_nav1.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		LinearLayout ll_nav2 = (LinearLayout)findViewById(R.id.ll_group_act_info_nav2);
		ll_nav2.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickCollect();
        	}
        });
		
		LinearLayout ll_nav3 = (LinearLayout)findViewById(R.id.ll_group_act_info_nav3);
		ll_nav3.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickShare();
        	}
        });
		
		LinearLayout ll_nav4 = (LinearLayout)findViewById(R.id.ll_group_act_info_nav4);
		ll_nav4.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAddAnswer();
        	}
        });
		
		FrameLayout fl_allanswer = (FrameLayout)findViewById(R.id.fl_group_act_info_allanswer);
		fl_allanswer.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAllAnswer();
        	}
        });
		
		img_showevalimg = (ImageView)findViewById(R.id.img_group_act_info_showeval);
		img_showevalimg.setOnTouchListener(this);
		
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
	
	private void onClickAllAnswer()
	{
		Intent groupactanswer_activity = new Intent(this, GroupActAnswerActivity.class);
		groupactanswer_activity.putExtra(GroupActAnswerActivity.GROUPACTANSWER_ID, m_nGroupActid);
		startActivity(groupactanswer_activity);
	}
	
	private void onClickCollect()
	{
		handler1 = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog1.dismiss();

                try {
                	
                	int isSucc = object.getInt("success");
                	
                	showCollectionAlertDialog(isSucc);

                	
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog1.dismiss();
            	showCollectionAlertDialog(0);
            }

            @Override
            public void onFinish()
            {
				progDialog1.dismiss();
            }
        };

        progDialog1 = ProgressDialog.show(GroupActInfoActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "collection_add.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("id", Integer.toString(m_nGroupActid));
            param.put("type", "1");
            
            client.get(str_url, param, handler1);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onClickShare()
	{
		Intent share_activity = new Intent(this, ShareActivity.class);
		startActivity(share_activity);
		finish();
	}
	
	private void onClickAddAnswer()
	{
		Intent groupactansweradd_activity = new Intent(this, GroupActAnswerAddActivity.class);
		groupactansweradd_activity.putExtra(GroupActAnswerAddActivity.GROUPACTANSWERADD_ID, m_nGroupActid);
		startActivity(groupactansweradd_activity);
	}
	
	@Override
    public boolean onTouch(View v, MotionEvent ev) {

        final int action = ev.getAction();
        final float x = ev.getX();
        final float y = ev.getY();

        switch (action) {
            case MotionEvent.ACTION_DOWN:
                // Find the child view that was touched (perform a hit test)
                Rect rect = new Rect();
                int[] listViewCoords = new int[2];
                mDownView = null;

                if (v == img_showevalimg)
                {
                    mDownView = v;
                }
                else
                {
                    mDownView = null;
                }

                if (mDownView != null)
                {
                    mLastMotionX = x;
                    mLastMotionY = y;
                }
                return true;
            case MotionEvent.ACTION_MOVE:
                final float dx = x - mLastMotionX;
                final float xDiff = Math.abs(dx);
                final float yDiff = Math.abs(y - mLastMotionY);
                if (/*xDiff > mTouchSlop && */xDiff > yDiff)
                {
                    mIsBeingDragged = true;
                }
                else
                {
                    mIsBeingDragged = false;
                }
                break;
            case MotionEvent.ACTION_CANCEL:
            case MotionEvent.ACTION_UP:
                final float deltaX = mLastMotionX - x;
                if (mIsBeingDragged && (mDownView != null)) {
                    // get selected state ( visible state of delete button )
                    if (deltaX > 0)     // left move event
                    {
                        {
                        	Intent groupactinfodetail_activity = new Intent(this, GroupActInfoDetailActivity.class);
                        	groupactinfodetail_activity.putExtra(GroupActInfoDetailActivity.GROUPACTINFODETAIL_ID, m_nGroupActid);
                    		startActivity(groupactinfodetail_activity);
                    		
                            mDownView.setTag(true);
                        }
                    }
                }

                break;
        }

        return super.onTouchEvent(ev);
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

        progDialog = ProgressDialog.show(GroupActInfoActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "activity_info.jsp";
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
				txt_title.setText(order.getString("title"));
			    txt_evalcount.setText(order.getString("eval_count") + getResources().getString(R.string.group_act_info_eval_string));
			    txt_body.setText(order.getString("body"));
			    txt_date.setText(order.getString("postdate"));
			    
			    data = order.getJSONArray("imagepath");
			    m_nImageCount = data.length();
			    for (int i = 0; i < m_nImageCount; i++) {
			    	m_sImagePath[i] = data.getString(i);
				}
			    
			    pager = (ViewPager) findViewById(R.id.pager_group_act_info_image);
				pager.setAdapter(new ImagePagerAdapter(m_sImagePath));
				pager.setCurrentItem(0);
			}


		} catch (JSONException e) {
			
		}
	}
	
	private void showCollectionAlertDialog(int type)
	{
		String message = "";
		if ( type == 0 )
			message = getResources().getString(R.string.add_collection_submitfail);
		else if ( type == 1 )
			message = getResources().getString(R.string.add_collection_submitsuccess);
		else if ( type == 2 )
			message = getResources().getString(R.string.add_collection_submitalreadydone);
		
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(message)
		.setNegativeButton(R.string.confirm, null)
		.show();
	}
	
	

	private class ImagePagerAdapter extends PagerAdapter {

		private String[] images;
		private LayoutInflater inflater;

		ImagePagerAdapter(String[] images) {
			this.images = images;
			inflater = getLayoutInflater();
		}

		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			((ViewPager) container).removeView((View) object);
		}

		@Override
		public void finishUpdate(View container) {
		}

		@Override
		public int getCount() {
			return m_nImageCount;
		}

		@Override
		public Object instantiateItem(ViewGroup view, int position) {
			View imageLayout = inflater.inflate(R.layout.item_pager_image, view, false);
			ImageView imageView = (ImageView) imageLayout.findViewById(R.id.image);
			final ProgressBar spinner = (ProgressBar) imageLayout.findViewById(R.id.loading);
			
			Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + images[position], imageView, Global.options, new SimpleImageLoadingListener() {
				@Override
				public void onLoadingStarted(String imageUri, View view) {
					spinner.setVisibility(View.VISIBLE);
				}

				@Override
				public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
					spinner.setVisibility(View.GONE);
				}

				@Override
				public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
					spinner.setVisibility(View.GONE);
				}
			});

			((ViewPager) view).addView(imageLayout, 0);
			return imageLayout;
		}

		@Override
		public boolean isViewFromObject(View view, Object object) {
			return view.equals(object);
		}

		@Override
		public void restoreState(Parcelable state, ClassLoader loader) {
		}

		@Override
		public Parcelable saveState() {
			return null;
		}

		@Override
		public void startUpdate(View container) {
		}
	}

}
