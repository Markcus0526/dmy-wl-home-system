package com.damy.wljy;

import java.io.File;
import java.io.InputStream;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.damy.HttpConn.AsyncHttpClient;
import com.damy.HttpConn.JsonHttpResponseHandler;
import com.damy.HttpConn.RequestParams;
import com.damy.Utils.AutoSizeEditText;
import com.damy.Utils.AutoSizeTextView;
import com.damy.common.Global;
import com.damy.common.wljyBinaryHttpResponseHandler;

import android.net.Uri;
import android.os.Bundle;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;

public class MemberInfo extends Activity {
	
	private JsonHttpResponseHandler handler;
    private ProgressDialog progDialog;
    
    private JsonHttpResponseHandler handler1;
    private ProgressDialog progDialog1;
    
    private String m_szSelPath = "";
	private Uri m_szSelUri = null;
	
	private int REQUEST_PHOTO = 0;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_member_info);
		
		LinearLayout ll_changepassbtn = (LinearLayout)findViewById(R.id.ll_member_info_passchange);
		ll_changepassbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickChangePass();
        	}
        });
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_member_info_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
		
		LinearLayout ll_photoedit = (LinearLayout)findViewById(R.id.ll_member_info_photoedit);
		ll_photoedit.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickPhotoEdit();
        	}
        });
		
		LinearLayout ll_nicknameedit = (LinearLayout)findViewById(R.id.ll_member_info_nicknameeidt);
		ll_nicknameedit.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickNicknameEdit();
        	}
        });
		
		LinearLayout ll_phonenumedit = (LinearLayout)findViewById(R.id.ll_member_info_phoneedit);
		ll_phonenumedit.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickPhonenumEdit();
        	}
        });
		
		DisplayUserPhoto();
		//readContents();
	}
	
	@Override
	protected void onResume()
	{
		readContents();
		super.onResume();
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

    		handler1 = new JsonHttpResponseHandler()
            {
                @Override
                public void onSuccess(JSONObject object)
                {
                    progDialog1.dismiss();

                    try {
                    	int isSuccess = object.getInt("success");
            			if ( isSuccess == 1 )
            			{
            				Global.Cur_UserPhoto = object.getString("imagepath");
            				DisplayUserPhoto();
            			}
            			else
            				onFailSubmit();
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }

                @Override
                public void onFailure(Throwable ex, String exception) {
                	progDialog1.dismiss();
                	onFailSubmit();
                }

                @Override
                public void onFinish()
                {
    				progDialog1.dismiss();
                }
            };

            progDialog1 = ProgressDialog.show(MemberInfo.this, "", "Waiting", true, false, null);
            
            AsyncHttpClient client = new AsyncHttpClient();
            RequestParams param = new RequestParams();
            
            try {
            	
            	String str_url = Global.STR_SERVER_URL + "photo_change.jsp";
            	param.put("userid", Integer.toString(Global.Cur_UserId));
            	
            	
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
                	progDialog1.dismiss();
                	return;
                }
                
                client.post(str_url, param, handler1);
                
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            
        }
    }
	
	
	private void onClickChangePass()
	{
		Intent changepass_activity = new Intent(this, PasswordChangeActivity.class);
		startActivity(changepass_activity);
	}
	
	private void onClickPhotoEdit()
	{
		Intent intent = new Intent(this, SelectPhotoActivity.class);
        startActivityForResult(intent, REQUEST_PHOTO);
	}
	
	private void onClickNicknameEdit()
	{
		Intent changenickname_activity = new Intent(this, NicknameChangeActivity.class);
		startActivity(changenickname_activity);
	}
	
	private void onClickPhonenumEdit()
	{
		Intent changephonenum_activity = new Intent(this, PhonenumChangeActivity.class);
		startActivity(changephonenum_activity);
	}
	
	private void onClickBack()
	{
		finish();
	}
	
	private void readContents()
	{
		handler = new JsonHttpResponseHandler()
        {
            @Override
            public void onSuccess(JSONObject object)
            {
                progDialog.dismiss();

                try {
                	parseMainItems(object);
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

        progDialog = ProgressDialog.show(MemberInfo.this, "", "Waiting", true, false, null);
        
        AsyncHttpClient client = new AsyncHttpClient();
        RequestParams param = new RequestParams();
        
        try {
        	
        	String str_url = Global.STR_SERVER_URL + "myinfo.jsp";
            param.put("userid", Integer.toString(Global.Cur_UserId));
            
            client.get(str_url, param, handler);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        

	}
	
	private void parseMainItems(JSONObject order)
	{
		try {
			
			JSONObject anItem = new JSONObject();
			JSONArray data = new JSONArray();
			int isSuccess;
			
			isSuccess = order.getInt("success");
			
			if ( isSuccess == 1 )
			{
				AutoSizeTextView lab_name = (AutoSizeTextView)findViewById(R.id.lab_member_info_name);
				AutoSizeTextView lab_othername = (AutoSizeTextView)findViewById(R.id.lab_member_info_othername);
				AutoSizeTextView lab_phone = (AutoSizeTextView)findViewById(R.id.lab_member_info_phone);
				AutoSizeTextView lab_integral = (AutoSizeTextView)findViewById(R.id.lab_member_info_integral);
				
				lab_name.setText(order.getString("name"));
				lab_othername.setText(order.getString("nickname"));
				lab_phone.setText(order.getString("phone"));
				lab_integral.setText(Integer.toString(order.getInt("integral")));
			}


		} catch (JSONException e) {
			
		}
	}
	
	private void DisplayUserPhoto()
	{		
		//readContents();
		
		ImageView img_photo = (ImageView)findViewById(R.id.img_member_info_photo);
		
		Global.imageLoader.displayImage(Global.STR_SERVER_URL1 + Global.Cur_UserPhoto, img_photo, Global.options);
		
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
