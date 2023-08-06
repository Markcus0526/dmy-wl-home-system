package com.damy.wljy;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.net.URL;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.BinaryHttpResponseHandler;
import com.damy.Utils.*;
import com.damy.common.*;
import com.damy.wljy.MainItemAdapter.MainItemHolder;

class MyCartItemAdapter extends BaseAdapter {
	Context			mContext = null;
	MyCartActivity 	mActivity = null;
    private LayoutInflater mInflater;
    private Bitmap bitmapNoImage;
    
    private Bitmap bitmapSelImage;
    private Bitmap bitmapUnSelImage;
    

    public MyCartItemAdapter(MyCartActivity activity, Context context) {
    	mContext = context;
    	mActivity = activity;
        // Cache the LayoutInflate to avoid asking for a new one each time.
        mInflater = LayoutInflater.from(context);
        
        bitmapNoImage = BitmapFactory.decodeResource(context.getResources(), R.drawable.noimage);
        bitmapSelImage = BitmapFactory.decodeResource(context.getResources(), R.drawable.mycart_radio_on);
        bitmapUnSelImage = BitmapFactory.decodeResource(context.getResources(), R.drawable.mycart_radio_off);
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
    	MyCartItemHolder anHolder;

        // When convertView is not null, we can reuse it directly, there is no need
        // to reinflate it. We only inflate a new View when the convertView supplied
        // by ListView is null.
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.activity_mycart_item, null);

            // Creates a ViewHolder and store references to the two children views
            // we want to bind data to.
            anHolder = new MyCartItemHolder();
            
            anHolder.lab_title = (AutoSizeTextView)convertView.findViewById(R.id.lab_mycart_item_title);
            anHolder.lab_marketprice = (AutoSizeTextView)convertView.findViewById(R.id.lab_mycart_item_cost);
            anHolder.lab_integralprice = (AutoSizeTextView)convertView.findViewById(R.id.lab_mycart_item_integral);
            anHolder.lab_delbtn = (AutoSizeTextView)convertView.findViewById(R.id.lab_mycart_item_del);
            anHolder.img_item_image = (ImageView)convertView.findViewById(R.id.img_mycart_item_img);
            anHolder.img_item_sel = (ImageView)convertView.findViewById(R.id.img_mycart_item_select);
            

            convertView.setTag(anHolder);
        } else {
            // Get the ViewHolder back to get fast access to the TextView
            // and the ImageView.
        	anHolder = (MyCartItemHolder) convertView.getTag();
        }

        STMyCartItemInfo anItem = mActivity.getItem(position);
        // Bind the data efficiently with the holder.
        if (anItem != null)
        {
            anHolder.lab_title.setText(anItem.title);
            anHolder.lab_marketprice.setText(anItem.marketprice);
            anHolder.lab_integralprice.setText(anItem.integralprice);
            
            anHolder.lab_delbtn.setTag(anItem.item_id);
            anHolder.lab_delbtn.setOnClickListener(new OnClickListener() {
            	public void onClick(View v) {
            		Integer k = (Integer)v.getTag();
            		mActivity.OnClickMyCartDel(k);
            	}
            });
            
            anHolder.img_item_sel.setTag(position);
            anHolder.img_item_sel.setOnClickListener(new OnClickListener() {
            	public void onClick(View v) {
            		Integer k = (Integer)v.getTag();
            		
            		ImageView imgView = (ImageView)v;
            		
            		mActivity.OnClickMyCartSel(k);
            		boolean isSel = mActivity.getItemSelInfo(k);
            		if ( isSel )
            			imgView.setImageBitmap(bitmapSelImage);
            		else
            			imgView.setImageBitmap(bitmapUnSelImage);

            	}
            });

            // show & hide selected option
            boolean isSel = mActivity.getItemSelInfo(position);
            if ( isSel )
                anHolder.img_item_sel.setImageBitmap(bitmapSelImage);
            else
                anHolder.img_item_sel.setImageBitmap(bitmapUnSelImage);
            
            try
            {
                Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + anItem.imagepath, anHolder.img_item_image, Global.options);
            }
            catch (Exception ex)
            {
                ex.printStackTrace();
            }
            
            /*wljyBinaryHttpResponseHandler imghandler = new wljyBinaryHttpResponseHandler();
            imghandler.setImage(anHolder.img_item_image, bitmapNoImage);            
            
            try {
            	String imgUrl = Global.STR_SERVER_URL1 + anItem.imagepath;
            	AsyncHttpClient client = new AsyncHttpClient();
				client.get(imgUrl, imghandler);
			} catch (Exception e) {
				e.printStackTrace();
				anHolder.img_item_image.setImageBitmap(bitmapNoImage);
			}*/
			
        }
        
        return convertView;
    }

    public void updateView(Runnable bd){
    	mActivity.runOnUiThread(bd);
    }
    
    public class MyCartItemHolder {
        AutoSizeTextView lab_title;
        AutoSizeTextView lab_marketprice;
        AutoSizeTextView lab_integralprice;
        AutoSizeTextView lab_state;
        AutoSizeTextView lab_delbtn;
        ImageView img_item_image;
        ImageView img_item_sel;
    }
}
