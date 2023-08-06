//
//  ActivityInfoViewController.h
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

#define kMinGestureLength   80
#define kMaxVariance        10

@interface ActivityInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    
    AppDelegate* appDelegate;    
    GetController *getController;
    
    CGPoint gestureStartPoint;
    
    NSArray *imageArray;
}

@property (nonatomic, assign, readwrite) int itemId;

@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *postdateLabel;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, strong) IBOutlet UIButton *evalCountButton;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIView *swipeView;
@property (nonatomic, strong) IBOutlet UIView *navigateView;

//- (IBAction)onPost:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onShowAllEval:(id)sender;
- (void)onShowSingle;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

- (IBAction)onNavigate:(id)sender;

@end
