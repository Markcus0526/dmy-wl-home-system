//
//  MyFeedbackViewController.h
//  wljy
//
//  Created by 111 on 14.03.06.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface MyFeedbackCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *rewardIntegralLabel;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;

@end

@interface MyFeedbackViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *myfeedbacks;
    NSMutableArray *heightDiffs;
    UILabel *testLabel;
    
    AppDelegate* appDelegate;    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int type;
@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIButton *allButton;
@property (nonatomic, strong) IBOutlet UIButton *passedButton;
@property (nonatomic, strong) IBOutlet UIButton *unpassedButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onSubtitle:(id)sender;
- (void)clearSelection;
- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
