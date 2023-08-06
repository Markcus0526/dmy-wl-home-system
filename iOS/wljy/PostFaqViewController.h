//
//  PostFaqViewController.h
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PostController.h"

@interface PostFaqViewController  : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    id activeText;
    AppDelegate* appDelegate;
    CGRect originRect;
    CGRect endFrameRect;
    
    PostController *postController;
}

@property (nonatomic, readwrite) UIViewController *previousViewController;

@property (nonatomic, assign, readwrite) int maxIntegral;

@property (nonatomic, readwrite) int type;
@property (nonatomic, strong) IBOutlet UILabel *maxIntegralLabel;

@property (nonatomic, strong) IBOutlet UITextField *titleText;
@property (nonatomic, strong) IBOutlet UITextField *integralText;
@property (nonatomic, strong) IBOutlet UITextView *bodyText;
@property (nonatomic, strong) IBOutlet UIView *bodyFrame;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIButton * postButton;
@property (nonatomic, strong) IBOutlet UIButton * majorButton;
@property (nonatomic, strong) IBOutlet UIButton * enterpriseButton;
@property (nonatomic, strong) IBOutlet UIButton * otherButton;

- (IBAction)onBack:(id)sender;

- (IBAction)onType:(id)sender;
- (IBAction)onPost:(id)sender;

- (void)postToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
