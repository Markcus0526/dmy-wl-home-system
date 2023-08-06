//
//  AppDelegate.h
//  wljy
//
//  Created by 111 on 14.01.14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDayNightMode @"dayNight"
#define kBlackWhiteMode @"blackWhite"

#define kShowMode @"ShowMode"

#define kDayMode    0
#define kNightMode  1
#define kBlackMode  2
#define kWhiteMode  3

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIStoryboard *storyboard;
@property (strong, nonatomic) UIViewController *currentViewController;

@property (nonatomic, assign) int userid;
@property (nonatomic, assign) int userPrivilege;
@property (nonatomic, readwrite) NSString *username;
@property (nonatomic, assign) int userIntegral;
@property (nonatomic, readwrite) NSString *lastLoginDate;
@property (nonatomic, readwrite) NSString *imagepath;

@property (nonatomic, assign) BOOL dayNightMode;
@property (nonatomic, assign) BOOL blackWhiteMode;

@property (nonatomic, assign) NSInteger showMode;

//- (void)decorateTabBar;
- (void) setAccountInfo : (int)user privilege:(int)privilege name:(NSString*)name integral:(int)integral lastLoginDate:(NSString*)loginDate photo:(NSString*)imagepath;
- (NSString*)dayOfWeekString:(int)dayOfWeek;
- (NSString*)getTodayDate;
- (BOOL)isMorning;
+ (NSInteger)phoneType;

- (void)getSettingsInfo;
- (void)setSettingsInfo;

@end
