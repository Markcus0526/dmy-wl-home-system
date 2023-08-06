//
//  FaqViewController.h
//  wljy
//
//  Created by 111 on 14.01.16.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetController.h"
#import "AppDelegate.h"

@interface FaqCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *rewardIntegralLabel;
@property (nonatomic, strong) IBOutlet UILabel *answerCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;

@end

@interface FaqViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *faqs;
    
    AppDelegate* appDelegate;
    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int type;
@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, assign, readwrite) int maxIntegral;

@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIButton *allButton;
@property (nonatomic, strong) IBOutlet UIButton *majorButton;
@property (nonatomic, strong) IBOutlet UIButton *enterpriseButton;
@property (nonatomic, strong) IBOutlet UIButton *otherButton;
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
