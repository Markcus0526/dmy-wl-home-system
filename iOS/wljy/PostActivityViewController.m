//
//  PostActivityViewController.m
//  wljy
//
//  Created by 111 on 14.03.06.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "PostActivityViewController.h"
#import "Constants.h"
#import "AFHTTPClient.h"

@implementation PostActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
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
    if(isPickerDisapeared == NO) {
        //self.filename = nil;
        //[self clearSelection];
        //self.typeAButton.selected = YES;
        
        [self.attachButton1 setImage:[UIImage imageNamed:@"feedback_attach.png"] forState:UIControlStateNormal];
        [self.attachButton2 setImage:[UIImage imageNamed:@"feedback_attach.png"] forState:UIControlStateNormal];
        [self.attachButton3 setImage:[UIImage imageNamed:@"feedback_attach.png"] forState:UIControlStateNormal];
        self.attachButton1.tag = 0;
        self.attachButton2.tag = 1;
        self.attachButton3.tag = 2;
        self.attachButton2.hidden = YES;
        self.attachButton3.hidden = YES;
        if(!attachArray)
            attachArray = [NSMutableArray array];
        else
            [attachArray removeAllObjects];
    }
    isPickerDisapeared = NO;
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:postController];
}

- (IBAction)onBack:(id)sender {
    //self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    //[self presentViewController:self.previousViewController animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeText = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([activeText isEqual:self.titleText])
        [self.bodyText becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    activeText = textView;
}

/*- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self.startdateText becomeFirstResponder];
    
    return YES;
}*/

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
    if([self.startdateText isFirstResponder])
        [self.startdateText resignFirstResponder];
}

- (IBAction)onAttachFile:(id)sender {
    //self.selectedimg = nil;
    curAttachButton = sender;
    [self.takeController takePhotoOrChooseFromLibrary];
}

- (IBAction)onPost:(id)sender {
    if(self.titleText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"活动错误" message:@"无标题!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    /*if(self.bodyText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"活动错误" message:@"无介绍内容!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }*/
    /*if(self.startdateText.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"活动错误" message:@"无开始时间!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }*/
    
//    [self postToServer];
    
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
        
//        [postController initialize];
//        [postController setUrlPath:@"postactivity.jsp"];
//        [postController setContentType:@"text/file"];
//        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", self.titleText.text, @"act_title", self.bodyText.text, @"act_body", self.filename, @"fileContent", nil];//, self.startdateText.text, @"act_start", nil];
//        [postController setParams:params];
        [postController startSend];
    }
}

- (void)connectionComplete:(NSNotification*)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        NSData *data = [info objectForKey:@"data"];
        NSLog(@"PostActivity: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSNumber *success = [jsonDic objectForKey:@"success"];
        if ([success intValue] == 1) {
            self.titleText.text = @"";
            self.bodyText.text = @"";
            self.startdateText.text = @"";
            [self onBack:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发起活动失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
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
    isPickerDisapeared = YES;
    /*UIAlertView *alertView;
     if (madeAttempt)
     alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled after selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     else
     alertView = [[UIAlertView alloc] initWithTitle:@"Example app" message:@"The take was cancelled without selecting media" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alertView show];*/
    NSLog(@"File Select Cancelled");
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info {
    isPickerDisapeared = YES;
    //self.selectedimg = photo;
    [curAttachButton setImage:photo forState:UIControlStateNormal];
    if(curAttachButton == self.attachButton1)
        self.attachButton2.hidden = NO;
    else if(curAttachButton == self.attachButton2)
        self.attachButton3.hidden = NO;
    if(attachArray.count < curAttachButton.tag+1)
        [attachArray addObject:photo];
    else
        [attachArray replaceObjectAtIndex:curAttachButton.tag withObject:photo];
}

- (void)takeController:(FDTakeController *)controller gotVideo:(NSURL *)video withInfo:(NSDictionary *)info {
    isPickerDisapeared = YES;
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
                                self.titleText.text, @"act_title",
                                self.bodyText.text, @"act_body",
                                nil];//, self.startdateText.text, @"act_start", nil];
        
        NSData * imageData = UIImageJPEGRepresentation(self.selectedimg, 1.0);
        
        NSString *method = Server_Address;
        method = [method stringByAppendingString:@"phone/"];
        method = [method stringByAppendingString:@"postactivity_many.jsp"];
        
        /*NSData * imageData = UIImageJPEGRepresentation(self.selectedimg, 1.0);
         NSMutableURLRequest  *request = [httpClient multipartFormRequestWithMethod:@"POST" path:method parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:imageData name:@"ssss.jpg" fileName:@"screenshot.jpg" mimeType:@"image/jpeg"];
         }];*/
        NSMutableURLRequest  *request = [httpClient multipartFormRequestWithMethod:@"POST" path:method parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for(NSInteger i = 0; i < attachArray.count; i ++) {
                UIImage *image = [attachArray objectAtIndex:i];
                NSData * imageData = UIImageJPEGRepresentation(image, 1.0);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"ssss%d.jpg", i] fileName:[NSString stringWithFormat:@"screenshot%d.jpg", i] mimeType:@"image/jpeg"];
            }
        }];
        
        [request setTimeoutInterval:10000];
        
        AFHTTPRequestOperation *operation = [httpClient
                                             HTTPRequestOperationWithRequest:request
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                 [self changeState:YES];
                                                 
                                                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                                 
                                                NSLog(@"PostActivity: %@", responseStr);
                                                
                                                NSError *jsonParsingError = nil;
                                                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonParsingError];
                                                NSNumber *success = [jsonDic objectForKey:@"success"];
                                                if ([success intValue] == 1) {
                                                    self.titleText.text = @"";
                                                    self.bodyText.text = @"";
                                                    self.startdateText.text = @"";
                                                    [self onBack:nil];
                                                } else {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发起活动失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
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
