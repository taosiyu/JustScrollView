//
//  JustRefreshLoadView.m
//  JustScrollView
//
//  Created by Assassin on 2018/12/1.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "JustRefreshLoadView.h"

@implementation JustRefreshLoadView
{
    BOOL _isStopingRefresh;
    BOOL _isStopingLoading;
    BOOL _viewBoundsChanged;
    CGFloat _offsetY;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

#pragma mark - init

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewBoundsChanged:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewBoundsChanged:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewBoundsChanged:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - private

//滚轮
- (void)scrollWheel:(NSEvent *)event {
    if (self.isRefreshing || self.isLoading) // 禁止滚动
        return;

    CGFloat scrollViewVisibleRectY           = NSMaxY(self.contentView.documentVisibleRect);
    CGFloat scrollViewDocumentViewHeight     = NSHeight(self.documentView.bounds);
    NSClipView *clipView                     = self.contentView;
    NSRect bounds                            = clipView.bounds;
    CGFloat scrollValue                      = bounds.origin.y;
    CGFloat selfFrameHeight                  = self.frame.size.height;
    
    if(event.scrollingDeltaY > 0 /*下拉,refresh方向*/ && scrollViewVisibleRectY <= selfFrameHeight)
    {
        if(_isHalfRefreshing == NO)
        {
            [self startHalfRefreshing];
        }
    }
    else if(event.scrollingDeltaY < 0 /*上拉* , load more方向*/ && scrollViewVisibleRectY >= scrollViewDocumentViewHeight)
    {
        if(_isHalfLoading == NO)
        {
            [self startHalfLoading];
        }
    }
    
    if(scrollValue == 0)
    {
        _viewBoundsChanged = NO;
    }
    
    [super scrollWheel:event];
}

- (void)viewBoundsChanged:(NSNotification *)note
{
    CGFloat scrollingDeltaY = self.documentVisibleRect.origin.y - _offsetY;
    _offsetY = self.documentVisibleRect.origin.y;
    _viewBoundsChanged = YES;
    
    if(scrollingDeltaY == 0)
    {
        return;
    }
    
    if(self.scrollWheelBlock)
    {
        self.scrollWheelBlock(self, nil);
    }
    
    if (self.isRefreshing)
        return;
    
    if (self.isLoading)
        return;
}

#pragma mark - Public

- (void)startHalfLoading
{
    _isHalfLoading = YES;
    if(self.halfLoadBlock)
    {
        self.halfLoadBlock(self);
    }
}

- (void)stopHalfLoading
{
    _isHalfLoading = NO;
}

- (void)startHalfRefreshing
{
    _isHalfRefreshing = YES;
    if(self.halfRefreshBlock)
    {
        self.halfRefreshBlock(self);
    }
}

- (void)stopHalfRefreshing
{
    _isHalfRefreshing = NO;
}

- (void)becomeLoading
{
    [self willChangeValueForKey:@"isLoading"];
    _isRefreshing            = YES;
    [self didChangeValueForKey:@"isLoading"];
}

- (void)becomeRefreshing
{
    [self willChangeValueForKey:@"isRefreshing"];
    _isRefreshing            = YES;
    [self didChangeValueForKey:@"isRefreshing"];
}

- (void)startRefreshing
{
    [self willChangeValueForKey:@"isRefreshing"];
    _isRefreshing            = YES;
    [self didChangeValueForKey:@"isRefreshing"];
    
    if (self.refreshBlock) {
        self.refreshBlock(self);
    }
}

- (void)stopRefreshing
{
    // now fake an event of scrolling for a natural look
    [self willChangeValueForKey:@"isRefreshing"];
    _isRefreshing = NO;
    [self didChangeValueForKey:@"isRefreshing"];
    _isStopingRefresh = YES;
    
    CGEventRef cgEvent   = CGEventCreateScrollWheelEvent(NULL,
                                                         kCGScrollEventUnitLine,
                                                         2,
                                                         1,
                                                         0);
    
    NSEvent *scrollEvent = [NSEvent eventWithCGEvent:cgEvent];
    [self scrollWheel:scrollEvent];
    CFRelease(cgEvent);
}

- (void)startLoading {
    [self willChangeValueForKey:@"isLoading"];
    _isLoading = YES;
    [self didChangeValueForKey:@"isLoading"];
    
    if (self.loadBlock) {
        self.loadBlock(self);
    }
}

- (void)stopLoading {
    [self willChangeValueForKey:@"isLoading"];
    _isLoading = NO;
    [self didChangeValueForKey:@"isLoading"];
    
    _isStopingLoading = YES;
    CGEventRef cgEvent   = CGEventCreateScrollWheelEvent(NULL,
                                                         kCGScrollEventUnitLine,
                                                         2,
                                                         1,
                                                         0);
    
    NSEvent *scrollEvent = [NSEvent eventWithCGEvent:cgEvent];
    [self scrollWheel:scrollEvent];
    CFRelease(cgEvent);
}



@end
