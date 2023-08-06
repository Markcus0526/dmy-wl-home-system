package com.damy.wljy;



import java.util.ArrayList;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;

import com.damy.Utils.AutoSizeTextView;
import com.damy.Utils.PullToRefreshBase;
import com.damy.Utils.PullToRefreshBase.Mode;
import com.damy.Utils.PullToRefreshBase.OnRefreshListener;
import com.damy.Utils.PullToRefreshListView;
import com.damy.common.Global;
import com.damy.common.STActivityItemInfo;
import com.damy.common.STStudyItemInfo;


import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.text.format.DateUtils;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListView;



public class GroupActActivity extends Activity {

	private ListView m_anContents = null;
	private GroupActItemAdapter mAdapter1 = null;
	private SingleActItemAdapter mAdapter2 = null;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
	
	private STActivityItemInfo m_Datas[] = null;
	private int m_itemCount = 0;
	private LinearLayout group = null;
	private AutoSizeTextView group_text = null;
	private LinearLayout single = null;
	private AutoSizeTextView single_text = null;
	
	private AutoSizeTextView lab_curdate;
	
	private PullToRefreshListView mPullRefreshListView;
	private ListView mRealListView;
	
	boolean bexistNext = true;
	int		nCurPageNumber = 1;
	int type = 2;
	
	private ArrayList<STActivityItemInfo> actListInfo = new ArrayList<STActivityItemInfo>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_group_act);
		
		initControls();		
		lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_activity_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_activity_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout ll_addbtn = (FrameLayout)findViewById(R.id.fl_act_myactadd);
		ll_addbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickAdd();
        	}
        });
		
	//	readContents(2);
		
	     mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.list_view_activity);
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
	                	actListInfo = parseActivityItems(object);	                	
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
		Intent myactadd_activity = new Intent(this, MyActAddActivity.class);
		startActivity(myactadd_activity);
	}
	
	private void initControls()
	{
		group = (LinearLayout)findViewById(R.id.act_group_btn);
		single = (LinearLayout)findViewById(R.id.act_single_btn);
		group_text = (AutoSizeTextView)findViewById(R.id.act_group);
		single_text = (AutoSizeTextView)findViewById(R.id.act_single);
		group.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		group.setBackgroundResource(R.drawable.activity_sel_btn);        		
        		single.setBackgroundResource(R.drawable.activity_unsel_btn);
        		group_text.setTextColor(getResources().getColor(R.color.color_white));
        		single_text.setTextColor(getResources().getColor(R.color.color_black));
        		type = 2;
        		onClickActivity();
        	}			
        });
		single.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		group.setBackgroundResource(R.drawable.activity_unsel_btn);
        		single.setBackgroundResource(R.drawable.activity_sel_btn);
        		group_text.setTextColor(getResources().getColor(R.color.color_black));
        		single_text.setTextColor(getResources().getColor(R.color.color_white));
        		type = 1;
        		onClickActivity();
        	}
        });
	}
	protected void onClickActivity() {
		// TODO Auto-generated method stub
		nCurPageNumber = 1;
		actListInfo.clear();
		RunBackGround();
		
		
	}
	
    private void initContents()
    {
    	if (mRealListView != null)
    	{
    		getShowListFromData();
    	}
    }
    
    private void RunBackGround()
	{
    	
	    progDialog = ProgressDialog.show(
	    		GroupActActivity.this,
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
         	
         	        	
         	String str_url = Global.STR_SERVER_URL + "activity.jsp";
             param.put("userid", Integer.toString(Global.Cur_UserId));
             param.put("type", Integer.toString(type));
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
			if (type == 2) {
				mAdapter1 = new GroupActItemAdapter(GroupActActivity.this, this.getApplicationContext());
				mRealListView.setAdapter(mAdapter1);
			}
			else {
				
				mAdapter2 = new SingleActItemAdapter(GroupActActivity.this, this.getApplicationContext());
				mRealListView.setAdapter(mAdapter2);
			}
			
			mRealListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
				public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
					onClickItem(position);
	        	}
			});
			
			
    	}
    }
    
	public String RequestActListWithParamNoDelay()
	{
		String connectUrl = Global.STR_SERVER_URL + "activity.jsp?userid=" + Integer.toString(Global.Cur_UserId)
				+ "&type=" + Integer.toString(type) + "&page=" + Integer.toString(nCurPageNumber);

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
	
	private ArrayList<STActivityItemInfo> parseActivityItems(JSONObject order)
	{
		ArrayList<STActivityItemInfo> retList = new ArrayList<STActivityItemInfo>();
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
					STActivityItemInfo itemInfo = new STActivityItemInfo();
					JSONArray image_path = new JSONArray();
					anItem = data.getJSONObject(i);
					itemInfo.item_id = anItem.getInt("id");
					itemInfo.title = anItem.getString("title");
					itemInfo.body = anItem.getString("body");
					itemInfo.postdate = anItem.getString("postdate").replace("-", ".");
					itemInfo.evalcnt = anItem.getString("eval_count");
					itemInfo.readcnt = anItem.getString("read_count");
					image_path = anItem.getJSONArray("imagepath");
					
					for (int j = 0;j < image_path.length();j++) {
						if (j == 0) itemInfo.imagepath1 = image_path.getString(j);
						else if (j == 1) itemInfo.imagepath2 = image_path.getString(j);
						else if (j == 2) itemInfo.imagepath3 = image_path.getString(j);//											
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
	
	private void onClickItem(int pos)
	{
		STActivityItemInfo clickedItem = getItem(pos - 1);
		
		Intent groupactinfo_activity = new Intent(this, GroupActInfoActivity.class);
		groupactinfo_activity.putExtra(GroupActInfoActivity.GROUPACTINFO_ID, clickedItem.item_id);
		startActivity(groupactinfo_activity);
	}

	public int getItemCount()
	{
		return actListInfo.size();
	}
	
	public STActivityItemInfo getItem(int position)
	{
		if (position < 0 || position >= actListInfo.size())
			return null;
		
		return actListInfo.get(position);
	}
	private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STActivityItemInfo>> {

		@Override
		protected ArrayList<STActivityItemInfo> doInBackground(Void... params) {
			// Simulates a background job.
			try {
				nCurPageNumber = nCurPageNumber + 1;
				
				String responseBody = RequestActListWithParamNoDelay();
				JSONObject result = new JSONObject(responseBody);
				ArrayList<STActivityItemInfo> parse_data = parseActivityItems(result);
				return parse_data;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STActivityItemInfo> result) {
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
				
				if (type == 2)
					mAdapter1.notifyDataSetChanged();
				else
					mAdapter2.notifyDataSetChanged();

				// Call onRefreshComplete when the list has been refreshed.
				mPullRefreshListView.onRefreshComplete();
			}
			
			super.onPostExecute(result);
		}
	}
	public int getCount() {
		// TODO Auto-generated method stub
		return actListInfo.size();
	}


}
