package com.damy.wljy;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import com.damy.Utils.*;
import com.damy.common.*;

class MyOpinionItemAdapter extends BaseAdapter {
	Context			mContext = null;
	MyOpinionActivity 	mActivity = null;
    private LayoutInflater mInflater;
    private Bitmap bitmapNoImage;

    public MyOpinionItemAdapter(MyOpinionActivity activity, Context context) {
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
    	MyOpinionItemHolder anHolder;

        // When convertView is not null, we can reuse it directly, there is no need
        // to reinflate it. We only inflate a new View when the convertView supplied
        // by ListView is null.
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.activity_myopinion_item, null);

            // Creates a ViewHolder and store references to the two children views
            // we want to bind data to.
            anHolder = new MyOpinionItemHolder();
            
            anHolder.lab_title = (AutoSizeTextView)convertView.findViewById(R.id.lab_myopinion_item_title);
            anHolder.lab_body = (AutoSizeTextView)convertView.findViewById(R.id.lab_myopinion_item_body);
            anHolder.lab_integral = (AutoSizeTextView)convertView.findViewById(R.id.lab_myopinion_item_integral);
            anHolder.lab_postdate = (AutoSizeTextView)convertView.findViewById(R.id.lab_myopinion_item_updatedate);
            anHolder.lab_state = (AutoSizeTextView)convertView.findViewById(R.id.lab_myopinion_item_state);
            
            convertView.setTag(anHolder);
        } else {
            // Get the ViewHolder back to get fast access to the TextView
            // and the ImageView.
        	anHolder = (MyOpinionItemHolder) convertView.getTag();
        }

        STMyOpinionItemInfo anItem = mActivity.getItem(position);
        // Bind the data efficiently with the holder.
        if (anItem != null)
        {
            anHolder.lab_title.setText(anItem.title);
            anHolder.lab_body.setText(anItem.body);
            anHolder.lab_integral.setText(Integer.toString(anItem.integral));
            anHolder.lab_postdate.setText(anItem.postdate);
            String strState = (anItem.state == 0 ) ? mActivity.getResources().getString(R.string.myopinion_type2) : mActivity.getResources().getString(R.string.myopinion_type3);
            anHolder.lab_state.setText(strState);
        }
        
        return convertView;
    }
    
    public void updateView(Runnable bd){
    	mActivity.runOnUiThread(bd);
    }
	
    public class MyOpinionItemHolder {
        AutoSizeTextView lab_title;
        AutoSizeTextView lab_body;
        AutoSizeTextView lab_integral;
        AutoSizeTextView lab_postdate;
        AutoSizeTextView lab_state;
    }
}
