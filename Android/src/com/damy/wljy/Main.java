package com.damy.wljy;

import java.io.ByteArrayInputStream;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.BinaryHttpResponseHandler;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;
import com.damy.Utils.AutoSizeTextView;
import com.damy.Utils.ResolutionSet;

import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;


import com.damy.common.*;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.readystatesoftware.viewbadger.BadgeView;


public class Main extends Activity {

	private ListView m_anContents = null;
	private MainItemAdapter mAdapter = null;
	
	private STMainItemInfo m_Datas[] = null;
	private int m_itemCount = 0;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private LinearLayout mainLayout;
    private LinearLayout menuLayout;
    private FrameLayout maskLayout;
    
    private FrameLayout homeLayout;
    private LinearLayout memberLayout;
    private FrameLayout homecoverLayout;
    
    private boolean m_bMemLayerShow;
    private boolean m_bInitialized = false;
    
    private Animator.AnimatorListener animListener;
    private boolean m_bNaviHiding = false;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		Global.options = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.ic_stub)
		.showImageForEmptyUri(R.drawable.ic_empty)
		.showImageOnFail(R.drawable.ic_error)
		.cacheInMemory()
		.cacheOnDisc()
		.build();
		
		FrameLayout fl_main = (FrameLayout)findViewById(R.id.fl_main);

		fl_main.getViewTreeObserver().addOnGlobalLayoutListener(
		     new ViewTreeObserver.OnGlobalLayoutListener() {
		          public void onGlobalLayout() {
		        	  if (m_bInitialized == false)
		        	  {
		        		  Rect r = new Rect();
		        		  mainLayout.getLocalVisibleRect(r);
		        		  ResolutionSet._instance.setResolution(r.width(), r.height());
		        		  //ResolutionSet._instance.iterateChild(findViewById(R.id.fl_main));
		        		  m_bInitialized = true;
		        		  
		        		  initNavigatePan();
		        	  }
		          }
		     }
	    );
		
		getSettingValue();
 		initControls();
		//readContents();
	}
	
	@Override
	protected void onResume()
	{
		readContents();
		super.onResume();
	}
	
	private void initControls()
	{
		LinearLayout tab_activity = (LinearLayout)findViewById(R.id.ll_main_tabactivity);
		LinearLayout tab_share = (LinearLayout)findViewById(R.id.ll_main_tabshare);
		LinearLayout tab_faq = (LinearLayout)findViewById(R.id.ll_main_tabfaq);
		LinearLayout tab_study = (LinearLayout)findViewById(R.id.ll_main_tabstudy);
		LinearLayout tab_plus = (LinearLayout)findViewById(R.id.ll_main_tabplus);
		LinearLayout nav_search = (LinearLayout)findViewById(R.id.ll_main_navi_search);
		FrameLayout nav_activity = (FrameLayout)findViewById(R.id.fl_main_navactivity);
		FrameLayout nav_share = (FrameLayout)findViewById(R.id.fl_main_navshare);
		FrameLayout nav_faq = (FrameLayout)findViewById(R.id.fl_main_navfaq);
		FrameLayout nav_feedback = (FrameLayout)findViewById(R.id.fl_main_navfeedback);
		FrameLayout nav_exchange = (FrameLayout)findViewById(R.id.fl_main_navexchange);
		FrameLayout nav_study = (FrameLayout)findViewById(R.id.fl_main_navstudy);
		LinearLayout member_data = (LinearLayout)findViewById(R.id.ll_main_memberpage_data);
		LinearLayout member_photo = (LinearLayout)findViewById(R.id.ll_main_memberpage_photo);
		LinearLayout member_faq = (LinearLayout)findViewById(R.id.ll_main_memberpage_faq);
		LinearLayout member_exchange = (LinearLayout)findViewById(R.id.ll_main_memberpage_exchange);
		LinearLayout member_feedback = (LinearLayout)findViewById(R.id.ll_main_memberpage_feedback);
		LinearLayout member_setting = (LinearLayout)findViewById(R.id.ll_main_memberpage_setting);
		//LinearLayout member_collection = (LinearLayout)findViewById(R.id.ll_main_memberpage_collectionpage);
		
		FrameLayout fl_navihide = (FrameLayout)findViewById(R.id.fl_main_navihide);
		LinearLayout ll_memshow = (LinearLayout)findViewById(R.id.ll_main_memshow);
		

		tab_activity.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickActivity();
        	}
        });
		
		tab_share.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickShare();
        	}
        });
		
		tab_faq.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickFaq();
        	}
        });
		
		tab_study.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickStudy();
        	}
        });
		
		tab_plus.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		showNavigatePan(500, null);
        	}
        });
		
		nav_search.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSearch();
        	}
        });
		
		nav_activity.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickActivity();
        	}
        });
		
		nav_share.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickShare();
        	}
        });
		
		nav_faq.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickFaq();
        	}
        });
		
		nav_study.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickStudy();
        	}
        });
		
		nav_feedback.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickFeedback();
        	}
        });
		
		nav_exchange.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				onClickExchange();
			}
		});
		
		member_data.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMemberData();
        	}
        });
		
		member_faq.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMemberFaq();
        	}
        });
		
		member_exchange.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMemberExchange();
        	}
        });
		
		member_photo.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMemberPhoto();
        	}
        });
		
		member_feedback.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMemberFeedback();
        	}
        });
		
		member_setting.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMemberSetting();
        	}
        });
		/*
		member_collection.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMemberCollection();
        	}
        });
		*/
		animListener = new Animator.AnimatorListener() {
			
			@Override
			public void onAnimationStart(Animator animation) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onAnimationRepeat(Animator animation) {
				// TODO Auto-generated method stub
				
			}
			
			@Override
			public void onAnimationEnd(Animator animation) {
				// TODO Auto-generated method stub
				maskLayout.setVisibility(android.view.View.INVISIBLE);
				m_bNaviHiding = false;
			}
			
			@Override
			public void onAnimationCancel(Animator animation) {
				// TODO Auto-generated method stub
				
			}
		};
		
		
		fl_navihide.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		//hideNavigatePan(500, animListener);
        	}
        });
		
		
		ll_memshow.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				showMemberLayer(500, null);
				homecoverLayout.setVisibility(android.view.View.VISIBLE);
			}
		});
		
		mainLayout = (LinearLayout)findViewById(R.id.ll_main_maincontent);
		menuLayout = (LinearLayout)findViewById(R.id.ll_main_menucontent);
		maskLayout = (FrameLayout)findViewById(R.id.ll_main_contentcover);
		
		homeLayout = (FrameLayout)findViewById(R.id.fl_main_home);
		memberLayout = (LinearLayout)findViewById(R.id.ll_main_member);
		homecoverLayout = (FrameLayout)findViewById(R.id.fl_main_homecover);
		
		homecoverLayout.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				hideMemberLayer(500, null);
				homecoverLayout.setVisibility(android.view.View.INVISIBLE);
			}
		});
		
		maskLayout.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				if ( m_bNaviHiding == false )
				{
					m_bNaviHiding = true;
					hideNavigatePan(500, animListener);
				}
			}
		});
		
		menuLayout.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				
			}
		});
		
		homecoverLayout.setVisibility(android.view.View.INVISIBLE);
		
		AutoSizeTextView lab_username = (AutoSizeTextView)findViewById(R.id.lab_main_member_title);
		AutoSizeTextView lab_userintegral = (AutoSizeTextView)findViewById(R.id.lab_main_member_integral_val);
		AutoSizeTextView lab_userlastlogin = (AutoSizeTextView)findViewById(R.id.lab_main_member_login_date);
		
		lab_username.setText(Global.Cur_UserName);
		lab_userintegral.setText(Integer.toString(Global.Cur_UserIntegral));
		lab_userlastlogin.setText(Global.Cur_UserLastLogin);
		
		DisplayUserPhoto();
	}
	
	private void DisplayUserPhoto()
	{
		ImageView img_photo1 = (ImageView)findViewById(R.id.img_main_photo);
		ImageView img_photo2 = (ImageView)findViewById(R.id.img_main_member_photo);
		
		Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + Global.Cur_UserPhoto, img_photo1, Global.options);
		Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + Global.Cur_UserPhoto, img_photo2, Global.options);
	}
	
	private void onClickSearch()
	{
		Intent search_activity = new Intent(this, SearchActivity.class);
		startActivity(search_activity);
	}

	private void onClickActivity()
	{
		Intent activity_activity = new Intent(this, GroupActActivity.class);
		startActivity(activity_activity);
	}
	
	private void onClickShare()
	{
		Intent share_activity = new Intent(this, ShareActivity.class);
		startActivity(share_activity);
	}
	
	private void onClickFaq()
	{
		Intent faq_activity = new Intent(this, FaqActivity.class);
		startActivity(faq_activity);
	}
	
	private void onClickStudy()
	{
		Intent study_activity = new Intent(this, StudyActivity.class);
		startActivity(study_activity);
	}
	
	private void onClickFeedback()
	{
		Intent feedback_activity = new Intent(this, FeedbackActivity.class);
		startActivity(feedback_activity);
	}
	
	private void onClickExchange()
	{
		Intent exchange_activity = new Intent(this, ExchangeActivity.class);
		startActivity(exchange_activity);
	}
	
	private void onClickMemberData()
	{
		Intent meminfo_activity = new Intent(this, MemberInfo.class);
		startActivity(meminfo_activity);
	}
	
	private void onClickMemberFaq()
	{
		Intent memfaq_activity = new Intent(this, MyFaqActivity.class);
		startActivity(memfaq_activity);
	}
	
	private void onClickMemberExchange()
	{
		Intent memcash_activity = new Intent(this, MyCashActivity.class);
		startActivity(memcash_activity);
	}
	
	private void onClickMemberPhoto()
	{
		Intent memphoto_activity = new Intent(this, MyPhotoActivity.class);
		startActivity(memphoto_activity);
	}
	
	private void onClickMemberFeedback()
	{
		Intent myopinion_activity = new Intent(this, MyOpinionActivity.class);
		startActivity(myopinion_activity);
	}
	
	private void onClickMemberSetting()
	{
		Intent member_setting_activity = new Intent(this, SettingDisplayActivity.class);
		startActivity(member_setting_activity);
	}
	
	private void onClickMemberCollection()
	{
		Intent member_collection_activity = new Intent(this, CollectionActivity.class);
		startActivity(member_collection_activity);
	}
	
	public void initNavigatePan()
	{
		float destPos = ResolutionSet.fXpro * 312;
		
		ObjectAnimator mover1 = ObjectAnimator.ofFloat(mainLayout, "translationX", 0f, 0f);
		mover1.setDuration(0);
		
		ObjectAnimator mover2 = ObjectAnimator.ofFloat(menuLayout, "translationX", 0f, destPos);
		mover2.setDuration(0);
		
		AnimatorSet animatorSet = new AnimatorSet();

		animatorSet.play(mover1).with(mover2);
		animatorSet.start();
		
		maskLayout.setVisibility(android.view.View.INVISIBLE);
		
		float destPos1 = ResolutionSet.fXpro * 480;
		
		ObjectAnimator mover3 = ObjectAnimator.ofFloat(homeLayout, "translationX", 0f, 0f);
		mover3.setDuration(0);
		
		ObjectAnimator mover4 = ObjectAnimator.ofFloat(memberLayout, "translationX", 0f, destPos1);
		mover4.setDuration(0);
		
		AnimatorSet animatorSet1 = new AnimatorSet();

		animatorSet1.play(mover3).with(mover4);
		animatorSet1.start();
		
		m_bMemLayerShow = false;
	}
	
	public void showNavigatePan(int nDuration, Animator.AnimatorListener listener)
	{
		
		float destPos = ResolutionSet.fXpro * 312;
		
		maskLayout.setVisibility(android.view.View.VISIBLE);
		
		ObjectAnimator mover1 = ObjectAnimator.ofFloat(mainLayout, "translationX", 0f, 0f);
		mover1.setDuration(nDuration);
		
		ObjectAnimator mover2 = ObjectAnimator.ofFloat(menuLayout, "translationX", destPos, 0f);
		mover2.setDuration(nDuration);
		
		AnimatorSet animatorSet = new AnimatorSet();
		
		if (listener != null)
			animatorSet.addListener(listener);
		
		animatorSet.play(mover1).with(mover2);
		animatorSet.start();
	}
	
	public void hideNavigatePan(int nDuration, Animator.AnimatorListener listener)
	{
		float destPos = ResolutionSet.fXpro * 312;
		
		ObjectAnimator mover1 = ObjectAnimator.ofFloat(mainLayout, "translationX", 0f, 0f);
		mover1.setDuration(nDuration);
		
		ObjectAnimator mover2 = ObjectAnimator.ofFloat(menuLayout, "translationX", 0f, destPos);
		mover2.setDuration(nDuration);
		
		AnimatorSet animatorSet = new AnimatorSet();
		
		if (listener != null)
			animatorSet.addListener(listener);
		
		animatorSet.play(mover1).with(mover2);
		animatorSet.start();
	}
	
	public void showMemberLayer(int nDuration, Animator.AnimatorListener listener)
	{
		float srcPos = ResolutionSet.fXpro * 480;
		float destPos = ResolutionSet.fXpro * 480 * 10 / 100;
		float destPos1 = ResolutionSet.fXpro * 480 * 90 / 100;
		
		ObjectAnimator mover1 = ObjectAnimator.ofFloat(homeLayout, "translationX", 0f, -destPos1);
		mover1.setDuration(nDuration);
		
		ObjectAnimator mover2 = ObjectAnimator.ofFloat(memberLayout, "translationX", srcPos, destPos);
		mover2.setDuration(nDuration);
		
		AnimatorSet animatorSet = new AnimatorSet();
		
		if (listener != null)
			animatorSet.addListener(listener);
		
		animatorSet.play(mover1).with(mover2);
		animatorSet.start();
		
		m_bMemLayerShow = true;
	}
	
	public void hideMemberLayer(int nDuration, Animator.AnimatorListener listener)
	{
		float srcPos = ResolutionSet.fXpro * 480;
		float destPos = ResolutionSet.fXpro * 480 * 10 / 100;
		float destPos1 = ResolutionSet.fXpro * 480 * 90 / 100;
		
		ObjectAnimator mover1 = ObjectAnimator.ofFloat(homeLayout, "translationX", -destPos1, 0f);
		mover1.setDuration(nDuration);
		
		ObjectAnimator mover2 = ObjectAnimator.ofFloat(memberLayout, "translationX", destPos, srcPos);
		mover2.setDuration(nDuration);
		
		AnimatorSet animatorSet = new AnimatorSet();
		
		if (listener != null)
			animatorSet.addListener(listener);
		
		animatorSet.play(mover1).with(mover2);
		animatorSet.start();
		
		m_bMemLayerShow = false;
	}
	
	private void getSettingValue() {
		SharedPreferences pref = getSharedPreferences(SettingDisplayActivity.WLJY_SETTING_ROOT_STR, 0);
		
		Global.Display_Mode = pref.getInt(SettingDisplayActivity.WLJY_SETTING_DISPLAY_MODE_STR, 1);
	}
	
	private void readContents()
	{
		DisplayUserPhoto();
		
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
            public void onFailure(Throwable ex, String exception) {}

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };
        
        progDialog = ProgressDialog.show(Main.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
       
        try {

        	String str_url = Global.STR_SERVER_URL + "main.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            
            client.get(str_url, param, handler);
        } catch (Exception e) {
            e.printStackTrace();
        }
		
	}

	public int getItemCount()
	{
		return m_itemCount;
	}
	
	public STMainItemInfo getItem(int position)
	{
		if (position < 0 || position >= m_Datas.length)
			return null;
		
		return m_Datas[position];
	}
	

	private void parseMainItems(JSONObject order)
	{
		try {
			
			JSONObject anItem = new JSONObject();
			int isSuccess;
			
			m_Datas = new STMainItemInfo[5];
			m_Datas[0] = new STMainItemInfo();
			m_Datas[1] = new STMainItemInfo();
			m_Datas[2] = new STMainItemInfo();
			m_Datas[3] = new STMainItemInfo();
			m_Datas[4] = new STMainItemInfo();

			isSuccess = order.getInt("success");
			
			if ( isSuccess == 1 )
			{
				
				m_itemCount = 5;
				
				anItem = order.getJSONObject("activity");
				m_Datas[0].item_id = anItem.getInt("activity_id");
				m_Datas[0].title = getResources().getString(R.string.activity);
				m_Datas[0].body = anItem.getString("activity_title");
				m_Datas[0].mname = anItem.getString("activity_user");
				m_Datas[0].readcount = anItem.getString("activity_readcount");
				m_Datas[0].imagepath = anItem.getString("activity_image");
				
				anItem = order.getJSONObject("share");
				m_Datas[1].item_id = anItem.getInt("share_id");
				m_Datas[1].title = getResources().getString(R.string.share);
				m_Datas[1].body = anItem.getString("share_title");
				m_Datas[1].mname = anItem.getString("share_user");
				m_Datas[1].readcount = anItem.getString("share_readcount");
				m_Datas[1].imagepath = anItem.getString("share_image");
				
				anItem = order.getJSONObject("study");
				m_Datas[2].item_id = anItem.getInt("study_id");
				m_Datas[2].title = getResources().getString(R.string.study);
				m_Datas[2].body = anItem.getString("study_title");
				m_Datas[2].mname = anItem.getString("study_user");
				m_Datas[2].readcount = anItem.getString("study_readcount");
				m_Datas[2].imagepath = anItem.getString("study_image");
				
				anItem = order.getJSONObject("faq");
				m_Datas[3].item_id = anItem.getInt("faq_id");
				m_Datas[3].title = getResources().getString(R.string.faq);
				m_Datas[3].body = anItem.getString("faq_title");
				m_Datas[3].mname = anItem.getString("faq_user");
				m_Datas[3].readcount = anItem.getString("faq_readcount");
				m_Datas[3].imagepath = anItem.getString("faq_image");
				
				anItem = order.getJSONObject("exchange");
				m_Datas[4].item_id = anItem.getInt("exchange_id");
				m_Datas[4].title = getResources().getString(R.string.exchange);
				m_Datas[4].body = anItem.getString("exchange_title");
				m_Datas[4].mname = anItem.getString("exchange_user");
				m_Datas[4].readcount = "";
				m_Datas[4].imagepath = anItem.getString("exchange_image");
				
				m_anContents = (ListView) findViewById(R.id.anContentView);
				
				if (m_anContents != null)
				{
					m_anContents.setCacheColorHint(getResources().getColor(R.color.common_backcolor));
					m_anContents.setDividerHeight(0);
					m_anContents.setBackgroundColor(getResources().getColor(R.color.common_backcolor));
					mAdapter = new MainItemAdapter(Main.this, this.getApplicationContext());
					m_anContents.setAdapter(mAdapter);
					
					m_anContents.setOnItemClickListener(new AdapterView.OnItemClickListener() {
						public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
							onClickItem(position);
			        	}
					});
				}
				String feedback = order.getString("feedback");
				
				if (!feedback.equals("0")) {
					AutoSizeTextView lab_feedback = (AutoSizeTextView)findViewById(R.id.bageview);
										
					BadgeView badge = new BadgeView(this, lab_feedback);
					badge.setText(feedback);
					badge.setTextSize(10);
					badge.setBadgePosition(BadgeView.POSITION_TOP_RIGHT);
					badge.show();
				}
				
				
				

				if ( Global.Display_Mode == 1 ) {
						findViewById(R.id.ll_main_member).setBackgroundResource(R.drawable.login_background2);
				}
				else if ( Global.Display_Mode == 2 ) {
						findViewById(R.id.ll_main_member).setBackgroundResource(R.drawable.login_background);
				}
				else if ( Global.Display_Mode == 3 ) {
						findViewById(R.id.ll_main_member).setBackgroundResource(R.color.main_back_black);
				}
				else {
					LinearLayout ll_main_member = (LinearLayout)findViewById(R.id.ll_main_member);
					ll_main_member.setBackgroundColor(getResources().getColor(R.color.main_back_white));
					
					AutoSizeTextView lab_main_member_title = (AutoSizeTextView)findViewById(R.id.lab_main_member_title);
					lab_main_member_title.setTextColor(getResources().getColor(R.color.main_back_white_header));
					
					AutoSizeTextView lab_main_member_integral_title = (AutoSizeTextView)findViewById(R.id.lab_main_member_integral_title);
					lab_main_member_integral_title.setTextColor(getResources().getColor(R.color.main_back_white_integral));
					
					AutoSizeTextView lab_main_member_integral_val = (AutoSizeTextView)findViewById(R.id.lab_main_member_integral_val);
					lab_main_member_integral_val.setTextColor(getResources().getColor(R.color.main_back_white_integral_val));
					
					AutoSizeTextView lab_main_member_login_title = (AutoSizeTextView)findViewById(R.id.lab_main_member_login_title);
					lab_main_member_login_title.setTextColor(getResources().getColor(R.color.main_back_white_integral));
					
					AutoSizeTextView lab_main_member_login_date = (AutoSizeTextView)findViewById(R.id.lab_main_member_login_date);
					lab_main_member_login_date.setTextColor(getResources().getColor(R.color.main_back_white_integral));
					
					ImageView img_main_member_integral = (ImageView)findViewById(R.id.img_main_member_integral);
					img_main_member_integral.setImageResource(R.drawable.member_integralmark1);
					
					ImageView img_main_header_right = (ImageView)findViewById(R.id.img_main_header_right);
					img_main_header_right.setImageResource(R.drawable.mydata_mail);
					
					AutoSizeTextView lab_main_member_collection_title = (AutoSizeTextView)findViewById(R.id.lab_main_member_collection_title);
					lab_main_member_collection_title.setTextColor(getResources().getColor(R.color.main_back_white_collection_title));
					
					AutoSizeTextView lab_main_member_collection_val = (AutoSizeTextView)findViewById(R.id.lab_main_member_collection_val);
					lab_main_member_collection_val.setTextColor(getResources().getColor(R.color.color_black));
					
					AutoSizeTextView lab_main_member_photo_title = (AutoSizeTextView)findViewById(R.id.lab_main_member_photo_title);
					lab_main_member_photo_title.setTextColor(getResources().getColor(R.color.main_back_white_collection_title));
					
					AutoSizeTextView lab_main_member_photo_val = (AutoSizeTextView)findViewById(R.id.lab_main_member_photo_val);
					lab_main_member_photo_val.setTextColor(getResources().getColor(R.color.color_black));
					
					AutoSizeTextView lab_main_member_info = (AutoSizeTextView)findViewById(R.id.lab_main_member_info);
					lab_main_member_info.setTextColor(getResources().getColor(R.color.main_back_white_title));
					
					ImageView img_main_member_info = (ImageView)findViewById(R.id.img_main_member_info);
					img_main_member_info.setImageResource(R.drawable.mydata_forward);
					
					AutoSizeTextView lab_main_member_myphoto = (AutoSizeTextView)findViewById(R.id.lab_main_member_myphoto);
					lab_main_member_myphoto.setTextColor(getResources().getColor(R.color.main_back_white_title));
					
					ImageView img_main_member_myphoto = (ImageView)findViewById(R.id.img_main_member_myphoto);
					img_main_member_myphoto.setImageResource(R.drawable.mydata_forward);
					
					AutoSizeTextView lab_main_member_faq = (AutoSizeTextView)findViewById(R.id.lab_main_member_faq);
					lab_main_member_faq.setTextColor(getResources().getColor(R.color.main_back_white_title));
					
					ImageView img_main_member_faq = (ImageView)findViewById(R.id.img_main_member_faq);
					img_main_member_faq.setImageResource(R.drawable.mydata_forward);
					
					AutoSizeTextView lab_main_member_exchange = (AutoSizeTextView)findViewById(R.id.lab_main_member_exchange);
					lab_main_member_exchange.setTextColor(getResources().getColor(R.color.main_back_white_title));
					
					ImageView img_main_member_exchange = (ImageView)findViewById(R.id.img_main_member_exchange);
					img_main_member_exchange.setImageResource(R.drawable.mydata_forward);
					
					AutoSizeTextView lab_main_member_feedback = (AutoSizeTextView)findViewById(R.id.lab_main_member_feedback);
					lab_main_member_feedback.setTextColor(getResources().getColor(R.color.main_back_white_title));
					
					ImageView img_main_member_feedback = (ImageView)findViewById(R.id.img_main_member_feedback);
					img_main_member_feedback.setImageResource(R.drawable.mydata_forward);
					
					AutoSizeTextView lab_main_member_setting = (AutoSizeTextView)findViewById(R.id.lab_main_member_setting);
					lab_main_member_setting.setTextColor(getResources().getColor(R.color.main_back_white_title));
					
					ImageView img_main_member_setting = (ImageView)findViewById(R.id.img_main_member_setting);
					img_main_member_setting.setImageResource(R.drawable.mydata_forward);
					/*
					AutoSizeTextView lab_main_member_collection = (AutoSizeTextView)findViewById(R.id.lab_main_member_collection);
					lab_main_member_collection.setTextColor(getResources().getColor(R.color.main_back_white_title));
					
					ImageView img_main_member_collection = (ImageView)findViewById(R.id.img_main_member_collection);
					img_main_member_collection.setImageResource(R.drawable.mydata_forward);
					*/
					LinearLayout ll_main_memberpage_collection = (LinearLayout)findViewById(R.id.ll_main_memberpage_collection);
					ll_main_memberpage_collection.setBackgroundColor(getResources().getColor(R.color.main_back_white_back));
					
					LinearLayout ll_main_memberpage_data = (LinearLayout)findViewById(R.id.ll_main_memberpage_data);
					ll_main_memberpage_data.setBackgroundColor(getResources().getColor(R.color.main_back_white_back));
					
					LinearLayout ll_main_memberpage_photo = (LinearLayout)findViewById(R.id.ll_main_memberpage_photo);
					ll_main_memberpage_photo.setBackgroundColor(getResources().getColor(R.color.main_back_white_back));
					
					LinearLayout ll_main_memberpage_faq = (LinearLayout)findViewById(R.id.ll_main_memberpage_faq);
					ll_main_memberpage_faq.setBackgroundColor(getResources().getColor(R.color.main_back_white_back));
					
					LinearLayout ll_main_memberpage_exchange = (LinearLayout)findViewById(R.id.ll_main_memberpage_exchange);
					ll_main_memberpage_exchange.setBackgroundColor(getResources().getColor(R.color.main_back_white_back));
					
					LinearLayout ll_main_memberpage_feedback = (LinearLayout)findViewById(R.id.ll_main_memberpage_feedback);
					ll_main_memberpage_feedback.setBackgroundColor(getResources().getColor(R.color.main_back_white_back));
					
					LinearLayout ll_main_memberpage_setting = (LinearLayout)findViewById(R.id.ll_main_memberpage_setting);
					ll_main_memberpage_setting.setBackgroundColor(getResources().getColor(R.color.main_back_white_back));
					/*
					LinearLayout ll_main_memberpage_collectionpage = (LinearLayout)findViewById(R.id.ll_main_memberpage_collectionpage);
					ll_main_memberpage_collectionpage.setBackgroundColor(getResources().getColor(R.color.main_back_white_back));
					*/
				}
					
			}

			else
				m_itemCount = 0;

		} catch (JSONException e) {
			
		}

	}
	
	private void onClickItem(int position)
	{
		int id = m_Datas[position].item_id;
		
		if (position == 0)
		{
			Intent groupactinfo_activity = new Intent(this, GroupActInfoActivity.class);
			groupactinfo_activity.putExtra(GroupActInfoActivity.GROUPACTINFO_ID, id);
			startActivity(groupactinfo_activity);
		}
		else if (position == 1)
		{
			Intent shareinfo_activity = new Intent(this, ShareInfoActivity.class);
			shareinfo_activity.putExtra(ShareInfoActivity.SHAREINFO_ID, id);
			startActivity(shareinfo_activity);
		}
		else if (position == 2)
		{
			Intent studyinfo_activity = new Intent(this, StudyInfoActivity.class);
			studyinfo_activity.putExtra(StudyInfoActivity.STUDYINFO_ID, id);
			startActivity(studyinfo_activity);
		}
		else if (position == 3)
		{
			Intent faqinfo_activity = new Intent(this, FaqInfoActivity.class);
			faqinfo_activity.putExtra(FaqInfoActivity.FAQINFO_ID, id);
			startActivity(faqinfo_activity);
		}
		else if (position == 4)
		{
			Intent exchangeinfo_activity = new Intent(this, ExchangeInfoActivity.class);
			exchangeinfo_activity.putExtra(ExchangeInfoActivity.EXCHANGEINFO_ID, id);
			startActivity(exchangeinfo_activity);
		}
		
		
	}

}
