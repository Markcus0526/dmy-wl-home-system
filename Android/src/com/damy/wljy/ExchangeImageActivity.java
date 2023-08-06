package com.damy.wljy;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.Bundle;
import android.os.Parcelable;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Gallery;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.Toast;
import android.widget.AdapterView.OnItemClickListener;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;

import com.damy.wljy.Main;
import com.damy.Utils.*;
import com.damy.common.Global; 
import com.damy.common.STFaqItemInfo;
import com.damy.common.wljyBinaryHttpResponseHandler;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;



public class ExchangeImageActivity extends Activity {
	
	public static final String EXCHANGEIMAGE_TITLE = "EXCHANGEIMAGETITLE";
	public static final String EXCHANGEIMAGE_COUNT = "EXCHANGEIMAGECOUNT";
	public static final String[] EXCHANGEIMAGE_PATH = {"EXCHANGEIMAGEPATH1", "EXCHANGEIMAGEPATH2", "EXCHANGEIMAGEPATH3", "EXCHANGEIMAGEPATH4", "EXCHANGEIMAGEPATH5", "EXCHANGEIMAGEPATH6", "EXCHANGEIMAGEPATH7"};
	
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private int m_nImageCount = 0;
    private String[] m_sImagePath = new String[7];
    private String m_sTitle;
    
    
    private Bitmap bitmapNoImage;
    
    private ViewPager pager;
    private Gallery gallery;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_exchange_image);
		
		m_sTitle = getIntent().getStringExtra(EXCHANGEIMAGE_TITLE);
		m_nImageCount = getIntent().getIntExtra(EXCHANGEIMAGE_COUNT, 0);
		
		for ( int i = 0; i < m_nImageCount; i++ )
			m_sImagePath[i] = getIntent().getStringExtra(EXCHANGEIMAGE_PATH[i]);
		
		
	    bitmapNoImage = BitmapFactory.decodeResource(getResources(), R.drawable.noimage);
	    
	    AutoSizeTextView lab_curdate = (AutoSizeTextView)findViewById(R.id.lab_exchange_image_curdate);
		lab_curdate.setText(Global.Cur_Date + " " + Global.Cur_Weekday);
	    
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_exchange_image_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		gallery = (Gallery) findViewById(R.id.gallery_exchange_image_all);
		gallery.setAdapter(new ImageGalleryAdapter());
		gallery.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				onClickImage(position);
			}
		});
		
		
		pager = (ViewPager) findViewById(R.id.pager_exchange_image_pager);
		pager.setAdapter(new ImagePagerAdapter(m_sImagePath));
		pager.setCurrentItem(0);

		readContents();
		
	}
	
	private void onClickImage(int position) {
		pager.setCurrentItem(position);
		gallery.setSelection(position);
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void readContents()
	{
		AutoSizeTextView lab_title;
		
		ImageView img_mainimg;
	    
	    lab_title = (AutoSizeTextView)findViewById(R.id.lab_exchange_image_title);
	    lab_title.setText(m_sTitle);
	}
	
	private class ImageGalleryAdapter extends BaseAdapter {
		@Override
		public int getCount() {
			return m_nImageCount;
		}

		@Override
		public Object getItem(int position) {
			return position;
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ImageView imageView = (ImageView) convertView;
			if (imageView == null) {
				imageView = (ImageView) getLayoutInflater().inflate(R.layout.item_gallery_image, parent, false);
			}
			Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + m_sImagePath[position], imageView, Global.options);
			return imageView;
		}
	}
	
	
	private class ImagePagerAdapter extends PagerAdapter {

		private String[] images;
		private LayoutInflater inflater;

		ImagePagerAdapter(String[] images) {
			this.images = images;
			inflater = getLayoutInflater();
		}

		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			((ViewPager) container).removeView((View) object);
		}

		@Override
		public void finishUpdate(View container) {
		}

		@Override
		public int getCount() {
			return m_nImageCount;
		}

		@Override
		public Object instantiateItem(ViewGroup view, int position) {
			View imageLayout = inflater.inflate(R.layout.item_pager_image, view, false);
			ImageView imageView = (ImageView) imageLayout.findViewById(R.id.image);
			final ProgressBar spinner = (ProgressBar) imageLayout.findViewById(R.id.loading);
			
			gallery.setSelection(pager.getCurrentItem());

			Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + images[position], imageView, Global.options, new SimpleImageLoadingListener() {
				@Override
				public void onLoadingStarted(String imageUri, View view) {
					spinner.setVisibility(View.VISIBLE);
				}

				@Override
				public void onLoadingFailed(String imageUri, View view, FailReason failReason) {
					/*
					String message = null;
					switch (failReason.getType()) {
						case IO_ERROR:
							message = "Input/Output error";
							break;
						case DECODING_ERROR:
							message = "Image can't be decoded";
							break;
						case NETWORK_DENIED:
							message = "Downloads are denied";
							break;
						case OUT_OF_MEMORY:
							message = "Out Of Memory error";
							break;
						case UNKNOWN:
							message = "Unknown error";
							break;
					}
					Toast.makeText(ExchangeImageActivity.this, message, Toast.LENGTH_SHORT).show();
					 */
					spinner.setVisibility(View.GONE);
				}

				@Override
				public void onLoadingComplete(String imageUri, View view, Bitmap loadedImage) {
					spinner.setVisibility(View.GONE);
				}
			});

			((ViewPager) view).addView(imageLayout, 0);
			return imageLayout;
		}

		@Override
		public boolean isViewFromObject(View view, Object object) {
			return view.equals(object);
		}

		@Override
		public void restoreState(Parcelable state, ClassLoader loader) {
		}

		@Override
		public Parcelable saveState() {
			return null;
		}

		@Override
		public void startUpdate(View container) {
		}
	}
}
