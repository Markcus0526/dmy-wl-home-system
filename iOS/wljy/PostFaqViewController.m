//
//  PostFaqViewController.m
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "PostFaqViewController.h"
#import "Constants.h"

@implementation PostFaqViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.type = 1;
    originRect = [self.bodyFrame frame];
    [self.loadingIndicator setHidden:YES];
    postController = [[PostController alloc] init];
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    self.maxIntegralLabel.text = [NSString stringWithFormat:@"最大积分是%d", self.maxIntegral];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:postController];
}

- (void)animateControl:(CGRect)endRect {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.bodyFrame.frame = endRect;
    [UIView commitAnimations];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    endFrameRect = CGRectMake(originRect.origin.x, self.view.frame.size.height - kbSize.height - originRect.size.height - 10, originRect.size.width, originRect.size.height);
    
    if([activeText isEqual:self.bodyText]) {
        [self animateControl:endFrameRect];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if([activeText isEqual:self.bodyText]) {
        [self animateControl:originRect];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField isEqual:self.integralText]) {
        if(string.length > 0 && [string compare:@"0"] != NSOrderedSame && [string integerValue] == 0)
            return NO;
        else
            return YES;
    } else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeText = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    activeText = nil;
    if (textField == self.titleText) {
        [self.integralText becomeFirstResponder];
    }
    if (textField == self.integralText) {
        [self.bodyText becomeFirstResponder];
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    activeText = textView;
    if(textView.frame.origin.y != originRect.origin.y)
        [self animateControl:endFrameRect];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self.bodyText resignFirstResponder];
    
    return YES;
}

/*- (void)textFieldDidEndEditing:(UITextField *)textField {
 [self.bodyText resignFirstResponder];
 }*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self.titleText isFirstResponder])
        [self.titleText resignFirstResponder];
    if([self.integralText isFirstResponder])
        [self.integralText resignFirstResponder];
    if([self.bodyText isFirstResponder])
        [self.bodyText resignFirstResponder];
}

- (void)clearSelection {
    [self.majorButton setSelected:NO];
    [self.enterpriseButton setSelected:NO];
    [self.otherButton setSelected:NO];
}

- (IBAction)onBack:(id)sender {
    //self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //[self presentViewController:self.previousViewController animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onType:(id)sender {
    [self clearSelection];
    ((UIButton*)sender).selected = YES;
    self.type = ((UIButton*)sender).tag;
}

- (IBAction)onPost:(id)sender {
    if(self.titleText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"问答错误" message:@"无标题!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if(self.integralText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"问答错误" message:@"无积分!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (self.integralText.text.integerValue > self.maxIntegral) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"问答错误" message:@"积分数量超过了最大价!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    /*if(self.bodyText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"问答错误" message:@"无问答内容!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }*/
    
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
        [postController setUrlPath:@"postquestion.jsp"];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", self.titleText.text, @"ques_title", [NSString stringWithFormat:@"%d", self.type], @"ques_type", self.integralText.text, @"ques_integral",self.bodyText.text, @"ques_body", nil];
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
        NSLog(@"PostFaq: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSNumber *success = [jsonDic objectForKey:@"success"];
        if ([success intValue] == 1) {
            self.titleText.text = @"";
            self.integralText.text = @"";
            self.bodyText.text = @"";
            [self onBack:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"问答失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
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
