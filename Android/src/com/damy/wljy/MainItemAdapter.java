package com.damy.wljy;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.content.ContextWrapper;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.BinaryHttpResponseHandler;
import com.damy.Utils.*;
import com.damy.common.*;
import com.nostra13.universalimageloader.core.display.RoundedBitmapDisplayer;

class MainItemAdapter extends BaseAdapter {
	Context			mContext = null;
	Main 			mActivity = null;
    private LayoutInflater mInflater;
    private Bitmap bitmapNoImage;    

    public MainItemAdapter(Main activity, Context context) {
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
    	
    	MainItemHolder anHolder;
        // When convertView is not null, we can reuse it directly, there is no need
        // to reinflate it. We only inflate a new View when the convertView supplied
        // by ListView is null.
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.activity_main_item, null);

            // Creates a ViewHolder and store references to the two children views
            // we want to bind data to.
            anHolder = new MainItemHolder();
            
            anHolder.lab_title = (AutoSizeTextView)convertView.findViewById(R.id.lab_item_title);
            anHolder.lab_body = (AutoSizeTextView)convertView.findViewById(R.id.lab_item_body);
            anHolder.lab_mname = (AutoSizeTextView)convertView.findViewById(R.id.lab_item_mname);
            anHolder.lab_integral = (AutoSizeTextView)convertView.findViewById(R.id.lab_item_integral);
            anHolder.img_item_image = (ImageView)convertView.findViewById(R.id.img_item_image);

            convertView.setTag(anHolder);
        } else {
            // Get the ViewHolder back to get fast access to the TextView
            // and the ImageView.
        	anHolder = (MainItemHolder) convertView.getTag();
        }

        STMainItemInfo anItem = mActivity.getItem(position);

        // Bind the data efficiently with the holder.
        if (anItem != null)
        {
            anHolder.lab_title.setText(anItem.title);
            anHolder.lab_body.setText(anItem.body);
            anHolder.lab_mname.setText(anItem.mname);
            anHolder.lab_integral.setText("  " + anItem.readcount);

            if ( anItem.imagepath != "" )
            {
                try
                {
                    Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + anItem.imagepath, anHolder.img_item_image, Global.options);
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }
                
            	/* wljyBinaryHttpResponseHandler imghandler = new wljyBinaryHttpResponseHandler();
                 imghandler.setImage(anHolder.img_item_image, bitmapNoImage);            
                 
                 try {
                 	String imgUrl = Global.STR_SERVER_URL1 + anItem.imagepath;
                 	AsyncHttpClient client = new AsyncHttpClient();
     				client.get(imgUrl, imghandler);
     			} catch (Exception e) {
     				e.printStackTrace();
     				anHolder.img_item_image.setImageBitmap(bitmapNoImage);
     			}*/
                 
	      /*      myBinaryHttpResponseHandler handler = new myBinaryHttpResponseHandler();
	            handler.setHolder(anHolder);
	            try {
	            	String imgUrl = Global.STR_SERVER_URL1 + anItem.imagepath;
	            	AsyncHttpClient client = new AsyncHttpClient();
					client.get(imgUrl, handler);
				} catch (Exception e) {
					e.printStackTrace();
					anHolder.img_item_image.setImageBitmap(bitmapNoImage);
				}*/
            }
            else
            	anHolder.img_item_image.setImageBitmap(bitmapNoImage);
            
            ImageView img_smile = (ImageView)convertView.findViewById(R.id.img_mainitem_smileface);
            
            
            if ( position == 4 )	
            	img_smile.setVisibility(android.view.View.INVISIBLE);
            else
            	img_smile.setVisibility(android.view.View.VISIBLE);

        }
        
        return convertView;
    }
    
    
    public class MainItemHolder {
        AutoSizeTextView lab_title;
        AutoSizeTextView lab_body;
        AutoSizeTextView lab_mname;
        AutoSizeTextView lab_integral;
        ImageView img_item_image;
    }
}
