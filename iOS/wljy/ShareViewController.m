//
//  ShareViewController.m
//  wljy
//
//  Created by 111 on 14.01.16.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ShareViewController.h"
#import "Constants.h"
#import "FaqInfoViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@implementation ShareCell

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    [self.todayLabel setText:[appDelegate getTodayDate]];    
    [self.noDataLabel setHidden:YES];
    [self.tableView.backgroundView setHidden:YES];
    [self.loadingIndicator setHidden:YES];
    getController = [[GetController alloc] init];
    [self registerNotifications];
    
    self.type = 1;
    [self.typeAButton setSelected:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self clearSelection];
    self.page = 1;
    self.lastArrived = NO;
    
    shares = [NSMutableArray array];
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

- (void)clearSelection {
    [self.typeAButton setSelected:NO];
    [self.typeBButton setSelected:NO];
    [self.typeCButton setSelected:NO];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
        [self.noDataLabel setHidden:YES];
    }
    else
        [self.loadingIndicator startAnimating];
    self.typeAButton.enabled = isLoaded;
    self.typeBButton.enabled = isLoaded;
    self.typeCButton.enabled = isLoaded;
}

- (IBAction)onSubtitle:(id)sender {
    UIButton *button = (UIButton*)sender;
    if([button isSelected] == NO) {
        [self clearSelection];
        [button setSelected:YES];
        self.type = button.tag;
        self.page = 1;
        self.lastArrived = NO;
        
        [shares removeAllObjects];
        [self.tableView reloadData];
        [self connectToServer];
    }
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"share.jsp"];        
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
            NSLog(@"Share: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"title", @"body", @"postdate", @"eval_count", @"readcount", @"username", @"imagepath"];
                                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *share = [NSMutableDictionary dictionary];
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            if([subkey compare:@"imagepath"] == NSOrderedSame) {
                                val = [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                            }
                            [share setObject:val forKey:subkey];
                        }
                    }
                    [shares addObject:share];
                }
                
                [self.tableView reloadData];
                
            } else {
                self.lastArrived = YES;
                if(shares.count == 0)
                    [self.noDataLabel setHidden:NO];
            }
        } else if ([contentType compare:@"collect"] == NSOrderedSame) {
            NSData *data = [info objectForKey:@"data"];
            NSLog(@"Share Collect: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
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
    } else {
        if([contentType compare:@"text"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 222;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 2.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [shares count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ShareCellIdentifier";
    
    ShareCell *cell = (ShareCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /*if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShareCell" owner:self options:nil];
        for(id oneObject in nib)
        {
            if([oneObject isKindOfClass:[ShareCell class]])
                cell = (ShareCell*)oneObject;
        }
    }*/
    
    NSDictionary *rowData = [shares objectAtIndex:[indexPath section]];
    [[cell titleLabel] setText:[rowData objectForKey:@"title"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDateComponents *dateCom = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:[dateFormatter dateFromString:[rowData objectForKey:@"postdate"]]];
    [[cell dayLabel] setText:[NSString stringWithFormat:@"%d", dateCom.day]];
    [[cell yearMonthLabel] setText:[NSString stringWithFormat:@"%d. %d", dateCom.year, dateCom.month]];
    [[cell dayOfWeekLabel] setText:[appDelegate dayOfWeekString:dateCom.weekday]];
    
    
    [[cell bodyLabel] setText:[rowData objectForKey:@"body"]];
    //[[cell evalCountLabel] setText:[NSString stringWithFormat:@"评论: %d", [[rowData objectForKey:@"eval_count"] intValue]]];
    [[cell readCountLabel] setText:[NSString stringWithFormat:@"☺ %@", [rowData objectForKey:@"readcount"]]];
    [[cell usernameLabel] setText:[rowData objectForKey:@"username"]];
        
    [cell.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    
    [cell.collectButton setTag:((NSNumber*)[rowData objectForKey:@"id"]).integerValue];
    [cell.collectButton addTarget:self action:@selector(onCollect:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = [shares objectAtIndex:[indexPath section]];
    
    FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
    viewController.pageClass = @"share";
    viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(targetContentOffset->y + scrollView.frame.size.height >= scrollView.contentSize.height && self.lastArrived == NO) {
        self.page ++;
        [self connectToServer];
    }
}

- (IBAction)onCollect:(id)sender {
    [self collectItem:((UIButton*)sender).tag];
}

- (void)collectItem:(NSInteger)itemId {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"collect"];
        [getController setUrlPath:@"collection_add.jsp"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", @"2", @"type", [NSString stringWithFormat:@"%d", itemId], @"id", nil];
        [getController setParams:params];
        [getController startReceive];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
