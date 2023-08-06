//
//  ExchangeImageViewController.h
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ExchangeImageViewController : UIViewController {
    AppDelegate *appDelegate;
}

@property (nonatomic, readwrite) NSString *productTitle;
@property (nonatomic, readwrite) NSArray *imagepaths;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *todayLabel;
@property (nonatomic, strong) IBOutlet UIImageView *mainImageView;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView1;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView2;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView3;
@property (nonatomic, strong) IBOutlet UIImageView *dataImageView4;

@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *subScrollView;

@end
