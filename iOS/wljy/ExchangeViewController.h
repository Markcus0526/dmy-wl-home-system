//
//  ExchangeViewController.h
//  wljy
//
//  Created by 111 on 14.01.16.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetController.h"
#import "AppDelegate.h"

@interface ExchangeCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UILabel *integralLabel;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;

@end

@interface ExchangeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    NSMutableArray *exchanges;
    
    AppDelegate* appDelegate;    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int type;
@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIButton *type1Button;
@property (nonatomic, strong) IBOutlet UIButton *type2Button;
@property (nonatomic, strong) IBOutlet UIButton *type3Button;
@property (nonatomic, strong) IBOutlet UITableView *tableViewLeft;
@property (nonatomic, strong) IBOutlet UITableView *tableViewRight;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onPost:(id)sender;

- (IBAction)onSubtitle:(id)sender;
- (void)clearSelection;
- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;


- (NSInteger)exchangeIndex:(NSInteger)index tableView:(UITableView*)tableView;

@end
