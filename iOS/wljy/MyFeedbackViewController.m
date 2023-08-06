//
//  MyFeedbackViewController.m
//  wljy
//
//  Created by 111 on 14.03.06.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "MyFeedbackViewController.h"
#import "Constants.h"

#define kCellBodyHeight         21
#define kCellBodyWidth          287

@implementation MyFeedbackCell


@end 

@implementation MyFeedbackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    [self.todayLabel setText:[appDelegate getTodayDate]];
    [self.tableView.backgroundView setHidden:YES];
    [self.loadingIndicator setHidden:YES];
    self.noDataLabel.hidden = YES;
    getController = [[GetController alloc] init];
    [self registerNotifications];
    
    self.type = 0;
    [self.allButton setSelected:YES];
    
    testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCellBodyWidth, kCellBodyHeight)];
    testLabel.numberOfLines = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self clearSelection];
    self.page = 1;
    self.lastArrived = NO;
    
    
    myfeedbacks = [NSMutableArray array];
    heightDiffs = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)fitView:(MyFeedbackCell*)cell index:(NSInteger)index {
    //NSInteger dif = [self fitAndCorrectView:cell.bodyLabel];
    NSInteger dif = ((NSNumber*)[heightDiffs objectAtIndex:index]).integerValue;
    
    CGRect rect = cell.bodyLabel.frame;
    rect.size.height = kCellBodyHeight + dif;
    cell.bodyLabel.frame = rect;
    
    //rect = cell.frame;
    //rect.size.height += dif;
    //cell.frame = rect;
}

- (void)clearSelection {
    [self.allButton setSelected:NO];
    [self.passedButton setSelected:NO];
    [self.unpassedButton setSelected:NO];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
        self.noDataLabel.hidden = YES;
    }
    else
        [self.loadingIndicator startAnimating];
    self.allButton.enabled = isLoaded;
    self.passedButton.enabled = isLoaded;
    self.unpassedButton.enabled = isLoaded;
}

- (IBAction)onSubtitle:(id)sender {
    UIButton *button = (UIButton*)sender;
    if([button isSelected] == NO) {
        [self clearSelection];
        [button setSelected:YES];
        self.type = button.tag;
        self.page = 1;
        self.lastArrived = NO;
        
        [myfeedbacks removeAllObjects];
        [heightDiffs removeAllObjects];
        [self.tableView reloadData];
        [self connectToServer];
    }
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"myopinion.jsp"];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.type], @"state", [NSString stringWithFormat:@"%d", self.page], @"page",nil];
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
            NSLog(@"MyFeedback: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"title", @"state", @"body", @"postdate", @"gainintegral"];
                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *myfeedback = [NSMutableDictionary dictionary];
                    NSNumber *dif;
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            if([subkey compare:@"body"] == NSOrderedSame) {
                                testLabel.frame = CGRectMake(0, 0, kCellBodyWidth, kCellBodyHeight);
                                testLabel.text = (NSString*)val;
                                dif = [NSNumber numberWithInt:[self fitAndCorrectView:testLabel]];
                                
                            }
                            [myfeedback setObject:val forKey:subkey];
                        }
                    }
                    [myfeedbacks addObject:myfeedback];
                    [heightDiffs addObject:dif];
                }
                
                [self.tableView reloadData];
            } else {
                self.lastArrived = YES;
                if(myfeedbacks.count == 0)
                    [self.noDataLabel setHidden:NO];
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
    return 80 + ((NSNumber*)[heightDiffs objectAtIndex:[indexPath section]]).integerValue;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 2.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [myfeedbacks count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyFeedbackCellIdentifier";
    
    MyFeedbackCell *cell = (MyFeedbackCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];    
    NSDictionary *rowData = [myfeedbacks objectAtIndex:[indexPath section]];
    [[cell titleLabel] setText:[rowData objectForKey:@"title"]];
    [[cell dateLabel] setText:[NSString stringWithFormat:@"献策日期: %@", [rowData objectForKey:@"postdate"]]];
    [[cell bodyLabel] setText:[NSString stringWithFormat:@"%@", [rowData objectForKey:@"body"]]];
    [[cell rewardIntegralLabel] setText:[NSString stringWithFormat:@"获得积分: %d", [[rowData objectForKey:@"gainintegral"] intValue]]];
    
    [self fitView:cell index:[indexPath section]];
    
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
