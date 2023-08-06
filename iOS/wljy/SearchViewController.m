//
//  SearchViewController.m
//  wljy
//
//  Created by 111 on 14.01.23.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "SearchViewController.h"
#import "Constants.h"
#import "ActivityInfoViewController.h"
#import "FaqInfoViewController.h"


@implementation SearchCell

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    
    [self.noDataLabel setHidden:YES];
    [self.loadingIndicator setHidden:YES];
    getController = [[GetController alloc] init];
    [self registerNotifications];
    
    self.page = 0;
    self.lastArrived = NO;
    results = [NSMutableArray array];
    
    [self.mySearchBar becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
     [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if(searchBar.text.length < 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"搜索错误" message:@"无搜索字!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self.mySearchBar resignFirstResponder];
    
    self.page = 0;
    self.lastArrived = NO;
    results = [NSMutableArray array];
    [self.tableView reloadData];
    
    self.searchText = searchBar.text;
    [self postToServer];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    [self searchBarSearchButtonClicked:searchBar];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([self.mySearchBar isFirstResponder])
        [self.mySearchBar resignFirstResponder];
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

- (void)postToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setUrlPath:@"search.jsp"];
        [getController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", self.searchText, @"search", [NSString stringWithFormat:@"%d", self.page], @"page", nil];
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
            NSLog(@"Search: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1) {
                if([count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"title", @"type"];
                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *result = [NSMutableDictionary dictionary];
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            [result setObject:val forKey:subkey];
                        }
                    }
                    [results addObject:result];
                }
                
                [self.tableView reloadData];
            } else {
                self.lastArrived = YES;
                if(results.count == 0)
                    [self.noDataLabel setHidden:NO];
            }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"搜索失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            }
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [results count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchCellIdentifier";
    
    SearchCell *cell = (SearchCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *rowData = [results objectAtIndex:[indexPath section]];
    NSNumber *ctype = [rowData objectForKey:@"type"];
    switch(ctype.integerValue) {
        case 1:
            [[cell pageClassLabel] setText:@"活动"];
            break;
        case 2:
            [[cell pageClassLabel] setText:@"学习"];
            break;
        case 3:
            [[cell pageClassLabel] setText:@"分享"];
            break;
        case 4:
            [[cell pageClassLabel] setText:@"问答"];
            break;
        default:
            [[cell pageClassLabel] setText:@"其他"];
            break;
    }
    [[cell contentLabel] setText:[rowData objectForKey:@"title"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = [results objectAtIndex:[indexPath section]];
    NSNumber *ctype = [rowData objectForKey:@"type"];
    switch (ctype.integerValue) {
        case 1:
        {
            ActivityInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityInfo"];
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case 2:
        {
            FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
            viewController.pageClass = @"study";
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case 3:
        {
            FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
            viewController.pageClass = @"share";
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
        case 4:
        {
            FaqInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FaqInfo"];
            viewController.pageClass = @"faq";
            viewController.itemId = [[rowData objectForKey:@"id"] integerValue];
            self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(targetContentOffset->y + scrollView.frame.size.height >= scrollView.contentSize.height && self.lastArrived == NO) {
        self.page ++;
        [self postToServer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
