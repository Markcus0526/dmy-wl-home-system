

function FlashInsert(FlashIDName, FlashFileName, FlashWidth, FlashHeight, DNSSetting, WMODESetting, FlashBGColor, QSetting, FlashAlign)
{

document.write('<OBJECT CLASSID="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"');

document.write('CODEBASE="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0" ');
	document.write(' ID="'+FlashIDName+'" WIDTH="' + FlashWidth + '" HEIGHT="' + FlashHeight + '" ALIGN="'+FlashAlign+'">');

document.write('<PARAM NAME="movie" VALUE="'+ FlashFileName +'">');

document.write('<PARAM NAME="quality" VALUE="'+QSetting+'">');

document.write('<PARAM NAME="bgcolor" VALUE="'+FlashBGColor+'">');

document.write('<PARAM NAME="wmode" VALUE="'+WMODESetting+'">');

document.write('<PARAM NAME="allowFullScreen" VALUE="true">');
document.write('<PARAM NAME="allowScriptAccess" VALUE="'+DNSSetting+'">');

document.write('<EMBED SRC="'+ FlashFileName +'"  NAME="'+FlashIDName+'"');

document.write(' WIDTH="' + FlashWidth + '" HEIGHT="' + FlashHeight + '" QUALITY="'+QSetting+'" BGCOLOR="'+FlashBGColor+'"');
	document.write(' ALLOWSCRIPTACCESS="'+DNSSetting+'" ALIGN="'+FlashAlign+'" WMODE="'+WMODESetting+'" TYPE="application/x-shockwave-flash" ');

document.write(' PLUGINSPAGE="http://www.macromedia.com/go/getflashplayer" >');

document.write('</EMBED>');

document.write('</OBJECT>');
}
