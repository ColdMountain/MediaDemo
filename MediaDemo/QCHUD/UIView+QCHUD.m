//
//  UIView+QCHUD.m
//  QCloud
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "UIView+QCHUD.h"

@implementation UIView (QCHUD)
- (CGFloat)left{
    return self.frame.origin.x;
}

- (CGFloat)top{
    return self.frame.origin.y;
}

- (CGFloat)right{
    return self.frame.origin.x+self.frame.size.width;
}

- (CGFloat)bottom{
    return self.frame.origin.y+self.frame.size.height;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (CGFloat)centerY{
    return self.center.y;
}

- (void)setLeft:(CGFloat)left{
    CGRect frame=self.frame;
    frame.origin.x=left;
    self.frame=frame;
}

- (void)setTop:(CGFloat)top{
    CGRect frame=self.frame;
    frame.origin.y=top;
    self.frame=frame;
}

- (void)setRight:(CGFloat)right{
    CGRect frame=self.frame;
    frame.origin.x=right-self.width;
    self.frame=frame;
}

- (void)setBottom:(CGFloat)bottom{
    CGRect frame=self.frame;
    frame.origin.y=bottom-self.height;
    self.frame=frame;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame=self.frame;
    frame.size.width=width;
    self.frame=frame;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame=self.frame;
    frame.size.height=height;
    self.frame=frame;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center=self.center;
    center.y=centerY;
    self.center=center;
}

- (void)setCenterX:(CGFloat)centerX{
    CGPoint center=self.center;
    center.x=centerX;
    self.center=center;
}

- (void)dropShadowWithOffset:(CGSize)offset radius:(CGFloat)radius color:(UIColor *)color opacity:(CGFloat)opacity{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    self.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    
    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    self.clipsToBounds = NO;
}
@end
