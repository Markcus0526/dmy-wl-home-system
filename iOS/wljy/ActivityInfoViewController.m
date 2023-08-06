//
//  ActivityInfoViewController.m
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ActivityInfoViewController.h"
#import "Constants.h"
#import "PostEvalViewController.h"
#import "AnswerViewController.h"
#import "SingleInfoViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"


#define kScrollObjWidth     298
#define kScrollObjHeight    181


@implementation ActivityInfoViewController

- (void)setConstraint {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.navigateView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *metrics = [NSDictionary dictionary];
    NSDictionary *viewDic = [NSDictionary dictionaryWithObjectsAndKeys:self.scrollView, @"scrollView", self.navigateView, @"navView", nil];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:metrics views:viewDic]];
    
#ifdef IOS7
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[scrollView]|" options:0 metrics:metrics views:viewDic]];
#else
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[scrollView]|" options:0 metrics:metrics views:viewDic]];
#endif
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navView]|" options:0 metrics:metrics views:viewDic]];
    
#ifdef IOS7
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[navView(==80)]|" options:0 metrics:metrics views:viewDic]];
#else
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[navView(==60)]|" options:0 metrics:metrics views:viewDic]];
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
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPost:(id)sender {
    PostEvalViewController *viewController = (PostEvalViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostEval"];
    viewController.previousViewController = self;
    viewController.itemId = self.itemId;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)onShowSingle {
    SingleInfoViewController *viewController = (SingleInfoViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"SingleInfo"];
    viewController.itemId = self.itemId;
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches Begin");
    
    UITouch *touch = [touches anyObject];
    gestureStartPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {    
    UITouch *touch = [touches anyObject];
    CGPoint currentPostition = [touch locationInView:self.view];
    
    CGFloat deltaX = fabsf(gestureStartPoint.x - currentPostition.x);
    CGFloat deltaY = fabsf(gestureStartPoint.y - currentPostition.y);
    
    if(deltaX >= kMinGestureLength && deltaY <= kMaxVariance) {
        NSLog(@"Horizontal swipe deteted");
        //[self onShowAllEval:nil];
        [self onShowSingle];
    } else if(deltaY >= kMinGestureLength && deltaX <= kMaxVariance) {
        NSLog(@"Vertical swipe deteted");
    }
}

- (IBAction)onShowAllEval:(id)sender {
    AnswerViewController *viewController = (AnswerViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"Answer"];
    viewController.previousViewController = self;
    viewController.pageClass = @"activity";
    viewController.itemId = self.itemId;
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

- (NSInteger)fitAndCorrectView:(UIView*)view {
    CGRect firstRect = view.frame;
    
    [view sizeToFit];
    CGRect lastRect = view.frame;
    
    NSInteger dif = lastRect.size.height - firstRect.size.height;
    
    firstRect.size.height = lastRect.size.height;
    view.frame = firstRect;
    
    return dif;
}

- (void)fitImageView {
    NSInteger dif = [self fitAndCorrectView:self.bodyLabel];
    CGRect rect = self.imageScrollView.frame;
    rect.size.height += dif;
    rect.origin.y += dif;
    self.imageScrollView.frame = rect;
    
    [self setImagesToScroll];
}

- (void)setScrollViewContentSize {
    CGRect scrollRect = self.scrollView.frame;
    
    scrollRect.size.height = self.imageScrollView.frame.origin.y + self.imageScrollView.frame.size.height;
    
    [self.scrollView setContentSize:scrollRect.size];
}

- (void)setImagesToScroll {
    [self.imageScrollView setCanCancelContentTouches:NO];
	self.imageScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.imageScrollView.clipsToBounds = YES;
	self.imageScrollView.scrollEnabled = YES;
	self.imageScrollView.pagingEnabled = YES;
	
	// load all the images from our bundle and add them to the scroll view
	NSUInteger i;
	for (i = 1; i <= imageArray.count; i++)
	{
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScrollObjWidth, kScrollObjHeight)];
        [imageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [imageArray objectAtIndex:i-1]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
		
		imageView.tag = i;
		[self.imageScrollView addSubview:imageView];
	}
    
    [self layoutScrollImages];
}

- (void)layoutScrollImages {
	UIImageView *view = nil;
    NSArray *subviews = [self.imageScrollView subviews];
    
    CGFloat curXLoc = 0;
    for (view in subviews)
    {
        if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
        {
            CGRect frame = view.frame;
            frame.origin = CGPointMake(curXLoc, 0);
            view.frame = frame;
            
            curXLoc += kScrollObjWidth;
        }
    }
    
    [self.imageScrollView setContentSize:CGSizeMake((imageArray.count * kScrollObjWidth), [self.imageScrollView bounds].size.height)];
}

/*- (void)fitImageView {
    NSInteger dif = [self fitAndCorrectView:self.bodyLabel];
    CGRect rect = self.dataImageView.frame;
    rect.size.height += dif;
    rect.origin.y += dif;
    self.dataImageView.frame = rect;
}

- (void)setScrollViewContentSize {
    CGRect scrollRect = self.scrollView.frame;
    
    scrollRect.size.height = self.dataImageView.frame.origin.y + self.dataImageView.frame.size.height;
    
    [self.scrollView setContentSize:scrollRect.size];
}*/

- (void)collectItem:(NSInteger)itemId {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"collect"];
        [getController setUrlPath:@"collection_add.jsp"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", @"1", @"type", [NSString stringWithFormat:@"%d", itemId], @"id", nil];
        [getController setParams:params];
        [getController startReceive];
    }
}

- (IBAction)onNavigate:(id)sender {
    UIButton *button = (UIButton*)sender;
    if(button.tag == 0) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (button.tag == 1) {
        [self collectItem:self.itemId];
    } else if (button.tag == 2){
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Share"];
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        PostEvalViewController *viewController = (PostEvalViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostEval"];
        viewController.previousViewController = self;
        viewController.itemId = self.itemId;
        viewController.pageClass = @"activity";
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"activity_info.jsp"];
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
            NSLog(@"ActivityInfo: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            if([success intValue] == 1) {
                NSArray *keys = @[@"title", @"postdate", @"body", @"eval_count",  @"imagepath"];
                                
                NSMutableDictionary *activityInfo = [NSMutableDictionary dictionary];
                for(NSString *key in keys) {
                    id val = [jsonDic objectForKey:key];
                    if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                        [activityInfo setObject:val forKey:key];
                        /*if([key compare:@"imagepath"] == NSOrderedSame) {
                            [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                        }*/
                    }
                }
                
                self.titleLabel.text = [activityInfo objectForKey:[keys objectAtIndex:0]];
                self.postdateLabel.text = [activityInfo objectForKey:[keys objectAtIndex:1]];
                
                self.bodyLabel.text = [activityInfo objectForKey:[keys objectAtIndex:2]];
                if(self.bodyLabel.text == nil || [self.bodyLabel.text isKindOfClass:[NSNull class]] || self.bodyLabel.text.length == 0)
                    self.bodyLabel.text = @"没有资料";                
                
                [self.evalCountButton setTitle:[NSString stringWithFormat:@"%@评论", [activityInfo objectForKey:[keys objectAtIndex:3]]] forState:UIControlStateNormal];
                
                /*[self.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [activityInfo objectForKey:[keys objectAtIndex:4]]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];*/
                imageArray = (NSArray*)[activityInfo objectForKey:[keys objectAtIndex:4]];
                
                [self fitImageView];
                [self setScrollViewContentSize];
                
            }
        } else if ([contentType compare:@"collect"] == NSOrderedSame) {
            NSData *data = [info objectForKey:@"data"];
            NSLog(@"ActivityInfo Collect: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            if ([success intValue] == 1) {
                // Success
            } else if ([success intValue] == 2){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏失败" message:@"你已经收藏了对这个。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"收藏失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            }
        }
    } else{
        if([contentType compare:@"text"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
