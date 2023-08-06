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
import com.damy.common.STMyCartItemInfo;
import com.damy.common.STMyCartItemInfo;
import com.damy.common.STShareItemInfo;

import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.text.format.DateUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.damy.wljy.*;

public class MyCartActivity extends Activity {

	private ListView m_anContents = null;
	private MyCartItemAdapter mAdapter = null;
	
	private STMyCartItemInfo m_Datas[] = null;
	private int m_itemCount = 0;
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private JsonHttpResponseHandler handler1;
    private ProgressDialog progDialog1;
    
    private JsonHttpResponseHandler handler2;
    private ProgressDialog progDialog2;
    
    private JsonHttpResponseHandler handler3;
    private ProgressDialog progDialog3;
    
    private PullToRefreshListView mPullRefreshListView;
	private ListView mRealListView;
	
	boolean bexistNext = true;
	int		nCurPageNumber = 1;
	private int m_nType = 0;
	
	boolean m_bSelAll = false;
	private Bitmap bitmapSelImage;
    private Bitmap bitmapUnSelImage;
    
    private ImageView img_sellAll;
	
	private ArrayList<STMyCartItemInfo> actListInfo = new ArrayList<STMyCartItemInfo>();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_mycart);
		
		m_bSelAll = false;
		
		bitmapSelImage = BitmapFactory.decodeResource(getResources(), R.drawable.mycart_radio_on);
        bitmapUnSelImage = BitmapFactory.decodeResource(getResources(), R.drawable.mycart_radio_off);

		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_mycart_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		AutoSizeTextView lab_selall = (AutoSizeTextView)findViewById(R.id.lab_mycart_selall);
		lab_selall.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSellAll();
        	}
        });
		
		AutoSizeTextView lab_seldel = (AutoSizeTextView)findViewById(R.id.lab_mycart_seldel);
		lab_seldel.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSellDel();
        	}
        });
		
		LinearLayout ll_submitbtn = (LinearLayout)findViewById(R.id.ll_mycart_submit);
		ll_submitbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSubmit();
        	}
        });
		
		img_sellAll = (ImageView)findViewById(R.id.img_mycart_selectall);
		
		mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.anMyCartContentView);
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
		        	actListInfo = parseMyCartItems(object);	                	
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
	
	@Override
	protected void onResume()
	{
		RunBackGround();
		super.onResume();
	}
	
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickSellAll()
	{
        m_bSelAll = !m_bSelAll;

        // set all sel option background image
        if (m_bSelAll == true)
        {
            img_sellAll.setImageResource(R.drawable.mycart_radio_on);
        }
        else
        {
            img_sellAll.setImageResource(R.drawable.mycart_radio_off);
        }

        // update state of all child item
        for (STMyCartItemInfo item : actListInfo)
        {
            item.isSelected = m_bSelAll;
        }

        mAdapter.notifyDataSetChanged();
        mRealListView.invalidate();
	}
	
	private void onClickSellDel()
	{
		String strIds = "";
		
		int cnt = getItemCount();
		int i;
		STMyCartItemInfo item;
		for ( i = 0; i < cnt; i++ )
		{
			item = getItem(i);
			if ( item.isSelected )
			{
				strIds += Integer.toString(item.item_id) + ",";
			}
		}

        if (strIds.length() <= 0)
        {
            Global.showToast(MyCartActivity.this, getString(R.string.msg_no_selected_item));
            return;
        }

		strIds = strIds.substring(0, strIds.length() - 1);
		
		
		handler2 = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog2.dismiss();

                ReloadTable();
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog2.dismiss();
            }

            @Override
            public void onFinish()
            {
				progDialog2.dismiss();
            }
        };

        progDialog2 = ProgressDialog.show(MyCartActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "exchange_seldel.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("cart_id", strIds);
            
            client.get(str_url, param, handler2);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onClickSubmit()
	{
		String strIds = "";
		
		int cnt = getItemCount();
		int i;
		STMyCartItemInfo item;
		for ( i = 0; i < cnt; i++ )
		{
			item = getItem(i);
			if ( item.isSelected )
			{
				strIds += Integer.toString(item.item_id) + ",";
			}
		}

        if (strIds.length() <= 0)
        {
            Global.showToast(MyCartActivity.this, getString(R.string.msg_no_selected_item));
            return;
        }

		strIds = strIds.substring(0, strIds.length() - 1);
		
		
		handler3 = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog3.dismiss();

                onSuccessSubmit();
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog3.dismiss();
            }

            @Override
            public void onFinish()
            {
				progDialog3.dismiss();
            }
        };

        progDialog3 = ProgressDialog.show(MyCartActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "exchange_success.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("cart_id", strIds);
            
            client.get(str_url, param, handler3);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void initContents()
    {
    	if (mRealListView != null)
    	{
    		getShowListFromData();
    	}
    }
	
	private void ReloadTable() {
		// TODO Auto-generated method stub
		nCurPageNumber = 1;
		actListInfo.clear();
		RunBackGround();
	}
	
	private void RunBackGround()
	{
    	
	    progDialog = ProgressDialog.show(
	    		MyCartActivity.this,
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
             
             String str_url = Global.STR_SERVER_URL + "mycart.jsp";
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

			mAdapter = new MyCartItemAdapter(MyCartActivity.this, this.getApplicationContext());
			mRealListView.setAdapter(mAdapter);
    	}
    }
    
	public String RequestActListWithParamNoDelay()
	{
		String connectUrl = Global.STR_SERVER_URL + "mycart.jsp?userid=" + Integer.toString(Global.Cur_UserId)
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
	
	private ArrayList<STMyCartItemInfo> parseMyCartItems(JSONObject order)
	{
		ArrayList<STMyCartItemInfo> retList = new ArrayList<STMyCartItemInfo>();
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
					STMyCartItemInfo itemInfo = new STMyCartItemInfo();
					anItem = data.getJSONObject(i);
					
					itemInfo.item_id = anItem.getInt("id");
					itemInfo.title = anItem.getString("name");
					itemInfo.marketprice = anItem.getString("market_price");
					itemInfo.integralprice = anItem.getString("integral_price");
					itemInfo.imagepath = anItem.getString("imagepath");
					itemInfo.isSelected = false;

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
	
	private class GetDataTask extends AsyncTask<Void, Void, ArrayList<STMyCartItemInfo>> {

		@Override
		protected ArrayList<STMyCartItemInfo> doInBackground(Void... params) {
			// Simulates a background job.
			try {
				nCurPageNumber = nCurPageNumber + 1;
				
				String responseBody = RequestActListWithParamNoDelay();
				JSONObject result = new JSONObject(responseBody);
				ArrayList<STMyCartItemInfo> parse_data = parseMyCartItems(result);
				return parse_data;
			} catch (Exception e) {
			}
			
			return null;
		}

		@Override
		protected void onPostExecute(ArrayList<STMyCartItemInfo> result) {
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
	
	private void onSuccessSubmit()
	{
		/*
		Intent mycartsuccess_activity = new Intent(this, MyCartSuccessActivity.class);
		startActivity(mycartsuccess_activity);
		finish();
		*/
		Intent mycash_activity = new Intent(this, MyCashActivity.class);
		startActivity(mycash_activity);
		finish();
	}
	
	public void OnClickMyCartSel(int pos)
	{
		STMyCartItemInfo item = getItem(pos);
		if ( item.isSelected == true )
			item.isSelected = false;
		else
			item.isSelected = true;
		
		actListInfo.set(pos, item);
	}
	
	public void ChangeMyCartSel(int pos, boolean state)
	{
		STMyCartItemInfo item = getItem(pos);
		item.isSelected = state;
		actListInfo.set(pos, item);
	}
	
	public boolean getItemSelInfo(int pos)
	{
		STMyCartItemInfo item = getItem(pos);
		
		return item.isSelected;
	}
	
	public void OnClickMyCartDel(int id)
	{
		handler1 = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog1.dismiss();

                ReloadTable();
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog1.dismiss();
            }

            @Override
            public void onFinish()
            {
				progDialog1.dismiss();
            }
        };

        progDialog1 = ProgressDialog.show(MyCartActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "exchange_del.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("cart_id", Integer.toString(id));
            
            client.get(str_url, param, handler1);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}

	public int getItemCount()
	{
		return actListInfo.size();
	}
	
	public STMyCartItemInfo getItem(int position)
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
