//
//  PhotoViewController.m
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "PhotoViewController.h"
#import "PostPhotoViewController.h"
#import "Constants.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];   
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self.loadingIndicator setHidden:YES];
    getController = [[GetController alloc] init];
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self connectToServer];
    
    /*[self.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, self.imagePath]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    
    [self.infoLabel setText:self.infoString];
    [self fitAndCorrectView:self.infoLabel];
    CGRect screenRect = self.view.frame;
    CGRect infoRect = self.infoLabel.frame;
    infoRect.origin.y = screenRect.size.height - infoRect.size.height;
    self.infoLabel.frame = infoRect;*/
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
     [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [getController setUrlPath:@"myphoto_info.jsp"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.itemId], @"id", nil];
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
            NSLog(@"FaqInfo: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            if([success intValue] == 1) {
                NSArray *keys = @[@"title", @"body", @"imagepath"];
                                
                NSMutableDictionary *photoInfo = [NSMutableDictionary dictionary];
                for(NSString *key in keys) {
                    id val = [jsonDic objectForKey:key];
                    if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                        [photoInfo setObject:val forKey:key];
                        if([key compare:@"imagepath"] == NSOrderedSame) {
                            [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                        }
                    }
                }                
                
                self.infoLabel.text = [NSString stringWithFormat:@"%@\n%@", [photoInfo objectForKey:[keys objectAtIndex:0]], [photoInfo objectForKey:[keys objectAtIndex:1]]];
                [self fitAndCorrectView:self.infoLabel];
                CGRect screenRect = self.view.frame;
                CGRect infoRect = self.infoLabel.frame;
                infoRect.origin.y = screenRect.size.height - infoRect.size.height;
                self.infoLabel.frame = infoRect;                
                
                [self.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [photoInfo objectForKey:[keys objectAtIndex:2]]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
            }
        }
    } else{
        if([contentType compare:@"text"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (IBAction)onPost:(id)sender {
    PostPhotoViewController *viewController = (PostPhotoViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostPhoto"];
    viewController.previousViewController = self;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)fitAndCorrectView:(UIView*)view {
    CGRect firstRect = view.frame;
    
    [view sizeToFit];
    CGRect lastRect = view.frame;
    firstRect.size.height = lastRect.size.height;
    view.frame = firstRect;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
