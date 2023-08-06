//
//  AnswerViewController.h
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface AnswerCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *evalLabel;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;
@property (nonatomic, strong) IBOutlet UIImageView *backImageView;
@property (nonatomic, strong) IBOutlet UIImageView *backImageView1;
@property (nonatomic, strong) IBOutlet UIImageView *backImageView2;
@property (nonatomic, strong) IBOutlet UIImageView *backImageView3;
@property (nonatomic, strong) IBOutlet UIImageView *backImageView4;

@end

@interface AnswerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *answers;
    NSMutableArray *heightDiffs;
    UILabel *testLabel;
    
    AppDelegate* appDelegate;    
    GetController *getController;    
}

@property (nonatomic, readwrite) NSString *pageClass;
@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, readwrite) UIViewController *previousViewController;

@property (nonatomic, assign, readwrite) int itemId;

@property (nonatomic, strong) IBOutlet UILabel *viewTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *tableViewTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;
@property (nonatomic, strong) IBOutlet UIView *tableHeaderView;

- (IBAction)onBack:(id)sender;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
