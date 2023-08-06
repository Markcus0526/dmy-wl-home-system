//
//  GrayPageControl.m
//  BathServe
//
//  Created by KimHakMin on 10/14/13.
//  Copyright (c) 2013 KimOC. All rights reserved.
//

#import "GrayPageControl.h"

@implementation GrayPageControl

@synthesize activeImage;
@synthesize inactiveImage;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	self.activeImage = [UIImage imageNamed:@"active_page_image.png"] ;
	self.inactiveImage = [UIImage imageNamed:@"inactive_page_image.png"] ;
	
	return  self;
}

-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIView* dotView = [self.subviews objectAtIndex:i];
        UIImageView* dot = nil;
        
        for (UIView* subview in dotView.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView*)subview;
                break;
            }
        }
        
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotView.frame.size.width, dotView.frame.size.height)];
            [dotView addSubview:dot];
        }
        
        if (i == self.currentPage)
        {
            if(self.activeImage)
                dot.image = activeImage;
        }
        else
        {
            if (self.inactiveImage)
                dot.image = inactiveImage;
        }
    }
}

-(void) setCurrentPage:(NSInteger)currentPage
{
	[super setCurrentPage:currentPage];
	[self updateDots];
}

@end
