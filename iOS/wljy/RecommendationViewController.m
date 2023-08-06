//
//  RecommendationViewController.m
//  wljy
//
//  Created by 111 on 14.01.14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "RecommendationViewController.h"
#import "Constants.h"
#import "ActivityInfoViewController.h"
#import "SingleInfoViewController.h"
#import "FaqInfoViewController.h"
#import "ExchangeInfoViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@implementation RecommendCell

@end


@implementation RecommendationViewController

- (void)setConstraint {    
    self.mainView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *metrics = [NSDictionary dictionary];
    NSDictionary *viewDic = [NSDictionary dictionaryWithObjectsAndKeys:self.tableView, @"tableView", self.mainView, @"mainView", nil];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainView]|" options:0 metrics:metrics views:viewDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|" options:0 metrics:metrics views:viewDic]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:metrics views:viewDic]];
#ifdef IOS7
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-88-[tableView]|" options:0 metrics:metrics views:viewDic]];
#else
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-68-[tableView]|" options:0 metrics:metrics views:viewDic]];
#endif
        
    //[self.view updateConstraints];
}

- (void)decorateTabBar {
    CGRect bar = self.tabBar.frame;
    [self.tabBar setFrame:(CGRect){bar.origin.x, bar.origin.y, bar.size.width, 30}];
    
    [self.tabBar setTintColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
    [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"main_submenu_select.png"]];
    
    for(int i = 0; i < 6; i ++) {
        UITabBarItem *item = [self.tabBar.items objectAtIndex:i];
        [item setTitle:@""];
        [item setTag:i];
        [item setFinishedSelectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"main_submenu_%d_sel.png", i+1]] withFinishedUnselectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"main_submenu_%d.png", i+1]]];
        [item setImageInsets:(UIEdgeInsets){12, 12, 0, 12}];
        if(i == 0) self.tabBar.selectedItem = item;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];	
    
    //[self setConstraint];
    
    CGRect maskRect = self.maskView.frame; maskRect.origin.y = 60;
    self.maskView.frame = maskRect;
    [self decorateTabBar];
    [self.tabBar setDelegate:self];
    self.loadingIndicator.hidden = YES;
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    getController = [[GetController alloc] init];
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self decorateTabBar];
    
    [self.userImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, appDelegate.imagepath]] placeholderImage:[UIImage imageNamed:@"main_header_image.png"]];
    
    recommends = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
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
        [getController setUrlPath:@"main.jsp"];
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
            NSLog(@"Recommend: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            if([success intValue] == 1) {
                NSArray *subtitles = @[SubTitle_Activity, SubTitle_Share, SubTitle_Faq, SubTitle_Study, SubTitle_Exchange];
                NSArray *keys = @[@"activity", @"share", @"faq", @"study", @"exchange"];
                NSArray *subkeys = @[@"id", @"type", @"user", @"title", @"readcount", @"image"];
                
                int i = 0;
                for(NSString *key in keys) {
                    NSMutableDictionary *recommend = [NSMutableDictionary dictionary];
                    
                    [recommend setObject:[subtitles objectAtIndex:i] forKey:@"name"];
                    
                    NSDictionary *dic = [jsonDic objectForKey:key];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:[NSString stringWithFormat:@"%@_%@", key, subkey]];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            if([subkey compare:@"image"] == NSOrderedSame) {
                                val = [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                            }
                            [recommend setObject:val forKey:subkey];
                        }
                    }
                    [recommends addObject:recommend];
                    i++;
                }
                
                [self.tableView reloadData];
                
                self.feedbackBadge = ((NSNumber*)[jsonDic objectForKey:@"feedback"]).integerValue;
            }
        }
        
    } else{
        if([contentType compare:@"text"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 114;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recommends count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RecommendCellIdentifier";
    
    RecommendCell *cell = (RecommendCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /*if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCell" owner:self options:nil];
        for(id oneObject in nib)
        {
            if([oneObject isKindOfClass:[RecommendCell class]])
                cell = (RecommendCell*)oneObject;
        }
        cell = [[RecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RecommendCellIdentifier];
        
    }*/
        
    NSDictionary *rowData = [recommends objectAtIndex:[indexPath row]];
    [[cell nameLabel] setText:[rowData objectForKey:@"name"]];
    [[cell titleLabel] setText:[rowData objectForKey:@"title"]];
    [[cell userLabel] setText:[rowData objectForKey:@"user"]];
    if([indexPath row] < 4)
        [[cell countLabel] setText:[NSString stringWithFormat:@"☺ %@", [rowData objectForKey:@"readcount"]]];
    else
        [[cell countLabel] setText:@""];
    [cell.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = [recommends objectAtIndex:[indexPath row]];
    
    switch ([indexPath row]) {
        case 0:
        {
            ActivityInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityInfo"];
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case 1:
        {            
            FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
            viewController.pageClass = @"share";
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case 2:
        {
            FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
            viewController.pageClass = @"faq";
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case 3:
        {
            FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
            viewController.pageClass = @"study";
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case 4:
        {
            ExchangeInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ExchangeInfo"];
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (void)navigatorOrInfoHidden {
    [self.maskView removeFromSuperview];
    if(self.isNavigatorShown)
        [self.navigatorView removeFromSuperview];
    else
        [self.myInfoView removeFromSuperview];
}

- (void)animateNavigator:(BOOL)show {    
    if(show) {
        [self.view.window addSubview: self.maskView];
        [self.view.window addSubview: self.navigatorView];        
        
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        
        self.maskView.frame = CGRectMake(screenRect.origin.x, screenRect.origin.y+40, screenRect.size.width, screenRect.size.height);
		CGSize navigatorSize = [self.navigatorView sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(screenRect.origin.x + screenRect.size.width, 60.0, navigatorSize.width, navigatorSize.height);
		self.navigatorView.frame = startRect;
		
		CGRect endRect = CGRectMake(screenRect.origin.x + screenRect.size.width - navigatorSize.width, 60.0, navigatorSize.width, navigatorSize.height);
        
		[UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
		
        //[UIView setAnimationDelegate:self];
		
        self.navigatorView.frame = endRect;
        self.maskView.alpha = 0.8;
        
		[UIView commitAnimations];
    } else {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.navigatorView.frame;
        endFrame.origin.x = screenRect.origin.x + screenRect.size.width;
        
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
        
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(navigatorOrInfoHidden)];
        
		self.navigatorView.frame = endFrame;
        self.maskView.alpha = 0.0;
        
        [UIView commitAnimations];
    }
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSArray *viewName = @[@"Activity", @"Share", @"Faq", @"Study"];
    if(item.tag > 0 && item.tag < 5) {
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[viewName objectAtIndex:item.tag-1]];
        [self presentViewController:viewController animated:YES completion:nil];    
    } else if(item.tag == 5) {
        self.isNavigatorShown = YES;
        [self animateNavigator:YES];
    }
}

- (IBAction)onNavigate:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSArray *viewName = @[@"Activity", @"Share", @"Faq", @"Study", @"Feedback", @"Exchange", @"Search"];
    [self animateNavigator:NO];
    
    if(button.tag > 0)  {
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:[viewName objectAtIndex:button.tag-1]];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];        
    }
        
}

- (IBAction)onNavCancel:(id)sender {
    if(self.isNavigatorShown) {
        [self animateNavigator:NO];
        self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    } else
        [self animateMyInfo:NO];
}

- (void)animateMyInfo:(BOOL)show {    
    if(show) {
        [self.view.window addSubview: self.maskView];
        [self.view.window addSubview: self.myInfoView];
        
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        self.maskView.frame = screenRect;
		CGSize myInfoSize = [self.myInfoView sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(screenRect.origin.x + screenRect.size.width, screenRect.origin.y, myInfoSize.width, myInfoSize.height);
		self.myInfoView.frame = startRect;
		
		CGRect endRect = CGRectMake(screenRect.origin.x + screenRect.size.width - myInfoSize.width, screenRect.origin.y, myInfoSize.width, myInfoSize.height);
        CGRect endRectForMain = self.mainView.frame;
        endRectForMain.origin.x -= endRect.size.width;
        
		[UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
		
        //[UIView setAnimationDelegate:self];
		
        self.myInfoView.frame = endRect;
        self.maskView.alpha = 0.1;
        self.mainView.frame= endRectForMain;
        
		[UIView commitAnimations];
    } else {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.myInfoView.frame;
        endFrame.origin.x = screenRect.origin.x + screenRect.size.width;
        
        CGRect endRectForMain = self.mainView.frame;
        endRectForMain.origin.x += endFrame.size.width;
        
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
        
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(navigatorOrInfoHidden)];
        
		self.myInfoView.frame = endFrame;
        self.maskView.alpha = 0;
        self.mainView.frame= endRectForMain;
        
        [UIView commitAnimations];
    }
}

- (IBAction)onMyInfo:(id)sender {
    [self navigatorOrInfoHidden];
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    
    self.isNavigatorShown = NO;
    
    [self.myInfoView.userImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, appDelegate.imagepath]] placeholderImage:[UIImage imageNamed:@"main_header_image.png"]];
    self.myInfoView.userNameLabel.text = appDelegate.username;
    self.myInfoView.propertyLabel.text = [NSString stringWithFormat:@"财富: %d ♕", appDelegate.userIntegral];
    self.myInfoView.lastLoginDateLabel.text = [NSString stringWithFormat:@"上次登录时间: %@", appDelegate.lastLoginDate];
    [self.myInfoView applyBackgroundSettings];
    self.myInfoView.currentViewController = self;
    
    if(self.feedbackBadge > 0) {
        self.myInfoView.hidden = NO;
        [self.myInfoView.feedbackBadgeButton setTitle:[NSString stringWithFormat:@"%d", self.feedbackBadge] forState:UIControlStateNormal];
    } else
        self.myInfoView.hidden = NO;        
    
    [self animateMyInfo:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
