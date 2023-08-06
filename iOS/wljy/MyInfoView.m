//
//  MyInfoView.m
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "MyInfoView.h"
#import "RecommendationViewController.h"

@implementation MyInfoView

- (IBAction)onNavigate:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    NSArray *viewName = @[@"Member", @"MyPhoto", @"MyFaq", @"MyExchange", @"MyFeedback", @"Settings", @"MyCollection"];
    UIViewController *viewController = [appDelegate.storyboard instantiateViewControllerWithIdentifier:[viewName objectAtIndex:button.tag]];
    [self.currentViewController presentViewController:viewController animated:YES completion:nil];
    
    [self.currentViewController onNavCancel:nil];
}

- (void)makeFontColorTo:(UIColor*)color {
    NSArray *subviews = [self subviews];
    for(id subview in subviews) {
        if([subview isKindOfClass:[UILabel class]])
            [(UILabel *)subview setTextColor:color];
        else if([subview isKindOfClass:[UIButton class]] && [subview isEqual:self.feedbackBadgeButton] == NO)
            [(UIButton *)subview setTitleColor:color forState:UIControlStateNormal];
    }
}

- (void)applyBackgroundSettings {
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIColor *fontColor;
    
    switch (appDelegate.showMode) {
        case kNightMode:
            [self.backImageView setHidden:NO];
            [self.backImageView setImage:[UIImage imageNamed:@"login_background.png"]];
            fontColor = [UIColor whiteColor];
            break;
        case kBlackMode:
            [self.backImageView setHidden:YES];
            self.backgroundColor = [UIColor darkGrayColor];
            fontColor = [UIColor whiteColor];
            break;
        case kWhiteMode:
            [self.backImageView setHidden:YES];
            self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
            fontColor = [UIColor blackColor];
            break;
        case kDayMode:
        default:
            [self.backImageView setHidden:NO];
            [self.backImageView setImage:[UIImage imageNamed:@"login_background2.png"]];
            fontColor = [UIColor whiteColor];
            break;
    }
    
    /*if(appDelegate.blackWhiteMode) {
        [self.backImageView setHidden:YES];
        if(appDelegate.dayNightMode) {
            if(appDelegate.isMorning) {
                self.backgroundColor = [UIColor darkGrayColor];
                fontColor = [UIColor whiteColor];
            } else {
                self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
                fontColor = [UIColor blackColor];
            }
        } else {
            self.backgroundColor = [UIColor darkGrayColor];
            fontColor = [UIColor whiteColor];            
        }
    } else {
        [self.backImageView setHidden:NO];
        if(appDelegate.dayNightMode) {
            if(appDelegate.isMorning)
                [self.backImageView setImage:[UIImage imageNamed:@"login_background2.png"]];
            else
                [self.backImageView setImage:[UIImage imageNamed:@"login_background.png"]];
        } else {
            [self.backImageView setImage:[UIImage imageNamed:@"login_background.png"]];
        }
        fontColor = [UIColor whiteColor];
    }*/
    
    [self makeFontColorTo:fontColor];
}

@end
