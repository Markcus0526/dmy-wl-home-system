//
//  MyCollectionViewController.m
//  wljy
//
//  Created by 111 on 14.01.26.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "Constants.h"

@implementation MyCollectionCell

@end

@implementation MyCollectionViewController

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
    mycollections = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPost:(id)sender {
    /*PostFaqViewController *viewController = (PostFaqViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostFaq"];
    viewController.previousViewController = self;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];*/
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
        self.noDataLabel.hidden = YES;
    }
    else
        [self.loadingIndicator startAnimating];
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"collection.jsp"];
        
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
            NSLog(@"MyCollection: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"title", @"type"];
                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *collection = [NSMutableDictionary dictionary];
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            [collection setObject:val forKey:subkey];
                        }
                    }
                    [mycollections addObject:collection];
                }
                
                [self.tableView reloadData];
            } else {
                self.lastArrived = YES;
                if(mycollections.count == 0)
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
    return 57;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [mycollections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyCollectionCellIdentifier";
    
    MyCollectionCell *cell = (MyCollectionCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *rowData = [mycollections objectAtIndex:[indexPath section]];
    NSNumber *ctype = [rowData objectForKey:@"type"];
    switch(ctype.integerValue) {
        case 1:
            [[cell pageClassLabel] setText:@"活动"];
            break;
        case 2:
            [[cell pageClassLabel] setText:@"分享"];
            break;
        default:
            [[cell pageClassLabel] setText:@"其他"];
            break;
    }
    [[cell contentLabel] setText:[rowData objectForKey:@"title"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*NSDictionary *rowData = [mycollections objectAtIndex:[indexPath section]];
    
    FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
    viewController.pageClass = @"faq";
    viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];*/
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
