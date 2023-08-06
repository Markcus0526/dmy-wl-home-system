//
//  MyPhotoViewController.m
//  wljy
//
//  Created by 111 on 14.01.21.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "MyPhotoViewController.h"
#import "Constants.h"
#import "PhotoViewController.h"
#import "PostPhotoViewController.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

@implementation MyPhotoCell

@end

@implementation MyPhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    
    [self.noDataLabel setHidden:YES];
    [self.tableView.backgroundView setHidden:YES];
    [self.loadingIndicator setHidden:YES];
    getController = [[GetController alloc] init];
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.page = 1;
    self.lastArrived = NO;
    myPhotoes = [NSMutableArray array];
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
    PostPhotoViewController *viewController = (PostPhotoViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PostPhoto"];
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
        [getController setUrlPath:@"myphoto.jsp"];
        
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
            NSLog(@"MyPhoto: %@, %@", status, [NSString stringWithFormat:@"%s", [data bytes]]);
            
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            NSNumber *success = [jsonDic objectForKey:@"success"];
            NSNumber *count = [jsonDic objectForKey:@"count"];
            NSArray *dataArray = [jsonDic objectForKey:@"data"];
            if([success intValue] == 1 && [count intValue] > 0) {
                NSArray *subkeys = @[@"id", @"postdate", @"imagepath"];
                
                for(NSUInteger i = 0; i < [count intValue]; i ++) {
                    NSMutableDictionary *photo = [NSMutableDictionary dictionary];
                    
                    NSDictionary *dic = [dataArray objectAtIndex:i];
                    for(NSString *subkey in subkeys) {
                        id val = [dic objectForKey:subkey];
                        if(val != nil && ![val isKindOfClass:[NSNull class]]) {
                            if([subkey compare:@"imagepath"] == NSOrderedSame) {
                                val = [val stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                            }
                            [photo setObject:val forKey:subkey];
                        }
                    }
                    [myPhotoes addObject:photo];
                }
                
                [self.tableView reloadData];
                
            } else {
                self.lastArrived = YES;
                if(myPhotoes.count == 0)
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
    return 81;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myPhotoes count] / 4 + (([myPhotoes count]%4==0)?0:1);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyQuestionCellIdentifier";
    
    MyPhotoCell *cell = (MyPhotoCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *rowData;
    if([indexPath row]*4 < [myPhotoes count]) {
        NSDictionary *rowData = [myPhotoes objectAtIndex:[indexPath row]*4];
        [cell.dataImageView1 setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
        
        [cell.imageButton1 setTag:[indexPath row]*4];
        [cell.imageButton1 addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if([indexPath row]*4+1 < [myPhotoes count]) {
        rowData = [myPhotoes objectAtIndex:[indexPath row]*4+1];
        [cell.dataImageView2 setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
        
        [cell.imageButton2 setTag:[indexPath row]*4+1];
        [cell.imageButton2 addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if([indexPath row]*4+2 < [myPhotoes count]) {
        rowData = [myPhotoes objectAtIndex:[indexPath row]*4+2];
        [cell.dataImageView3 setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
        
        [cell.imageButton3 setTag:[indexPath row]*4+2];
        [cell.imageButton3 addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if([indexPath row]*4+3 < [myPhotoes count]) {
        rowData = [myPhotoes objectAtIndex:[indexPath row]*4+3];
        [cell.dataImageView4 setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [rowData objectForKey:@"imagepath"]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
        
        [cell.imageButton4 setTag:[indexPath row]*4+3];
        [cell.imageButton4 addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

/*- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(targetContentOffset->y + scrollView.frame.size.height >= scrollView.contentSize.height && self.lastArrived == NO) {
        self.page ++;
        [self connectToServer];
    }
}*/

- (IBAction)onSelect:(id)sender {
    PhotoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Photo"];
    NSDictionary *rowData = [myPhotoes objectAtIndex:((UIButton*)sender).tag];
    //viewController.infoString = [NSString stringWithFormat:@"%@\n%@", [rowData objectForKey:@"title"], [rowData objectForKey:@"body"]];
    //viewController.imagePath = [rowData objectForKey:@"imagepath"];
    viewController.itemId = ((NSNumber*)[rowData objectForKey:@"id"]).integerValue;
    
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
