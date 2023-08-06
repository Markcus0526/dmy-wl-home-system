//
//  PostExchangeViewController.m
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "PostExchangeViewController.h"
#import "Constants.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@implementation MyCartCell

@end

@implementation MyCartButtonCell

@end

@implementation PostExchangeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self.noDataLabel setHidden:YES];
    [self.tableView.backgroundView setHidden:YES];
    [self.loadingIndicator setHidden:YES];
    getController = [[GetController alloc] init];
    postController = [[PostController alloc] init];
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    myCarts = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionCompleteForGet:) name:HConnectionCompleteNotification object:getController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionCompleteForPost:) name:HConnectionCompleteNotification object:postController];
}

- (IBAction)onBack:(id)sender {
    //self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    //[self presentViewController:self.previousViewController animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)onSelect:(id)sender {
    self.selectedId = ((UIButton*)sender).tag;
    
    MyCartCell *cell = (MyCartCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:((UIButton*)sender).tag]];
    cell.selectButton.selected = !cell.selectButton.selected;
}

- (IBAction)onDelete:(id)sender {
    //self.selectedId = ((UIButton*)sender).tag;
    self.selectedArray = [NSMutableArray array];
    [self.selectedArray addObject:[NSNumber numberWithInt:((UIButton*)sender).tag]];
    
    [self postToServer:((UIButton*)sender).tag];
}

- (IBAction)onSelectAll:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    for(NSInteger i = 0; i < myCarts.count; i ++) {
        MyCartCell *cell = (MyCartCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        cell.selectButton.selected = button.selected;
    }
}

- (IBAction)onDeleteAll:(id)sender {
    self.selectedArray = [NSMutableArray array];
    
    NSMutableArray *selArray = [NSMutableArray array];
    for(NSInteger i = 0; i < myCarts.count; i ++) {
        MyCartCell *cell = (MyCartCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        if(cell.selectButton.selected) {
            [self.selectedArray addObject:[NSNumber numberWithInt:i]];
            
            NSDictionary *rowData = [myCarts objectAtIndex:i];
            [selArray addObject:[rowData objectForKey:@"id"]];
            //[self postToServer:((NSNumber*)[rowData objectForKey:@"id"]).integerValue];
        }
    }
    
    if(selArray.count > 0) {
        NSString *postString = [selArray componentsJoinedByString:@","];
        [self postToServerForDeleteAll:postString];
    }
}

- (IBAction)onPost:(id)sender {
    self.selectedArray = [NSMutableArray array];
    
    NSMutableArray *selArray = [NSMutableArray array];
    for(NSInteger i = 0; i < myCarts.count; i ++) {
        MyCartCell *cell = (MyCartCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        if(cell.selectButton.selected) {
            [self.selectedArray addObject:[NSNumber numberWithInt:i]];
            
            NSDictionary *rowData = [myCarts objectAtIndex:i];
            [selArray addObject:[rowData objectForKey:@"id"]];
            //[self postToServerForExchange:((NSNumber*)[rowData objectForKey:@"id"]).integerValue];
        }
    }
    
    if(selArray.count > 0) {
        NSString *postString = [selArray componentsJoinedByString:@","];
        [self postToServerForExchange:postString];
    }
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"mycart.jsp"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", nil];
        [getController setParams:params];
        [getController startReceive];
    }
}

- (void)connectionCompleteForGet:(NSNotification *)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    NSString *contentType = [info objectForKey:@"contentType"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        if([contentType compare:@"text"] == NSOrderedSame) {
            NSData *data = [info objectForKey:@"data"];
            NSLog(@"PostExchange MyCart: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"name", @"market_price", @"integral_price", @"state", @"imagepath"];
                                
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
                    [myCarts addObject:exchange];
                }
                
                [self.tableView reloadData];
                
            } else {
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
    if([indexPath section] < [myCarts count])
        return 84;
    else
        return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 2.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([myCarts count] > 0)
        return [myCarts count] + 1;
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    if([indexPath section] < [myCarts count]) {
        cellIdentifier = @"MyCartCellIdentifier";
        MyCartCell *cell = (MyCartCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        NSDictionary *rowData = [myCarts objectAtIndex:[indexPath section]];
        
        [[cell titleLabel] setText:[rowData objectForKey:@"name"]];
        [[cell marketPriceLabel] setText:[NSString stringWithFormat:@"¥%.2f", [[rowData objectForKey:@"market_price"] floatValue]]];
        [[cell integralPriceLabel] setText:[NSString stringWithFormat:@"积分: %d", [[rowData objectForKey:@"integral_price"] intValue]]];
            
        [cell.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    
    
        [cell.deleteButton setTag:[indexPath section]];
        [cell.deleteButton addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
        [cell.selectButton setTag:[indexPath section]];
        [cell.selectButton addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    
        return cell;
    } else {
        cellIdentifier = @"MyCartButtonCellIdentifier";
        MyCartButtonCell *cell = (MyCartButtonCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        [cell.deleteAllButton addTarget:self action:@selector(onDeleteAll:) forControlEvents:UIControlEventTouchUpInside];
        [cell.selectAllButton addTarget:self action:@selector(onSelectAll:) forControlEvents:UIControlEventTouchUpInside];
        [cell.exchangeButton addTarget:self action:@selector(onPost:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (void)removeArrayWithId:(NSInteger)removeId {
    for(NSInteger i = 0; i < myCarts.count; i ++) {
        NSDictionary *rowData = [myCarts objectAtIndex:i];
        if(removeId == ((NSNumber*)[rowData objectForKey:@"id"]).integerValue) {
            [myCarts removeObjectAtIndex:i];
            break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)removeArrayWithIds:(NSArray*)array {
    self.noDataLabel.hidden = YES;
    
    MyCartButtonCell *cell = (MyCartButtonCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:myCarts.count]];
    cell.selectAllButton.selected = NO;
    for(NSInteger i = 0; i < myCarts.count; i ++) {
        MyCartCell *cell = (MyCartCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        cell.selectButton.selected = NO;
    }
    
    for(NSInteger i = array.count - 1; i >= 0 ; i --) {
        NSInteger index = ((NSNumber*)[array objectAtIndex:i]).integerValue;
        [myCarts removeObjectAtIndex:index];
    }
    
    [self.tableView reloadData];
    
    if(myCarts.count < 1)
        self.noDataLabel.hidden = NO;
}

- (void)postToServer:(NSInteger)delId {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [postController initialize];
        [postController setUrlPath:@"exchange_del.jsp"];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", delId], @"cart_id", nil];
        [postController setParams:params];
        [postController startSend];
    }
}

- (void)postToServerForDeleteAll:(NSString*)seletedids {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [postController initialize];
        [postController setUrlPath:@"exchange_seldel.jsp"];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", seletedids,@"cart_id", nil];
        [postController setParams:params];
        [postController startSend];
    }
}

- (void)postToServerForExchange:(NSString*)seletedids {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [postController initialize];
        [postController setUrlPath:@"exchange_success.jsp"];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", seletedids,@"cart_id", nil];
        [postController setParams:params];
        [postController startSend];
    }
}

/*- (void)postToServerForExchange:(NSInteger)seletedid {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [postController initialize];
        [postController setUrlPath:@"exchange_all.jsp"];
        [postController setContentType:@"text"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", seletedid],@"id", nil];
        [postController setParams:params];
        [postController startSend];
    }
}*/

- (void)connectionCompleteForPost:(NSNotification *)aNotification {
    [self changeState:YES];
    
    NSDictionary* info = [aNotification userInfo];
    NSString *status = [info objectForKey:@"status"];
    NSString *urlpath = [info objectForKey:@"urlpath"];
    
    if([status compare:@"succeeded"] == NSOrderedSame) {
        NSData *data = [info objectForKey:@"data"];
        NSLog(@"PostExchange: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
        
        NSError *jsonParsingError = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        NSNumber *success = [jsonDic objectForKey:@"success"];
        
        if([urlpath compare:@"exchange_del.jsp"] == NSOrderedSame) {
            if ([success intValue] == 1) {
                [self removeArrayWithIds:self.selectedArray];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            }
        } else if ([urlpath compare:@"exchange_seldel.jsp"] == NSOrderedSame){
            
            if ([success intValue] == 1) {
                [self removeArrayWithIds:self.selectedArray];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            }
        } else {
            
            if ([success intValue] == 1) {
                [self removeArrayWithIds:self.selectedArray];
                
                UIViewController *viewController = [appDelegate.storyboard instantiateViewControllerWithIdentifier:@"MyExchange"];
                [self presentViewController:viewController animated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"兑换失败" message:@"可能是服务机错误。" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
            }
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接错误" message:@"不能连接服务机!" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
