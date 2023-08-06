//
//  StudyViewController.m
//  wljy
//
//  Created by 111 on 14.01.16.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "StudyViewController.h"
#import "Constants.h"
#import "FaqInfoViewController.h"

@implementation StudyCell

@end

@implementation StudyViewController


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
    
    self.type = 0;
    [self.allButton setSelected:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self clearSelection];
    self.page = 1;
    self.lastArrived = NO;
    
    studies = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (void)clearSelection {
    [self.allButton setSelected:NO];
    [self.majorButton setSelected:NO];
    [self.enterpriseButton setSelected:NO];
    [self.otherButton setSelected:NO];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
        [self.noDataLabel setHidden:YES];
    }
    else
        [self.loadingIndicator startAnimating];
    self.allButton.enabled = isLoaded;
    self.majorButton.enabled = isLoaded;
    self.enterpriseButton.enabled = isLoaded;
    self.otherButton.enabled = isLoaded;
}

- (IBAction)onSubtitle:(id)sender {
    UIButton *button = (UIButton*)sender;
    if([button isSelected] == NO) {
        [self clearSelection];
        [button setSelected:YES];
        self.type = button.tag;
        self.page = 1;
        self.lastArrived = NO;
        
        [studies removeAllObjects];
        [self.tableView reloadData];
        [self connectToServer];
    }
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"study.jsp"];
        
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
            NSLog(@"Study: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"title", @"body", @"postdate", @"read_count", @"answer_count"];
                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *study = [NSMutableDictionary dictionary];
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            [study setObject:val forKey:subkey];
                        }
                    }
                    [studies addObject:study];
                }
                
                [self.tableView reloadData];
            } else {
                self.lastArrived = YES;
                if(studies.count == 0)
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
    return 127;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 2.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [studies count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StudyCellIdentifier";
    
    StudyCell *cell = (StudyCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /*if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudyCell" owner:self options:nil];
        for(id oneObject in nib)
        {
            if([oneObject isKindOfClass:[StudyCell class]])
                cell = (StudyCell*)oneObject;
        }
    }*/
    
    NSDictionary *rowData = [studies objectAtIndex:[indexPath section]];
    [[cell titleLabel] setText:[rowData objectForKey:@"title"]];
    [[cell dateLabel] setText:[NSString stringWithFormat:@"更新日期: %@", [rowData objectForKey:@"postdate"]]];
    [[cell bodyLabel] setText:[NSString stringWithFormat:@"%@ [详细]", [rowData objectForKey:@"body"]]];
    [[cell readCountLabel] setText:[NSString stringWithFormat:@"游览: %d", [[rowData objectForKey:@"read_count"] intValue]]];
    [[cell answerCountLabel] setText:[NSString stringWithFormat:@"回答: %d", [[rowData objectForKey:@"answer_count"] intValue]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = [studies objectAtIndex:[indexPath section]];
    
    FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
    viewController.pageClass = @"study";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
