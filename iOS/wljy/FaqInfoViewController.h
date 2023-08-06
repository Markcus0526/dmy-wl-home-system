//
//  FaqInfoViewController.h
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"
#import "PostController.h"

@interface FaqInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    NSMutableDictionary *imagepathes;
    
    AppDelegate* appDelegate;    
    GetController *getController;
    PostController *postController;
}

@property (nonatomic, readwrite) NSString *pageClass;
@property (nonatomic, assign, readwrite) int itemId;

@property (nonatomic, assign, readwrite) int evalUpDown;

@property (nonatomic, strong) IBOutlet UILabel *viewTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *integralTitleLabel;
@property (nonatomic, strong) IBOutlet UIButton *allAnswerButton;
@property (nonatomic, strong) IBOutlet UILabel *recentAnswerLabel;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *providerNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *integralLabel;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;
@property (nonatomic, strong) IBOutlet UILabel *postdateLabel;
@property (nonatomic, strong) IBOutlet UILabel *answerCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *typeLabel;
@property (nonatomic, strong) IBOutlet UILabel *readCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *answerEvalLabel;

@property (nonatomic, strong) IBOutlet UIButton *evalUpButton;
@property (nonatomic, strong) IBOutlet UIButton *evalDownButton;

@property (nonatomic, strong) IBOutlet UIImageView *answererImageView;
@property (nonatomic, strong) IBOutlet UILabel *answererNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *answerDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *answerBodyLabel;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *middleView;
@property (nonatomic, strong) IBOutlet UIView *bottomView;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImageView;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImageView1;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImageView2;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImageView3;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImageView4;

@property (nonatomic, strong) IBOutlet UIButton *postButton;

- (IBAction)onPost:(id)sender;
- (IBAction)onEvalUpDown:(id)sender;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionCompleteForGet:(NSNotification*)aNotification;


- (void)postToServer:(NSInteger)evaltype;
- (void)connectionCompleteForPost:(NSNotification*)aNotification;

- (IBAction)onAllAnswer:(id)sender;

@end
