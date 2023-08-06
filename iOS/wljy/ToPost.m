//
//  ToPost.m
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ToPost.h"

@implementation ToPost

- (void) perform {
    UIViewController *destination = self.destinationViewController;
    destination.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:YES completion:nil];
}

@end
