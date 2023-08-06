//
//  FeedbackViewController.m
//  wljy
//
//  Created by 111 on 14.01.20.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Constants.h"
#import "AFHTTPClient.h"


@implementation FeedbackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    
    [self.todayLabel setText:[appDelegate getTodayDate]];    
    originRect = [self.bodyFrame frame];
    [self.loadingIndicator setHidden:YES];
    postController = [[PostController alloc] init];
    [self registerNotifications];
    
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;
    self.takeController.viewControllerForPresentingImagePickerController = self;
    self.selectedimg = nil;
    isPickerDisapeared = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    //self.filename = nil;
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

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
     [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeText = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.bodyText becomeFirstResponder];
    
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
    if([self.bodyText isFirstResponder])
        [self.bodyText resignFirstResponder];
}

- (IBAction)onAttachFile:(id)sender {
    NSLog(@"Attach File");
    self.selectedimg = nil;
    [self.takeController takePhotoOrChooseFromLibrary];
}

- (IBAction)onPost:(id)sender {
    if(self.titleText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"献策错误" message:@"无标题!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if(self.bodyText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"献策错误" message:@"无献策内容!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //[self postToServer];
    
    // call service
    [self callSubmitActivity];
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
        
        //NSString *filename = [[NSBundle mainBundle]  pathForResource:@"main_header" ofType:@"png"];
        //self.filename = [NSURL fileURLWithPath:filename];
        
        /*[postController initialize];
        [postController setUrlPath:@"feedback.jsp"];
        [postController setContentType:@"text/file"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", self.titleText.text, @"title", self.bodyText.text, @"body", self.filename, @"fileContent", nil];
        
        [postController setParams:params];
        [postController startSend];*/
    }
}

- (void)connectionComplete:(NSNotification*)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        NSData *data = [info objectForKey:@"data"];
        NSLog(@"Feedback: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSNumber *success = [jsonDic objectForKey:@"success"];
        if ([success intValue] == 1) {            
            self.titleText.text = @"";
            self.bodyText.text = @"";
            [self onBack:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"献策失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
    /*UIAlertView *alertView;
    if (madeAttempt)
        alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled after selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    else
        alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled without selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];*/
    NSLog(@"File Select Cancelled");
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info {
    self.selectedimg = photo;
}

- (void)takeController:(FDTakeController *)controller gotVideo:(NSURL *)video withInfo:(NSDictionary *)info {
    //self.filename = [info objectForKey:UIImagePickerControllerReferenceURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// activityReport.ashx
- (void) callSubmitActivity
{
    
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        NSURL  *baseURL = [NSURL URLWithString:Server_Address];
        AFHTTPClient  *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%d", appDelegate.userid], @"userid",
                                self.titleText.text, @"title",
                                self.bodyText.text, @"body",
                                nil];
        
        NSData * imageData = UIImageJPEGRepresentation(self.selectedimg, 1.0);
        
        NSString *method = Server_Address;
        method = [method stringByAppendingString:@"phone/"];
        method = [method stringByAppendingString:@"feedback.jsp"];
        
        NSMutableURLRequest  *request = [httpClient multipartFormRequestWithMethod:@"POST" path:method parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"ssss.jpg" fileName:@"screenshot.jpg" mimeType:@"image/jpeg"];
        }];
        
        [request setTimeoutInterval:10000];
        
        AFHTTPRequestOperation *operation = [httpClient
                                             HTTPRequestOperationWithRequest:request
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                 [self changeState:YES];
                                                 
                                                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                                 
                                                 NSLog(@"Feedback: %@", responseStr);
                                                 
                                                 NSError *jsonParsingError = nil;
                                                 NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonParsingError];
                                                 NSNumber *success = [jsonDic objectForKey:@"success"];
                                                 if ([success intValue] == 1) {
                                                     self.titleText.text = @"";
                                                     self.bodyText.text = @"";
                                                     [self onBack:nil];
                                                 } else {
                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"献策失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                                                     [alert show];
                                                 }
                                             }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                             {
                                                 [self changeState:YES];
                                                 
                                                 NSLog(@"%@", error);
                                                 
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                                                 [alert show];
                                                 
                                             }];
        
        [httpClient enqueueHTTPRequestOperation:operation];
    }
}

@end
