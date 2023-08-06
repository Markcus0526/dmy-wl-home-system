//
//  MemberEditViewController.h
//  wljy
//
//  Created by Hercules on 4/11/14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PostController.h"

#define kNickname   @"nickname"
#define kTel        @"phonenum"

@interface MemberEditViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    id activeText;
    AppDelegate* appDelegate;
    PostController *postController;
}

@property(nonatomic, readwrite) NSString *editType;

@property (nonatomic, strong) IBOutlet UILabel *editTitle;
@property (nonatomic, strong) IBOutlet UITextField *nicknameOrTel;
@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIButton * postButton;

- (IBAction)onPost:(id)sender;

- (void)postToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
