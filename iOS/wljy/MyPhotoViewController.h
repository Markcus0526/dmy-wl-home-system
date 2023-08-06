//
//  MyPhotoViewController.h
//  wljy
//
//  Created by 111 on 14.01.21.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface MyPhotoCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *dataImageView1;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView2;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView3;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView4;

@property (nonatomic, strong) IBOutlet UIButton *imageButton1;
@property (nonatomic, strong) IBOutlet UIButton *imageButton2;
@property (nonatomic, strong) IBOutlet UIButton *imageButton3;
@property (nonatomic, strong) IBOutlet UIButton *imageButton4;

@end

@interface MyPhotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *myPhotoes;
    
    AppDelegate* appDelegate;    
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int type;
@property (nonatomic, assign, readwrite) int page;
@property (nonatomic, assign, readwrite) BOOL lastArrived;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;

- (IBAction)onPost:(id)sender;

- (void)changeState:(BOOL)isLoaded;

- (void)connectToServer;
- (void)connectionComplete:(NSNotification*)aNotification;


- (IBAction)onSelect:(id)sender;

@end
