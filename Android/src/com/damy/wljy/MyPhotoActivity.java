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
import com.damy.common.STMyPhotoItemInfo;
import com.nostra13.universalimageloader.core.DisplayImageOptions;


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
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.text.format.DateUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.AdapterView.OnItemClickListener;

public class MyPhotoActivity extends Activity {

	private ListView m_anContents = null;
		
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
	
	private int m_itemCount = 0;
	private int m_rowCount = 0;
	
	STMyPhotoItemInfo[] m_Datas;	
	
	DisplayImageOptions options;
	
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_myphoto);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_myphoto_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		FrameLayout fl_myphotoadd = (FrameLayout)findViewById(R.id.fl_myphoto_submitbtn);
		fl_myphotoadd.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMyPhotoAdd();
        	}
        });
		
		options = new DisplayImageOptions.Builder()
		.showStubImage(R.drawable.ic_stub)
		.showImageForEmptyUri(R.drawable.ic_empty)
		.showImageOnFail(R.drawable.ic_error)
		.cacheInMemory()
		.cacheOnDisc()
		.bitmapConfig(Bitmap.Config.RGB_565)
		.build();
		
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
	
	private void onClickMyPhotoAdd()
	{
		Intent myphotoadd_activity = new Intent(this, MyPhotoAddActivity.class);
		startActivity(myphotoadd_activity);
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
        
	    progDialog = ProgressDialog.show(MyPhotoActivity.this, "", "Waiting", true, true);
	    
	    AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {

        	String str_url = Global.STR_SERVER_URL + "myphoto.jsp";
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
			if (isSuccess == 1) {
				m_itemCount = order.getInt("count");
				data = order.getJSONArray("data");
				m_Datas = new STMyPhotoItemInfo[m_itemCount];

				for (int i = 0; i < m_itemCount;i++) {
					m_Datas[i] = new STMyPhotoItemInfo();
					
					anItem = data.getJSONObject(i);
					m_Datas[i].item_id = anItem.getInt("id");
					m_Datas[i].imagepath = anItem.getString("imagepath");
				}
				
				GridView listView = (GridView) findViewById(R.id.grid_myphoto_view);
				((GridView) listView).setAdapter(new ImageAdapter());
				listView.setOnItemClickListener(new OnItemClickListener() {
					@Override
					public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
						OnClickPhotoItem(position);
					}
				});
			}

		} catch (JSONException e) {
			
		}
	}

	public int getItemCount()
	{
		return m_itemCount;
	}
	
	public STMyPhotoItemInfo getItem(int position)
	{
		if (position < 0 || position >= m_itemCount)
			return null;
		
		return m_Datas[position];
	}
	
	public void OnClickPhotoItem(int pos)
	{
		Intent myphotoinfo_activity = new Intent(this, MyPhotoInfoActivity.class);
		myphotoinfo_activity.putExtra(MyPhotoInfoActivity.MYPHOTO_ID, m_Datas[pos].item_id);
		startActivity(myphotoinfo_activity);
	}
	
	
	public class ImageAdapter extends BaseAdapter {
		@Override
		public int getCount() {
			return m_itemCount;
		}

		@Override
		public Object getItem(int position) {
			return null;
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			final ImageView imageView;
			if (convertView == null) {
				imageView = (ImageView) getLayoutInflater().inflate(R.layout.item_grid_image, parent, false);
			} else {
				imageView = (ImageView) convertView;
			}

			Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + m_Datas[position].imagepath, imageView, options);

			return imageView;
		}
	}

}
