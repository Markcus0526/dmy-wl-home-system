//
//  StudyViewController.h
//  wljy
//
//  Created by 111 on 14.01.16.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface StudyCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *readCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *answerCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;

@end

@interface StudyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *studies;
    
    AppDelegate* appDelegate;
    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int type;
@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIButton *allButton;
@property (nonatomic, strong) IBOutlet UIButton *majorButton;
@property (nonatomic, strong) IBOutlet UIButton *enterpriseButton;
@property (nonatomic, strong) IBOutlet UIButton *otherButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onSubtitle:(id)sender;
- (void)clearSelection;
- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
