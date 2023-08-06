//
//  ExchangeImageViewController.m
//  wljy
//
//  Created by 111 on 14.01.24.
//  Copyright (c) 2014 Hercules. All rights reserved.
//

#import "ExchangeImageViewController.h"
#import "Constants.h"

#import "NSURL+IFUnicodeURL.h"
#import "UIImageView+WebCache.h"

#define kMainScrollObjWidth     320
#define kMainScrollObjHeight     306

#define kSubScrollObjWidth      72
#define kSubScrollTap           6

@implementation ExchangeImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    
    [self.todayLabel setText:[appDelegate getTodayDate]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.titleLabel.text = self.productTitle;
    
	[self.mainScrollView setCanCancelContentTouches:NO];
	self.mainScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.mainScrollView.clipsToBounds = YES;
	self.mainScrollView.scrollEnabled = YES;	
	self.mainScrollView.pagingEnabled = YES;
	
	// load all the images from our bundle and add them to the scroll view
	NSUInteger i;
	for (i = 1; i <= self.imagepaths.count; i++)
	{
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMainScrollObjWidth, kMainScrollObjHeight)];
        [imageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [self.imagepaths objectAtIndex:i-1]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
		
		imageView.tag = i;	
		[self.mainScrollView addSubview:imageView];
	}
	
	[self layoutScrollImages:YES];
    
    [self.subScrollView setCanCancelContentTouches:NO];
	self.subScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.subScrollView.clipsToBounds = YES;
	self.subScrollView.scrollEnabled = YES;
	self.subScrollView.pagingEnabled = NO;
	
	// load all the images from our bundle and add them to the scroll view
	for (i = 1; i <= self.imagepaths.count; i++)
	{
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSubScrollObjWidth, kSubScrollObjWidth)];
        [imageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [self.imagepaths objectAtIndex:i-1]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
		
		imageView.tag = i;
		[self.subScrollView addSubview:imageView];
	}
	
	[self layoutScrollImages:NO];
    
    
    /*[self.mainImageView setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [self.imagepaths objectAtIndex:0]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
    
    NSArray *imageViewArray = @[self.dataImageView1, self.dataImageView2, self.dataImageView3, self.dataImageView4];
    for(NSInteger i = 0; i < self.imagepaths.count && i < 4; i ++) {
        [(UIImageView*)[imageViewArray objectAtIndex:i] setImageWithURL:[NSURL URLWithUnicodeString:[NSString stringWithFormat:@"%@%@", Server_Address, [self.imagepaths objectAtIndex:i+1]]] placeholderImage:[UIImage imageNamed:@"noimage.png"]];
        if(i > 3)
            break;
    }*/
}

- (IBAction)onBack:(id)sender {
    /*self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
     [self presentViewController:self.previousViewController animated:YES completion:nil];*/
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)layoutScrollImages:(BOOL)isMain {
	UIImageView *view = nil;
    if(isMain) {
        NSArray *subviews = [self.mainScrollView subviews];
        
        // reposition all image subviews in a horizontal serial fashion
        CGFloat curXLoc = 0;
        for (view in subviews)
        {
            if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
            {
                CGRect frame = view.frame;
                frame.origin = CGPointMake(curXLoc, 0);
                view.frame = frame;
                
                curXLoc += kMainScrollObjWidth;
            }
        }
        
        // set the content size so it can be scrollable
        [self.mainScrollView setContentSize:CGSizeMake((self.imagepaths.count * kMainScrollObjWidth), [self.mainScrollView bounds].size.height)];
    } else {
        NSArray *subviews = [self.subScrollView subviews];
        
        // reposition all image subviews in a horizontal serial fashion
        CGFloat curXLoc = kSubScrollTap;
        for (view in subviews)
        {
            if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
            {
                CGRect frame = view.frame;
                frame.origin = CGPointMake(curXLoc, 0);
                view.frame = frame;
                
                UIButton *button = [[UIButton alloc] initWithFrame:frame];
                button.tag = view.tag;
                [button addTarget:self action:@selector(onSelectSub:) forControlEvents:UIControlEventTouchUpInside];
                [self.subScrollView addSubview:button];
                
                curXLoc += kSubScrollObjWidth + kSubScrollTap;
            }
        }
        
        // set the content size so it can be scrollable
        [self.subScrollView setContentSize:CGSizeMake((self.imagepaths.count * (kSubScrollObjWidth + kSubScrollTap)) + kSubScrollTap, [self.subScrollView bounds].size.height)];
    }
}

- (IBAction)onSelectSub:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSLog(@"%d", button.tag);
    [self.mainScrollView setContentOffset:CGPointMake((button.tag-1)*kMainScrollObjWidth, 0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
