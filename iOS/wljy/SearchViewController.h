//
//  SearchViewController.h
//  wljy
//
//  Created by 111 on 14.01.23.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface SearchCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *pageClassLabel;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;

@end

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *results;
    
    AppDelegate* appDelegate;
    NSMutableDictionary *imageRequests;
    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, strong, readwrite) NSString *searchText;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UISearchBar *mySearchBar;
//@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (void)postToServer;
- (void)connectionComplete:(NSNotification*)aNotification;

@end
