//
//  PostExchangeViewController.h
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"
#import "PostController.h"

@interface MyCartCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *marketPriceLabel;
@property (nonatomic, strong) IBOutlet UILabel *integralPriceLabel;
@property (nonatomic, strong) IBOutlet UIButton *selectButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;

@end

@interface MyCartButtonCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *selectAllButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteAllButton;
@property (nonatomic, strong) IBOutlet UIButton *exchangeButton;

@end

@interface PostExchangeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *myCarts;
    
    AppDelegate* appDelegate;    
    GetController *getController;
    PostController *postController;
}

@property (nonatomic, readwrite) UIViewController *previousViewController;

@property (nonatomic, readwrite) NSMutableArray *selectedArray;
@property (nonatomic, readwrite) int selectedId;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onBack:(id)sender;


- (IBAction)onSelectAll:(id)sender;
- (IBAction)onPost:(id)sender;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionCompleteForGet:(NSNotification*)aNotification;

- (void)postToServer:(NSInteger)delId;
- (void)connectionCompleteForPost:(NSNotification*)aNotification;

@end
