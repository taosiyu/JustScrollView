//
//  JustClipView.m
//  JustScrollView
//
//  Created by Assassin on 2018/12/1.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "JustClipView.h"
#import "JustPullAndDrapView.h"

@implementation JustClipView

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin { // this method determines the "elastic" of the scroll view or how high it can scroll without resistence.
    NSPoint constrained = [super constrainScrollPoint:proposedNewOrigin];
    CGFloat scrollValue = proposedNewOrigin.y; // this is the y value where the top of the document view is
    BOOL over = scrollValue <= self.minimumScroll;
    
    if (self.isRefreshing&&scrollValue <= 0) { // if we are refreshing
        if (over) // and if we are scrolled above the refresh view
            proposedNewOrigin.y = 0-self.headerView.frame.size.height; // constrain us to the refresh view
        return NSMakePoint(constrained.x, proposedNewOrigin.y);
    }
    return constrained;
}

- (BOOL)isFlipped {
    return YES;
}

- (NSRect)documentRect { //this is to make scrolling feel more normal so that the spinner is within the scrolled area
    NSRect sup = [super documentRect];
    if (self.isRefreshing) {
        sup.size.height+=self.headerView.frame.size.height;
        sup.origin.y-=self.headerView.frame.size.height;
    }
    return sup;
}

- (BOOL)isRefreshing {
    return [(JustPullAndDrapView*)self.superview isRefreshing];
}

- (NSView*)headerView {
    return [(JustPullAndDrapView*)self.superview refreshHeader];
}

- (CGFloat)minimumScroll {
    return [(JustPullAndDrapView*)self.superview minimumScroll];
}


@end
