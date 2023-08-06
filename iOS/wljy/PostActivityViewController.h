//
//  PostActivityViewController.h
//  wljy
//
//  Created by 111 on 14.03.06.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PostController.h"
#import "FDTakeController.h"

@interface PostActivityViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, FDTakeDelegate> {
    id activeText;
    AppDelegate* appDelegate;    
    PostController *postController;
    
    NSMutableArray *attachArray;
    UIButton *curAttachButton;
    
    BOOL isPickerDisapeared;
}

@property (nonatomic, strong) IBOutlet UIViewController *previousViewController;

@property (nonatomic, strong) IBOutlet UITextField *titleText;
@property (nonatomic, strong) IBOutlet UITextView *bodyText;
@property (nonatomic, strong) IBOutlet UIView *bodyFrame;
@property (nonatomic, strong) IBOutlet UITextField *startdateText;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIButton * postButton;

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
