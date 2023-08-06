//
//  MyCollectionViewController.h
//  wljy
//
//  Created by 111 on 14.01.26.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface MyCollectionCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *pageClassLabel;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;

@end

@interface MyCollectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *mycollections;
    
    AppDelegate* appDelegate;    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onPost:(id)sender;
- (IBAction)onBack:(id)sender;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
