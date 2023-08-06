package com.damy.wljy;

import java.io.ByteArrayInputStream;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.BinaryHttpResponseHandler;
import com.damy.Utils.*;
import com.damy.common.*;
import com.damy.wljy.ShareItemAdapter.ShareItemHolder;


class ShareEvalItemAdapter extends BaseAdapter {
	Context			mContext = null;
	ShareEvalActivity 	mActivity = null;
    private LayoutInflater mInflater;
    private Bitmap bitmapNoImage;

	public ShareEvalItemAdapter(ShareEvalActivity activity, Context context) {
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
    	CommonDetailItemHolder anHolder;

        // When convertView is not null, we can reuse it directly, there is no need
        // to reinflate it. We only inflate a new View when the convertView supplied
        // by ListView is null.
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.activity_common_detail_item, null);

            // Creates a ViewHolder and store references to the two children views
            // we want to bind data to.
            anHolder = new CommonDetailItemHolder();
            
            anHolder.lab_mname = (AutoSizeTextView)convertView.findViewById(R.id.lab_commondetail_item_name);
            anHolder.lab_postdate = (AutoSizeTextView)convertView.findViewById(R.id.lab_commondetail_item_postdate);
            anHolder.lab_body = (AutoSizeTextView)convertView.findViewById(R.id.lab_commondetail_item_body);
            anHolder.img_memimg = (ImageView)convertView.findViewById(R.id.img_commondetail_item_memimg);
            convertView.setTag(anHolder);
        } else {
            // Get the ViewHolder back to get fast access to the TextView
            // and the ImageView.
        	anHolder = (CommonDetailItemHolder) convertView.getTag();
        }

        STCommonDetailItemInfo anItem = mActivity.getItem(position);
        // Bind the data efficiently with the holder.
        if (anItem != null)
        {
            anHolder.lab_mname.setText(anItem.mname);
            anHolder.lab_postdate.setText(anItem.postdate + mActivity.getResources().getString(R.string.studyeval_timeago));
            anHolder.lab_body.setText(anItem.body);
            
            try
            {
                Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + anItem.imgpath, anHolder.img_memimg, Global.options);
            }
            catch (Exception ex)
            {
                ex.printStackTrace();
            }
            
           /* wljyBinaryHttpResponseHandler imghandler = new wljyBinaryHttpResponseHandler();
            imghandler.setImage(anHolder.img_memimg, bitmapNoImage);            
            
            try {
            	String imgUrl = Global.STR_SERVER_URL1 + anItem.imgpath;
            	AsyncHttpClient client = new AsyncHttpClient();
				client.get(imgUrl, imghandler);
			} catch (Exception e) {
				e.printStackTrace();
				anHolder.img_memimg.setImageBitmap(bitmapNoImage);
			}*/
            
        }
        
        return convertView;
    }
    
    public void updateView(Runnable bd){
    	mActivity.runOnUiThread(bd);
    }
    
    public class CommonDetailItemHolder {
        AutoSizeTextView lab_mname;
        AutoSizeTextView lab_postdate;
        AutoSizeTextView lab_body;
        ImageView img_memimg;
    }
}
