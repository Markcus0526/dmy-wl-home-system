package com.damy.wljy;

import java.util.ArrayList;

import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;
import com.damy.Utils.AutoSizeTextView;
import com.damy.Utils.PullToRefreshBase;
import com.damy.Utils.PullToRefreshListView;
import com.damy.Utils.PullToRefreshBase.Mode;
import com.damy.Utils.PullToRefreshBase.OnRefreshListener;
import com.damy.common.Global;
import com.damy.common.STExchangeItemInfo;
import com.damy.common.STExchangeItemInfo;
import com.damy.common.STExchangeItemInfo;
import com.damy.common.STShareItemInfo;

import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.text.format.DateUtils;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.LinearLayout;
import android.widget.ListView;

public class ExchangeActivity extends Activity {

	private ListView m_anContents = null;
	private ExchangeItemAdapter mAdapter = null;
	
	private STExchangeItemInfo m_Datas[] = null;
	private int m_itemCount = 0;
	private int m_rowCount = 0;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private LinearLayout ll_type1;
    private LinearLayout ll_type2;
    private LinearLayout ll_type3;
    
	private AutoSizeTextView lab_typ1;
	private AutoSizeTextView lab_typ2;
	private AutoSizeTextView lab_typ3;
	
	private AutoSizeTextView lab_curdate;
	
	private PullToRefreshListView mPullRefreshListView;
	private ListView mRealListView;
	
	boolean bexistNext = true;
	int		nCurPageNumber = 1;
	private int 	m_nType = 0;
	
	private ArrayList<STExchangeItemInfo> actListInfo = new ArrayList<STExchangeItemInfo>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_exchange);
		
		Global.Weekday_Str = getResources().getString(R.string.weekday).split(",");

		ll_type1 = (LinearLayout)findViewById(R.id.ll_exchange_type1);
		ll_type2 = (LinearLayout)findViewById(R.id.ll_exchange_type2);
		ll_type3 = (LinearLayout)findViewById(R.id.ll_exchange_type3);
		lab_typ1 = (AutoSizeTextView)findViewById(R.id.lab_exchange_type1);
		lab_typ2 = (AutoSizeTextView)findViewById(R.id.lab_exchange_type2);
		lab_typ3 = (AutoSizeTextView)findViewById(R.id.lab_exchange_type3);
		
		ll_type1.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type1.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		ll_type2.setBackgroundResource(R.drawable.activity_unsel_btn);
        		ll_type3.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ1.setTextColor(getResources().getColor(R.color.color_white));
        		lab_typ2.setTextColor(getResources().getColor(R.color.color_black));
        		lab_typ3.setTextColor(getResources().getColor(R.color.color_black));
        		
        		m_nType = 0;
        		onClickExchangeType();
        		//readContents(0);
        	}			
        });
		ll_type2.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type1.setBackgroundResource(R.drawable.activity_unsel_btn);
        		ll_type2.setBackgroundResource(R.drawable.activity_sel_btn);
        		ll_type3.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ1.setTextColor(getResources().getColor(R.color.color_black));
        		lab_typ2.setTextColor(getResources().getColor(R.color.color_white));
        		lab_typ3.setTextColor(getResources().getColor(R.color.color_black));

        		m_nType = 1;
        		onClickExchangeType();
        		//readContents(1);
        	}
        });
		ll_type3.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type1.setBackgroundResource(R.drawable.activity_unsel_btn);
        		ll_type2.setBackgroundResource(R.drawable.activity_unsel_btn);
        		ll_type3.setBackgroundResource(R.drawable.activity_sel_btn);
        		lab_typ1.setTextColor(getResources().getColor(R.color.color_black));
        		lab_typ2.setTextColor(getResources().getColor(R.color.color_black));
        		lab_typ3.setTextColor(getResources().getColor(R.color.color_white));

        		m_nType = 2;
        		onClickExchangeType();
        		//readContents(2);
        	}
        });		
		
		lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_exchange_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
		
		LinearLayout ll_backbtn  = (LinearLayout)findViewById(R.id.ll_exchange_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		//readContents(0);
		
		mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.anExchangeContentView);
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
		        	actListInfo = parseExchangeItems(object);	                	
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
		
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void initContents()
    {
    	if (mRealListView != null)
    	{
    		getShowListFromData();
    	}
    }
	
	protected void onClickExchangeType() {
		// TODO Auto-generated method stub
		nCurPageNumber = 1;
		actListInfo.clear();
		RunBackGround();
	}
	
	private void RunBackGround()
	{
    	
	    progDialog = ProgressDialog.show(
	    		ExchangeActivity.this,
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
             
             String str_url = Global.STR_SERVER_URL + "exchange.jsp";
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
    		
    	
    	if (actListInfo.size() == Global.Page_Cnt / 2)
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

			mAdapter = new ExchangeItemAdapter(ExchangeActivity.this, this.getApplicationContext());
			mRealListView.setAdapter(mAdapter);
    	}
    }
    
	public String RequestActListWithParamNoDelay()
	{
		String connectUrl = Global.STR_SERVER_URL + "exchange.jsp?userid=" + Integer.toString(Global.Cur_UserId)
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
	
	private ArrayList<STExchangeItemInfo> parseExchangeItems(JSONObject order)
	{
		ArrayList<STExchangeItemInfo> retList = new ArrayList<STExchangeItemInfo>();
		try {
			JSONObject anItem = new JSONObject();
			JSONArray data = new JSONArray();
			int isSuccess;
			isSuccess = order.getInt("success");
			
			if (isSuccess == 1) {
				m_itemCount = order.getInt("count");
				if (m_itemCount == 0) return retList;		
				data = order.getJSONArray("data");
				
				if (m_itemCount % 2 == 0)
					m_rowCount = m_itemCount / 2;
				else
					m_rowCount = m_itemCount / 2 + 1;
				
				
				for (int i = 0; i < m_rowCount; i++) {

					STExchangeItemInfo itemInfo = new STExchangeItemInfo();
					
					anItem = data.getJSONObject(i * 2);
					
					itemInfo.item_id1 = anItem.getInt("id");
					itemInfo.name1 = anItem.getString("name");
					itemInfo.market_price1 = anItem.getString("market_price");
					itemInfo.integral1 = anItem.getString("integral_price");
					itemInfo.imagepath1 = anItem.getString("imagepath");
	
					if ( i * 2 + 1 < m_itemCount )
					{
						anItem = data.getJSONObject(i * 2 + 1);
						
						itemInfo.item_id2 = anItem.getInt("id");
						itemInfo.name2 = anItem.getString("name");
						itemInfo.market_price2 = anItem.getString("market_price");
						itemInfo.integral2 = anItem.getString("integral_price");
						itemInfo.imagepath2 = anItem.getString("imagepath");
					}
					else
					{
						itemInfo.item_id2 = 0;
						itemInfo.name2 = "";
						itemInfo.market_price2 = "";
						itemInfo.integral2 = "";
						itemInfo.imagepath2 = "";
					}
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
	
	private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STExchangeItemInfo>> {

		@Override
		protected ArrayList<STExchangeItemInfo> doInBackground(Void... params) {
			// Simulates a background job.
			try {
				nCurPageNumber = nCurPageNumber + 1;
				
				String responseBody = RequestActListWithParamNoDelay();
				JSONObject result = new JSONObject(responseBody);
				ArrayList<STExchangeItemInfo> parse_data = parseExchangeItems(result);
				return parse_data;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STExchangeItemInfo> result) {
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

        progDialog = ProgressDialog.show(ExchangeActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	
        	
        	String str_url = Global.STR_SERVER_URL + "exchange.jsp";
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
			m_anContents = (ListView) findViewById(R.id.anExchangeContentView);
			
			if ( isSuccess == 1 )
			{
				m_itemCount = order.getInt("count");
				if (m_itemCount % 2 == 0)
					m_rowCount = m_itemCount / 2;
				else
					m_rowCount = m_itemCount / 2 + 1;
				
				if ( m_rowCount > 0 ) {
				
					m_Datas = new STExchangeItemInfo[m_rowCount];
					
					for (int i = 0; i < m_rowCount; i++) {
						m_Datas[i] = new STExchangeItemInfo();
					}
					data = order.getJSONArray("data");
					int j = 0;
					for (int i = 0; i < m_itemCount;i++) {
						anItem = data.getJSONObject(i);
						if (i % 2 == 0) {
							m_Datas[j].item_id1 = anItem.getInt("id");
							m_Datas[j].name1 = anItem.getString("name");
							m_Datas[j].market_price1 = anItem.getString("market_price");
							m_Datas[j].integral1 = anItem.getString("integral_price");
							m_Datas[j].imagepath1 = anItem.getString("imagepath");
						}
						else {
							m_Datas[j].item_id2 = anItem.getInt("id");
							m_Datas[j].name2 = anItem.getString("name");
							m_Datas[j].market_price2 = anItem.getString("market_price");
							m_Datas[j].integral2 = anItem.getString("integral_price");
							m_Datas[j].imagepath2 = anItem.getString("imagepath");
							j++;
						}					
					}
					
					if (j != m_rowCount){
						m_Datas[j].item_id2 = 0;
						m_Datas[j].name2 = "";
						m_Datas[j].market_price2 = "";
						m_Datas[j].integral2 = "";
						m_Datas[j].imagepath2 = "";
					}
				
				
					if (m_anContents != null)
					{
						m_anContents.setVisibility(android.view.View.VISIBLE);
						m_anContents.setCacheColorHint(getResources().getColor(R.color.common_backcolor));
						m_anContents.setDividerHeight(0);
						m_anContents.setBackgroundColor(getResources().getColor(R.color.common_backcolor));
						mAdapter = new ExchangeItemAdapter(ExchangeActivity.this, this.getApplicationContext());
						
						m_anContents.setAdapter(mAdapter);
					}
				}
				else
				{
					if (m_anContents != null)
					{
						m_anContents.setVisibility(android.view.View.INVISIBLE);
					}
				}
			}
			else
			{
				m_rowCount = 0;
				if (m_anContents != null)
				{
					m_anContents.setVisibility(android.view.View.INVISIBLE);
				}
			}
			

		} catch (JSONException e) {
			
		}
	}

	 */
	
	
	public int getItemCount()
	{
		return actListInfo.size();
	}
	
	public STExchangeItemInfo getItem(int position)
	{
		if (position < 0 || position >= actListInfo.size())
			return null;
		
		return actListInfo.get(position);
	}
	
	public int getCount() {
		// TODO Auto-generated method stub
		return actListInfo.size();
	}
	
	public void OnClickExchangeItem(int id)
	{
		Intent exchangeinfo_activity = new Intent(this, ExchangeInfoActivity.class);
		exchangeinfo_activity.putExtra(ExchangeInfoActivity.EXCHANGEINFO_ID, id);
		startActivity(exchangeinfo_activity);
	}


}
