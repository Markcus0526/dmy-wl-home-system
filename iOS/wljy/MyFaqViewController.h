//
//  MyQuestionViewController.h
//  wljy
//
//  Created by 111 on 14.01.21.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface MyFaqCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *readCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *answerCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *providerNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *answererNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;

@end

@interface MyFaqViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *myFaqs;
    
    AppDelegate* appDelegate;    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, assign, readwrite) int maxIntegral;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onPost:(id)sender;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;


@end
