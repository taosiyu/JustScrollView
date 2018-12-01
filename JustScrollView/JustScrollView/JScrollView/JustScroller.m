//
//  JustScroller.m
//  JustScrollView
//
//  Created by Assassin on 2018/12/1.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "JustScroller.h"

@implementation JustScroller
{
    NSColor *_customColor;
    NSColor *_customHoverColor;
    CGFloat _customWidth;
    NSTrackingArea* _trackingArea;
    BOOL _customIsHover;
}

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self baseInitializer];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInitializer];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self baseInitializer];
}

#pragma mark - public

- (void)setCustomKnobColor:(NSColor *)color hoverColor:(NSColor *)hColor width:(CGFloat)width
{
    if (!color || !hColor) {
        return;
    }
    _customWidth = width;
    _customColor = color;
    _customHoverColor = hColor;
}

#pragma mark - private

- (void)baseInitializer {
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                 options:(
                                                          NSTrackingMouseEnteredAndExited
                                                          | NSTrackingActiveInActiveApp
                                                          | NSTrackingMouseMoved
                                                          )
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self drawKnob];
}

- (void)drawKnob
{
    if (_customColor && _customHoverColor) {
        CGFloat width = _customWidth >0 ? _customWidth +4 : 10;
        NSRect rect = [self rectForPart:NSScrollerKnob];
        if (rect.size.width > width) {
            rect.origin.x = rect.origin.x + rect.size.width - width;
            rect.size.width = width -4;
        }
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:width/2 yRadius:width/2];
        [(_customIsHover ? _customHoverColor : _customColor)  set];
        [path fill];
    }else {
        [super drawKnob];
    }
}

- (void)setFloatValue:(float)aFloat
{
    [super setFloatValue:aFloat];
    [self.animator setAlphaValue:1.0f];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOut) object:nil];
    [self performSelector:@selector(fadeOut) withObject:nil afterDelay:1.5f];
}

- (void)fadeOut
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.3f;
        [self.animator setAlphaValue:0.0f];
    } completionHandler:nil];
}

#pragma mark - mouse

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];
    _customIsHover = NO;
    [self fadeOut];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];
    _customIsHover = YES;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.1f;
        
        [self.animator setAlphaValue:1.0f];
    } completionHandler:^{
    }];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOut) object:nil];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [super mouseMoved:theEvent];
    _customIsHover = YES;
    self.alphaValue = 1.0f;
}


@end














