//
//  AutoMessageBox.h
//  Showhand
//
//  Created by Lion User on 01/02/2013.
//  Copyright (c) 2013 AppDevCenter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoMessageBox : UIViewController{
    IBOutlet UILabel        *lblMsg;
    IBOutlet UIImageView    *imgSuccess;
    IBOutlet UIImageView    *imgFailure;
    
    NSString            *strMsg;
    BOOL                bSuccess;
}


+ (void)AutoMsgInView:(UIView *)parentView withText:(NSString *)text withSuccess:(BOOL)success;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text:(NSString *)text success:(BOOL)success;
@end
