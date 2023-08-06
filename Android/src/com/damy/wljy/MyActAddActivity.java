package com.damy.wljy;


import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLConnection;

import org.apache.http.Header;
import org.apache.http.message.BasicHeader;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;
import com.damy.Utils.AutoSizeEditText;
import com.damy.Utils.AutoSizeTextView;
import com.damy.common.Global;

import android.net.Uri;
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


public class MyActAddActivity extends Activity {

	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private String[] m_szSelPath = new String[3];
	private Uri[] m_szSelUri = new Uri[3];
	
	private int REQUEST_PHOTO = 0;
	
	private FrameLayout fl_addimgframe1;
	private FrameLayout fl_addimgframe2;
	private FrameLayout fl_addimgframe3;
	
	private ImageView img_addimg1;
	private ImageView img_addimg2;
	private ImageView img_addimg3;
	
	private AutoSizeTextView txt_addimgtxt1;
	private AutoSizeTextView txt_addimgtxt2;
	private AutoSizeTextView txt_addimgtxt3;
	
	private int m_nCurImg = 0;
	private ImageView m_CurImgView;
	private int m_nCurImgCount = 0;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_myactadd);
		
		FrameLayout fl_submit = (FrameLayout)findViewById(R.id.fl_myactadd_submitbtn);
		
		fl_submit.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSubmit();
        	}
        });
		
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_myactadd_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		fl_addimgframe1 = (FrameLayout)findViewById(R.id.fl_myactadd_imgframe1);
		fl_addimgframe2 = (FrameLayout)findViewById(R.id.fl_myactadd_imgframe2);
		fl_addimgframe3 = (FrameLayout)findViewById(R.id.fl_myactadd_imgframe3);
		
		fl_addimgframe1.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickFilebtn(1);
        	}
        });
		
		fl_addimgframe2.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickFilebtn(2);
        	}
        });
		
		fl_addimgframe3.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickFilebtn(3);
        	}
        });
		
		img_addimg1 = (ImageView)findViewById(R.id.img_myactadd_addimg1);
		img_addimg2 = (ImageView)findViewById(R.id.img_myactadd_addimg2);
		img_addimg3 = (ImageView)findViewById(R.id.img_myactadd_addimg3);
		
		txt_addimgtxt1 = (AutoSizeTextView)findViewById(R.id.txt_myactadd_addimgtxt1);
		txt_addimgtxt2 = (AutoSizeTextView)findViewById(R.id.txt_myactadd_addimgtxt2);
		txt_addimgtxt3 = (AutoSizeTextView)findViewById(R.id.txt_myactadd_addimgtxt3);
		
		fl_addimgframe2.setVisibility(android.view.View.INVISIBLE);
		fl_addimgframe3.setVisibility(android.view.View.INVISIBLE);
	}
	

	@Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);    //To change body of overridden methods use File | Settings | File Templates.

        if (requestCode == REQUEST_PHOTO && resultCode == RESULT_OK)
            updateUserImage(data);
    }
	
	private void updateUserImage(Intent data)
    {
        if (data.getIntExtra(SelectPhotoActivity.szRetCode, -999) == SelectPhotoActivity.nRetSuccess)
        {
            Object objPath = data.getExtras().get(SelectPhotoActivity.szRetPath);
            Object objUri = data.getExtras().get(SelectPhotoActivity.szRetUri);

            if (objPath != null)
            	m_szSelPath[m_nCurImg - 1] = (String)objPath;

            if (objUri != null)
            	m_szSelUri[m_nCurImg - 1] = (Uri)objUri;
            
            if (objPath != null && !objPath.equals(""))
                updateUserImageWithPath(m_szSelPath[m_nCurImg - 1]);
            else if (objUri != null)
            	updateUserImageWithUri(m_szSelUri[m_nCurImg - 1]);
            
            if ( m_nCurImg == 1 )
            {
            	fl_addimgframe2.setVisibility(android.view.View.VISIBLE);
            	txt_addimgtxt1.setVisibility(android.view.View.INVISIBLE);
            }
            else if ( m_nCurImg == 2 )
            {
            	fl_addimgframe3.setVisibility(android.view.View.VISIBLE);
            	txt_addimgtxt2.setVisibility(android.view.View.INVISIBLE);
            }
            else
            	txt_addimgtxt3.setVisibility(android.view.View.INVISIBLE);
            
            m_nCurImgCount++;
        }
    }
	
	private void updateUserImageWithPath(String szPath)
    {
        try {
			/* Update user photo info view */
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;
            Bitmap bitmap = BitmapFactory.decodeFile(szPath, options);

            m_CurImgView.setImageBitmap(bitmap);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }


    private void updateUserImageWithUri(Uri uri)
    {
        BufferedInputStream bis = null;
        InputStream is = null;
        Bitmap bmp = null;

        try {

            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.ARGB_8888;

            is = getContentResolver().openInputStream(uri);
            bmp = BitmapFactory.decodeStream(is, null, options);

            m_CurImgView.setImageBitmap(bmp);

        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
        finally {
            if (bis != null) {
                try {
                    bis.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            if (is != null) {
                try {
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
	
	private void onClickFilebtn(int curImg)
	{
		m_nCurImg = curImg;
		
		if ( m_nCurImg == 1 )
			m_CurImgView = img_addimg1;
		else if ( m_nCurImg == 2 )
			m_CurImgView = img_addimg2;
		else
			m_CurImgView = img_addimg3;
		
		Intent intent = new Intent(MyActAddActivity.this, SelectPhotoActivity.class);
        startActivityForResult(intent, REQUEST_PHOTO);
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickSubmit()
	{
		AutoSizeEditText txt_title = (AutoSizeEditText)findViewById(R.id.txt_myactadd_title);
		AutoSizeEditText txt_body = (AutoSizeEditText)findViewById(R.id.txt_myactadd_body);
		
		if (txt_title.getText().toString().length() == 0) {
			new AlertDialog.Builder(this)
			.setTitle(R.string.app_name)
			.setMessage(R.string.no_title)
			.setNegativeButton(R.string.confirm, null)
			.show();
			return;
		}
		
		handler = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog.dismiss();

                try {
                	int isSuccess = object.getInt("success");
        			if ( isSuccess == 1 )
        				onSuccessSubmit();
        			else
        				onFailSubmit();
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Throwable ex, String exception) {
            	progDialog.dismiss();
            	onFailSubmit();
            }

            @Override
            public void onFinish()
            {
				progDialog.dismiss();
            }
        };

        progDialog = ProgressDialog.show(MyActAddActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "postactivity_many.jsp";
        	param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("act_title", txt_title.getText().toString());
            param.put("act_body", txt_body.getText().toString());

            int j;
            for ( j = 0; j < m_nCurImgCount; j++ )
            {
	            File tmpFile;
	            try {
	
	        		if (m_szSelPath[j] != null && !m_szSelPath[j].equals(""))
	        		{
	        			tmpFile = new File(m_szSelPath[j]);
	        			param.put("upload-file" + String.valueOf(j), tmpFile);
	        		}
	                else if (m_szSelUri[j] != null)
	                {
	                	InputStream is = null;
	                	is = getContentResolver().openInputStream(m_szSelUri[j]);
	                	param.put("upload-file" + String.valueOf(j), is, "tmp" + String.valueOf(j) + ".jpg");
	                }
		
	            }
	            catch (Exception e) {
	            	e.printStackTrace();
	            	progDialog.dismiss();
	            	return;
	            }
            }

            client.post(str_url, param, handler);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onSuccessSubmit()
	{
        Global.showToast(MyActAddActivity.this, getString(R.string.msg_success));
		finish();
	}
	
	private void onFailSubmit()
	{
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(R.string.submitfail)
		.setNegativeButton(R.string.confirm, null)
		.show();
	}
	

}
