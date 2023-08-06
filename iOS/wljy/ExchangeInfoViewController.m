//
//  ExchangeInfoViewController.m
//  wljy
//
//  Created by 111 on 14.01.23.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ExchangeInfoViewController.h"
#import "Constants.h"
#import "PostExchangeViewController.h"
#import "ExchangeImageViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@implementation ExchangeInfoViewController

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
    [self setScrollViewContentSize:NO];
        
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionCompleteForPost:) name:HConnectionCompleteNotification object:postController];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPost:(id)sender {
    if (self.exchangeCountText.text.integerValue > self.totalSecure) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"兑换错误" message:@"产品数量超过了兑换库存!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self postToServer];
    
    PostExchangeViewController *viewController = (PostExchangeViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostExchange"];
    viewController.previousViewController = self;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
    }
    else
        [self.loadingIndicator startAnimating];
}

- (void)animateControl:(BOOL)isUp {
    NSInteger offsetY;
    if(isUp)
        offsetY = -self.explainView.frame.size.height;
    else
        offsetY = self.explainView.frame.size.height;
    
    CGRect endRectForTopView = self.topView.frame;
    endRectForTopView.origin.y += offsetY;
    CGRect endRectForExplainButton = self.explainButton.frame;
    endRectForExplainButton.origin.y += offsetY;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.topView.frame = endRectForTopView;
    self.explainButton.frame = endRectForExplainButton;
    [UIView commitAnimations];
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

- (void)fitExplainView {
    NSInteger dif = [self fitAndCorrectView:self.explainLabel];
    CGRect rect = self.explainView.frame;
    rect.size.height += dif;
    rect.origin.y = self.subImagesButton.frame.origin.y - rect.size.height;
    self.explainView.frame = rect;
}

- (void)setScrollViewContentSize:(BOOL)isIncludingExplain {
    CGRect scrollRect = self.topView.frame;
    scrollRect.size.height += self.explainButton.frame.size.height;
    scrollRect.size.height += self.subImagesButton.frame.size.height;
    scrollRect.size.height += self.bottomView.frame.size.height;
    
    if(isIncludingExplain)
        scrollRect.size.height += self.explainView.frame.size.height;
    
    [self.scrollView setContentSize:scrollRect.size];
}

- (IBAction)onSubButton:(id)sender {
    UIButton *button = (UIButton*)sender;
    if(button.tag == 0)
        [self animateControl:YES];
    else
        [self animateControl:NO];
    button.tag = 1 - button.tag;
}

- (IBAction)onSubImage:(id)sender {
    ExchangeImageViewController *viewController = (ExchangeImageViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ExchangeImage"];
    viewController.productTitle = self.titleLabel.text;
    viewController.imagepaths = imagepathes;
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)onPlusMinus:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSInteger count = [self.exchangeCountText.text integerValue];
    if(button.tag == 0)
        count --;
    else
        count ++;
    if(count < 1) count = 1;
    self.exchangeCountText.text = [NSString stringWithFormat:@"%d", count];    
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"exchange_info.jsp"];
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
            NSLog(@"ExchangeInfo: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            if([success intValue] == 1) {
                NSArray *keys = @[@"title", @"market_price", @"integral_price", @"total_secure", @"total_exchange", @"property", @"imagepath"];
                
                NSMutableDictionary *exchangeInfo = [NSMutableDictionary dictionary];
                for(NSString *key in keys) {
                    id val = [jsonDic objectForKey:key];
                    if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                        [exchangeInfo setObject:val forKey:key];
                        if([key compare:@"imagepath"] == NSOrderedSame) {
                            for(NSInteger i = 0; i < ((NSArray*)val).count; i ++) {
                                id subval = [(NSArray*)val objectAtIndex:i];
                                if(subval != nil && ![subval isKindOfClass:[NSNull class]]) {
                                    [subval stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                                }
                            }
                        }
                    }
                }
                
                self.titleLabel.text = [exchangeInfo objectForKey:[keys objectAtIndex:0]];
                self.marketPriceLabel.text = [NSString stringWithFormat:@"¥%@", [exchangeInfo objectForKey:[keys objectAtIndex:1]]];
                self.integralPriceLabel.text = [NSString stringWithFormat:@"所需积分: %@", [exchangeInfo objectForKey:[keys objectAtIndex:2]]];
                
                
                self.stockCountLabel.text = [NSString stringWithFormat:@"库存: %@", [exchangeInfo objectForKey:[keys objectAtIndex:3]]];
                self.totalExchangeLabel.text = [NSString stringWithFormat:@"累计兑换: %@", [exchangeInfo objectForKey:[keys objectAtIndex:4]]];
                
                NSString *propertyString = [exchangeInfo objectForKey:[keys objectAtIndex:5]];
                if(propertyString == nil || [propertyString isKindOfClass:[NSNull class]] || propertyString.length == 0)
                    propertyString = @"没有资料";
                self.explainLabel.text = propertyString;
                
                imagepathes = [exchangeInfo objectForKey:[keys objectAtIndex:6]];
                [self.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [imagepathes objectAtIndex:0]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
                
                [self fitExplainView];
                [self setScrollViewContentSize:NO];
                
                self.integralPrice = ((NSNumber*)[exchangeInfo objectForKey:[keys objectAtIndex:2]]).integerValue;
                self.totalSecure = ((NSNumber*)[exchangeInfo objectForKey:[keys objectAtIndex:3]]).integerValue;
            }
        }        
    } else{
        if([contentType compare:@"text"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)postToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [postController initialize];
        [postController setUrlPath:@"exchange_add.jsp"];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.itemId], @"product_id", self.exchangeCountText.text, @"exchange_count", [NSString stringWithFormat:@"%d", self.integralPrice], @"product_integral", nil];
        [postController setParams:params];
        [postController startSend];
    }
}

- (void)connectionCompleteForPost:(NSNotification *)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        NSData *data = [info objectForKey:@"data"];
        NSLog(@"ExchangeInfo PostExchange: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSNumber *success = [jsonDic objectForKey:@"success"];
        if ([success intValue] == 1) {
            //success;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"兑换失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
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
