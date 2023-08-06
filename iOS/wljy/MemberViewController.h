//
//  MemberViewController.h
//  wljy
//
//  Created by 111 on 14.01.21.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetController.h"
#import "AppDelegate.h"
#import "FDTakeController.h"

@interface MemberViewController : UIViewController <FDTakeDelegate>{
    AppDelegate *appDelegate;
    GetController *getController;
    
    BOOL isPickerDisappeared;
}

@property(nonatomic, strong) IBOutlet UIImageView *userImageView;

@property(nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property(nonatomic, strong) IBOutlet UILabel *nickNameLabel;
@property(nonatomic, strong) IBOutlet UILabel *phoneNumberLabel;
@property(nonatomic, strong) IBOutlet UILabel *integralLabel;

@property(nonatomic, strong) IBOutlet UIImageView *backImageView;

@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;

@property (nonatomic, strong) FDTakeController *takeController;
@property (nonatomic, readwrite) UIImage * selectedimg;

- (void)registerNotifications;
- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
