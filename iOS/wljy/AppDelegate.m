//
//  AppDelegate.m
//  wljy
//
//  Created by 111 on 14.01.14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

@implementation AppDelegate

+ (NSInteger)phoneType
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if ([UIScreen mainScreen].bounds.size.height >= 548) {
            return IPHONE5;
         } else {
            return IPHONE4;
         }
    } else {
         return IPAD;
    }
}

- (void)getSettingsInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.showMode = [defaults integerForKey:kShowMode];
    
    //self.dayNightMode = YES;//[defaults boolForKey:kDayNightMode];
    //self.blackWhiteMode = [defaults boolForKey:kBlackWhiteMode];
    
}

- (void)setSettingsInfo {    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.showMode forKey:kShowMode];
    
    //[defaults setBool:self.dayNightMode forKey:kDayNightMode];
    //[defaults setBool:self.blackWhiteMode forKey:kBlackWhiteMode];
}

- (void) setAccountInfo : (int)user privilege:(int)privilege name:(NSString*)name integral:(int)integral lastLoginDate:(NSString*)loginDate photo:(NSString *)imagepath
{
    self.userid = user;
    self.userPrivilege = privilege;
    self.username = name;
    self.userIntegral = integral;
    self.lastLoginDate = loginDate;
    self.imagepath = imagepath;
}

- (NSString*)dayOfWeekString:(int)dayOfWeek {
    switch (dayOfWeek) {
        case 1:
            return @"星期日";
        case 2:
            return @"星期一";
        case 3:
            return @"星期二";
        case 4:
            return @"星期三";
        case 5:
            return @"星期四";
        case 6:
            return @"星期五";
        case 7:
            return @"星期六";
        default:
            break;
    }
    return @"星期日";
}

- (NSString*)getTodayDate {
    NSDateComponents *nowDate = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%d. %d. %d %@", [nowDate year], [nowDate month], [nowDate day], [self dayOfWeekString:[nowDate weekday]]];
}

- (BOOL)isMorning {
    NSDateComponents *nowDate = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
    
    if(nowDate.hour < 12)
        return YES;
    else
        return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self getSettingsInfo];
    
    self.storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
   
    self.window.rootViewController = [self.storyboard instantiateInitialViewController];
    //self.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Recommendation"];
    
    [self.window makeKeyAndVisible];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //self.window.rootViewController = [self.storyboard instantiateInitialViewController];
    //[self.window makeKeyAndVisible];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
