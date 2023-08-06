package com.damy.wljy;


import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;

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

import android.view.View;
import android.view.View.OnClickListener;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.ListView;


public class MyPhotoAddActivity extends Activity {

	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private String m_szSelPath = "";
	private Uri m_szSelUri = null;
	
	private int REQUEST_PHOTO = 0;
    
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_myphotoadd);
		
		FrameLayout fl_submit = (FrameLayout)findViewById(R.id.fl_myphotoadd_submitbtn);
		FrameLayout fl_filebtn = (FrameLayout)findViewById(R.id.fl_myphotoadd_filebtn);
		
		fl_submit.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickSubmit();
        	}
        });
		
		fl_filebtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickFilebtn();
        	}
        });
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_myphotoadd_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
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
            	m_szSelPath = (String)objPath;

            if (objUri != null)
            	m_szSelUri = (Uri)objUri;
            
        }
    }
	
	
	private void onClickFilebtn()
	{
		/*
		Intent fileexplorer_activity = new Intent(this, FileExplorer.class);
		startActivity(fileexplorer_activity);
		*/
		
		Intent intent = new Intent(this, SelectPhotoActivity.class);
        startActivityForResult(intent, REQUEST_PHOTO);
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void onClickSubmit()
	{
		AutoSizeEditText txt_title = (AutoSizeEditText)findViewById(R.id.txt_myphotoadd_title);
		AutoSizeEditText txt_body = (AutoSizeEditText)findViewById(R.id.txt_myphotoadd_body);
		
		if (txt_title.getText().toString().length() == 0) {
			new AlertDialog.Builder(this)
			.setTitle(R.string.app_name)
			.setMessage(R.string.no_title)
			.setNegativeButton(R.string.confirm, null)
			.show();
			return;
		}
		
		if ( m_szSelPath.equals("") && m_szSelUri == null ) {
			new AlertDialog.Builder(this)
			.setTitle(R.string.app_name)
			.setMessage(R.string.no_picture)
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
        				onSuccessUpdate();
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

        progDialog = ProgressDialog.show(MyPhotoAddActivity.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "postphoto.jsp";
        	param.put("userid", Integer.toString(Global.Cur_UserId));
            param.put("photo_title", txt_title.getText().toString());
            param.put("photo_body", txt_body.getText().toString());
            

            File tmpFile;
            try {

        		if (m_szSelPath != null && !m_szSelPath.equals(""))
        		{
        			tmpFile = new File(m_szSelPath);
        			param.put("upload-file", tmpFile);
        		}
                else if (m_szSelUri != null)
                {
                	InputStream is = null;
                	is = getContentResolver().openInputStream(m_szSelUri);
                	param.put("upload-file", is, "tmp.jpg");
                }
	
            }
            catch (Exception e) {
            	e.printStackTrace();
            	progDialog.dismiss();
            	return;
            }


            client.post(str_url, param, handler);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
	}
	
	private void onSuccessUpdate()
	{
		finish();
		/*
		new AlertDialog.Builder(this)
		.setTitle(R.string.app_name)
		.setMessage(R.string.submitsuccess)
		.setNegativeButton(R.string.confirm, null)
		.show();
		*/
	}

}
