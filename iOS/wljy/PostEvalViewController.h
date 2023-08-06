//
//  EvalViewController.h
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PostController.h"

@interface PostEvalViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
    AppDelegate* appDelegate;
    
    PostController *postController;
}

@property (nonatomic, readwrite) UIViewController *previousViewController;

@property (nonatomic, readwrite) NSString * pageClass;
@property (nonatomic, assign, readwrite) int itemId;

@property (nonatomic, strong) IBOutlet UITextView *bodyText;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UIButton * postButton;

- (IBAction)onBack:(id)sender;
- (IBAction)onPost:(id)sender;

- (void)postToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
