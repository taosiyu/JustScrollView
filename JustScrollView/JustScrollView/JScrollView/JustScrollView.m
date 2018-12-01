//
//  JustScrollView.m
//  JustScrollView
//
//  Created by Assassin on 2018/12/1.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "JustScrollView.h"
#import "JustScroller.h"

@implementation JustScrollView

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
         _headerOffset = [self tableHeaderOffsetFromSuperview];
    }
    return self;
}

- (void)awakeFromNib {
    
     _headerOffset = [self tableHeaderOffsetFromSuperview];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)tile {
    [super tile];
    
    CGFloat width = [NSScroller scrollerWidthForControlSize:self.verticalScroller.controlSize
                                              scrollerStyle:self.verticalScroller.scrollerStyle];
    [self.verticalScroller setFrame:(NSRect){
        self.bounds.size.width - width,
        self.headerOffset,
        width,
        self.bounds.size.height - self.headerOffset
    }];
    
    // Move scroller to front
    [self sortSubviewsUsingFunction:scrollerViewsComparator
                            context:NULL];
}

- (NSInteger)tableHeaderOffsetFromSuperview
{
    for (NSView *subView in [self subviews])
    {
        if ([subView isKindOfClass:[NSClipView class]])
        {
            for (NSView *subView2 in [subView subviews])
            {
                if ([subView2 isKindOfClass:[NSTableView class]])
                {
                    return [(NSTableView *)subView2 headerView].frame.size.height;
                }
            }
        }
    }
    return 0;
}

#pragma mark - static

static NSComparisonResult scrollerViewsComparator(NSView *view1, NSView *view2, void *context)
{
    if ([view1 isKindOfClass:[JustScroller class]]) {
        return NSOrderedDescending;
    } else if ([view2 isKindOfClass:[JustScroller class]]) {
        return NSOrderedAscending;
    }
    
    return NSOrderedSame;
}

@end
