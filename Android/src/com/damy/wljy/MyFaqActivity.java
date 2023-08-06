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
import com.damy.common.STFaqItemInfo;
import com.damy.common.STMyFaqItemInfo;
import com.damy.common.STMyFaqItemInfo;

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


public class MyFaqActivity extends Activity {

	private ListView m_anContents = null;
	private MyFaqItemAdapter mAdapter = null;
	
	private MyFaqAddActivity	m_faqAddContents = null;
	private STMyFaqItemInfo m_Datas[] = null;
	private int m_itemCount = 0;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
	private AutoSizeTextView lab_curdate;
	
	private PullToRefreshListView mPullRefreshListView;
	private ListView mRealListView;
	
	boolean bexistNext = true;
	int		nCurPageNumber = 1;
	private int 	m_nType = 0;
	
	private ArrayList<STMyFaqItemInfo> actListInfo = new ArrayList<STMyFaqItemInfo>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_myfaq);

		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_myfaq_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout ll_addbtn = (FrameLayout)findViewById(R.id.fl_myfaq_addbtn);
		ll_addbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAdd();
        	}
        });
		
		mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.anMyFaqContentView);
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
		
		RunBackGround();
		
		//readContents();
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
	    		MyFaqActivity.this,
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
             
             String str_url = Global.STR_SERVER_URL + "myquestion.jsp";
             param.put("userid", Integer.toString(Global.Cur_UserId));
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

			mAdapter = new MyFaqItemAdapter(MyFaqActivity.this, this.getApplicationContext());
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
		String connectUrl = Global.STR_SERVER_URL + "myquestion.jsp?userid=" + Integer.toString(Global.Cur_UserId)
				+ "&page=" + Integer.toString(nCurPageNumber);

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
	
	private ArrayList<STMyFaqItemInfo> parseFaqItems(JSONObject order)
	{
		ArrayList<STMyFaqItemInfo> retList = new ArrayList<STMyFaqItemInfo>();
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
					STMyFaqItemInfo itemInfo = new STMyFaqItemInfo();
					anItem = data.getJSONObject(i);

					itemInfo.item_id = anItem.getInt("id");
					itemInfo.title = anItem.getString("title");
					itemInfo.body = anItem.getString("body");
					itemInfo.postdate = anItem.getString("postdate");
					itemInfo.readcount = anItem.getInt("read_count");
					itemInfo.answer = anItem.getInt("answer_count");
					itemInfo.recentanswer = anItem.getString("answerer_name");

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
	
	private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STMyFaqItemInfo>> {

		@Override
		protected ArrayList<STMyFaqItemInfo> doInBackground(Void... params) {
			// Simulates a background job.
			try {
				nCurPageNumber = nCurPageNumber + 1;
				
				String responseBody = RequestActListWithParamNoDelay();
				JSONObject result = new JSONObject(responseBody);
				ArrayList<STMyFaqItemInfo> parse_data = parseFaqItems(result);
				return parse_data;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STMyFaqItemInfo> result) {
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
            public void onFailure(Throwable ex, String exception) {}

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(MyFaqActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	
        	
        	String str_url = Global.STR_SERVER_URL + "myquestion.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            
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
				
				m_Datas = new STMyFaqItemInfo[m_itemCount];
				for (int i = 0; i < m_itemCount; i++) {
					m_Datas[i] = new STMyFaqItemInfo();
				}
				data = order.getJSONArray("data");
				for (int i = 0; i < m_itemCount;i++) {
					anItem = data.getJSONObject(i);
					m_Datas[i].item_id = anItem.getInt("id");
					m_Datas[i].title = anItem.getString("title");
					m_Datas[i].body = anItem.getString("body");
					m_Datas[i].postdate = anItem.getString("postdate");
					m_Datas[i].readcount = anItem.getInt("read_count");
					m_Datas[i].answer = anItem.getInt("answer_count");
					m_Datas[i].recentanswer = anItem.getString("answerer_name");
				}
				
				m_anContents = (ListView) findViewById(R.id.anMyFaqContentView);
				if (m_anContents != null)
				{
					m_anContents.setCacheColorHint(getResources().getColor(R.color.common_backcolor));
					m_anContents.setDividerHeight(0);
					m_anContents.setBackgroundColor(getResources().getColor(R.color.common_backcolor));
					mAdapter = new MyFaqItemAdapter(MyFaqActivity.this, this.getApplicationContext());
					
					m_anContents.setAdapter(mAdapter);
				}
			}
			else
				m_itemCount = 0;

		} catch (JSONException e) {
			
		}
	}
	*/
	
	private void onClickItem(int position)
	{
		STMyFaqItemInfo clickedItem = getItem(position - 1);
		
		Intent faqinfo_activity = new Intent(this, FaqInfoActivity.class);
		faqinfo_activity.putExtra(FaqInfoActivity.FAQINFO_ID, clickedItem.item_id);
		startActivity(faqinfo_activity);
	}

	public int getItemCount()
	{
		return actListInfo.size();
	}
	
	public STMyFaqItemInfo getItem(int position)
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
