//
//  ToForward.m
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ToForward.h"

@implementation ToForward

- (void) perform {
    UIViewController *destination = self.destinationViewController;
    destination.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:YES completion:nil];
}

@end
