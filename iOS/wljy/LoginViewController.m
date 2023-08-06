//
//  ViewController.m
//  wljy
//
//  Created by 111 on 14.01.14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    getController = [[GetController alloc] init];
    
    self.loadingIndicator.hidden = YES;
    self.password.secureTextEntry = YES;
    originRect = [self.viewNamePass frame];
    [self registerNotifications];
    
    
    [self.yourname setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.password setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(appDelegate.dayNightMode) {
        if(appDelegate.isMorning)
            [self.backImageView setImage:[UIImage imageNamed:@"login_background.png"]];
        else
            [self.backImageView setImage:[UIImage imageNamed:@"login_background1.png"]];
    }
}


- (void)animateControl:(CGRect)endRect {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];    
    self.viewNamePass.frame = endRect;    
    [UIView commitAnimations];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //CGRect rect = CGRectMake(originRect.origin.x, originRect.origin.y - kbSize.height + 100, originRect.size.width, originRect.size.height);
    CGRect rect = CGRectMake(originRect.origin.x, self.view.frame.size.height - kbSize.height - originRect.size.height - 10, originRect.size.width, originRect.size.height);

    
    [self animateControl:rect];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [self animateControl:originRect];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    activeField = nil;
    if (textField == self.password) {
        [self.password resignFirstResponder];
    }
    if (textField == self.yourname) {        
        [self.password becomeFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self.password isFirstResponder])
        [self.password resignFirstResponder];
    else if([self.yourname isFirstResponder])
        [self.yourname resignFirstResponder];
}

- (IBAction)LoginProcess:(id)sender {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimating];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"login.jsp"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.yourname.text, @"userid", self.password.text, @"password", nil];
        [getController setParams:params];
        [getController startReceive];
    }
}

- (void)connectionComplete:(NSNotification*)aNotification {
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator.hidden = YES;
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    NSString *contentType = [info objectForKey:@"contentType"];
    
    if([status compare:@"succeeded"] == NSOrderedSame && [contentType compare:@"text"] == NSOrderedSame) {
        NSData *data = [info objectForKey:@"data"];
        NSLog(@"Login: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        userPrivilege = [jsonDic objectForKey:@"privilege"];
        userid = [jsonDic objectForKey:@"userid"];
        username = [jsonDic objectForKey:@"username"];
        userIntegral = [jsonDic objectForKey:@"integral"];
        lastLoginDate = [jsonDic objectForKey:@"lastlogindate"];
        NSString *imagepath = [jsonDic objectForKey:@"photo"];
        
        if ([userid intValue] < 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"您的账号被禁用，请联系管理员!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        } else {
            [appDelegate setAccountInfo:[userid intValue] privilege:[userPrivilege intValue] name:username integral:[userIntegral integerValue] lastLoginDate:lastLoginDate photo:imagepath];
            
            UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Recommendation"];
            //UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Exchange"];
            
            [self presentViewController:viewController animated:YES completion:nil];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
    
    
}

@end
