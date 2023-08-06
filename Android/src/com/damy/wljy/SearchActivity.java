package com.damy.wljy;


import java.util.ArrayList;

import android.view.KeyEvent;
import android.view.inputmethod.EditorInfo;
import android.widget.*;
import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;
import com.damy.Utils.AutoSizeEditText;
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
import com.damy.common.STSearchItemInfo;

import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;

import android.text.format.DateUtils;
import android.view.View;
import android.view.View.OnClickListener;


public class SearchActivity extends Activity implements TextView.OnEditorActionListener {

	private ListView m_anContents = null;
	private SearchItemAdapter mAdapter = null;
	
	private STSearchItemInfo m_Datas[] = null;
	private int m_itemCount = 0;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private PullToRefreshListView mPullRefreshListView;
	private ListView mRealListView;
	
	boolean bexistNext = true;
	int		nCurPageNumber = 0;
	private int 	m_nType = 0;
	
	private String m_sSearchText = "";
    private EditText m_txtSearch = null;
	
	private ArrayList<STSearchItemInfo> actListInfo = new ArrayList<STSearchItemInfo>();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_search);

		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_search_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		//readContents();

        m_txtSearch = (EditText)findViewById(R.id.txt_search_searchtext);
        m_txtSearch.setOnEditorActionListener(this);
        m_txtSearch.setImeOptions(EditorInfo.IME_ACTION_SEARCH);
		
		ImageView img_searchbtn = (ImageView)findViewById(R.id.img_search_searchbtn);
		img_searchbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSearch();
        	}
        });
		

		mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.anSearchContentView);
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
		        	actListInfo = parseSearchItems(object);	                	
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
		
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickSearch()
	{
		AutoSizeEditText search_text = (AutoSizeEditText)findViewById(R.id.txt_search_searchtext);
		m_sSearchText = search_text.getText().toString();
		if ( !m_sSearchText.equals("") )
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
	    		SearchActivity.this,
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
             
             String str_url = Global.STR_SERVER_URL + "search.jsp";
             param.put("userid", Integer.toString(Global.Cur_UserId));
             param.put("search", m_sSearchText);
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
    	
    	
    	if (actListInfo.size() == Global.Search_Page_Cnt)
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

			mAdapter = new SearchItemAdapter(SearchActivity.this, this.getApplicationContext());
			mRealListView.setAdapter(mAdapter);

			mRealListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
				public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
					onClickSearchItem(position);
	        	}
			});
    	}
    }
    
	public String RequestActListWithParamNoDelay()
	{
		String connectUrl = Global.STR_SERVER_URL + "search.jsp?userid=" + Integer.toString(Global.Cur_UserId)
				+ "&search=" + m_sSearchText + "&page=" + Integer.toString(nCurPageNumber);

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
	
	private ArrayList<STSearchItemInfo> parseSearchItems(JSONObject order)
	{
		ArrayList<STSearchItemInfo> retList = new ArrayList<STSearchItemInfo>();
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
					STSearchItemInfo itemInfo = new STSearchItemInfo();
					JSONArray image_path = new JSONArray();
					anItem = data.getJSONObject(i);

					itemInfo.item_id = anItem.getInt("id");
					itemInfo.type = anItem.getInt("type");
					itemInfo.title = anItem.getString("title");
					
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

    @Override
    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {

        if ((actionId == EditorInfo.IME_ACTION_SEARCH) || (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER))
        {
            onClickSearch();
            return true;
        }
        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STSearchItemInfo>> {

		@Override
		protected ArrayList<STSearchItemInfo> doInBackground(Void... params) {
			// Simulates a background job.
			try {
				nCurPageNumber = nCurPageNumber + 1;
				
				String responseBody = RequestActListWithParamNoDelay();
				JSONObject result = new JSONObject(responseBody);
				ArrayList<STSearchItemInfo> parse_data = parseSearchItems(result);
				return parse_data;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STSearchItemInfo> result) {
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
	
	public int getItemCount()
	{
		return actListInfo.size();
	}
	
	public STSearchItemInfo getItem(int position)
	{
		if (position < 0 || position >= actListInfo.size())
			return null;
		
		return actListInfo.get(position);
	}
	
	public int getCount() {
		// TODO Auto-generated method stub
		return actListInfo.size();
	}
	
	public void onClickSearchItem(int position)
	{
		if (position < 1 || position > actListInfo.size())
			return;
		
		STSearchItemInfo itemInfo = actListInfo.get(position - 1);
		
		if (itemInfo.type == 1)
		{
			Intent groupactinfo_activity = new Intent(this, GroupActInfoActivity.class);
			groupactinfo_activity.putExtra(GroupActInfoActivity.GROUPACTINFO_ID, itemInfo.item_id);
			startActivity(groupactinfo_activity);
		}
    	else if (itemInfo.type == 2)
    	{
    		Intent studyinfo_activity = new Intent(this, StudyInfoActivity.class);
			studyinfo_activity.putExtra(StudyInfoActivity.STUDYINFO_ID, itemInfo.item_id);
			startActivity(studyinfo_activity);
    	}
    	else if (itemInfo.type == 3)
    	{
    		Intent shareinfo_activity = new Intent(this, ShareInfoActivity.class);
			shareinfo_activity.putExtra(ShareInfoActivity.SHAREINFO_ID, itemInfo.item_id);
			startActivity(shareinfo_activity);
    	}
    	else if (itemInfo.type == 4)
    	{
    		Intent faqinfo_activity = new Intent(this, FaqInfoActivity.class);
			faqinfo_activity.putExtra(FaqInfoActivity.FAQINFO_ID, itemInfo.item_id);
			startActivity(faqinfo_activity);
    	}
		
		
	}
	
	
	
}
