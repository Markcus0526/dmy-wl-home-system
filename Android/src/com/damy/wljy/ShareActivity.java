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
import com.damy.common.STShareItemInfo;

import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.app.AlertDialog;
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

import com.damy.wljy.*;

public class ShareActivity extends Activity {

	private ListView m_anContents = null;
	private ShareItemAdapter mAdapter = null;
	
	private STShareItemInfo m_Datas[] = null;
	private int m_itemCount = 0;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private JsonHttpResponseHandler handler1;
    private ProgressDialog progDialog1;
    
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
	private int m_nType = 1;
	
	private ArrayList<STShareItemInfo> actListInfo = new ArrayList<STShareItemInfo>();
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_share);
		
		
		Global.Weekday_Str = getResources().getString(R.string.weekday).split(",");

		ll_type1 = (LinearLayout)findViewById(R.id.ll_share_type1);
		ll_type2 = (LinearLayout)findViewById(R.id.ll_share_type2);
		ll_type3 = (LinearLayout)findViewById(R.id.ll_share_type3);
		lab_typ1 = (AutoSizeTextView)findViewById(R.id.lab_share_type1);
		lab_typ2 = (AutoSizeTextView)findViewById(R.id.lab_share_type2);
		lab_typ3 = (AutoSizeTextView)findViewById(R.id.lab_share_type3);
		ll_type1.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		ll_type1.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		ll_type2.setBackgroundResource(R.drawable.activity_unsel_btn);
        		ll_type3.setBackgroundResource(R.drawable.activity_unsel_btn);
        		lab_typ1.setTextColor(getResources().getColor(R.color.color_white));
        		lab_typ2.setTextColor(getResources().getColor(R.color.color_black));
        		lab_typ3.setTextColor(getResources().getColor(R.color.color_black));
        		
        		m_nType = 1;
        		onClickShareType();
        		//readContents(1);
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

        		m_nType = 2;
        		onClickShareType();
        		//readContents(2);
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

        		m_nType = 3;
        		onClickShareType();
        		//readContents(2);
        	}
        });
		
		lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_share_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_share_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout fl_submitbtn = (FrameLayout)findViewById(R.id.fl_share_addbtn);
		fl_submitbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAdd();
        	}
        });
		
		mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.anShareContentView);
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
		        	actListInfo = parseShareItems(object);	                	
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
		
		//readContents(1);
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
		Intent shareadd_activity = new Intent(this, ShareAddActivity.class);
		startActivity(shareadd_activity);
	}
	
	private void initContents()
    {
    	if (mRealListView != null)
    	{
    		getShowListFromData();
    	}
    }
	
	protected void onClickShareType() {
		// TODO Auto-generated method stub
		nCurPageNumber = 1;
		actListInfo.clear();
		RunBackGround();
	}
	
	private void RunBackGround()
	{
    	
	    progDialog = ProgressDialog.show(
	    		ShareActivity.this,
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
             
             String str_url = Global.STR_SERVER_URL + "share.jsp";
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

			mAdapter = new ShareItemAdapter(ShareActivity.this, this.getApplicationContext());
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
		String connectUrl = Global.STR_SERVER_URL + "share.jsp?userid=" + Integer.toString(Global.Cur_UserId)
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
	
	private ArrayList<STShareItemInfo> parseShareItems(JSONObject order)
	{
		ArrayList<STShareItemInfo> retList = new ArrayList<STShareItemInfo>();
		try {
			JSONObject anItem = new JSONObject();
			JSONArray data = new JSONArray();
			int isSuccess;
			isSuccess = order.getInt("success");
			
			if (isSuccess == 1) {
				m_itemCount = order.getInt("count");
				if (m_itemCount == 0) return retList;		
				data = order.getJSONArray("data");
				for (int i = 0; i < m_itemCount;i++) {
					STShareItemInfo itemInfo = new STShareItemInfo();
					JSONArray image_path = new JSONArray();
					anItem = data.getJSONObject(i);

					itemInfo.item_id = anItem.getInt("id");
					itemInfo.title = anItem.getString("title");
					itemInfo.body = anItem.getString("body");
					itemInfo.mname = anItem.getString("username");
					itemInfo.day = anItem.getString("postdate").substring(8, 10);
					itemInfo.yearmonth = anItem.getString("postdate").substring(0, 4) + "." + anItem.getString("postdate").substring(5, 7);
					itemInfo.weekday = Global.Weekday_Str[anItem.getInt("week")];
					itemInfo.readcount = anItem.getInt("readcount");
					itemInfo.imagepath = anItem.getString("imagepath");
                    itemInfo.imagepath1 = anItem.getString("imagepath1");
                    itemInfo.imagepath2 = anItem.getString("imagepath2");

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
	
	private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STShareItemInfo>> {

		@Override
		protected ArrayList<STShareItemInfo> doInBackground(Void... params) {
			// Simulates a background job.
			try {
				nCurPageNumber = nCurPageNumber + 1;
				
				String responseBody = RequestActListWithParamNoDelay();
				JSONObject result = new JSONObject(responseBody);
				ArrayList<STShareItemInfo> parse_data = parseShareItems(result);
				return parse_data;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STShareItemInfo> result) {
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
            public void onFailure(Throwable ex, String exception) {
            	
            	progDialog.dismiss();
            }

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(ShareActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	
        	
        	String str_url = Global.STR_SERVER_URL + "share.jsp";
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
					m_Datas = new STShareItemInfo[m_itemCount];
					for (int i = 0; i < m_itemCount; i++) {
						m_Datas[i] = new STShareItemInfo();
					}
					data = order.getJSONArray("data");
					for (int i = 0; i < m_itemCount;i++) {
						anItem = data.getJSONObject(i);
						m_Datas[i].item_id = anItem.getInt("id");
						m_Datas[i].title = anItem.getString("title");
						m_Datas[i].body = anItem.getString("body");
						m_Datas[i].mname = anItem.getString("username");
						m_Datas[i].day = anItem.getString("postdate").substring(8, 10);
						m_Datas[i].yearmonth = anItem.getString("postdate").substring(0, 4) + "." + anItem.getString("postdate").substring(5, 7);
						m_Datas[i].weekday = Global.Weekday_Str[anItem.getInt("week")];
						m_Datas[i].readcount = anItem.getInt("readcount");
						m_Datas[i].imagepath = anItem.getString("imagepath");
					}
					
					m_anContents = (ListView) findViewById(R.id.anShareContentView);
					if (m_anContents != null)
					{
						m_anContents.setVisibility(android.view.View.VISIBLE);
						m_anContents.setCacheColorHint(getResources().getColor(R.color.common_backcolor));
						m_anContents.setDividerHeight(0);
						m_anContents.setBackgroundColor(getResources().getColor(R.color.common_backcolor));
						mAdapter = new ShareItemAdapter(ShareActivity.this, this.getApplicationContext());
						
						m_anContents.setAdapter(mAdapter);
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
				{
					m_anContents.setVisibility(android.view.View.INVISIBLE);
				}				
			}			

		} catch (JSONException e) {
			
		}
	}
	*/
	
	public void OnClickCollectItem(int id)
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

        progDialog1 = ProgressDialog.show(ShareActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "collection_add.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("id", Integer.toString(id));
            param.put("type", "2");
            
            client.get(str_url, param, handler1);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onClickItem(int position)
	{
		STShareItemInfo clickedItem = getItem(position - 1);
		
		Intent shareinfo_activity = new Intent(this, ShareInfoActivity.class);
		shareinfo_activity.putExtra(ShareInfoActivity.SHAREINFO_ID, clickedItem.item_id);
		startActivity(shareinfo_activity);
	}

	public int getItemCount()
	{
		return actListInfo.size();
	}
	
	public STShareItemInfo getItem(int position)
	{
		if (position < 0 || position >= actListInfo.size())
			return null;
		
		return actListInfo.get(position);
	}
	
	public int getCount() {
		// TODO Auto-generated method stub
		return actListInfo.size();
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
}
