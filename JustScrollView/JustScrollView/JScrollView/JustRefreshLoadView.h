//
//  JustRefreshLoadView.h
//  JustScrollView
//
//  Created by Assassin on 2018/12/1.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "JustScrollView.h"

@interface JustRefreshLoadView : JustScrollView

@property (assign) BOOL isRefreshing;
@property (assign) BOOL isLoading;
@property (assign) BOOL isHalfRefreshing;
@property (assign) BOOL isHalfLoading;

@property (nonatomic, copy) void (^refreshBlock)(JustScrollView *scrollView);
@property (nonatomic, copy) void (^halfRefreshBlock)(JustScrollView *scrollView);
@property (nonatomic, copy) void (^loadBlock)(JustScrollView *scrollView);
@property (nonatomic, copy) void (^halfLoadBlock)(JustScrollView *scrollView);
@property (nonatomic, copy) void (^scrollWheelBlock)(JustScrollView *scrollView,NSEvent* event);

@end
