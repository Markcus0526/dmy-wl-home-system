//
//  Common.h
//  4S-C
//
//  Created by R CJ on 1/5/13.
//  Copyright (c) 2013 PIC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define MOVE_FROM_RIGHT     CATransition *animation = [CATransition animation]; \
                            [animation setDuration:0.3]; \
                            [animation setType:kCATransitionPush]; \
                            [animation setSubtype:kCATransitionFromRight]; \
                            [animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]]; \
                            [[self.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];

#define MOVE_FROM_LEFT      CATransition *animation = [CATransition animation]; \
                            [animation setDuration:0.3]; \
                            [animation setType:kCATransitionPush]; \
                            [animation setSubtype:kCATransitionFromLeft]; \
                            [animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]]; \
                            [[self.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];

#define SHOW_VIEW(ctrl)     MOVE_FROM_RIGHT \
                            [self presentViewController:ctrl animated:NO completion:nil];

#define BACK_VIEW           MOVE_FROM_LEFT \
                            [self dismissViewControllerAnimated:NO completion:nil];

#define TEST_NETWORK_RETURN if ([CommManager hasConnectivity] == NO) { \
                                [DejalActivityView removeView]; \
                                [AutoMessageBox AutoMsgInView:self.view withText:NSLocalizedString(@"MSG_NO_CONNECTION", nil) withSuccess:FALSE]; \
                                return; \
                            }

#define BACKGROUND_TEST_NETWORK_RETURN    if ([CommManager hasConnectivity] == NO) { \
                                                return; \
                                            }



#define FACEBOOK_APPID			@"664686076915193"/*@"8e1ee50901bebd486473407b9f918ec8"*/
#define FACEBOOK_PERMISSION		@"publish_stream"


typedef NS_ENUM(NSInteger, DEVICE_KIND) {
    IPHONE4= 1,
    IPHONE5,
    IPAD,
};

@interface Common : NSObject {
}

+ (BOOL) isIOSVer7;

+ (void) makeErrorWindow : (NSString *)content TopOffset:(NSInteger)topOffset BottomOffset:(NSInteger)bottomOffset View:(UIView *)view;

+ (void) setDeviceToken : (NSString*)newDeviceToken;
+ (NSString*) deviceToken;

+ (void) setUserInfo : (STUserInfo*)userInfo;
+ (STUserInfo*) userInfo;
+ (NSString*) userId;

+ (void) setReserveInfo : (STCurReserveInfo*)rsrvInfo;
+ (STCurReserveInfo*) reserveInfo;

+ (void) setReserveMode : (NSString*)rsrvMode;


+ (NSString*) getCurTime : (NSString*)fmt;

+ (NSInteger) MAXLENGTH;

+ (NSInteger) phoneType;

+ (NSString *) getCurLang;

+ (NSString *)getRealImagePath :(NSString *)path :(NSString *)rate :(NSString *)size;
+ (NSString *)getBackImagePath :(NSString *)path :(NSString *)rate :(NSString *)size;

+ (NSString*)base64forData:(NSData*)theData;
+ (NSData*)base64forString:(NSString*)theString;

+ (NSString *)appNameAndVersionNumberDisplayString;

+ (NSString *)weatherUrl;
+ (NSArray *)provinceArray;
+ (NSArray *)cityArray :(NSString *)province;
+ (NSString *)getRegionCodeFromCarNumber :(NSString *)carNum;

+ (NSArray *)getBookContentArray :(NSString *)carBrand;

+ (NSString *)getCarBrandImage :(NSString *)carBrand;
+ (NSArray *)getCarBrandArray;

+ (NSArray *)getCarProvinceArray;
+ (NSArray *)getCarCityArray;
+ (NSArray *)getCarNumberArray;


@end
