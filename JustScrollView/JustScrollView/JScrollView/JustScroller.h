//
//  JustScroller.h
//  JustScrollView
//
//  Created by Assassin on 2018/12/1.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JustScroller : NSScroller

- (void)setCustomKnobColor:(NSColor *)color hoverColor:(NSColor *)hColor width:(CGFloat)width;

@end
