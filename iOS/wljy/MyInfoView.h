//
//  MyInfoView.h
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class RecommendationViewController;

@interface MyInfoView : UIView {
    AppDelegate *appDelegate;
}

@property(nonatomic, readwrite) RecommendationViewController *currentViewController;

@property(nonatomic, strong) IBOutlet UIImageView *userImageView;

@property(nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property(nonatomic, strong) IBOutlet UILabel *propertyLabel;
@property(nonatomic, strong) IBOutlet UILabel *lastLoginDateLabel;
@property(nonatomic, strong) IBOutlet UILabel *textCollectionCountLabel;
@property(nonatomic, strong) IBOutlet UILabel *imageCollectionCountLabel;
@property(nonatomic, strong) IBOutlet UIButton *feedbackBadgeButton;

@property(nonatomic, strong) IBOutlet UIImageView *backImageView;

- (IBAction)onNavigate:(id)sender;

- (void)applyBackgroundSettings;

@end
