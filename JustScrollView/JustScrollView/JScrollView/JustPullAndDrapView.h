//
//  JustPullAndDrapView.h
//  JustScrollView
//
//  Created by Assassin on 2018/12/1.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "JustScrollView.h"

@protocol JustRefreshDelegate <NSObject>
@optional
- (void)startLoading:(NSScrollView *)scrollView;
- (void)viewBoundDidChange;
- (void)scrollViewDidScrollToBottom:(JustScrollView *)scrollView;
- (void)scrollViewWillStartScroll:(JustScrollView *)scrollView;
- (void)scrollViewDidEndScrolling:(JustScrollView *)scrollView;
- (void)scrollViewDidLiveScroll:(JustScrollView *)scrollView;
- (void)scrollViewDidStop:(JustScrollView*)scrollView;
- (BOOL)isAbleToShowLoadingTips;
@end

@interface JustPullAndDrapView : JustScrollView
{
    NSProgressIndicator *refreshSpinner;
    
    NSView *refreshHeader;
    NSView *refreshSymbol;
    NSView *refreshArrow;
    
    BOOL isRefreshing;
    BOOL isRefreshingInLegacy;
    BOOL overHeaderView;
    BOOL isEnd;
    BOOL hasReachTheTop; //键盘、拖动到达顶部时置为YES
    BOOL isScolling; //记录苹果滚轮、触摸板触发滚动的状态
    CFAbsoluteTime lastLoadTime;  //记录上一次加载的时间
}

@property (weak) id<JustRefreshDelegate> delegate;
@property (readonly) BOOL isRefreshing;
@property (readonly) NSView *refreshHeader;
@property (nonatomic,assign) CGFloat vScollerOffsetX;

#pragma mark - void

- (CGFloat)minimumScroll;

@end
