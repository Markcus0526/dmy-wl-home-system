//
//  MyExchangeViewController.h
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface MyExchangeCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *marketPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *integralPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *stateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;

@end

@interface MyExchangeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *myExchanges;
    
    AppDelegate* appDelegate;    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onPost:(id)sender;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;


@end
