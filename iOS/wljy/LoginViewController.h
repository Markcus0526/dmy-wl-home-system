//
//  ViewController.h
//  wljy
//
//  Created by 111 on 14.01.14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetController.h"
#import "AppDelegate.h"


@interface LoginViewController : UIViewController <UITabBarControllerDelegate> {
    UITextField *activeField;
    CGRect originRect;
    
    NSNumber *userPrivilege;
    NSNumber *userid;
    NSString *username;
    NSNumber *userIntegral;
    NSString *lastLoginDate;
    
    AppDelegate *appDelegate;

    
    GetController *getController;
}

@property(nonatomic, strong) IBOutlet UIView *viewNamePass;
@property(nonatomic, strong) IBOutlet UITextField *password;
@property(nonatomic, strong) IBOutlet UITextField *yourname;

@property(nonatomic, strong) IBOutlet UIImageView *backImageView;

@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;

- (void)registerNotifications;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
- (IBAction)LoginProcess:(id)sender;
- (void)connectionComplete:(NSNotification*)aNotification;

@end

