package com.damy.wljy;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;

import com.damy.wljy.Main;
import com.damy.Utils.*;
import com.damy.common.Global; 
import com.damy.common.STFaqItemInfo;
import com.damy.common.wljyBinaryHttpResponseHandler;

public class ExchangeInfoActivity extends Activity {
	
	public static final String EXCHANGEINFO_ID = "EXCHANGEINFOID";
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private JsonHttpResponseHandler handler1;
    private ProgressDialog progDialog1;
    
    private int m_nExchangeid = 0;
    private String m_sTitle = "";
    private String[] m_sImagePath = new String[7];
    private int m_nImageCount = 0;
    
    private int m_nExchangeintegral = 0;
    private int m_nExchangesecure = 0;
    
    private AutoSizeTextView txt_title;
    private AutoSizeTextView txt_price;
    private AutoSizeTextView txt_integral;
    private AutoSizeTextView txt_secure;
    private AutoSizeTextView txt_total;
    private AutoSizeTextView txt_property;
    private AutoSizeTextView txt_quantity;

    private ImageView img_mainimg;
    
    private LinearLayout ll_property;
    
    private Bitmap bitmapNoImage;
    
    private boolean m_bShowProperty = false;
    private int m_nQuantity = 1;
    
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_exchange_info);
		
		m_nExchangeid = getIntent().getIntExtra(EXCHANGEINFO_ID, 0);
		
		txt_title = (AutoSizeTextView)findViewById(R.id.lab_exchange_info_title);
		txt_price = (AutoSizeTextView)findViewById(R.id.lab_exchange_info_price);
		txt_integral = (AutoSizeTextView)findViewById(R.id.lab_exchange_info_integral);
		txt_secure = (AutoSizeTextView)findViewById(R.id.lab_exchange_info_secure);
		txt_total = (AutoSizeTextView)findViewById(R.id.lab_exchange_info_total);
		txt_property = (AutoSizeTextView)findViewById(R.id.lab_exchange_info_property);
		txt_quantity = (AutoSizeTextView)findViewById(R.id.lab_exchange_info_quantity);
	    
		img_mainimg = (ImageView)findViewById(R.id.img_exchange_info_image);
		
		ll_property = (LinearLayout)findViewById(R.id.ll_exchange_info_propertylayer);
	    
	    bitmapNoImage = BitmapFactory.decodeResource(getResources(), R.drawable.noimage);
	    
	    AutoSizeTextView lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_exchange_info_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_exchange_info_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		LinearLayout ll_showpropertybtn = (LinearLayout)findViewById(R.id.ll_exchange_info_showproperty);
		ll_showpropertybtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickShowProperty();
        	}
        });
		
		m_bShowProperty = false;
		ll_property.setVisibility(android.view.View.GONE);
		
		LinearLayout ll_showimagebtn = (LinearLayout)findViewById(R.id.ll_exchange_info_showimage);
		ll_showimagebtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickShowImage();
        	}
        });
		
		LinearLayout ll_minusbtn = (LinearLayout)findViewById(R.id.ll_exchange_info_minus);
		ll_minusbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickMinus();
        	}
        });
		
		LinearLayout ll_plusbtn = (LinearLayout)findViewById(R.id.ll_exchange_info_plus);
		ll_plusbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickPlus();
        	}
        });
		
		FrameLayout fl_submitbtn = (FrameLayout)findViewById(R.id.fl_exchange_info_submitbtn);
		fl_submitbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSubmit();
        	}
        });
		
		
		
		readContents();
		
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickShowImage()
	{
		Intent exchangeimage_activity = new Intent(this, ExchangeImageActivity.class);
		exchangeimage_activity.putExtra(ExchangeImageActivity.EXCHANGEIMAGE_TITLE, m_sTitle);
		
		int tmp = m_nImageCount > 7 ? 7 : m_nImageCount;
		
		exchangeimage_activity.putExtra(ExchangeImageActivity.EXCHANGEIMAGE_COUNT, tmp);
		
		for (int i = 0; i < tmp; i++ )
			exchangeimage_activity.putExtra(ExchangeImageActivity.EXCHANGEIMAGE_PATH[i], m_sImagePath[i]);

		startActivity(exchangeimage_activity);
	}
	
	private void onClickShowProperty()
	{
		if ( m_bShowProperty )
		{
			m_bShowProperty = false;
			ll_property.setVisibility(android.view.View.GONE);
		}
		else
		{
			m_bShowProperty = true;
			ll_property.setVisibility(android.view.View.VISIBLE);
			ll_property.setBackgroundColor(getResources().getColor(R.color.exchange_info_subback_color));
		}
		
	}
	
	private void onClickPlus()
	{
		m_nQuantity++;
		ShowCurrentQuantity();
	}
	
	private void onClickMinus()
	{
		if ( m_nQuantity > 1)
			m_nQuantity--;
		ShowCurrentQuantity();
	}
	
	private void onSuccessAdd()
	{
		Intent mycart_activity = new Intent(this, MyCartActivity.class);
		startActivity(mycart_activity);
		finish();
	}
	
	private void onClickSubmit()
	{
		if ( m_nExchangesecure < m_nQuantity )
		{
			new AlertDialog.Builder(this)
			.setMessage(R.string.exchange_info_failsubmit_string)
			.setNegativeButton(R.string.confirm, null)
			.show();

			return;
		}
		
		handler1 = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog1.dismiss();

                onSuccessAdd();
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

        progDialog1 = ProgressDialog.show(ExchangeInfoActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "exchange_add.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("product_id", Integer.toString(m_nExchangeid));
            param.put("exchange_count", Integer.toString(m_nQuantity));
            param.put("product_integral", Integer.toString(m_nExchangeintegral));
            
            client.get(str_url, param, handler1);
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void ShowCurrentQuantity()
	{
		txt_quantity.setText(Integer.toString(m_nQuantity));
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

        progDialog = ProgressDialog.show(ExchangeInfoActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "exchange_info.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("id", Integer.toString(m_nExchangeid));
            
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
				m_sTitle = order.getString("title");
				txt_title.setText(m_sTitle);
				txt_price.setText(getResources().getString(R.string.exchange_info_wonmark_string) + Integer.toString(order.getInt("market_price")));
				m_nExchangeintegral = order.getInt("integral_price");
			    txt_integral.setText(Integer.toString(m_nExchangeintegral));
			    m_nExchangesecure = order.getInt("total_secure");
			    txt_secure.setText(Integer.toString(m_nExchangesecure));
			    txt_total.setText(Integer.toString(order.getInt("total_exchange")));
			    txt_property.setText(order.getString("property"));
			    
			    data = order.getJSONArray("imagepath");
			    m_nImageCount = data.length();
			    for (int i = 0; i < m_nImageCount; i++) {
			    	m_sImagePath[i] = data.getString(i);
				}
			    

	            
			 //   wljyBinaryHttpResponseHandler imghandler = new wljyBinaryHttpResponseHandler();
	         //   imghandler.setImage(img_mainimg, bitmapNoImage);
	            
	            if ( m_nImageCount > 0 )
	            {
		            try
		            {
		                Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + m_sImagePath[0], img_mainimg, Global.options);
		            }
		            catch (Exception ex)
		            {
		                ex.printStackTrace();
		            }
		            
		          /*  try {
		            	String imgUrl = Global.STR_SERVER_URL1 + m_sImagePath[0];
		            	AsyncHttpClient client = new AsyncHttpClient();
						client.get(imgUrl, imghandler);
					} catch (Exception e) {
						e.printStackTrace();
						img_mainimg.setImageBitmap(bitmapNoImage);
					}*/
	            }
			}

		} catch (JSONException e) {
			
		}
	}
	
}
