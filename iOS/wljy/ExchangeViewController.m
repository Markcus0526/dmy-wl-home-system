//
//  ExchangeViewController.m
//  wljy
//
//  Created by 111 on 14.01.16.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ExchangeViewController.h"
#import "Constants.h"
#import "ExchangeInfoViewController.h"
#import "PostExchangeViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@implementation ExchangeCell

@end

@implementation ExchangeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self.todayLabel setText:[appDelegate getTodayDate]];    
    [self.noDataLabel setHidden:YES];
    [self.tableViewLeft.backgroundView setHidden:YES];
    [self.tableViewRight.backgroundView setHidden:YES];
    [self.loadingIndicator setHidden:YES];
    getController = [[GetController alloc] init];
    [self registerNotifications];
    
    self.type = 0;
    [self.type1Button setSelected:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self clearSelection];
    self.page = 1;
    self.lastArrived = NO;
    
    exchanges = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onPost:(id)sender {
    PostExchangeViewController *viewController = (PostExchangeViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostExchange"];
    viewController.previousViewController = self;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)clearSelection {
    [self.type1Button setSelected:NO];
    [self.type2Button setSelected:NO];
    [self.type3Button setSelected:NO];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];        
        [self.noDataLabel setHidden:YES];
    }
    else
        [self.loadingIndicator startAnimating];
    self.type1Button.enabled = isLoaded;
    self.type2Button.enabled = isLoaded;
    self.type3Button.enabled = isLoaded;
}

- (IBAction)onSubtitle:(id)sender {
    UIButton *button = (UIButton*)sender;
    if([button isSelected] == NO) {
        [self clearSelection];
        [button setSelected:YES];
        self.type = button.tag;
        self.page = 1;
        self.lastArrived = NO;
        
        [exchanges removeAllObjects];
        [self.tableViewLeft reloadData];
        [self.tableViewRight reloadData];
        [self connectToServer];
    }
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"exchange.jsp"];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.type], @"type", [NSString stringWithFormat:@"%d", self.page], @"page",nil];
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
                NSArray *subkeys = @[@"id", @"name", @"market_price", @"integral_price", @"imagepath"];
                
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
                    [exchanges addObject:exchange];
                }
                
                [self.tableViewLeft reloadData];
                [self.tableViewRight reloadData];         
                
            } else {
                self.lastArrived = YES;
                if(exchanges.count == 0)
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

- (NSInteger)exchangeIndex:(NSInteger)index tableView:(UITableView*)tableView {
    if([tableView isEqual:self.tableViewLeft])
        return index * 2;
    else
        return index * 2 + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 205;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 2.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [exchanges count];
    if([tableView isEqual:self.tableViewLeft])
        return (int)(count / 2) + count % 2;
    else
        return count / 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ExchangeCellIdentifier";
    
    ExchangeCell *cell = (ExchangeCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /*if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ExchangeCell" owner:self options:nil];
        for(id oneObject in nib)
        {
            if([oneObject isKindOfClass:[ExchangeCell class]])
                cell = (ExchangeCell*)oneObject;
        }
    }*/
    
    NSInteger index = [self exchangeIndex:[indexPath section] tableView:tableView];
    NSDictionary *rowData = [exchanges objectAtIndex:index];
    [[cell titleLabel] setText:[rowData objectForKey:@"name"]];
    [[cell priceLabel] setText:[NSString stringWithFormat:@"¥%.2f", [[rowData objectForKey:@"market_price"] floatValue]]];
    [[cell integralLabel] setText:[NSString stringWithFormat:@"积分: %d", [[rowData objectForKey:@"integral_price"] intValue]]];
    
    [cell.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:self.tableViewLeft]) {
        NSIndexPath *iPath = [self.tableViewRight indexPathForSelectedRow];
        [self.tableViewRight deselectRowAtIndexPath:iPath animated:YES];
    } else {
        NSIndexPath *iPath = [self.tableViewLeft indexPathForSelectedRow];
        [self.tableViewLeft deselectRowAtIndexPath:iPath animated:YES];
    }
    
    NSInteger index = [self exchangeIndex:[indexPath section] tableView:tableView];
    NSDictionary *rowData = [exchanges objectAtIndex:index];
    
    ExchangeInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ExchangeInfo"];
    viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UIScrollView *other = (UIScrollView*)(([scrollView isEqual:self.tableViewLeft]) ? self.tableViewRight : self.tableViewLeft);
    [other setContentOffset:[scrollView contentOffset]];
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
