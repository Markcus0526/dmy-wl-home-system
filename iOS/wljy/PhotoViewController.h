//
//  PhotoViewController.h
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GetController.h"

@interface PhotoViewController : UIViewController {    
    AppDelegate* appDelegate;
    GetController *getController;
}

@property (nonatomic, assign, readwrite) int itemId;

@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView * loadingIndicator;

//@property (nonatomic, readwrite) NSString *infoString;
//@property (nonatomic, readwrite) NSString *imagePath;

@property (nonatomic, strong) IBOutlet UIImageView *dataImageView;
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;

- (IBAction)onPost:(id)sender;

@end
