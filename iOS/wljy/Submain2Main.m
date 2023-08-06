//
//  Submain2Main.m
//  wljy
//
//  Created by 111 on 14.01.17.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "Submain2Main.h"
#import "AppDelegate.h"

@implementation Submain2Main

- (void) perform {    
    UIViewController *destination = self.destinationViewController;
    destination.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:YES completion:nil];
}

@end
