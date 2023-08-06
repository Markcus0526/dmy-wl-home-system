package com.damy.wljy;


import com.damy.Utils.AutoSizeTextView;
import com.damy.common.Global;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;

import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;


public class SettingDisplayActivity extends Activity {
	
	private ImageView	display_state_switch1;
	private ImageView	display_state_switch2;
	private ImageView	display_state_switch3;
	private ImageView	display_state_switch4;
	
	public static final String WLJY_SETTING_ROOT_STR = "WLJY_SETTING_ROOT";
	public static final String WLJY_SETTING_DISPLAY_MODE_STR = "WLJY_SETTING_DISPLAY_MODE";
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_setting_display);
		
		display_state_switch1 = (ImageView)findViewById(R.id.setting_display_switch1);
		
		display_state_switch1.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickDisplaySetting(1);
        	}
		});
		
		display_state_switch2 = (ImageView)findViewById(R.id.setting_display_switch2);
		
		display_state_switch2.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickDisplaySetting(2);
        	}
		});
		
		display_state_switch3 = (ImageView)findViewById(R.id.setting_display_switch3);
		
		display_state_switch3.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickDisplaySetting(3);
        	}
		});
		
		display_state_switch4 = (ImageView)findViewById(R.id.setting_display_switch4);
		
		display_state_switch4.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickDisplaySetting(4);
        	}
		});
		
		onRestorePreference();
		onSetSwitchImage(Global.Display_Mode);
		
		LinearLayout ll_backbtn = (LinearLayout)findViewById(R.id.ll_setting_display_backbtn);
		ll_backbtn.setOnClickListener(new OnClickListener() {
        	public void onClick(View v) {
        		onClickBack();
        	}
        });
	}
	
	private void onClickBack() {
		Intent main_activity = new Intent(this, Main.class);
		startActivity(main_activity);
		finish();
	}
	
	public void onClickDisplaySetting(int mod) {
		Global.Display_Mode = mod;
		onSavePreference(Global.Display_Mode);
		onSetSwitchImage(Global.Display_Mode);
	}
	
	private void onSavePreference(int state) {
		SharedPreferences pref = getSharedPreferences(WLJY_SETTING_ROOT_STR, 0);
		SharedPreferences.Editor edit = pref.edit();

		edit.putInt(WLJY_SETTING_DISPLAY_MODE_STR, state);
		
		edit.commit();
	}
	
	private void onRestorePreference() {
		SharedPreferences pref = getSharedPreferences(WLJY_SETTING_ROOT_STR, 0);
		
		Global.Display_Mode = pref.getInt(WLJY_SETTING_DISPLAY_MODE_STR, 1);
	}
	
	private void onSetSwitchImage(int state) {
		int drw_off = R.drawable.setting_display_off;
		int drw_on = R.drawable.setting_display_on;
		
		display_state_switch1.setImageResource(drw_off);
		display_state_switch2.setImageResource(drw_off);
		display_state_switch3.setImageResource(drw_off);
		display_state_switch4.setImageResource(drw_off);
		
		if ( state == 1 )
			display_state_switch1.setImageResource(drw_on);
		else if ( state == 2 )
			display_state_switch2.setImageResource(drw_on);
		else if ( state == 3 )
			display_state_switch3.setImageResource(drw_on);
		else if ( state == 4 )
			display_state_switch4.setImageResource(drw_on);
	}
}
