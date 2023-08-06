//
//  AnswerViewController.m
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "AnswerViewController.h"
#import "Constants.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

#define kCellBackImageHeight    72
#define kCellBodyHeight         21
#define kCellBodyWidth         255
#define kCellLeftBackHeight        87
#define kCellRightBackHeight         72
#define kCellBottomBackY         76

@implementation AnswerCell

@end

@implementation AnswerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    [self.todayLabel setText:[appDelegate getTodayDate]];
    [self.tableView.backgroundView setHidden:YES];
    [self.loadingIndicator setHidden:YES];
    getController = [[GetController alloc] init];
    [self registerNotifications];
    
    testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCellBodyWidth, kCellBodyHeight)];
    testLabel.numberOfLines = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([self.pageClass compare:@"faq"] == NSOrderedSame) {
        self.viewTitleLabel.text = @"问答";
        self.tableViewTitleLabel.text = @"       全部回答";
    } else if([self.pageClass compare:@"study"] == NSOrderedSame) {
        self.viewTitleLabel.text = @"学习";
        self.tableViewTitleLabel.text = @"       全部回答";
    } else if([self.pageClass compare:@"activity"] == NSOrderedSame) {
        self.viewTitleLabel.text = @"活动";
        self.tableViewTitleLabel.text = @"       全部评论";
    } else if([self.pageClass compare:@"single"] == NSOrderedSame) {
        self.viewTitleLabel.text = @"活动";
        self.tableViewTitleLabel.text = @"       全部评论";
    }
    
    self.page = 1;
    self.lastArrived = NO;
    answers = [NSMutableArray array];
    heightDiffs = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onBack:(id)sender {
    //self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    //[self presentViewController:self.previousViewController animated:YES completion:nil];
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

- (void)fitView:(AnswerCell*)cell index:(NSInteger)index {
    //NSInteger dif = [self fitAndCorrectView:cell.bodyLabel];
    NSInteger dif = ((NSNumber*)[heightDiffs objectAtIndex:index]).integerValue;
    
    CGRect rect = cell.bodyLabel.frame;
    rect.size.height = kCellBodyHeight + dif;
    cell.bodyLabel.frame = rect;
    
    rect = cell.backImageView1.frame;
    rect.size.height = kCellLeftBackHeight + dif;
    cell.backImageView1.frame = rect;
    
    rect = cell.backImageView2.frame;
    rect.size.height = kCellRightBackHeight + dif;
    cell.backImageView2.frame = rect;
    
    rect = cell.backImageView3.frame;
    rect.origin.y = kCellBottomBackY + dif;
    cell.backImageView3.frame = rect;
    
    /*rect = cell.backImageView.frame;
    rect.size.height = kCellBackImageHeight + dif;
    cell.backImageView.frame = rect;*/
    
    
    
    //rect = cell.frame;
    //rect.size.height += dif;
    //cell.frame = rect;
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
        self.noDataLabel.hidden = YES;
        [self.tableView setHidden:NO];
    }
    else
        [self.loadingIndicator startAnimating];
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:[NSString stringWithFormat:@"%@_detail.jsp", self.pageClass]];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.itemId], @"id", [NSString stringWithFormat:@"%d", self.page], @"page", nil];
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
            NSLog(@"FaqAnswer: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"name", @"body", @"postdate", @"eval", @"imagepath"];
                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *answer = [NSMutableDictionary dictionary];
                    NSNumber *dif;
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            if([subkey compare:@"body"] == NSOrderedSame) {
                                testLabel.frame = CGRectMake(0, 0, kCellBodyWidth, kCellBodyHeight);
                                testLabel.text = (NSString*)val;
                                dif = [NSNumber numberWithInt:[self fitAndCorrectView:testLabel]];
                                
                            } else if([subkey compare:@"imagepath"] == NSOrderedSame) {
                                val = [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                            }
                            [answer setObject:val forKey:subkey];
                        }
                    }
                    [answers addObject:answer];
                    [heightDiffs addObject:dif];
                }
                
                [self.tableView reloadData];
            } else {
                self.lastArrived = YES;
                if(answers.count == 0) {
                    [self.noDataLabel setHidden:NO];
                    [self.tableView setHidden:YES];
                }
            }
        }
        
    } else{
        if([contentType compare:@"text"] == NSOrderedSame) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
            
            [self.noDataLabel setHidden:NO];
            [self.tableView setHidden:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 87 + ((NSNumber*)[heightDiffs objectAtIndex:[indexPath row]]).integerValue;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}
    
/*- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [faqs count];
}*/

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.tableHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [answers count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AnswerCellIdentifier";
    
    AnswerCell *cell = (AnswerCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *rowData = [answers objectAtIndex:[indexPath row]];
    [[cell nameLabel] setText:[rowData objectForKey:@"name"]];
    [[cell dateLabel] setText:[NSString stringWithFormat:@"%@天前", [rowData objectForKey:@"postdate"]]];
    [[cell bodyLabel] setText:[rowData objectForKey:@"body"]];
    [[cell evalLabel] setText:[rowData objectForKey:@"eval"]];
        
    [cell.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    
    [self fitView:cell index:[indexPath row]];
    
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
