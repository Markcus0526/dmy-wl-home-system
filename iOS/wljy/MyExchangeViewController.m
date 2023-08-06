//
//  MyExchangeViewController.m
//  wljy
//
//  Created by 111 on 14.01.22.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "MyExchangeViewController.h"
#import "Constants.h"
#import "PostExchangeViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@implementation MyExchangeCell

@end

@implementation MyExchangeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    
    [self.tableView.backgroundView setHidden:YES];
    [self.loadingIndicator setHidden:YES];
    self.noDataLabel.hidden = YES;
    getController = [[GetController alloc] init];
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.page = 1;
    self.lastArrived = NO;
    myExchanges = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
     [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPost:(id)sender {
    PostExchangeViewController *viewController = (PostExchangeViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostExchange"];
    viewController.previousViewController = self;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
        [self.noDataLabel setHidden:YES];
    }
    else
        [self.loadingIndicator startAnimating];
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"myexchange.jsp"];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.page], @"page",nil];
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
            NSLog(@"Exchange: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"title", @"market_price", @"integral_price", @"state", @"imagepath"];
                                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *exchange = [NSMutableDictionary dictionary];
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            if([subkey compare:@"imagepath"] == NSOrderedSame) {
                                val = [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                            }
                            [exchange setObject:val forKey:subkey];
                        }
                    }
                    [myExchanges addObject:exchange];
                }
                
                [self.tableView reloadData];                
            } else {
                self.lastArrived = YES;
                if(myExchanges.count == 0)
                    [self.noDataLabel setHidden:NO];
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
    return 99;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 2.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return [myExchanges count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyExchangeCellIdentifier";
    
    MyExchangeCell *cell = (MyExchangeCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary *rowData = [myExchanges objectAtIndex:[indexPath section]];
    
    [[cell titleLabel] setText:[rowData objectForKey:@"title"]];
    [[cell marketPriceLabel] setText:[NSString stringWithFormat:@"¥%.2f", [[rowData objectForKey:@"market_price"] floatValue]]];
    [[cell integralPriceLabel] setText:[NSString stringWithFormat:@"积分: %d", [[rowData objectForKey:@"integral_price"] intValue]]];    
    [[cell stateLabel] setText:[rowData objectForKey:@"state"]];
    if([((NSString*)[rowData objectForKey:@"state"]) compare:@"等待受理"] == NSOrderedSame) {
        cell.stateLabel.textColor = [UIColor redColor];
    } else if([((NSString*)[rowData objectForKey:@"state"]) compare:@"已受理可领取"] == NSOrderedSame) {
        cell.stateLabel.textColor = [UIColor greenColor];
    } else if([((NSString*)[rowData objectForKey:@"state"]) compare:@"没有兑换"] == NSOrderedSame) {
        cell.stateLabel.textColor = [UIColor blueColor];
    } else {
        cell.stateLabel.textColor = [UIColor darkGrayColor];
    }
        
    [cell.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    
    
    return cell;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(targetContentOffset->y + scrollView.frame.size.height >= scrollView.contentSize.height && self.lastArrived == NO) {
        self.page ++;
        [self connectToServer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
