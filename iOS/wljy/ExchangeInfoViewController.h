//
//  ExchangeInfoViewController.h
//  wljy
//
//  Created by 111 on 14.01.23.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"
#import "PostController.h"

@interface ExchangeInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    NSArray *imagepathes;
    
    AppDelegate* appDelegate;    
    GetController *getController;
    PostController *postController;
}

@property (nonatomic, assign, readwrite) int itemId;
@property (nonatomic, assign, readwrite) int integralPrice;
@property (nonatomic, assign, readwrite) int totalSecure;

@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *marketPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *integralPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *stockCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalExchangeLabel;
@property (nonatomic, strong) IBOutlet UILabel *explainLabel;
@property (nonatomic, strong) IBOutlet UIButton *explainButton;
@property (nonatomic, strong) IBOutlet UIButton *subImagesButton;
@property (nonatomic, strong) IBOutlet UITextField *exchangeCountText;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIView *explainView;
@property (nonatomic, strong) IBOutlet UIView *bottomView;

- (IBAction)onBack:(id)sender;
- (IBAction)onPost:(id)sender;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

- (void)postToServer;
- (void)connectionCompleteForPost:(NSNotification*)aNotification;

- (IBAction)onSubButton:(id)sender;
- (IBAction)onSubImage:(id)sender;
- (IBAction)onPlusMinus:(id)sender;

@end
