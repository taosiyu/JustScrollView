//
//  JustPullAndDrapView.m
//  JustScrollView
//
//  Created by Assassin on 2018/12/1.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "JustPullAndDrapView.h"
#import "JustClipView.h"

#define REFRESH_HEADER_HEIGHT   50.0f
#define CONTAINER_INIT_POS      (-5.0f)
#define SPINNER_SIZE            20.0f

@implementation JustPullAndDrapView

- (void)createHeaderView {
    
    if (refreshHeader) {
        [refreshHeader removeFromSuperview];
        refreshHeader = nil;
    }
    
    [self setVerticalScrollElasticity:NSScrollElasticityAllowed];
    
    NSView *documentView = super.documentView;
    
    JustClipView *clipView = [[JustClipView alloc] initWithFrame:[super contentView].frame];
    clipView.documentView=documentView;
    clipView.copiesOnScroll=YES;
    clipView.drawsBackground=NO;
    [self setContentView:clipView];
    
    
    [self.contentView setPostsFrameChangedNotifications:YES];
    [self.contentView setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewBoundsChanged:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:self.contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDidEndLiveScroll:)
                                                 name:NSScrollViewDidEndLiveScrollNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewWillStartScroll:)
                                                 name:NSScrollViewWillStartLiveScrollNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDidLiveScroll:)
                                                 name:NSScrollViewDidLiveScrollNotification
                                               object:self];
    
    // add header view to clipview
    NSRect contentRect = [self.contentView.documentView frame];
    refreshHeader = [[NSView alloc] initWithFrame:NSMakeRect(0,
                                                             -REFRESH_HEADER_HEIGHT, //contentRect.origin.y+contentRect.size.height,
                                                             contentRect.size.width,
                                                             REFRESH_HEADER_HEIGHT)];
    [self.contentView addSubview:refreshHeader];
    
    [self resetRefreshComponent];
    
    [self.contentView scrollToPoint:NSMakePoint(contentRect.origin.x, 0)];
    [self reflectScrolledClipView:self.contentView];
    
}

- (void)resetRefreshComponent {
    [refreshArrow removeFromSuperview];
    [refreshSpinner removeFromSuperview];
    [refreshSymbol removeFromSuperview];
    
    // just_arrow
    NSImage *arrowImage = [NSImage imageNamed:@"just_arrow"];
    refreshArrow = [[NSView alloc] initWithFrame:NSMakeRect(0,
                                                            0,
                                                            arrowImage.size.width,
                                                            arrowImage.size.height)];
    refreshArrow.wantsLayer=YES;
    refreshArrow.layer=[CALayer layer];
    refreshArrow.layer.contents=(id)[arrowImage CGImageForProposedRect:NULL
                                                               context:nil
                                                                 hints:nil];
    
    refreshSymbol = [[NSView alloc] initWithFrame:NSMakeRect(NSMidX(refreshHeader.bounds) - (NSWidth(refreshArrow.frame)) / 2.0, CONTAINER_INIT_POS, NSWidth(refreshArrow.frame), NSHeight(refreshArrow.frame))];
    
    refreshSymbol.wantsLayer = YES;
    [refreshArrow setFrameOrigin:NSMakePoint(0,- refreshArrow.frame.size.height - 1)];
    [refreshSymbol addSubview:refreshArrow];
    [refreshSymbol setAlphaValue:0.0f];
    
    refreshSpinner = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(floor(NSMidX(refreshHeader.bounds) - SPINNER_SIZE/2),
                                                                           floor(NSMidY(refreshHeader.bounds) - SPINNER_SIZE/2),
                                                                           SPINNER_SIZE,
                                                                           SPINNER_SIZE)];
    [refreshSpinner setStyle:NSProgressIndicatorSpinningStyle];
    [refreshSpinner setDisplayedWhenStopped:NO];
    [refreshSpinner setUsesThreadedAnimation:YES];
    [refreshSpinner setIndeterminate:YES];
    [refreshSpinner setBezeled:NO];
    refreshSpinner.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin; // center
    refreshSymbol.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
    refreshHeader.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin; // stretch/center
    
    [refreshHeader addSubview:refreshSpinner];
    [refreshHeader addSubview:refreshSymbol];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale fromWindow:(NSWindow *)window
{
    return YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    refreshHeader = nil;
}

#pragma mark - private

//滚轮
- (void)scrollWheel:(NSEvent *)event
{
    if(event.phase == NSEventPhaseBegan) {
        isScolling = YES;
    }else if(event.phase == NSEventPhaseEnded) {
        isScolling = NO;
    }
    
    if(CFAbsoluteTimeGetCurrent() - lastLoadTime > 0.8f){
        NSRect bound = [[self contentView] bounds];
        if (([[self verticalScroller] isHidden] || bound.origin.y < 0.001) && [event deltaY] > 0.0 && !isRefreshingInLegacy && !isEnd)
        {
            lastLoadTime = CFAbsoluteTimeGetCurrent();
            isRefreshingInLegacy = YES;
            [self startLoading];
        }
    }else{
        //在两次loading的触发间隔之内，不加载。
    }

    [super scrollWheel:event];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self.documentView selector: @selector(updateVisibleRect) object: nil];
    if ([self.documentView respondsToSelector:@selector(updateVisibleRect)]) {
        [self.documentView  performSelector: @selector(updateVisibleRect) withObject: nil afterDelay: 0.1];
    }
}

#pragma mark - loading

- (void)autoStartLoading
{
    if (_isRefreshing || isRefreshingInLegacy) {
        return;
    }
    NSClipView *clipView = self.contentView;
    NSRect bounds = clipView.bounds;
    CGFloat scrollValue = bounds.origin.y;
    
    if (scrollValue <= 0) {
        [self startLoading];
        [NSObject cancelPreviousPerformRequestsWithTarget:self.documentView selector: @selector(updateVisibleRect) object: nil];
        if ([self.documentView respondsToSelector:@selector(updateVisibleRect)]) {
            [self.documentView  performSelector: @selector(updateVisibleRect) withObject: nil afterDelay: 0.1];
        }
    }
}

- (void)viewBoundsChanged:(NSNotification*)note {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewBoundDidChange)]) {
        [self.delegate viewBoundDidChange];
    }
    
    NSView *documentView = [self documentView];
    if (documentView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScrollToBottom:)]) {
            if (NSMaxY(self.contentView.bounds) >= NSHeight(documentView.frame)-5) {
                [self.delegate scrollViewDidScrollToBottom:self];
            }
        }
        
        if(CFAbsoluteTimeGetCurrent() - lastLoadTime > 0.8f) {
            CGFloat currBoundYPos = NSMinY(self.contentView.bounds);
            if(self.contentView.frame.size.height != documentView.frame.size.height && currBoundYPos < 0.01 && !isScolling && !isRefreshingInLegacy && !isEnd) {
                lastLoadTime = CFAbsoluteTimeGetCurrent();
                [self readyToLoadingWhenReachTheTop];
            }
        }else {
            //在两次loading的触发间隔之内，不加载。
        }
    }
    
    if (isRefreshing)
        return;
    
    BOOL start = [self overRefreshView];
    if (start) {
        // point arrow up
        NSSize arrowSize = refreshArrow.frame.size;
        CATransform3D mtx = CATransform3DMakeTranslation(arrowSize.width, arrowSize.height, 0);
        [refreshArrow layer].transform = CATransform3DRotate(mtx, M_PI, 0, 0, 1);
        [refreshSymbol setAlphaValue:1];
        overHeaderView = YES;
    } else {
        NSClipView *clipView = self.contentView;
        NSRect bounds = clipView.bounds;
        CGFloat scrollValue = bounds.origin.y;
        
        if ( scrollValue < 0 && fabs(scrollValue) <= REFRESH_HEADER_HEIGHT)
        {
            NSRect symFrame = refreshSymbol.frame;
            [refreshSymbol setFrameOrigin: NSMakePoint(symFrame.origin.x, fabs(scrollValue)*0.5+CONTAINER_INIT_POS)];
            CGFloat text =  sinf(fabs(scrollValue) / 20.0f * M_PI_2);
            [refreshSymbol setAlphaValue:text];
        }
        else
        {
            [refreshSymbol setFrameOrigin:NSMakePoint(NSMinX(refreshSymbol.frame), CONTAINER_INIT_POS)];
            [refreshSymbol setAlphaValue: 0.0f];
        }
        
        // point arrow down
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI*2, 0, 0, 1);
        overHeaderView = NO;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollViewDidStop) object:nil];
    [self performSelector:@selector(scrollViewDidStop) withObject:nil afterDelay:0.4];
}

- (void)scrollViewDidStop
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidStop:)]) {
        [self.delegate scrollViewDidStop:self];
    }
    //抵达顶部
    if(hasReachTheTop && isRefreshing) {
        [self startLoading];
    }
}

// 普通鼠标和苹果鼠标都响应_stephenysli
-(void)scrollViewDidLiveScroll:(NSNotification *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidLiveScroll:)]) {
        [self.delegate scrollViewDidLiveScroll:self];
    }
}

// 苹果鼠标响应，普通鼠标不响应_stephenysli
- (void)scrollViewWillStartScroll:(NSNotification *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillStartScroll:)]) {
        [self.delegate scrollViewWillStartScroll:self];
    }
}

// 苹果鼠标响应，普通鼠标不响应_stephenysli
- (void)scrollViewDidEndLiveScroll:(NSNotification *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
        [self.delegate scrollViewDidEndScrolling:self];
    }
}

- (BOOL)overRefreshView {
    
    NSClipView *clipView = self.contentView;
    NSRect bounds = clipView.bounds;
    
    CGFloat scrollValue = bounds.origin.y;
    
    return scrollValue <= self.minimumScroll;
    
}

- (void)readyToLoadingWhenReachTheTop
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(isAbleToShowLoadingTips)]) {
        BOOL showLoading = [self.delegate isAbleToShowLoadingTips];
        if(!showLoading)
            return;
    }
    
    isRefreshing = YES;
    hasReachTheTop = YES;
    
    //显示加载动画
    NSRect rcSpinner = refreshSpinner.frame;
    [refreshSpinner setFrameOrigin: NSMakePoint(rcSpinner.origin.x, (REFRESH_HEADER_HEIGHT - rcSpinner.size.height)/2)];
    [refreshSpinner startAnimation:self];
    [refreshSpinner setAlphaValue:1.0];
    NSPoint pt = refreshSymbol.frame.origin;
    [refreshSymbol setFrameOrigin: NSMakePoint(pt.x, CONTAINER_INIT_POS)];
    
    CGEventRef cgEvent = CGEventCreateScrollWheelEvent(NULL,
                                                       kCGScrollEventUnitPixel,
                                                       1,
                                                       1,
                                                       0);
    NSEvent *scrollEvent = [NSEvent eventWithCGEvent:cgEvent];
    [self scrollWheel:scrollEvent];
    CFRelease(cgEvent);
}

- (void)startLoading {

    [self willChangeValueForKey:@"isRefreshing"];
    isRefreshing = YES;
    [self didChangeValueForKey:@"isRefreshing"];
    
    [refreshArrow setHidden:YES];
    
    NSClipView *clipView = self.contentView;
    NSRect bounds = clipView.bounds;
    CGFloat scrollValue = bounds.origin.y;
    NSRect rcSpinner = refreshSpinner.frame;
    [refreshSpinner setFrameOrigin: NSMakePoint(rcSpinner.origin.x, (fabs(scrollValue) - rcSpinner.size.height)/2)];
    [refreshSpinner startAnimation:self];
    
    NSPoint pt = refreshSymbol.frame.origin;
    [refreshSymbol setFrameOrigin: NSMakePoint(pt.x, CONTAINER_INIT_POS)];

    if(self.delegate && [self.delegate respondsToSelector:@selector(startLoading:)]){
        [self.delegate startLoading:self];
    }
}

- (void)stopLoading:(BOOL)isOver {
    if (isOver) {
        isEnd = isOver;
        [refreshArrow setHidden:YES];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize: 12], NSFontAttributeName, [NSColor colorWithDeviceRed:120 / 255.0 green: 120 / 255.0 blue: 120 / 255.0 alpha: 1.0], NSForegroundColorAttributeName, nil];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"Loading Over", nil) attributes: dic];
        NSSize size = [string size];
        
        [refreshSymbol setAlphaValue:0.0f];
        [refreshSymbol setFrame:NSMakeRect(NSMidX(refreshHeader.bounds) / 2.0, 0, 0, 0)];
        [refreshSymbol setFrameOrigin:NSMakePoint(floor(NSMidX(refreshHeader.bounds)), 0)];
    }
    else
    {
        [refreshArrow setHidden:NO];
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        [refreshSpinner stopAnimation:self];
        [refreshSymbol setAlphaValue:0.0f];
        [refreshSymbol setFrameOrigin:NSMakePoint(NSMinX(refreshSymbol.frame), 0)];
    }
    
    [refreshSpinner stopAnimation:self];
    
    // now fake an event of scrolling for a natural look
    
    [self willChangeValueForKey:@"isRefreshing"];
    isRefreshing = NO;
    [self didChangeValueForKey:@"isRefreshing"];
    hasReachTheTop = NO;
    
    CGEventRef cgEvent = CGEventCreateScrollWheelEvent(NULL,
                                                       kCGScrollEventUnitLine,
                                                       2,
                                                       1,
                                                       0);
    NSEvent *scrollEvent = [NSEvent eventWithCGEvent:cgEvent];
    [self scrollWheel:scrollEvent];
    CFRelease(cgEvent);
}


- (CGFloat)minimumScroll {
    return -20.0f;
}

-(void)tile
{
    [super tile];
    // Resize vertical scroller
    CGFloat width = [NSScroller scrollerWidthForControlSize:self.verticalScroller.controlSize
                                              scrollerStyle:self.verticalScroller.scrollerStyle];
    NSRect frame = (NSRect){
        self.bounds.size.width - width + self.vScollerOffsetX,
        0,
        width,
        self.bounds.size.height
    };
    [self.verticalScroller setFrame:frame];
    
    
}

@end


















