//
//  PostShareViewController.h
//  wljy
//
//  Created by 111 on 14.01.23.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PostController.h"
#import "FDTakeController.h"

@interface PostShareViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, FDTakeDelegate> {
    id activeText;
    AppDelegate* appDelegate;
    
    PostController *postController;
    
    NSMutableArray *attachArray;
    UIButton *curAttachButton;
    
    BOOL isPickerDisapeared;
}

@property (nonatomic, strong) IBOutlet UIViewController *previousViewController;

@property (nonatomic, readwrite) int type;
@property (nonatomic, strong) IBOutlet UITextField *titleText;
@property (nonatomic, strong) IBOutlet UITextView *bodyText;
@property (nonatomic, strong) IBOutlet UIView *bodyFrame;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIButton * postButton;
@property (nonatomic, strong) IBOutlet UIButton *typeAButton;
@property (nonatomic, strong) IBOutlet UIButton *typeBButton;
@property (nonatomic, strong) IBOutlet UIButton *typeCButton;

@property (nonatomic, strong) IBOutlet UIButton *attachButton1;
@property (nonatomic, strong) IBOutlet UIButton *attachButton2;
@property (nonatomic, strong) IBOutlet UIButton *attachButton3;

@property (nonatomic, strong) FDTakeController *takeController;
@property (nonatomic, readwrite) UIImage * selectedimg;

- (IBAction)onBack:(id)sender;

- (IBAction)onAttachFile:(id)sender;
- (IBAction)onPost:(id)sender;

- (void)postToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
