package com.damy.wljy;


import java.util.ArrayList;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;
import com.damy.Utils.AutoSizeTextView;
import com.damy.Utils.PullToRefreshBase;
import com.damy.Utils.PullToRefreshListView;
import com.damy.Utils.PullToRefreshBase.Mode;
import com.damy.Utils.PullToRefreshBase.OnRefreshListener;

import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.damy.common.Global;
import com.damy.common.STActivityItemInfo;
import com.damy.common.STFaqItemInfo;
import com.damy.common.STFaqItemInfo;


import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;

import android.text.format.DateUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListView;


public class FaqActivity extends Activity {

	private ListView m_anContents = null;
	private FaqItemAdapter mAdapter = null;
	
	private STFaqItemInfo m_Datas[] = null;
	private int m_itemCount = 0;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private LinearLayout ll_type1;
    private LinearLayout ll_type2;
    private LinearLayout ll_type3;
    private LinearLayout ll_type4;
	private AutoSizeTextView lab_typ1;
	private AutoSizeTextView lab_typ2;
	private AutoSizeTextView lab_typ3;
	private AutoSizeTextView lab_typ4;
	
	private AutoSizeTextView lab_curdate;
	
	private PullToRefreshListView mPullRefreshListView;
	private ListView mRealListView;
	
	boolean bexistNext = true;
	int		nCurPageNumber = 1;
	private int m_nType = 0;
	
	private ArrayList<STFaqItemInfo> actListInfo = new ArrayList<STFaqItemInfo>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_faq);
		

		ll_type1 = (LinearLayout)findViewById(R.id.ll_faq_type1);
		ll_type2 = (LinearLayout)findViewById(R.id.ll_faq_type2);
		ll_type3 = (LinearLayout)findViewById(R.id.ll_faq_type3);
		ll_type4 = (LinearLayout)findViewById(R.id.ll_faq_type4);
		lab_typ1 = (AutoSizeTextView)findViewById(R.id.lab_faq_type1);
		lab_typ2 = (AutoSizeTextView)findViewById(R.id.lab_faq_type2);
		lab_typ3 = (AutoSizeTextView)findViewById(R.id.lab_faq_type3);
		lab_typ4 = (AutoSizeTextView)findViewById(R.id.lab_faq_type4);
		
		ll_type1.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type1.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		lab_typ1.setTextColor(getResources().getColor(R.color.color_white));
        		
        		ll_type2.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ2.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type3.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ3.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type4.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ4.setTextColor(getResources().getColor(R.color.color_black));
        		
        		m_nType = 0;
        		onClickFaqType();
        		//readContents(0);
        	}
        });
		ll_type2.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type2.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		lab_typ2.setTextColor(getResources().getColor(R.color.color_white));
        		
        		ll_type1.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ1.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type3.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ3.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type4.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ4.setTextColor(getResources().getColor(R.color.color_black));

        		m_nType = 1;
        		onClickFaqType();
        		//readContents(1);
        	}
        });
		ll_type3.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type3.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		lab_typ3.setTextColor(getResources().getColor(R.color.color_white));
        		
        		ll_type1.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ1.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type2.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ2.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type4.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ4.setTextColor(getResources().getColor(R.color.color_black));

        		m_nType = 2;
        		onClickFaqType();
        		//readContents(2);
        	}
        });
		ll_type4.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type4.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		lab_typ4.setTextColor(getResources().getColor(R.color.color_white));
        		
        		ll_type1.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ1.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type2.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ2.setTextColor(getResources().getColor(R.color.color_black));
        		ll_type3.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ3.setTextColor(getResources().getColor(R.color.color_black));

        		m_nType = 3;
        		onClickFaqType();
        		//readContents(3);
        	}
        });
		
		lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_faq_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_faq_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout ll_addbtn = (FrameLayout)findViewById(R.id.fl_faq_myfaqadd);
		ll_addbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAdd();
        	}
        });
		
		
		//readContents(0);
		
		mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.anFaqContentView);
		mPullRefreshListView.setMode(Mode.PULL_FROM_END);
		
		mPullRefreshListView.setOnRefreshListener(new OnRefreshListener<ListView>() {
			@Override
			public void onRefresh(PullToRefreshBase<ListView> refreshView) {
				String label = DateUtils.formatDateTime(getApplicationContext(), System.currentTimeMillis(),
								DateUtils.FORMAT_SHOW_TIME | DateUtils.FORMAT_SHOW_DATE | DateUtils.FORMAT_ABBREV_ALL);
			
				// Update the LastUpdatedLabel
				refreshView.getLoadingLayoutProxy().setLastUpdatedLabel(label);
			
				// Do work to refresh the list here.
				new GetDataTask().execute();
			}
		});
		
		mRealListView = mPullRefreshListView.getRefreshableView();
		
		// Need to use the Actual ListView when registering for Context Menu
		registerForContextMenu(mRealListView);
		
		handler = new JsonHttpResponseHandler()
		{
		    @Override
		    public void onSuccess(JSONObject object)
		    {
		        progDialog.dismiss();
		
		        try {
		        	actListInfo = parseFaqItems(object);	                	
		        	initContents();
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
		
		//RunBackGround();
	}
	
	@Override
	protected void onResume()
	{
		nCurPageNumber = 1;
		RunBackGround();
		super.onResume();
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickAdd()
	{
		Intent myfaqadd_activity = new Intent(this, MyFaqAddActivity.class);
		startActivity(myfaqadd_activity);
	}
	
	private void initContents()
    {
    	if (mRealListView != null)
    	{
    		getShowListFromData();
    	}
    }
	
	protected void onClickFaqType() {
		// TODO Auto-generated method stub
		nCurPageNumber = 1;
		actListInfo.clear();
		RunBackGround();
	}
	
	private void RunBackGround()
	{
    	
	    progDialog = ProgressDialog.show(
	    		FaqActivity.this,
				"",
	            "Waiting",
	            true,
	            true,
	            new DialogInterface.OnCancelListener(){
	                @Override
	                public void onCancel(DialogInterface dialog) {
	                    
	                }
	            }
	        );
	    GetResponse();	    
	}
	
	private void GetResponse()
    {
    	 AsyncHttpClient client = new AsyncHttpClient();
         RequestParams param = new RequestParams();
         
         try {
             
             String str_url = Global.STR_SERVER_URL + "faq.jsp";
             param.put("userid", Integer.toString(Global.Cur_UserId));
             param.put("type", Integer.toString(m_nType));
             param.put("page", Integer.toString(nCurPageNumber));
             
             client.get(str_url, param, handler);
             
         } catch (Exception e) {
             e.printStackTrace();
         }
    }
    private void getShowListFromData()
    {
    	if (actListInfo == null) {
    		if (mRealListView != null)
    		{
    			mRealListView.setVisibility(android.view.View.INVISIBLE);
    		}
    		return;
    	}
    		
    	
    	if (actListInfo.size() == Global.Page_Cnt)
    	{
    		bexistNext = true;
   			mPullRefreshListView.setMode(Mode.PULL_FROM_END);
    	}
    	else
    	{
    		bexistNext = false;
   			mPullRefreshListView.setMode(Mode.DISABLED);
    	}
    	
    	if (mRealListView != null)
    	{
    		mRealListView.setVisibility(android.view.View.VISIBLE);
    		mRealListView.setCacheColorHint(getResources().getColor(R.color.main_item_back));
			mRealListView.setDividerHeight(0);
			//m_anContents.setBackgroundColor(getResources().getColor(R.color.bottombar_blue));

			mAdapter = new FaqItemAdapter(FaqActivity.this, this.getApplicationContext());
			mRealListView.setAdapter(mAdapter);

			mRealListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
				public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
					onClickItem(position);
	        	}
			});
			
			
    	}
    }
    
	public String RequestActListWithParamNoDelay()
	{
		String connectUrl = Global.STR_SERVER_URL + "faq.jsp?userid=" + Integer.toString(Global.Cur_UserId)
				+ "&type=" + Integer.toString(m_nType) + "&page=" + Integer.toString(nCurPageNumber);

		HttpClient client = new DefaultHttpClient();
		HttpGet get = new HttpGet(connectUrl);

		ResponseHandler responseHandler = new BasicResponseHandler();

		String responseBody = "";
		try {
			responseBody = (String)client.execute(get, responseHandler);
		} catch(Exception ex) {
		ex.printStackTrace();
		}
		
		return responseBody;
	}
	
	private ArrayList<STFaqItemInfo> parseFaqItems(JSONObject order)
	{
		ArrayList<STFaqItemInfo> retList = new ArrayList<STFaqItemInfo>();
		try {
			JSONObject anItem = new JSONObject();
			JSONArray data = new JSONArray();
			int isSuccess;
			isSuccess = order.getInt("success");
			
			if (isSuccess == 1) {
				m_itemCount = order.getInt("count");
				Global.Cur_FaqMaxIntegral = order.getInt("max");
				if (m_itemCount == 0) return retList;		
				data = order.getJSONArray("data");
				for (int i = 0; i < m_itemCount;i++) {
					STFaqItemInfo itemInfo = new STFaqItemInfo();
					anItem = data.getJSONObject(i);

					itemInfo.item_id = anItem.getInt("id");
					itemInfo.title = anItem.getString("title");
					itemInfo.body = anItem.getString("body");
					itemInfo.updatedate = anItem.getString("postdate").substring(0, 4) + "." + anItem.getString("postdate").substring(5, 7) + "." + anItem.getString("postdate").substring(8, 10);
					itemInfo.rewardintegral = anItem.getInt("rewardintegral");
					itemInfo.answer = anItem.getInt("answer_count");

					retList.add(itemInfo);
				}				
				
				return retList;
			}
			
			
			else
				return retList;
			
			

		} catch (JSONException e) {
			
		}
		return retList;
	}
	
	private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STFaqItemInfo>> {

		@Override
		protected ArrayList<STFaqItemInfo> doInBackground(Void... params) {
			// Simulates a background job.
			try {
				nCurPageNumber = nCurPageNumber + 1;
				
				String responseBody = RequestActListWithParamNoDelay();
				JSONObject result = new JSONObject(responseBody);
				ArrayList<STFaqItemInfo> parse_data = parseFaqItems(result);
				return parse_data;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STFaqItemInfo> result) {
			if (result != null)
			{
				int nBufSize = result.size();
				/*if (nBufSize == 8)
					bexistNext = true;
				else
					bexistNext = false;
				*/
				for (int i = 0; i < nBufSize; i++)
				{
					actListInfo.add(result.get(i));
				}
				
				mAdapter.notifyDataSetChanged();

				// Call onRefreshComplete when the list has been refreshed.
				mPullRefreshListView.onRefreshComplete();
			}
			
			super.onPostExecute(result);
		}
	}
	
	/*
	
	private void readContents(int type)
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
            public void onFailure(Throwable ex, String exception) {}

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(FaqActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	
        	String str_url = Global.STR_SERVER_URL + "faq.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("type", Integer.toString(type));
            
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
				m_itemCount = order.getInt("count");
				if (m_itemCount > 0) {
					m_Datas = new STFaqItemInfo[m_itemCount];
					for (int i = 0; i < m_itemCount; i++) {
						m_Datas[i] = new STFaqItemInfo();
					}
					data = order.getJSONArray("data");
					for (int i = 0; i < m_itemCount;i++) {
						anItem = data.getJSONObject(i);
						m_Datas[i].item_id = anItem.getInt("id");
						m_Datas[i].title = anItem.getString("title");
						m_Datas[i].body = anItem.getString("body");
						m_Datas[i].updatedate = anItem.getString("postdate").substring(0, 4) + "." + anItem.getString("postdate").substring(5, 7) + "." + anItem.getString("postdate").substring(8, 10);
						m_Datas[i].rewardintegral = anItem.getInt("rewardintegral");
						m_Datas[i].answer = anItem.getInt("answer_count");
					}
					
					m_anContents = (ListView) findViewById(R.id.anFaqContentView);
					if (m_anContents != null)
					{
						m_anContents.setVisibility(android.view.View.VISIBLE);
						m_anContents.setCacheColorHint(getResources().getColor(R.color.common_backcolor));
						m_anContents.setDividerHeight(0);
						m_anContents.setBackgroundColor(getResources().getColor(R.color.common_backcolor));
						mAdapter = new FaqItemAdapter(FaqActivity.this, this.getApplicationContext());
						
						m_anContents.setAdapter(mAdapter);
						
						m_anContents.setOnItemClickListener(new AdapterView.OnItemClickListener() {
							public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
								onClickItem(position);
				        	}
						});
					}
				}
				else {
					if (m_anContents != null)
					{
						m_anContents.setVisibility(android.view.View.INVISIBLE);
					}
				}
			
			}
			else {
				m_itemCount = 0;
				if (m_anContents != null)
					m_anContents.setVisibility(android.view.View.INVISIBLE);
			}

		} catch (JSONException e) {
			
		}
	}
	*/
	
	private void onClickItem(int position)
	{
		STFaqItemInfo clickedItem = getItem(position - 1);
		
		Intent faqinfo_activity = new Intent(this, FaqInfoActivity.class);
		faqinfo_activity.putExtra(FaqInfoActivity.FAQINFO_ID, clickedItem.item_id);
		startActivity(faqinfo_activity);
	}

	public int getItemCount()
	{
		return actListInfo.size();
	}
	
	public STFaqItemInfo getItem(int position)
	{
		if (position < 0 || position >= actListInfo.size())
			return null;
		
		return actListInfo.get(position);
	}
	
	public int getCount() {
		// TODO Auto-generated method stub
		return actListInfo.size();
	}
}
