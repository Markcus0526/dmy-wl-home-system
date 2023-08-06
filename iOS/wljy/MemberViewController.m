//
//  MemberViewController.m
//  wljy
//
//  Created by 111 on 14.01.21.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "MemberViewController.h"
#import "Constants.h"
#import "ChangePasswdViewController.h"
#import "MemberEditViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"
#import "AFHTTPClient.h"


@implementation MemberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loadingIndicator.hidden = YES;
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    getController = [[GetController alloc] init];
    [self registerNotifications];
    
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;
    self.takeController.viewControllerForPresentingImagePickerController = self;
    self.selectedimg = nil;
    
    isPickerDisappeared = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(isPickerDisappeared == NO) {
        [self.userImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, appDelegate.imagepath]] placeholderImage:[UIImage imageNamed:@"main_header_image.png"]];
        
        [self connectToServer];
    } else
        isPickerDisappeared = NO;
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
     [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onChangeImage:(id)sender {
    self.selectedimg = nil;
    isPickerDisappeared = YES;
    [self.takeController takePhotoOrChooseFromLibrary];
}

- (IBAction)onChangeNickname:(id)sender {
    MemberEditViewController *viewController = (MemberEditViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MemberEdit"];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    viewController.editType = kNickname;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)onChangeTel:(id)sender {
    MemberEditViewController *viewController = (MemberEditViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MemberEdit"];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    viewController.editType = kTel;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)onChangePassword:(id)sender {
    ChangePasswdViewController *viewController = (ChangePasswdViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ChangePassword"];
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded)
        [self.loadingIndicator stopAnimating];
    else
        [self.loadingIndicator startAnimating];
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"myinfo.jsp"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", nil];
        [getController setParams:params];
        [getController startReceive];
    }
}

- (void)connectionComplete:(NSNotification*)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    NSString *contentType = [info objectForKey:@"contentType"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        if([contentType compare:@"text"] == NSOrderedSame) {
            NSData *data = [info objectForKey:@"data"];
            NSLog(@"Member: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            if([success intValue] == 1) {
                NSArray *keys = @[@"name", @"nickname", @"phone", @"integral", @"imagepath"];
                                
                NSMutableDictionary *memberInfo = [NSMutableDictionary dictionary];
                for(NSString *key in keys) {
                    id val = [jsonDic objectForKey:key];
                    if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                        [memberInfo setObject:val forKey:key];
                        if([key compare:@"imagepath"] == NSOrderedSame) {
                            val = [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                        }
                    }
                }
                
                self.userNameLabel.text = [memberInfo objectForKey:[keys objectAtIndex:0]];
                self.nickNameLabel.text = [memberInfo objectForKey:[keys objectAtIndex:1]];
                self.phoneNumberLabel.text = [memberInfo objectForKey:[keys objectAtIndex:2]];
                self.integralLabel.text = [NSString stringWithFormat:@"%@", [memberInfo objectForKey:[keys objectAtIndex:3]]];
                
                //[self.userImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [memberInfo objectForKey:[keys objectAtIndex:4]]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
            }
        }
        
    } else {
        if([contentType compare:@"text"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }
}


#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
    NSLog(@"File Select Cancelled");
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info {
    self.selectedimg = photo;
    [self callSubmitActivity];
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
                                [NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", nil];
        
        NSData * imageData = UIImageJPEGRepresentation(self.selectedimg, 1.0);
        
        NSString *method = Server_Address;
        method = [method stringByAppendingString:@"phone/"];
        method = [method stringByAppendingString:@"photo_change.jsp"];
        
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
                                                 
                                                 NSLog(@"Member: %@", responseStr);
                                                 
                                                 NSError *jsonParsingError = nil;
                                                 NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonParsingError];
                                                 NSNumber *success = [jsonDic objectForKey:@"success"];
                                                 if ([success intValue] == 1) {
                                                     self.userImageView.image = self.selectedimg;
                                                     appDelegate.imagepath = [jsonDic objectForKey:@"imagepath"];
                                                     [self onBack:nil];
                                                 } else {
                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发布失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
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
