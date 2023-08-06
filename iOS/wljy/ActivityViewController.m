			//
//  ActivityViewController.m
//  wljy
//
//  Created by 111 on 14.01.14.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ActivityViewController.h"
#import "Constants.h"
#import "ActivityInfoViewController.h"
#import "SingleInfoViewController.h"
#include "PostActivityViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@implementation ActivityCell

@end

@implementation SingleCell

@end

@implementation ActivityViewController

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
    
    self.type = 2;
    [self.playButton setSelected:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self clearSelection];
    self.page = 1;
    self.lastArrived = NO;
    
    activities = [NSMutableArray array];
    [self connectToServer];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionComplete:) name:HConnectionCompleteNotification object:getController];
}

- (IBAction)onPost:(id)sender {
    PostActivityViewController *viewController = (PostActivityViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostActivity"];
    viewController.previousViewController = self;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)clearSelection {
    [self.playButton setSelected:NO];
    [self.singleButton setSelected:NO];
}

- (void)changeState:(BOOL)isLoaded {
    self.loadingIndicator.hidden = isLoaded;
    if(isLoaded) {
        [self.loadingIndicator stopAnimating];
        [self.noDataLabel setHidden:YES];
    }
    else
        [self.loadingIndicator startAnimating];
    self.playButton.enabled = isLoaded;
    self.playButton.enabled = isLoaded;
}

- (IBAction)onSubtitle:(id)sender {
    UIButton *button = (UIButton*)sender;
    if([button isSelected] == NO) {
        [self clearSelection];
        [button setSelected:YES];
        self.type = button.tag;
        self.page = 1;
        self.lastArrived = NO;
        
        [activities removeAllObjects];
        [self.tableView reloadData];
        [self connectToServer];
    }
}

- (void)connectToServer {
    if(self.loadingIndicator.isAnimating == NO && self.loadingIndicator.hidden == YES) {
        [self changeState:NO];
        
        [getController initialize];
        [getController setContentType:@"text"];
        [getController setUrlPath:@"activity.jsp"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", appDelegate.userid], @"userid", [NSString stringWithFormat:@"%d", self.type], @"type", [NSString stringWithFormat:@"%d", self.page], @"page", nil];
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
            NSLog(@"Activity: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"title", @"body", @"postdate", @"eval_count", @"read_count", @"imagepath"];
                                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *activity = [NSMutableDictionary dictionary];
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            if([subkey compare:@"imagepath"] == NSOrderedSame) {
                                if(self.type == 2) {
                                    if(((NSArray*)val).count > 0) {
                                        id subval = [(NSArray*)val objectAtIndex:0];
                                        if(subval != nil && ![subval isKindOfClass:[NSNull class]]) {                                            
                                            subval = [subval stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                                        }
                                    }
                                } else {
                                    for(NSInteger j = 0; j < ((NSArray*)val).count; j ++) {
                                        id subval = [(NSArray*)val objectAtIndex:j];
                                        if(subval != nil && ![subval isKindOfClass:[NSNull class]]) {
                                            [subval stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                                        }
                                    }
                                }                                
                            }
                            [activity setObject:val forKey:subkey];
                        }
                    }
                    [activities addObject:activity];
                }
                
                [self.tableView reloadData];
            } else {
                self.lastArrived = YES;
                if(activities.count == 0)
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
    if(self.type == 2)
        return 154;
    else {
        NSDictionary *rowData = [activities objectAtIndex:[indexPath section]];
        id val = [rowData objectForKey:@"imagepath"];
        if([val isKindOfClass:[NSArray class]] && ((NSArray*)val).count > 0)
            return 154;
        else
            return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 2.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [activities count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.type == 2) {
        static NSString *cellIdentifier = @"ActivityCellIdentifier";
        
        ActivityCell *cell = (ActivityCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        /*if(cell == nil)
         {
         NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ActivityCell" owner:self options:nil];
         for(id oneObject in nib)
         {
         if([oneObject isKindOfClass:[ActivityCell class]])
         cell = (ActivityCell*)oneObject;
         }
         }*/
        
        NSDictionary *rowData = [activities objectAtIndex:[indexPath section]];
        [[cell titleLabel] setText:[rowData objectForKey:@"title"]];
        [[cell dateLabel] setText:[rowData objectForKey:@"postdate"]];
        [[cell bodyLabel] setText:[rowData objectForKey:@"body"]];
        [[cell evalCountLabel] setText:[NSString stringWithFormat:@"评论: %d", [[rowData objectForKey:@"eval_count"] intValue]]];
        [[cell readCountLabel] setText:[NSString stringWithFormat:@"☺ %@", [rowData objectForKey:@"read_count"]]];
        
        NSArray *imageArray = [rowData objectForKey:@"imagepath"];        
        if(imageArray.count > 0)
            [cell.dataImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [imageArray objectAtIndex:0]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
        
        return cell;
        
    } else {
        static NSString *cellIdentifier = @"SingleCellIdentifier";
        
        SingleCell *cell = (SingleCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSDictionary *rowData = [activities objectAtIndex:[indexPath section]];
        [[cell titleLabel] setText:[rowData objectForKey:@"title"]];
        [[cell dateLabel] setText:[rowData objectForKey:@"postdate"]];
        [[cell evalCountLabel] setText:[NSString stringWithFormat:@"评论: %d", [[rowData objectForKey:@"eval_count"] intValue]]];
        [[cell readCountLabel] setText:[NSString stringWithFormat:@"☺ %@", [rowData objectForKey:@"read_count"]]];
        
        NSArray *imageArray = [rowData objectForKey:@"imagepath"];
        if(imageArray.count > 0) {
            cell.dataImageView1.hidden = NO;
            [cell.dataImageView1 setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [imageArray objectAtIndex:0]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
        }
        if(imageArray.count > 1) {
            cell.dataImageView2.hidden = NO;
            [cell.dataImageView2 setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [imageArray objectAtIndex:1]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
        }
        if(imageArray.count > 2) {
            cell.dataImageView3.hidden = NO;
            [cell.dataImageView3 setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [imageArray objectAtIndex:2]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
            }
        if(imageArray.count == 0) {
            cell.dataImageView1.hidden = YES;
            cell.dataImageView2.hidden = YES;
            cell.dataImageView3.hidden = YES;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *rowData = [activities objectAtIndex:[indexPath section]];
    ActivityInfoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityInfo"];
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
