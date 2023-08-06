//
//  ChangePasswdViewController.m
//  wljy
//
//  Created by 111 on 14.03.06.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ChangePasswdViewController.h"
#import "Constants.h"

@implementation ChangePasswdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    
    [self.todayLabel setText:[appDelegate getTodayDate]];
    [self.loadingIndicator setHidden:YES];
    postController = [[PostController alloc] init];
    [self registerNotifications];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:postController];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeText = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([activeText isEqual:self.oldPassword])
        [self.mynewPassword becomeFirstResponder];
    else if([activeText isEqual:self.mynewPassword])
        [self.validPassword becomeFirstResponder];
    else
        [self.validPassword resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self.oldPassword isFirstResponder])
        [self.oldPassword resignFirstResponder];
    if([self.mynewPassword isFirstResponder])
        [self.mynewPassword resignFirstResponder];
    if([self.validPassword isFirstResponder])
        [self.validPassword resignFirstResponder];
}

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
     [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPost:(id)sender {
    if(self.oldPassword.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码错误" message:@"无当前密码!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if(self.mynewPassword.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码错误" message:@"无新密码!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if(self.validPassword.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码错误" message:@"无确认密码!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if([self.mynewPassword.text compare:self.validPassword.text] != NSOrderedSame) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"密码错误" message:@"新密码和确认密码不同!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self postToServer];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded)
        [self.loadingIndicator stopAnimating];
    else
        [self.loadingIndicator startAnimating];
    self.postButton.enabled = isLoaded;
}

- (void)postToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [postController initialize];
        [postController setUrlPath:@"pass_change.jsp"];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", self.oldPassword.text, @"old_pass", self.mynewPassword.text, @"new_pass", nil];
        [postController setParams:params];
        [postController startSend];
    }
}

- (void)connectionComplete:(NSNotification*)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        NSData *data = [info objectForKey:@"data"];
        NSLog(@"ChangePassword: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSNumber *success = [jsonDic objectForKey:@"success"];
        if ([success intValue] == 1) {
            self.oldPassword.text = @"";
            self.mynewPassword.text = @"";
            self.validPassword.text = @"";
            [self onBack:nil];
        } else if ([success intValue] == 2) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改密码失败" message:@"你写的当前密码是错的。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改密码失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
