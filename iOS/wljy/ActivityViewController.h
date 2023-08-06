//
//  ActivityViewController.h
//  wljy
//
//  Created by 111 on 14.01.14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetController.h"
#import "AppDelegate.h"

@interface ActivityCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;
@property (nonatomic, strong) IBOutlet UILabel *evalCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *readCountLabel;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;

@end

@interface SingleCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *evalCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *readCountLabel;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView1;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView2;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView3;

@end

@interface ActivityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *activities;
    
    AppDelegate* appDelegate;    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int type;
@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *singleButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onPost:(id)sender;

- (IBAction)onSubtitle:(id)sender;
- (void)clearSelection;
- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
