//
//  Common.m
//  4S-C
//
//  Created by R CJ on 1/5/13.
//  Copyright (c) 2013 PIC. All rights reserved.
//

#import "Common.h"


// Common variables

NSString *  _deviceToken = @"";
STUserInfo *_userInfo = nil;

STCurReserveInfo * _curRsrvInfo = nil;

#define _MAXLENGTH       50

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation Common

+ (BOOL) isIOSVer7
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        // code here
        return true;
    }
    
    return false;
}

+ (void) makeErrorWindow : (NSString *)content TopOffset:(NSInteger)topOffset BottomOffset:(NSInteger)bottomOffset View:(UIView *)view
{
    CGRect rt = [view frame];
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0., topOffset, rt.size.width, rt.size.height - topOffset - bottomOffset)];
    [imgView setImage:[UIImage imageNamed:@"bkError.png"]];
    
    UILabel * lblContent = [[UILabel alloc] initWithFrame:CGRectMake(0., topOffset, rt.size.width, rt.size.height - topOffset - bottomOffset)];
    lblContent.backgroundColor = [UIColor clearColor];
    lblContent.textAlignment = UITextAlignmentCenter;
    lblContent.text = content;
    
    [view addSubview:imgView];
    [view addSubview:lblContent];
}


+ (void) setDeviceToken : (NSString*)newDeviceToken
{
    _deviceToken = newDeviceToken;
}

+ (NSString*) deviceToken
{
    return _deviceToken;
}

+ (void) setUserInfo : (STUserInfo*)userInfo;
{
    _userInfo = userInfo;
}

+ (STUserInfo*) userInfo
{
    return _userInfo;
}

+ (NSString*) userId
{
    return [NSString stringWithFormat:@"%d", _userInfo.userId];
}

+ (void) setReserveInfo : (STCurReserveInfo*)rsrvInfo
{
    _curRsrvInfo = rsrvInfo;
}

+ (STCurReserveInfo*) reserveInfo
{
    return _curRsrvInfo;
}

+ (void) setReserveMode : (NSString*)rsrvMode
{
    if (_curRsrvInfo != nil) {
        _curRsrvInfo.reserveMode = rsrvMode;
        if ([rsrvMode isEqualToString:RESERVE_MODE_ENGINEER]) {
            _curRsrvInfo.familiar = FAMILIAR_YES;
        } else {
            _curRsrvInfo.familiar = FAMILIAR_NO;
        }
    }
}


+ (NSInteger) MAXLENGTH
{
    return _MAXLENGTH;
}

+ (NSString*) getCurTime : (NSString*)fmt
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if ( fmt == nil ) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
        [dateFormatter setDateFormat:fmt];
    }
    
    return [dateFormatter stringFromDate:currentDate];
}

+ (NSInteger)phoneType
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([UIScreen mainScreen].bounds.size.height == 568) {
            return IPHONE5;
        }
        else {
            return IPHONE4;
        }
    }
    else {
        return IPAD;
    }
}

+ (NSString *) getCurLang
{
    NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if ([currentLanguage rangeOfString:@"zh"].location != NSNotFound)
    {
        return LANG_CN;
    }
    
    return LANG_US;
}

+ (NSString *)getRealImagePath :(NSString *)path :(NSString *)rate :(NSString *)size
{
    if (path.length > 0) {
        NSArray *pathArray = [path componentsSeparatedByString:@"/"];
        NSMutableString *realPath = [NSMutableString string];
        
        for (int i = 0; i < pathArray.count-1; i++) {
            [realPath appendString:[pathArray objectAtIndex:i]];
            [realPath appendString:@"/"];
        }
        
        [realPath appendString:@"640960"];
        [realPath appendString:@"_"];
        [realPath appendString:rate];
        [realPath appendString:@"_"];
        [realPath appendString:size];
        [realPath appendString:@"_"];
        [realPath appendString:[pathArray objectAtIndex:pathArray.count-1]];
        
        NSLog(@"%@", realPath);
        return realPath;
    }
    else {
        return @"";
    }
}

+ (NSString *)getBackImagePath :(NSString *)path :(NSString *)rate :(NSString *)size
{
    if (path.length > 0) {
        NSArray *pathArray = [path componentsSeparatedByString:@"/"];
        NSMutableString *realPath = [NSMutableString string];
        
        for (int i = 0; i < pathArray.count-1; i++) {
            [realPath appendString:[pathArray objectAtIndex:i]];
            [realPath appendString:@"/"];
        }
        
        if ([Common phoneType] == IPHONE5) {
            [realPath appendString:@"6401136"];
        }
        else {
            [realPath appendString:@"640960"];
        }
        [realPath appendString:@"_"];
        [realPath appendString:rate];
        [realPath appendString:@"_"];
        [realPath appendString:size];
        [realPath appendString:@"_"];
        [realPath appendString:[pathArray objectAtIndex:pathArray.count-1]];
        
        NSLog(@"%@", realPath);
        return realPath;
    }
    else {
        return @"";
    }
}

+ (NSString*)base64forData:(NSData*)theData 
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F]  :'=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F]  :'=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+ (NSData*)base64forString:(NSString*)theString
{
    NSMutableData *mutableData = nil;

    if (theString) {
		unsigned long ixtext = 0;
		unsigned long lentext = 0;
		unsigned char ch = 0;
		unsigned char inbuf[4], outbuf[3];
		short i = 0, ixinbuf = 0;
		BOOL flignore = NO;
		BOOL flendtext = NO;
		NSData *base64Data = nil;
		const unsigned char *base64Bytes = nil;
        
		// Convert the string to ASCII data.
		base64Data = [theString dataUsingEncoding:NSASCIIStringEncoding];
		base64Bytes = [base64Data bytes];
		mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
		lentext = [base64Data length];
        
		while( YES ) {
			if( ixtext >= lentext ) break;
			ch = base64Bytes[ixtext++];
			flignore = NO;
            
			if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
			else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
			else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
			else if( ch == '+' ) ch = 62;
			else if( ch == '=' ) flendtext = YES;
			else if( ch == '/' ) ch = 63;
			else flignore = YES;
            
			if( ! flignore ) {
				short ctcharsinbuf = 3;
				BOOL flbreak = NO;
                
				if( flendtext ) {
					if( ! ixinbuf ) break;
					if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
					else ctcharsinbuf = 2;
					ixinbuf = 3;
					flbreak = YES;
				}
                
				inbuf [ixinbuf++] = ch;
                
				if( ixinbuf == 4 ) {
					ixinbuf = 0;
					outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
					outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
					outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );
                    
					for( i = 0; i < ctcharsinbuf; i++ )
						[mutableData appendBytes:&outbuf[i] length:1];
				}
                
				if( flbreak )  break;
			}
		}
	}
    
	return mutableData;
}


+ (NSString *)appNameAndVersionNumberDisplayString 
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    //NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return majorVersion;
}

+ (NSString *)weatherUrl
{
    //return @"http://m.weather.com.cn/data/";
    return @"http://api.sijimishu.com/weather.ashx?city=";
}

+ (NSArray *)provinceArray
{
    NSArray *array = [[NSArray alloc] initWithObjects:@"直辖市", @"特别行政区", @"黑龙江", @"吉林", @"辽宁", @"内蒙古", @"河北", @"河南", @"山东", @"山西", @"江苏", @"安徽", @"陕西", @"宁夏", @"甘肃", @"青海", @"湖北", @"湖南", @"浙江", @"江西", @"福建", @"贵州", @"广东", @"广西", @"云南", @"海南", @"新疆", @"西藏", @"台湾", nil];
    return  array;
}

+ (NSArray *)cityArray :(NSString *)province
{
    NSArray *array = nil;
    
    if ([province compare:@"直辖市"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"北京,101010100", @"上海,101020100", @"天津,101030100", @"重庆,101040100", nil];
    } 
    else if ([province compare:@"特别行政区"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"香港,101320101", @"澳门,101330101", nil];
    }
    else if ([province compare:@"黑龙江"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"哈尔滨,101050101", @"齐齐哈尔,101050201", @"牡丹江,101050301", @"大庆,101050901", @"伊春,101050801", @"双鸭山,101051301", @"鹤岗,101051201", @"鸡西,101051101", @"佳木斯,101050401", @"七台河,101051002", @"黑河,101050601", @"绥化,101050501", @"大兴安岭,101050701", nil];
    }
    else if ([province compare:@"吉林"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"长春,101060101", @"延吉,101060301", @"吉林,101060201", @"白山,101060901", @"白城,101060601", @"四平,101060401", @"松原,101060801", @"辽源,101060701", @"大安,101060603", @"通化,101060501", nil];
    }
    else if ([province compare:@"辽宁"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"沈阳,101070101", @"大连,101070201", @"葫芦岛,101071401", @"盘锦,101071301", @"本溪,101070501", @"抚顺,101070401", @"铁岭,101071101", @"辽阳,101071001", @"营口,101070801", @"阜新,101070901", @"朝阳,101071201", @"锦州,101070701", @"丹东,101070601", @"鞍山,101070301", nil];
    }
    else if ([province compare:@"内蒙古"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"呼和浩特,101080101", @"呼伦贝尔,101081000", @"锡林浩特,101080901", @"包头,101080201", @"赤峰,101080601", @"海拉尔,101081001", @"乌海,101080301", @"鄂尔多斯,101080701", @"通辽,101080501", nil];
    }
    else if ([province compare:@"河北"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"石家庄,101090101", @"唐山,101090501", @"张家口,101090301", @"廊坊,101090601", @"邢台,101090901", @"邯郸,101091001", @"沧州,101090701", @"衡水,101090801", @"承德,101090402", @"保定,101090201", @"秦皇岛,101091101", nil];
    }
    else if ([province compare:@"河南"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"郑州,101180101", @"开封,101180801", @"洛阳,101180901", @"平顶山,101180501", @"焦作,101181101", @"鹤壁,101181201", @"新乡,101180301", @"安阳,101180201", @"濮阳,101181301", @"许昌,101180401", @"漯河,101181501", @"三门峡,101181701", @"南阳,101180701", @"商丘,101181001", @"信阳,101180601", @"周口,101181401", @"驻马店,101181601", nil];
    }
    else if ([province compare:@"山东"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"济南,101120101", @"青岛,101120201", @"淄博,101120301", @"威海,101121301", @"曲阜,101120710", @"临沂,101120901", @"烟台,101120501", @"枣庄,101121401", @"聊城,101121701", @"济宁,101120701", @"菏泽,101121001", @"泰安,101120801", @"日照,101121501", @"东营,101121201", @"德州,101120401", @"滨州,101121101", @"莱芜,101121601", @"潍坊,101120601", nil];
    }
    else if ([province compare:@"山西"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"太原,101100101", @"阳泉,101100301", @"晋城,101100601", @"晋中,101100401", @"临汾,101100701", @"运城,101100801", @"长治,101100501", @"朔州,101100901", @"忻州,101101001", @"大同,101100201", @"吕梁,101101101", nil];
    }
    else if ([province compare:@"江苏"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"南京,101190101", @"苏州,101190401", @"昆山,101190404", @"南通,101190501", @"太仓,101190408", @"吴县,101190406", @"徐州,101190801", @"宜兴,101190203", @"镇江,101190301", @"淮安,101190901", @"常熟,101190402", @"盐城,101190701", @"泰州,101191201", @"无锡,101190201", @"连云港,101191001", @"扬州,101190601", @"常州,101191101", @"宿迁,101191301", nil];
    }
    else if ([province compare:@"安徽"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"合肥,101220101", @"巢湖,101221601", @"蚌埠,101220201", @"安庆,101220601", @"六安,101221501", @"滁州,101221101", @"马鞍山,101220501", @"阜阳,101220801", @"宣城,101221401", @"铜陵,101221301", @"淮北,101221201", @"芜湖,101220301", @"毫州,101220901", @"宿州,101220701", @"淮南,101220401", @"池州,101221701", nil];
    }
    else if ([province compare:@"陕西"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"西安,101110101", @"韩城,101110510", @"安康,101110701", @"汉中,101110801", @"宝鸡,101110901", @"咸阳,101110200", @"榆林,101110401", @"渭南,101110501", @"商洛,101110601", @"铜川,101111001", @"延安,101110300", nil];
    }
    else if ([province compare:@"宁夏"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"银川,101170101", @"固原,101170401", @"中卫,101170501", @"石嘴山,101170201", @"吴忠,101170301", nil];
    }
    else if ([province compare:@"甘肃"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"兰州,101160101", @"白银,101161301", @"庆阳,101160401", @"酒泉,101160801", @"天水,101160901", @"武威,101160501", @"张掖,101160701", @"甘南,101050204", @"临夏,101161101", @"平凉,101160301", @"定西,101160201", @"金昌,101160601", nil];
    }
    else if ([province compare:@"青海"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"西宁,101150101", @"海北,101150801", @"海西,101150701", @"黄南,101150301", @"果洛,101150501", @"玉树,101150601", @"海东,101150201", @"海南,101150401", nil];
    }
    else if ([province compare:@"湖北"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"武汉,101200101", @"宜昌,101200901", @"黄冈,101200501", @"恩施,101201001", @"荆州,101200801", @"神农架,101201201", @"十堰,101201101", @"咸宁,101200701", @"襄阳,101200201", @"孝感,101200401", @"随州,101201301", @"黄石,101200601", @"荆门,101201401", @"鄂州,101200301", nil];
    }
    else if ([province compare:@"湖南"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"长沙,101250101", @"邵阳,101250901", @"常德,101250601", @"郴州,101250501", @"吉首,101251501", @"株洲,101250301", @"娄底,101250801", @"湘潭,101250201", @"益阳,101250701", @"永州,101251401", @"岳阳,101251001", @"衡阳,101250401", @"怀化,101251201", @"韶山,101250202", @"张家界,101251101", nil];
    }
    else if ([province compare:@"浙江"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"杭州,101210101", @"湖州,101210201", @"金华,101210901", @"宁波,101210401", @"丽水,101210801", @"绍兴,101210501", @"衢州,101211001", @"嘉兴,101210301", @"台州,101210601", @"舟山,101211101", @"温州,101210701", nil];
    }
    else if ([province compare:@"江西"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"南昌,101240101", @"萍乡,101240901", @"九江,101240201", @"上饶,101240301", @"抚州,101240401", @"吉安,101240601", @"鹰潭,101241101", @"宜春,101240501", @"新余,101241001", @"景德镇,101240801", @"赣州,101240701", nil];
    }
    else if ([province compare:@"福建"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"福州,101230101", @"厦门,101230201", @"龙岩,101230701", @"南平,101230901", @"宁德,101230301", @"莆田,101230401", @"泉州,101230501", @"三明,101230801", @"漳州,101230601", nil];
    }
    else if ([province compare:@"贵州"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"贵阳,101260101", @"安顺,101260301", @"赤水,101260208", @"遵义,101260201", @"铜仁,101260601", @"六盘水,101260801", @"毕节,101260701", @"凯里,101260501", @"都匀,101260401", nil];
    }
    else if ([province compare:@"四川"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"成都,101270101", @"泸州,101271001", @"内江,101271201", @"凉山,101271601", @"阿坝,101271901", @"巴中,101270901", @"广元,101272101", @"乐山,101271401", @"绵阳,101270401", @"德阳,101272001", @"攀枝花,101270201", @"雅安,101271701", @"宜宾,101271101", @"自贡,101270301", @"甘孜州,101271801", @"达州,101270601", @"资阳,101271301", @"广安,101270801", @"遂宁,101270701", @"眉山,101271501", @"南充,101270501", nil];
    }
    else if ([province compare:@"广东"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"广州,101280101", @"深圳,101280601", @"潮州,101281501", @"韶关,101280201", @"湛江,101281001", @"惠州,101280301", @"清远,101281301", @"东莞,101281601", @"江门,101281101", @"茂名,101282001", @"肇庆,101280901", @"汕尾,101282101", @"河源,101281201", @"揭阳,101281901", @"梅州,101280401", @"中山,101281701", @"德庆,101280905", @"阳江,101281801", @"云浮,101281401", @"珠海,101280701", @"汕头,101280501", @"佛山,101280800", nil];
    }
    else if ([province compare:@"广西"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"南宁,101300101", @"桂林,101300501", @"阳朔,101300510", @"柳州,101300301", @"梧州,101300601", @"玉林,101300901", @"桂平,101300802", @"贺州,101300701", @"钦州,101301101", @"贵港,101300801", @"防城港,101301401", @"百色,101301001", @"北海,101301301", @"河池,101301201", @"来宾,101300401", @"崇左,101300201", nil];
    }
    else if ([province compare:@"云南"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"昆明,101290101", @"保山,101290501", @"楚雄,101290801", @"德宏,101291501", @"红河,101290301", @"临沧,101291101", @"怒江,101291201", @"曲靖,101290401", @"思茅,101290901", @"文山,101290601", @"玉溪,101290701", @"昭通,101291001", @"丽江,101291401", @"大理,101290201", nil];
    }
    else if ([province compare:@"海南"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"海口,101310101", @"三亚,101310201", @"儋州,101310205", @"琼山,101310102", @"通什,101310222", @"文昌,101310212", nil];
    }
    else if ([province compare:@"新疆"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"乌鲁木齐,101130101", @"阿勒泰,101131401", @"阿克苏,101130801", @"昌吉,101130401", @"哈密,101131201", @"和田,101131301", @"喀什,101130901", @"克拉玛依,101130201", @"石河子,101130301", @"塔城,101131101", @"库尔勒,101130601", @"吐鲁番,101130501", @"伊宁,101131001", nil];
    }
    else if ([province compare:@"西藏"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"拉萨,101140101", @"阿里,101140701", @"昌都,101140501", @"那曲,101140601", @"日喀则,101140201", @"山南,101140301", @"林芝,101140401", nil];
    }
    else if ([province compare:@"台湾"] == NSOrderedSame) {
        array = [[NSArray alloc] initWithObjects:@"台北,101340102", @"高雄,101340201", nil];
    }
    
    return  array;
}

+ (NSString *)getRegionCodeFromCarNumber :(NSString *)carNum
{
    NSString *prefix = [carNum substringFromIndex:0];
    NSArray *array = [Common provinceArray];
    
    for (int i = 0; i < array.count; i++) {
        NSString *item = [array objectAtIndex:i];
        
        if ([prefix compare:[item substringFromIndex:0]] == NSOrderedSame) {
            return item;
        }
    }
    
    return nil;
}

+ (NSArray *)getBookContentArray :(NSString *)carBrand
{
    NSArray *bookWagenContentArray = [[NSArray alloc] initWithObjects:
        @"指示灯含义：\n 1. 制动液液位过低。\n 2. 制动系统有故障。\n 3. 配置电子驻车系统的车辆，如故该指示灯与按钮中的电子驻车制动器指示灯一起亮起，代表电子驻车制动器已接通。\n\n处理方法：\n 1. 制动液面过低，添加指定品牌的制动液，并检修是制动管路是否泄漏。\n 2. 制动系统故障 请及时联系品牌经销商进行检修。\n\n汽车小贴士：\n如果必须进行制动而汽车不能再像往常一样制动（制动距离突然变长），则可能是某个制动回路已失灵。如果发现警告灯XXX。\n和必要时通过一条文字信息指示。请立即到最近的汽车经销商检修，排除损坏。在前往汽车经销商的路上要以较低的车速行驶，同时针对制动距离变长和踏板压力变大调整驾驶方式。",
        @"指示灯含义：\n 1. 电动助力转向作用降低。\n 2. 汽车蓄电池已断开后重新连接，所导致。\n\n处理方法：\n 1. 针对电动助力转向作用降低，立即让汽车经销商检测转向系。\n如果此黄色警告灯在重新启动发动机并短暂行驶后不重新亮起，则不需要到经销商检修。\n 2. 以 15 – 20 km/h 的车速行驶一小段路程后，指示灯会熄灭，如不熄灭，请到品牌经销商检修。\n\n汽车小贴士：\n转向助力不是以液压方式进行，而是采用电控机械方式。该转向系的优点是，液压软管、液压油、泵、过滤器和其他零件都不再需要。电控机械式系统能节约燃油。液压系统需要系统中有持续的油压，而在电控机械式转向系中，只有在转向时才需要能量输送。",
        @"指示灯含义：\n 电控机械式转向系失灵。\n\n处理方法：\n 立即让汽车经销商检测转向系。不能进行正常行驶。\n\n汽车小贴士：\n 1. 电控机械式转向系的转向助力会根据车速、转向力矩和车轮转向角度自动调整。电控机械式转向系只在发动机运行时起作用（牵引工况除外）。\n 2. 如果转向助力不工作，则要用很大的力量才能转动方向盘，而且会使汽车转向变得困难。",
        @"指示灯含义：\n 1. 在打开点火开关时，示灯会短暂亮起，表明在进行功能检测。它们在几秒钟后会熄灭。\n 2. 如果指示灯一直点亮，提示燃油箱内油料过低，需添加油料。\n\n处理方法：\n如果如果指示灯一直点亮，提示燃油箱内油料过低，需马上添加油料，如果不及时注入燃油，会降低燃油泵使用寿命。\n\n汽车小贴士：\n要始终确保油箱锁正确关闭，以免燃油蒸发和泼出。\n 1. 添加燃油时切勿进入车内，若不得不进入车内，则必须关闭车门，并在再次接触加油枪前应触摸一下金属表面，这样可去除身上的静电荷，否则，可能产生电火花，加油时可能引发火灾。\n 2. 为安全起见，在加油时必须关闭发动机。\n 3. 添加燃油时切勿吸烟，远离明火，谨防引爆燃油！\n 4. 安全起见，建议不要随车携带备用油罐，以免发生事故时油罐破损泄漏，引发火灾。",
        @"指示灯含义：\n 1. 若某个轮胎的气压较低，大大低于驾驶员设定的轮胎气压，该警告灯将亮起。\n 2. 系统存在故障时该警告灯也可能亮起，若轮胎气压正常，但点火开关关闭后再打开或按压按钮后警告灯不熄灭，则表明轮胎气压监控系统存在故障。\n\n处理方法：\n 1. 胎压过低，某个车轮的轮胎充气压力过低，请重点检查轮胎本身，然后及时调整标准轮胎气压。\n 2. 轮胎气压监控系统故障，请及时联系汽车经销商处理。\n\n汽车小贴士：\n 1. 胎压不同或胎压过低可能导致轮胎失效、失去对汽车的控制、事故、受伤。\n 2. 若警告灯 XXX亮起，必须立即降低车速，避免急转弯和紧急制动，就近停车，尽快检查轮胎气压。\n 3. 驾驶员必须负责使所有轮胎始终保持正确气压，因此，必须定期检查轮胎气压，最好在添加燃油时和长途行驶前检查轮胎气压。",
        @"指示灯含义：\n 1. 左侧转向信号灯已打开。\n 2. 右侧转向信号灯已打开。\n\n处理方法：\n 1. 正常在变道行驶的过程中，开启左/右侧转向灯。\n 2. 如果在突发事件后，必须开启警告指示灯，使左右两侧的转向灯同时开启。\n\n汽车小贴士：\n 1. 转向信号灯在点火开关已打开的情况下才能工作。闪烁报警灯在点火开关已关闭的情况下也同样能工作。\n 2. 当本车上的一个转向信号灯失灵时，该指示灯以约正常情况下两倍的频率快速闪烁，需进品牌经销商进行检修。",
        @"指示灯含义：\n 1. 制动摩擦片磨损至极限。\n 2. 制动摩擦片线束故障。\n\n处理方法：\n 联系品牌经销商进行检修。检查所有制动摩擦片并在必要时更换，如果制动摩擦片厚度正常，重点检查该部位线束。\n\n汽车小贴士：\n 1. 新制动摩擦片在前 200 至 300 km 期间还不具备充分的制动效果，而且必须首先进行“磨合”。在磨合期间要避免全制动和制动器承受高负荷。例如在距离过近跟车行驶时。\n 2. 制动摩擦片的磨损情况完全取决于使用条件和驾驶方式。\n 3. 在制动器潮湿的情况下行车时（例如涉水行车后、强降雨时或清洗汽车后），制动效果可能由于潮湿或冬季制动盘结冰而变差。通过多次在较高车速小心的制动，尽快“ 干燥制动”。",
        @"指示灯含义：\n 灯泡及灯泡线束故障，不影响白天正常行驶。\n\n处理方法：\n 1. 常规进行车辆灯光检查，并更换相应的灯泡。\n 2. 若果所有灯泡都正常，则要到请到汽车经销商处检修。\n\n汽车小贴士：\n 1. 通常不先拆下其它的汽车零件是无法更换灯泡的。对于那些只能从发动机舱才能接近的灯泡，情况更是如此。因此进行这项工作需要专门的技能。因此我们建议您前往汽车经销商处更换灯泡。\n 2. 在发动机舱工作时要特别小心注意！\n 灯泡是有压力的，更换时有可能爆炸——注意伤害危险！",
        @"指示灯含义：\n 远光灯已接通或远光灯变光功能已操作。\n\n处理方法：\n 如果通过操作远光开关，该等能够正常熄灭，属于正常设计范畴如果不能通过开关进行控制，需到品牌经销商处进行检修。\n\n汽车小贴士：\n 1. 大灯调节得过高和不恰当地使用远光灯可能转移其它交通参与者的注意力和导致眩目，从而导致事故和受伤。\n 2. 请确保大灯始终调节正确。\n 3. 如果可能给其它交通参与者造成眩目，绝对不能使用远光灯或远光灯变光功能。",
        @"指示灯含义：\n 后雾灯已经开启。\n\n处理方法：\n 1. 如果通过操作开关，该等能够正常熄灭，属于正常设计范畴。\n 2. 如果不能通过开关进行控制，需到品牌经销商处进行检修。\n\n汽车小贴士：\n 为了您和他人的安全，建议您在雾雨天气开启雾灯。",
        @"指示灯含义：\n 未系安全带指示灯。\n 1. 前排驾驶位或副驾驶位置都坐有乘客时，未系上安全带。\n 2. 副驾驶员座椅上放有物品。\n\n处理方法：\n 1. 系上安全带。\n 2. 将物品从副驾驶员座椅上取下并可靠存放。\n\n汽车小贴士：\n 1. 如果开始行驶且车速超过 25 km/h（15 mph）时没有系上安全带，或在行驶期间松开安全带，则会发出一个声音信号。此外安全带警告灯*也会闪烁。\n 2. 当驾驶员和副驾驶员在点火开关已打开的情况下系好安全带时，安全带警告灯才会熄灭。",
        @"指示灯含义：\n 安全气囊系统故障。\n\n处理方法：\n 请及时联系品牌经销商进行检修。\n\n汽车小贴士：\n 切勿仅仅依靠安全气囊系统来保护自己 \n 1. 即使是触发了安全气囊，它也只能提供辅助性的防护功能。\n 2. 安全气囊系统与已正确系上的安全带配合提供最佳保护效果并减小受伤的风险。\n 3. 每位乘员在每次行驶前都必须采取正确的坐姿，正确系上自己座位的安全带，而且在行驶过程中保持正确系好安全带。此要求适用于所有乘员。",
        @"指示灯含义：\n 1. 冷却液温度过高。\n 2. 冷却液液位过低：停车让发动机冷却。检查冷却液液位。\n\n处理方法：\n 1. 冷却液温度过高\n首先观察冷却液温度表的温度计数，若指针偏向表盘右端，表明冷却液温度过高，应立即停车，关闭发动机，检查冷却液液位 。若冷却液液位正常，系统过热可能是散热器风扇故障导致的，请联系经销商检修。\n 2. 冷却液液位偏低\n首先观察冷却液温度表的温度读数，若指针处于表盘正常范围内，则尽早添加冷却液。\n\n汽车小贴士：\n 发动机达到暖态或热态时冷却液系统处于高压状态！此时切不可拧开膨胀罐盖，否则，可能被高温蒸汽烫伤。",
        @"指示灯含义：\n 请勿继续行驶！\n发动机机油压力过低，请关闭发动机，然后检查发动机机油油。\n\n处理方法：\n 1. 不要继续行驶！关闭发动机。检查发动机机油油位。\n 2. 如果尽管发动机机油油位正常，但警告灯闪烁，不要继续行驶或让发动机运转。否则会损坏发动机。请让经销商专业人员处理。\n\n汽车小贴士：\n 1. 发动机机油在发动机运转时会变得特别热，可能严重烫伤皮肤。务必让发动机冷却。\n 2. 发动机机油有毒，必须保存在儿童的接触范围之外。\n 3. 发动机机油只可保存在封闭的原装容器中。此规定也适用于废弃处理之前的废机油。\n 4. 切勿用空食品盒、瓶子和其它容器保存发动机机油，否则可能会误导他人喝下其中的发动机机油。",
        @"指示灯含义：\n 请勿继续行驶！\n行李厢盖已打开或未正确关闭。\n\n处理方法：\n 请打开行李厢盖然后重新关闭。\n 1. 如果行李厢盖已打开或未正确关闭，则显示屏上的警告灯会亮起。\n 2. 视汽车装备而定，可能在显示屏上显示一个符号来代替警告灯。显示在点火开关已关闭的情况下也能看到。在汽车上锁后，显示在约 15 秒钟后熄灭。\n\n汽车小贴士：\n 1. 关闭行李厢盖时切勿疏忽大意。否则可能会给您自己或他人造成严重伤害！要确保在行李厢盖的转动范围内没有人。\n 2. 打开行李厢盖时没有固定好的松散物品可能会掉落出来造成人身伤害。",
        @"指示灯含义：\n 发电机本身或线路有故障。\n\n处理方法：\n 1. 打开点火开关时警告灯亮起，发动机启动运转时该警告灯应熄灭。\n行驶时若警告灯亮起，表明发电机不再对蓄电池充电，遇此情况，应尽快驾车到就近的经销商进行检修。\n 2. 途中若无绝对需要，尽可能不要使用电气设备，否则，蓄电池将快速放电。此外，显示屏可能显示相关文本信息，提示或警告驾驶员需立即执行相关操作。\n\n汽车小贴士：\n 1. 忽视亮起的警告灯和文字信息会导致在道路交通中抛锚，引起事故和受伤。\n 2. 一旦道路条件允许且安全，就立即停车。",
        @"指示灯含义：\n 定速巡航系统已开启。\n\n处理方法：\n 该系统可在约20 km/h 以上的车速进行设置使汽车以设定的车速恒速行驶。一旦达到所需车速，并设定存储后，驾驶员即可将脚抬离油门踏板，汽车将以设定的车速恒定行驶。\n\n汽车小贴士：\n 1. 配备自动变速箱的汽车：选档杆位于P, N 或R 档时，定速巡航系统不起作用。\n 2. 打开定速巡航系统时仪表内的指示灯随之点亮，但这不一定表明任何情况下定速巡航系统均能正常控制车速。\n 3. 下坡行驶时，定速巡航系统不能使汽车保持一个恒定的车速。汽车根据自身的重量而加速。",
        @"指示灯含义：\n 电子驻车制动器已接通。\n\n处理方法：\n 1. 关闭电子驻车制动器。\n 接通点火开关，按压按钮同时用力踩下制动踏板或在发动机运转时略微踩下油门踏板，按钮中的指示灯和组合仪表中的指示灯 熄灭 。\n 2. 起步时自动关闭电子驻车制动器。\n 起步时在驾驶员侧车门已关闭且驾驶员已系好安全带时，电子驻车制动器自动关闭。对于手动变速箱，在起步前还必须将离合器完全踩到底，以便系统识别并松开驻车制动器。\n\n汽车小贴士：\n 1. 除在紧急情况下，切勿将电子驻车制动器用于本车的制动。否则因为只对后车轮进行制动，制动距离会大大变长。务必使用脚制动器。\n 2. 切勿在已挂入行驶档或已挂入档位且发动机运转的情况下从发动机舱内给油。本车在已挂入电子驻车制动器的情况下也可能移动。",
        @"指示灯含义：\n 车窗玻璃清洗液罐中的液位过低。\n\n处理方法：\n 请及时给车窗玻璃清洗液储液罐添加清洗液。\n\n汽车小贴士：\n 1. 如果在车窗玻璃刮水器已在接通的情况下关闭点火开关，则车窗玻璃刮水器在重新打开点火开关时在相同的刮水档中继续刮水。在车窗玻璃或后窗玻璃上有霜、雪和其它障碍物时，可能导致车窗玻璃刮水器和车窗玻璃刮水器马达损坏。\n 2. 车窗玻璃刮水器只在点火开关已打开且发动机舱盖或行李厢盖已关闭的情况下工作。\n 3. 车窗玻璃的间歇刮水根据车速进行变化。车速越快，车窗玻璃刮水器就越频繁地刮水。",
        @"指示灯含义：\n 请勿继续行驶！\n至少有一扇车门开着或未正确关闭。\n\n处理方法：\n 请打开相应的车门并重新关闭。\n 如果一个车门已打开或未正确关闭，则显示屏上的警告灯会亮起。视汽车装备而定，可能在显示屏上显示一个符号来代替警告灯。显示在点火开关已关闭的情况下也能看到。\n\n汽车小贴士：\n 1. 未正确关好的车门可能会自行开启，可能导致人身伤害和交通事故！\n 2. 关闭车门时切勿疏忽大意。否则可能会给您自己或他人造成严重的人身伤害！每次关闭车门时都要确保车门的转动范围内没有人。",
        @"指示灯含义：\n 保养周期指示器，不影响行驶，提醒功能。\n\n处理方法：\n 服务保养周期指示器。\n 1.	参阅汽车使用说明书进行手动复位。\n 2. 在品牌经销商电脑使用电脑检测设备进行电脑复位。\n\n汽车小贴士：\n 参照保养规定执行。\n 1. 请勿在保养周期之间将该显示复位，否则显示会出错。\n 2. 如果较长时间地把汽车蓄电池断开，则可能无法正确计算下次保养到期日的时间。",
        @"指示灯含义：\n 尾气排放控制系统有故障。\n\n处理方法：\n 联系品牌经销商，咨询具体情况，如可以继续行驶，请低速小心驾驶。\n\n汽车小贴士：\n 排气装置的部件可能会很热。于是可能引起火灾。\n 1. 不要让排气装置部件接触到汽车下的易燃物质（例如干草）。\n 2. 切勿在排气管、尾气催化净化器、隔热板上使用附加的底部保护层或防腐材料。",
        @"指示灯含义：\n 闪烁：电子稳定系统（ESP）正在调节或牵引力控制系统（ASR）已闭。\n\n处理方法：\n 将脚从油门踏板上抬起。使驾驶方式与道路状况相匹配。\n\n汽车小贴士：\n 1. 制动辅助系统不能超越物理规律的限制。即使有 ESP 和其它系统，光滑和潮湿的道路仍旧有很大的危险。\n 2. 汽车的改装和更改会影响 ABS、HBA、EDS 和 ESP 的功能。\n 3. 更改汽车悬架或使用未许可的车轮和轮胎组合会影响 ABS、HBA、EDS 和 ESP 的功能，以及降低它们的效果\n 4. ESP 的效果同样由合适的轮胎确定。",
        @"指示灯含义：\n 牵引力控制系统（ASR）已手动关闭。\n\n处理方法：\n 接通牵引力控制系统（ASR）。\n通过接通和关闭开关接通牵引力控制系统（ASR）。\n\n汽车小贴士：\n 牵引力控制系统（ASR）可以在发动机运行时通过按压按钮关闭。在达不到足够的牵引力的情况下，遇到例如以下情况时可关闭 ASR：\n 1. 在深雪中或在松软的路面上行车时。\n 2. 在汽车“摆脱卡陷”时。\n 接着要通过按压按钮重新接通 ASR。",
        @"指示灯含义：\n 防抱死制动系统（ABS）有故障。\n\n处理方法：\n 谨慎驾驶，请及时到品牌经销商处进行检修。\n\n汽车小贴士：\n 1. 如果制动装置警告灯与 ABS 指示灯 一起亮起，则说明 ABS 的调节功能可能已失灵。于是在制动时后车轮可能较快抱死。抱死的后车轮可能导致失去对汽车的控制！如果可行，则降低车速并小心地以较低车速行驶到最近的汽车经销商，让其检查制动装置。在前往途中要避免紧急制动。\n 2. 如果 ABS 指示灯不熄灭或在行驶过程中亮起，则 ABS 未正确工作。只能通过正常制动使本车停车（无 ABS 功能）。于是没有 ABS 提供的保护作用。请尽快到汽车经销商检修。",
        @"指示灯含义：\n 发动机控制系统有故障。\n\n处理方法：\n 尽快到汽车经销商检测发动机控制系统及其部件。\n\n汽车小贴士：\n 1. 如果EPC指示灯点亮，需要考虑到发动机故障、耗油量提高以及发动机功率下降。\n 2. 如果在行驶期间发生失火（缺缸）、功率下降或发动机运转不平稳，要立即降低车速，并让汽车经销商检测汽车。",
        @"指示灯含义：\n 驻车制动装置故障。\n\n处理方法：\n 谨慎驾驶，请及时到品牌经销商处进行检修。\n\n汽车小贴士：\n 1. 过热的制动器会降低制动效果和显著延长制动距离。\n 2. 在下坡上行驶时制动器的负荷特别高，并且会很快过热。\n 3. 在驶过较长的陡下坡之前要降低车速，挂入某个较低的档位。这样可以充分利用发动机制动并减轻制动器负荷。\n 4. 非标配的或损坏的前扰流板可能影响制动器的通风，并导致制动器过热。",
        @"指示灯含义：\n 请踩下制动踏板。\n\n处理方法：\n 将制动踏板完全踩到底。\n\n汽车小贴士：\n 起步辅助系统的智能技术不能超越物理规律的限制。切勿凭借起步辅助系统提高了舒适性而冒险行驶。\n 1. 汽车意外移动可能导致受伤。\n 2. 起步辅助系统不能代替驾驶员的注意力。\n 3. 要使车速和驾驶方式始终与能见度、天气情况、路面状况和交通状况相匹配。\n 4. 起步辅助系统并非在任何情况下都能将汽车保持在上坡路面上或制动在下坡路段上（例如在光滑或结冰的地面上）。",
        nil];
    
    NSArray *array = [[NSArray alloc] init];
    
    if ([carBrand isEqualToString:@"Wagen"])
        array = bookWagenContentArray;
    
    return  array;
}

+ (NSString *)getCarBrandImage :(NSString *)carBrand
{
    NSMutableString *imgFile = [NSMutableString string];
    [imgFile appendString:@"btnMenu"];
    
    /*if ([carBrand isEqualToString:@"Wagen"]) {
        [imgFile appendString:@"Wagen.png"];
        return imgFile;
    }*/
    
    [imgFile appendFormat:@"%@.png", carBrand];
    return imgFile;
}

+ (NSArray *)getCarBrandArray
{
    NSArray *array = [[NSArray alloc] initWithObjects:@"GMC", @"MG", @"MINI", @"Smart", @"一汽", @"三菱", @"世爵", @"东南", @"东风", @"东风风神", @"中兴", @"中华", @"中客华北", @"中欧", @"中顺", @"丰田", @"五菱", @"众泰", @"依维柯", @"保时捷", @"光冈", @"克莱斯勒", @"全球鹰", @"兰博基尼", @"凯迪拉克", @"别克", @"力帆", @"劳斯莱斯", @"北京汽车", @"北汽制造", @"华普", @"华泰", @"双环", @"双龙", @"吉奥", @"吉普", @"哈飞", @"大众", @"大迪", @"天马", @"奇瑞", @"奔腾", @"奔驰", @"奥迪", @"威旺", @"威麟", @"宝马", @"宝骏", @"宝龙", @"宾利", @"富奇", @"布嘉迪", @"帝豪", @"广汽", @"广汽日野", @"庆铃", @"开瑞", @"悍马", @"捷豹", @"斯巴鲁", @"斯柯达", @"新大地", @"日产", @"昌河", @"本田", @"林肯", @"柯尼赛格", @"标致", @"欧宝", @"比亚迪", @"永源", @"汇众", @"江南", @"江淮", @"江铃", @"沃尔沃", @"法拉利", @"海格", @"海马", @"海马商用车", @"玛莎拉蒂", @"现代", @"理念", @"瑞麒", @"福特", @"福田", @"福迪", @"红旗", @"纳智捷", @"美亚", @"航天圆通", @"英伦", @"英菲尼迪", @"荣威", @"莲花", @"菲亚特", @"萨博", @"蓝旗亚", @"西雅特", @"讴歌", @"起亚", @"路特斯", @"路虎", @"迈巴赫", @"道奇", @"野马", @"金旅客车", @"金杯", @"金龙联合", @"铃木", @"长丰", @"长城", @"长安商用车", @"长安微车", @"长安轿车", @"阿尔法·罗米欧", @"阿斯顿·马丁", @"陆风", @"雪佛兰", @"雪铁龙", @"雷克萨斯", @"雷诺", @"风行", @"马自达", @"黄海", nil];
    
    return  array;
}

+ (NSArray *)getCarProvinceArray
{
    NSArray *array = [[NSArray alloc] initWithObjects:@"京", @"津", @"冀", @"晋", @"蒙", @"辽", @"吉", @"黑", @"沪", @"苏", @"浙", @"皖", @"闽", @"赣", @"鲁", @"豫", @"鄂", @"湘", @"粤", @"桂", @"琼", @"渝", @"川", @"贵", @"云", @"藏", @"陕", @"甘", @"青", @"宁", @"新", @"台", @"4", nil];
    return  array;
}

+ (NSArray *)getCarCityArray
{
    NSArray *array = [[NSArray alloc] initWithObjects:@"A", @"B",@"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    return  array;
}

+ (NSArray *)getCarNumberArray
{
    NSArray *array = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B",@"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    return  array;
}


@end
