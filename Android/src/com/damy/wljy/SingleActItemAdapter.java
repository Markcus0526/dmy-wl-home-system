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
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.BinaryHttpResponseHandler;
import com.damy.Utils.*;
import com.damy.common.*;
import com.damy.wljy.ShareItemAdapter.ShareItemHolder;

class SingleActItemAdapter extends BaseAdapter {
	Context			mContext = null;
	GroupActActivity	mActivity = null;
    private LayoutInflater mInflater;
    private Bitmap bitmapNoImage;

    public SingleActItemAdapter(GroupActActivity activity, Context context) {
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
        return mActivity.getCount();
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
    	ActivityItemHolder anHolder;

        // When convertView is not null, we can reuse it directly, there is no need
        // to reinflate it. We only inflate a new View when the convertView supplied
        // by ListView is null.
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.activity_single_act_item, null);

            // Creates a ViewHolder and store references to the two children views
            // we want to bind data to.
            anHolder = new ActivityItemHolder();
            
            anHolder.lab_title = (AutoSizeTextView)convertView.findViewById(R.id.single_act_item_title);
//            anHolder.lab_body = (AutoSizeTextView)convertView.findViewById(R.id.act_item_body);
            anHolder.lab_postdate = (AutoSizeTextView)convertView.findViewById(R.id.single_act_item_date);
            anHolder.lab_evalcnt = (AutoSizeTextView)convertView.findViewById(R.id.single_act_item_evalcnt);
            anHolder.lab_readcnt = (AutoSizeTextView)convertView.findViewById(R.id.single_act_item_readcnt);
            anHolder.ll_item_image1 = (LinearLayout)convertView.findViewById(R.id.ll_single_act_item_imagelayer1);
            anHolder.ll_item_image2 = (LinearLayout)convertView.findViewById(R.id.ll_single_act_item_imagelayer2);
            anHolder.ll_item_image3 = (LinearLayout)convertView.findViewById(R.id.ll_single_act_item_imagelayer3);
            anHolder.img_item_image1 = (ImageView)convertView.findViewById(R.id.single_act_item_image1);
            anHolder.img_item_image2 = (ImageView)convertView.findViewById(R.id.single_act_item_image2);
            anHolder.img_item_image3 = (ImageView)convertView.findViewById(R.id.single_act_item_image3);
            
            convertView.setTag(anHolder);
        } else {
            // Get the ViewHolder back to get fast access to the TextView
            // and the ImageView.
        	anHolder = (ActivityItemHolder) convertView.getTag();
        }

        STActivityItemInfo anItem = mActivity.getItem(position);
        // Bind the data efficiently with the holder.
        if (anItem != null)
        {
        	
            anHolder.lab_title.setText(anItem.title);
           // anHolder.lab_body.setText(anItem.body);
            anHolder.lab_postdate.setText(anItem.postdate);
            anHolder.lab_evalcnt.setText("  " + anItem.evalcnt);
            anHolder.lab_readcnt.setText("  " + anItem.readcnt);
            
            
            if (anItem.imagepath1 != null) {
            	convertView.findViewById(R.id.ll_single_image).setVisibility(android.view.View.VISIBLE);
            	anHolder.ll_item_image1.setVisibility(android.view.View.VISIBLE);
            	
                try
                {
                    Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + anItem.imagepath1, anHolder.img_item_image1, Global.options);
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }
                
            	/*wljyBinaryHttpResponseHandler imghandler1 = new wljyBinaryHttpResponseHandler();
                imghandler1.setImage(anHolder.img_item_image1, bitmapNoImage);            
                
                try {
                	String imgUrl = Global.STR_SERVER_URL1 + anItem.imagepath1;
                	AsyncHttpClient client = new AsyncHttpClient();
    				client.get(imgUrl, imghandler1);
    			} catch (Exception e) {
    				e.printStackTrace();
    				anHolder.img_item_image1.setImageBitmap(bitmapNoImage);
    			}*/
            }
            else {
            	convertView.findViewById(R.id.ll_single_image).setVisibility(android.view.View.GONE);
            	anHolder.ll_item_image1.setVisibility(android.view.View.INVISIBLE);            	
            }
            
            
            if (anItem.imagepath2 != null)
            {
            	anHolder.ll_item_image2.setVisibility(android.view.View.VISIBLE);
                try
                {
                    Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + anItem.imagepath2, anHolder.img_item_image2, Global.options);
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }
                
            	/*wljyBinaryHttpResponseHandler imghandler2 = new wljyBinaryHttpResponseHandler();
                imghandler2.setImage(anHolder.img_item_image2, bitmapNoImage);            
                
                try {
                	String imgUrl = Global.STR_SERVER_URL1 + anItem.imagepath2;
                	AsyncHttpClient client = new AsyncHttpClient();
    				client.get(imgUrl, imghandler2);
    			} catch (Exception e) {
    				e.printStackTrace();
    				anHolder.img_item_image2.setImageBitmap(bitmapNoImage);
    			}*/            
            }
            else {            	
            	anHolder.ll_item_image2.setVisibility(android.view.View.INVISIBLE);
            }
            
            if (anItem.imagepath3 != null) {
            	anHolder.ll_item_image3.setVisibility(android.view.View.VISIBLE);
            	
                try
                {
                    Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + anItem.imagepath3, anHolder.img_item_image3, Global.options);
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }
                
            	/*wljyBinaryHttpResponseHandler imghandler3 = new wljyBinaryHttpResponseHandler();
                imghandler3.setImage(anHolder.img_item_image3, bitmapNoImage);            
                
                try {
                	String imgUrl = Global.STR_SERVER_URL1 + anItem.imagepath3;
                	AsyncHttpClient client = new AsyncHttpClient();
    				client.get(imgUrl, imghandler3);
    			} catch (Exception e) {
    				e.printStackTrace();
    				anHolder.img_item_image3.setImageBitmap(bitmapNoImage);
    			}*/
            }
            else {
            	anHolder.ll_item_image3.setVisibility(android.view.View.INVISIBLE);
            }
            
            
                    
            

            
        }
        
        return convertView;
    }
    
    public void updateView(Runnable bd){
    	mActivity.runOnUiThread(bd);
    }
    
 /*   public class myBinaryHttpResponseHandler extends BinaryHttpResponseHandler{
    	public ActivityItemHolder thisHolder;
    	
    	public void setHolder(ActivityItemHolder holder)
    	{
    		thisHolder = holder;
    	}
    	
		@Override
		public void onSuccess(byte[] imageData) {
		// Successfully got a response
			ByteArrayInputStream is = new ByteArrayInputStream(imageData);
			Bitmap bitmap = BitmapFactory.decodeStream(is);
			thisHolder.img_item_image.setScaleType(ImageView.ScaleType.FIT_CENTER);
			thisHolder.img_item_image.setAdjustViewBounds(true);
			thisHolder.img_item_image.setImageBitmap(bitmap);
		}
		
		@Override
		public void onFailure(Throwable e, byte[] imageData) {
		// Response failed :(
			thisHolder.img_item_image.setImageBitmap(bitmapNoImage);
		}
    }*/
	
    public class ActivityItemHolder {
        AutoSizeTextView lab_title;
        AutoSizeTextView lab_body;
        AutoSizeTextView lab_postdate;
        AutoSizeTextView lab_evalcnt;
        AutoSizeTextView lab_readcnt;
        LinearLayout ll_item_image1;
        LinearLayout ll_item_image2;
        LinearLayout ll_item_image3;
        ImageView img_item_image1;
        ImageView img_item_image2;
        ImageView img_item_image3;
    }
}
