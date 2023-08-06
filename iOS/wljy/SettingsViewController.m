//
//  SettingsViewController.m
//  wljy
//
//  Created by 111 on 14.01.23.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    /*CGRect rect = self.blackWhiteModeSwitch.frame;
    self.blackWhiteModeSwitch.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width+50, rect.size.height);*/
    
    self.dayModeSwitch.onImage = [UIImage imageNamed:@"switch_on.png"];
    self.dayModeSwitch.offImage = [UIImage imageNamed:@"switch_off.png"];
    self.dayModeSwitch.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    self.nightModeSwitch.onImage = [UIImage imageNamed:@"switch_on.png"];
    self.nightModeSwitch.offImage = [UIImage imageNamed:@"switch_off.png"];
    self.nightModeSwitch.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    self.blackModeSwitch.onImage = [UIImage imageNamed:@"switch_on.png"];
    self.blackModeSwitch.offImage = [UIImage imageNamed:@"switch_off.png"];
    self.blackModeSwitch.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    self.whiteModeSwitch.onImage = [UIImage imageNamed:@"switch_on.png"];
    self.whiteModeSwitch.offImage = [UIImage imageNamed:@"switch_off.png"];
    self.whiteModeSwitch.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [appDelegate setSettingsInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.dayModeSwitch.on = (appDelegate.showMode == kDayMode);
    self.nightModeSwitch.on = (appDelegate.showMode == kNightMode);
    self.blackModeSwitch.on = (appDelegate.showMode == kBlackMode);
    self.whiteModeSwitch.on = (appDelegate.showMode == kWhiteMode);
}

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
     [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSwitch:(id)sender {
    UISwitch *modeSwitch = (UISwitch*)sender;
    if(modeSwitch.on == YES) {
        self.dayModeSwitch.on = NO;
        self.nightModeSwitch.on = NO;
        self.blackModeSwitch.on = NO;
        self.whiteModeSwitch.on = NO;
        
        modeSwitch.on = YES;
        appDelegate.showMode = modeSwitch.tag;
    }else
        modeSwitch.on = YES;
        
    /*if([self.dayNightModeSwitch isEqual:sender]) {
        appDelegate.dayNightMode = self.dayNightModeSwitch.on;
    } else {
        appDelegate.blackWhiteMode = self.blackWhiteModeSwitch.on;
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
