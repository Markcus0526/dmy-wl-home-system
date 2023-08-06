package com.damy.wljy;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.net.URL;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.damy.Utils.AutoSizeTextView;
import com.damy.common.Global;
import com.damy.common.STExchangeItemInfo;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.Utils.*;
import com.damy.common.*;




public class ExchangeItemAdapter extends BaseAdapter{
	Context			mContext = null;
	ExchangeActivity 	mActivity = null;
    private LayoutInflater mInflater;
    private Bitmap bitmapNoImage;

    public ExchangeItemAdapter(ExchangeActivity activity, Context context) {
    	mContext = context;
    	mActivity = activity;
        // Cache the LayoutInflate to avoid asking for a new one each time.
        mInflater = LayoutInflater.from(context);
        
        bitmapNoImage = BitmapFactory.decodeResource(context.getResources(), R.drawable.noimage);
    }

    /**
     * The number of items in the list is determined by the number of speeches
     * in our array.
     *
     * @see android.widget.ListAdapter#getCount()
     */
    public int getCount() {
    	return mActivity.getItemCount();
    }

    /**
     * Since the data comes from an array, just returning the index is
     * sufficient to get at the data. If we were using a more complex data
     * structure, we would return whatever object represents one row in the
     * list.
     *
     * @see android.widget.ListAdapter#getItem(int)
     */
    public Object getItem(int position) {
        return position;
    }

    /**
     * Use the array index as a unique id.
     *
     * @see android.widget.ListAdapter#getItemId(int)
     */
    public long getItemId(int position) {
        return position;
    }

    /**
     * Make a view to hold each row.
     *
     * @see android.widget.ListAdapter#getView(int, android.view.View,
     *      android.view.ViewGroup)
     */
    public View getView(int position, View convertView, ViewGroup parent) {
        // A ViewHolder keeps references to children views to avoid unneccessary calls
        // to findViewById() on each row.
    	ExchangeItemHolder anHolder;

        // When convertView is not null, we can reuse it directly, there is no need
        // to reinflate it. We only inflate a new View when the convertView supplied
        // by ListView is null.
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.activity_exchange_item, null);

            // Creates a ViewHolder and store references to the two children views
            // we want to bind data to.
            anHolder = new ExchangeItemHolder();
            
            anHolder.lab_name1 = (AutoSizeTextView)convertView.findViewById(R.id.lab_exchangeitem_name1);
            anHolder.lab_market1 = (AutoSizeTextView)convertView.findViewById(R.id.lab_exchangeitem_price1);
            anHolder.lab_integral1 = (AutoSizeTextView)convertView.findViewById(R.id.lab_exchangeitem_integral1);
            anHolder.img_item_image1 = (ImageView)convertView.findViewById(R.id.img_exchangeitem_image1);
            anHolder.lab_name2 = (AutoSizeTextView)convertView.findViewById(R.id.lab_exchangeitem_name2);
            anHolder.lab_market2 = (AutoSizeTextView)convertView.findViewById(R.id.lab_exchangeitem_price2);
            anHolder.lab_integral2 = (AutoSizeTextView)convertView.findViewById(R.id.lab_exchangeitem_integral2);
            anHolder.img_item_image2 = (ImageView)convertView.findViewById(R.id.img_exchangeitem_image2);
            anHolder.ll_seconditem = (LinearLayout)convertView.findViewById(R.id.ll_exchange_item_seconditem);
            
            convertView.setTag(anHolder);
        } else {
            // Get the ViewHolder back to get fast access to the TextView
            // and the ImageView.
        	anHolder = (ExchangeItemHolder) convertView.getTag();
        }

        STExchangeItemInfo anItem = mActivity.getItem(position);
        // Bind the data efficiently with the holder.
        if (anItem != null)
        {
            anHolder.lab_name1.setText(anItem.name1);
            anHolder.lab_market1.setText(anItem.market_price1);
            anHolder.lab_integral1.setText(anItem.integral1);
            
            
            anHolder.img_item_image1.setTag(anItem.item_id1);
            anHolder.img_item_image1.setOnClickListener(new OnClickListener() {
            	public void onClick(View v) {
            		Integer k = (Integer)v.getTag();
            		mActivity.OnClickExchangeItem(k);
            	}
            });

            try
            {
                Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + anItem.imagepath1, anHolder.img_item_image1, Global.options);
            }
            catch (Exception ex)
            {
                ex.printStackTrace();
            }
            
          //  wljyBinaryHttpResponseHandler imghandler1 = new wljyBinaryHttpResponseHandler();
           // imghandler1.setImage(anHolder.img_item_image1, bitmapNoImage);
            
          /*  try {
            	String imgUrl1 = Global.STR_SERVER_URL1 + anItem.imagepath1;
            	AsyncHttpClient client1 = new AsyncHttpClient();
            	client1.get(imgUrl1, imghandler1);
            } catch (Exception e) {
            	e.printStackTrace();
            	anHolder.img_item_image1.setImageBitmap(bitmapNoImage);
            }*/
            
            if ( anItem.name2 != "" )
            {
            	anHolder.ll_seconditem.setVisibility(android.view.View.VISIBLE);
	            anHolder.lab_name2.setText(anItem.name2);
	            anHolder.lab_market2.setText(anItem.market_price2);
	            anHolder.lab_integral2.setText(anItem.integral2);
	            
	            anHolder.img_item_image2.setTag(anItem.item_id2);
	            anHolder.img_item_image2.setOnClickListener(new OnClickListener() {
	            	public void onClick(View v) {
	            		Integer k = (Integer)v.getTag();
	            		mActivity.OnClickExchangeItem(k);
	            	}
	            });
	            
	            try
	            {
	                Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + anItem.imagepath2, anHolder.img_item_image2, Global.options);
	            }
	            catch (Exception ex)
	            {
	                ex.printStackTrace();
	            }
	            
	       //     wljyBinaryHttpResponseHandler imghandler2 = new wljyBinaryHttpResponseHandler();
	        //    imghandler2.setImage(anHolder.img_item_image2, bitmapNoImage);
	            
	         /*   try {
	            	String imgUrl2 = Global.STR_SERVER_URL1 + anItem.imagepath2;
	            	AsyncHttpClient client2 = new AsyncHttpClient();
	            	client2.get(imgUrl2, imghandler2);
	            } catch (Exception e) {
	            	e.printStackTrace();
	            	anHolder.img_item_image2.setImageBitmap(bitmapNoImage);
	            }   */     
            }
            else
            {
            	anHolder.ll_seconditem.setVisibility(android.view.View.INVISIBLE);
            }

        }
        
        return convertView;
    } 
    
    public void updateView(Runnable bd){
    	mActivity.runOnUiThread(bd);
    }

	
    public class ExchangeItemHolder {
        AutoSizeTextView lab_name1;
        AutoSizeTextView lab_market1;
        AutoSizeTextView lab_integral1;
        ImageView img_item_image1;
        AutoSizeTextView lab_name2;
        AutoSizeTextView lab_market2;
        AutoSizeTextView lab_integral2;
        ImageView img_item_image2;
        LinearLayout ll_seconditem;

    }
}
