//
//  ChangePasswdViewController.h
//  wljy
//
//  Created by 111 on 14.03.06.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PostController.h"

@interface ChangePasswdViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    id activeText;
    AppDelegate* appDelegate;    
    PostController *postController;
}

@property (nonatomic, strong) IBOutlet UITextField *oldPassword;
@property (nonatomic, strong) IBOutlet UITextField *validPassword;
@property (nonatomic, strong) IBOutlet UITextField *mynewPassword;
@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIButton * postButton;

- (IBAction)onPost:(id)sender;

- (void)postToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
