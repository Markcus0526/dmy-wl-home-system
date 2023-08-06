package com.damy.common;

import java.io.ByteArrayInputStream;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.widget.ImageView;

import com.damy.HttpConn.BinaryHttpResponseHandler;
import com.damy.wljy.R;

public class wljyBinaryHttpResponseHandler extends BinaryHttpResponseHandler{

	public ImageView thisImage;
	private Bitmap bitmapNoImage;
	
	public void setImage(ImageView image, Bitmap noimage)
	{
		thisImage = image;
		bitmapNoImage = noimage;
	}
	
	@Override
	public void onSuccess(byte[] imageData) {
	// Successfully got a response
		ByteArrayInputStream is = new ByteArrayInputStream(imageData);
		Bitmap bitmap = BitmapFactory.decodeStream(is);
		//thisImage.setScaleType(ImageView.ScaleType.FIT_CENTER);
		thisImage.setAdjustViewBounds(true);
		thisImage.setImageBitmap(bitmap);
		
	}
	
	@Override
	public void onFailure(Throwable e, byte[] imageData) {
	// Response failed :(		
		thisImage.setImageBitmap(bitmapNoImage);
	}
}
