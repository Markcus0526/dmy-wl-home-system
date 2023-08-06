//
//  SingleInfoViewController.m
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "SingleInfoViewController.h"
#import "Constants.h"
#import "AnswerViewController.h"
#import "PostEvalViewController.h"
#import "PostActivityViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

#define kBottomLeftBackHeight        81
#define kBottomRightBackHeight         72
#define kBottomBottomBackY         122


@implementation SingleInfoViewController

- (void)setConstraint {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *metrics = [NSDictionary dictionary];
    NSDictionary *viewDic = [NSDictionary dictionaryWithObjectsAndKeys:self.scrollView, @"scrollView", nil];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:metrics views:viewDic]];
#ifdef IOS7
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[scrollView]|" options:0 metrics:metrics views:viewDic]];
#else
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[scrollView]|" options:0 metrics:metrics views:viewDic]];
#endif
    
    //[self.view updateConstraints];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self setConstraint];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self.todayLabel setText:[appDelegate getTodayDate]];
    [self.loadingIndicator setHidden:YES];
    getController = [[GetController alloc] init];
    postController = [[PostController alloc] init];
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self setScrollViewContentSize];
    
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionCompleteForGet:) name:HConnectionCompleteNotification object:getController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionCompleteForPost:) name:HConnectionCompleteNotification object:postController];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
    }
    else
        [self.loadingIndicator startAnimating];
    self.postButton.enabled = isLoaded;
    self.evalUpButton.enabled = isLoaded;
    self.evalDownButton.enabled = isLoaded;
}

- (NSInteger)fitAndCorrectView:(UIView*)view {
    CGRect firstRect = view.frame;
    
    [view sizeToFit];
    CGRect lastRect = view.frame;
    
    NSInteger dif = lastRect.size.height - firstRect.size.height;
    
    firstRect.size.height = lastRect.size.height;
    view.frame = firstRect;
    
    return dif;
}

- (void)fitView {
    NSInteger dif = [self fitAndCorrectView:self.bodyLabel];
    
    CGRect rect = self.middleView.frame;
    rect.origin.y += dif;
    self.middleView.frame = rect;
    
    rect = self.bottomView.frame;
    rect.origin.y += dif;
    self.bottomView.frame = rect;
    
    dif = [self fitAndCorrectView:self.answerBodyLabel];
    
    rect = self.bottomImageView1.frame;
    rect.size.height += dif;//= kBottomLeftBackHeight + dif;
    self.bottomImageView1.frame = rect;
    
    rect = self.bottomImageView2.frame;
    rect.size.height += dif;//= kBottomRightBackHeight + dif;
    self.bottomImageView2.frame = rect;
    
    rect = self.bottomImageView3.frame;
    rect.origin.y += dif;//= kBottomBottomBackY + dif;
    self.bottomImageView3.frame = rect;
    
    /*rect = self.bottomImageView.frame;
    rect.size.height += dif;
    self.bottomImageView.frame = rect;*/
    
    rect = self.bottomView.frame;
    rect.size.height += dif;
    self.bottomView.frame = rect;
}

- (void)setScrollViewContentSize {
    CGRect scrollRect = self.scrollView.frame;
    scrollRect.size.height = self.middleView.frame.origin.y + self.middleView.frame.size.height;
    scrollRect.size.height += self.bottomView.frame.size.height;
    
    [self.scrollView setContentSize:scrollRect.size];
}

- (IBAction)onAllAnswer:(id)sender {
    AnswerViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Answer"];
    viewController.previousViewController = self;
    viewController.pageClass = @"activity";
    viewController.itemId = self.itemId;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"single_info.jsp"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.itemId], @"id", nil];
        [getController setParams:params];
        [getController startReceive];
    }
}

- (void)connectionCompleteForGet:(NSNotification*)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    NSString *contentType = [info objectForKey:@"contentType"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        if([contentType compare:@"text"] == NSOrderedSame) {
            NSData *data = [info objectForKey:@"data"];
            NSLog(@"SingleInfo: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            if([success intValue] == 1) {
                NSArray *keys = @[@"body", @"evalup_count", @"evaldown_count", @"have_answer", @"answerer_name", @"answer_date", @"answer_body", @"imagepath"];
                
                imagepathes = [NSMutableDictionary dictionary];
                
                NSMutableDictionary *singleInfo = [NSMutableDictionary dictionary];
                for(NSString *key in keys) {
                    id val = [jsonDic objectForKey:key];
                    if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                        [singleInfo setObject:val forKey:key];
                        if([key compare:@"imagepath"] == NSOrderedSame) {
                            [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                            /*for(NSInteger i = 0; i < ((NSArray*)val).count; i ++) {
                                id subval = [(NSArray*)val objectAtIndex:i];
                                if(subval != nil && ![subval isKindOfClass:[NSNull class]]) {
                                    [subval stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                                    [imageRequests setObject:subval forKey:[NSNumber numberWithInt:i]];
                                }
                            }*/
                        }
                    }
                }
                                
                self.bodyLabel.text = [singleInfo objectForKey:[keys objectAtIndex:0]];
                if(self.bodyLabel.text == nil || [self.bodyLabel.text isKindOfClass:[NSNull class]] || self.bodyLabel.text.length == 0)
                    self.bodyLabel.text = @"没有资料";
                
                [self.evalUpButton setTitle:[NSString stringWithFormat:@"%@", [singleInfo objectForKey:[keys objectAtIndex:1]]] forState:UIControlStateNormal];                
                [self.evalDownButton setTitle:[NSString stringWithFormat:@"%@", [singleInfo objectForKey:[keys objectAtIndex:2]]] forState:UIControlStateNormal];                
                self.answerEvalLabel.text = [NSString stringWithFormat:@"%@赞 %@踩", [singleInfo objectForKey:[keys objectAtIndex:1]], [singleInfo objectForKey:[keys objectAtIndex:2]]];
                
                if([[singleInfo objectForKey:[keys objectAtIndex:3]] integerValue] > 0) {
                    self.answererNameLabel.text = [singleInfo objectForKey:[keys objectAtIndex:4]];
                    self.answerDateLabel.text = [NSString stringWithFormat:@"%@天前", [singleInfo objectForKey:[keys objectAtIndex:5]]];
                    
                    self.answerBodyLabel.text = [singleInfo objectForKey:[keys objectAtIndex:6]];
                    if(self.answerBodyLabel.text == nil || [self.answerBodyLabel.text isKindOfClass:[NSNull class]] || self.answerBodyLabel.text.length == 0)
                        self.answerBodyLabel.text = @"没有资料";
                    
                    [self.answererImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [singleInfo objectForKey:[keys objectAtIndex:7]]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];

                    
                    self.bottomView.hidden = NO;
                } else {                    
                    self.bottomView.hidden = YES;
                }
                                
                
                [self fitView];
                [self setScrollViewContentSize];
                
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
    PostActivityViewController *viewController = (PostActivityViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostActivity"];
    viewController.previousViewController = self;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)onPostEval:(id)sender {
    PostEvalViewController *viewController = (PostEvalViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostEval"];
    viewController.previousViewController = self;
    viewController.itemId = self.itemId;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)onEvalUpDown:(id)sender {
    [self postToServer:((UIButton*)sender).tag];
    self.evalUpDown = ((UIButton*)sender).tag;
}

- (void)postToServer:(NSInteger)evaltype {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [postController initialize];
        [postController setUrlPath:@"activity_addcomment.jsp"];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.itemId], @"id", [NSString stringWithFormat:@"%d", evaltype], @"type", nil];
        [postController setParams:params];
        [postController startSend];
    }
}

- (void)connectionCompleteForPost:(NSNotification*)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        NSData *data = [info objectForKey:@"data"];
        NSLog(@"SingleInfo: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSNumber *success = [jsonDic objectForKey:@"success"];
        if ([success intValue] == 1) {
            // Success
            /*if(self.evalUpDown == 1) {
                int num = [self.evalUpButton.titleLabel.text integerValue]; num ++;
                [self.evalUpButton setTitle:[NSString stringWithFormat:@"%d", num] forState:UIControlStateNormal];
            } else {
                int num = [self.evalDownButton.titleLabel.text integerValue]; num ++;
                [self.evalDownButton setTitle:[NSString stringWithFormat:@"%d", num] forState:UIControlStateNormal];
            }*/            
            [self connectToServer];
        } else if ([success intValue] == 2){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"评价失败" message:@"你已经评价了对这个。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"评价失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
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
