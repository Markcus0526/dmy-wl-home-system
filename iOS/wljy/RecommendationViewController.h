//
//  RecommendationViewController.h
//  wljy
//
//  Created by 111 on 14.01.14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetController.h"
#import "AppDelegate.h"
#import "MyInfoView.h"

@interface RecommendCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;

@end

@interface RecommendationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate> {
    NSMutableArray *recommends;
    
    AppDelegate *appDelegate;    
    GetController *getController;
}

@property(nonatomic, strong) IBOutlet UIImageView *userImageView;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UITabBar *tabBar;

@property (nonatomic, strong) IBOutlet UIView *mainView;
@property (nonatomic, strong) IBOutlet UIView *navigatorView;
@property (nonatomic, strong) IBOutlet UIView *maskView;
@property (nonatomic, strong) IBOutlet MyInfoView *myInfoView;
@property (nonatomic, readwrite) BOOL isNavigatorShown;
@property (nonatomic, readwrite) int feedbackBadge;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;


- (IBAction)onNavigate:(id)sender;
- (IBAction)onNavCancel:(id)sender;
- (IBAction)onMyInfo:(id)sender;

@end
