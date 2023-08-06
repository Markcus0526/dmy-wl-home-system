//
//  SettingsViewController.h
//  wljy
//
//  Created by 111 on 14.01.23.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController {
    AppDelegate *appDelegate;
}

@property(nonatomic, strong) IBOutlet UISwitch *dayModeSwitch;
@property(nonatomic, strong) IBOutlet UISwitch *nightModeSwitch;
@property(nonatomic, strong) IBOutlet UISwitch *blackModeSwitch;
@property(nonatomic, strong) IBOutlet UISwitch *whiteModeSwitch;

- (IBAction)onSwitch:(id)sender;

@end
