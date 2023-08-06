//
//  EvalViewController.m
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "PostEvalViewController.h"
#import "Constants.h"


@implementation PostEvalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
    [self.loadingIndicator setHidden:YES];
    postController = [[PostController alloc] init];
    [self registerNotifications];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:postController];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self.bodyText resignFirstResponder];
    
    return YES;
}

/*- (void)textFieldDidEndEditing:(UITextField *)textField {
 [self.bodyText resignFirstResponder];
 }*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self.bodyText isFirstResponder])
        [self.bodyText resignFirstResponder];
}

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPost:(id)sender {
    if(self.bodyText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"评论错误" message:@"无评论内容!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
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
        if([self.pageClass compare:@"activity"] == NSOrderedSame)
            [postController setUrlPath:@"activity_addanswer.jsp"];
        else
            [postController setUrlPath:[NSString stringWithFormat:@"%@_info_addans.jsp", self.pageClass]];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.itemId], @"id", self.bodyText.text, @"postdata", nil];
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
        NSLog(@"PostEval: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSNumber *success = [jsonDic objectForKey:@"success"];
        if ([success intValue] == 1) {
            self.bodyText.text = @"";
            [self onBack:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"评论失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
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
