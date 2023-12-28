//
//  QCHUDView.m
//  QCloud
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "QCHUDView.h"
#import <CoreText/CoreText.h>
#import "UIView+QCHUD.h"
#import "QCHUDTool.h"
#define kQCHUD_SIZE_RADIUS_WIDTH 15
#define kQCHUD_SIZE_FONT_TIP 13
#define kQCHUD_LINE_WIDTH 2
#define kQCHUD_SCREEN [UIScreen mainScreen].bounds.size

#define KEY_ANIMATION_ROTATE @"KEY_ANIMATION_ROTATE"
#define KEY_ANIMATION_TEXT @"KEY_ANIMATION_TEXT"
#define RGB(r,g,b,a) ([UIColor colorWithRed:r green:g blue:b alpha:a])
@implementation QCHUDView

#pragma mark 加载中动画
+ (instancetype)showHUDShowText:(NSString *)showText
{
    QCHUDView *hud = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds showText:showText HUDType:QCHUDLoadingType];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud show:YES view:hud.toast];
    return hud;
}
#pragma mark 加载成功动画
+ (instancetype)showSuccessfulAnimatedText:(NSString *)ShowText {
    [QCHUDView hideAllHUDAnimated:NO];
    QCHUDView *hud = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds showText:ShowText HUDType:QCHUDSuccessfulAnimatedType];
    [hud show:NO view:hud.toast];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [self performSelector:@selector(DelayHideHud) withObject:nil afterDelay:1.5];
    return hud;
}
#pragma mark 加载错误动画
+ (instancetype)showErrorAnimatedText:(NSString *)ShowText {
    [QCHUDView hideAllHUDAnimated:NO];
    QCHUDView *hud = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds showText:ShowText HUDType:QCHUDErrorAnimatedType];
    [hud show:YES view:hud.toast];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [self performSelector:@selector(DelayHideHud) withObject:nil afterDelay:1.5];
    return hud;
}
#pragma mark 文字提示
+ (instancetype)showDpromptText:(NSString *)showText {
    [QCHUDView hideAllHUDAnimated:NO];
    QCHUDView *hud = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds showText:showText HUDType:QCHUDpromptTextType];
    [hud show:YES view:hud.showTextLabel];
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [self performSelector:@selector(DelayHideHud) withObject:nil afterDelay:1.5];
    return hud;
}


//延迟隐藏hud
+ (void)DelayHideHud {
    [QCHUDView hideAllHUDAnimated:YES];
}
#pragma mark 隐藏
+ (NSUInteger)hideAllHUDAnimated:(BOOL)animated
{
    NSMutableArray *huds = [NSMutableArray array];
    NSArray *subviews =[UIApplication sharedApplication].keyWindow.subviews;
    for (UIView *aView in subviews)
    {
        if ([aView isKindOfClass:[QCHUDView class]])
        {
            [huds addObject:aView];
        }
    }
    
    for (QCHUDView *hud in huds)
    {
        if (hud.type== QCHUDpromptTextType) {
            [hud hide:animated view:hud.showTextLabel];
        } else {
            [hud hide:animated view:hud.toast];
        }
    }
    return [huds count];
}

- (void)dealloc
{
    
}

static CGFloat toastWidth = 100;
- (instancetype)initWithFrame:(CGRect)frame showText:(NSString *)showText HUDType:(QCHUDType)type{
    self = [super initWithFrame:frame];
    if (self)
    {
        _tipText=showText;
        _type=type;
        _toast = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - toastWidth) / 2, (self.frame.size.height - toastWidth) / 2 , toastWidth,toastWidth)];
        
        CGSize size = [QCHUDTool workOutSizeWithStr:showText andFont:14 value:[NSValue valueWithCGSize:CGSizeMake(self.frame.size.width-30, 999)]];
        if (size.width>100) {
            _toast.width=size.width+30;
        }
        _toast.center=CGPointMake(kQCHUD_SCREEN.width/2, kQCHUD_SCREEN.height/2);
        _toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _toast.layer.cornerRadius = 10;
        _toast.hidden = YES;
        [self addSubview:_toast];
        
        if (type==QCHUDLoadingType) {
            //加载
            [self loadingAnimated];
        } else if (type==QCHUDSuccessfulAnimatedType) {
            //成功
            [self pictureCorrect];
        } else if (type==QCHUDErrorAnimatedType) {
            //失败效果
            [self picturError];
        } else if (type==QCHUDpromptTextType) {
            //提示文字
            [self DpromptText];
        }
        
    }
    return self;
}
#pragma mark 加载动画
- (void)loadingAnimated {
    
    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    testActivityIndicator.center = CGPointMake(_toast.width/ 2, _toast.height /2);//只能设置中心，不能设置大小
    [_toast addSubview:testActivityIndicator];
    [testActivityIndicator startAnimating];
    
    UILabel * showTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, testActivityIndicator.bottom+7, _toast.width-10, 20)];
    showTextLabel.text=_tipText;
    showTextLabel.font=[UIFont systemFontOfSize:14];
    showTextLabel.textColor=[UIColor whiteColor];
    showTextLabel.textAlignment=NSTextAlignmentCenter;
    [_toast addSubview:showTextLabel];
    
}
#pragma mark 成功效果
- (void)pictureCorrect {
    CGFloat height =_toast.frame.size.height-50;
    UIView * successfulView = [[UIView alloc] initWithFrame:CGRectMake((_toast.frame.size.width/2)-height/2, 5, height, height)];
    
    successfulView.backgroundColor=[UIColor clearColor];
    successfulView.center=CGPointMake(_toast.width/2, _toast.height/2-10);
    [_toast addSubview:successfulView];
    CGFloat x = 0;
    CGFloat y = 0;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, successfulView.frame.size.width, successfulView.frame.size.height) cornerRadius:successfulView.frame.size.height/2];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    //开始点
    [path moveToPoint:CGPointMake(12, successfulView.height/2+5)];
    //
    CGPoint P1 = CGPointMake(successfulView.frame.size.width/2-3, successfulView.frame.size.height-13);
    [path addLineToPoint:P1];
    CGPoint P2 = CGPointMake(successfulView.frame.size.width-11, 13);
    [path addLineToPoint:P2];
    CAShapeLayer * layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [[UIColor clearColor] CGColor];
    layer.strokeColor = [[UIColor whiteColor] CGColor];
    layer.lineWidth = kQCHUD_LINE_WIDTH;
    layer.path = path.CGPath;
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 1;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [successfulView.layer addSublayer:layer];
    
    UILabel * showTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, successfulView.bottom+7, _toast.width-10, 20)];
    showTextLabel.text=_tipText;
    showTextLabel.font=[UIFont systemFontOfSize:14];
    showTextLabel.textColor=[UIColor whiteColor];
    showTextLabel.textAlignment=NSTextAlignmentCenter;
    [_toast addSubview:showTextLabel];
    
}
#pragma mark 错误效果
- (void)picturError {
    CGFloat height =_toast.frame.size.height-50;
    UIView * errorView = [[UIView alloc] initWithFrame:CGRectMake((_toast.frame.size.width/2)-height/2, 5, height, height)];
    errorView.center=CGPointMake(_toast.width/2, _toast.height/2-10);
    errorView.backgroundColor=[UIColor clearColor];
    [_toast addSubview:errorView];
    CGFloat x = 0;
    CGFloat y = 0;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, errorView.frame.size.width, errorView.frame.size.height) cornerRadius:errorView.frame.size.height/2];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    //开始点
    [path moveToPoint:CGPointMake(15, 15)];
    CGPoint P1 =  CGPointMake(errorView.frame.size.width-15, errorView.frame.size.height-15);
    //第二个点
    [path addLineToPoint:P1];
    
    [path moveToPoint:CGPointMake(errorView.frame.size.width-15, 15)];
    CGPoint P2 = CGPointMake(15, errorView.frame.size.height-15);
    [path addLineToPoint:P2];
    
    CAShapeLayer * layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [[UIColor clearColor] CGColor];
    layer.strokeColor = [[UIColor whiteColor] CGColor];
    layer.lineWidth = kQCHUD_LINE_WIDTH;
    layer.path = path.CGPath;
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [errorView.layer addSublayer:layer];
    
    
    UILabel * showTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, errorView.bottom+7, _toast.width-10, 20)];
    showTextLabel.text=_tipText;
    showTextLabel.font=[UIFont systemFontOfSize:14];
    showTextLabel.textColor=[UIColor whiteColor];
    showTextLabel.textAlignment=NSTextAlignmentCenter;
    [_toast addSubview:showTextLabel];
}


#pragma mark 文字提示
- (void)DpromptText {
    _toast.hidden=YES;
    _showTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 40)];
    _showTextLabel.text=_tipText;
    _showTextLabel.font=[UIFont systemFontOfSize:14];
    _showTextLabel.textColor=[UIColor whiteColor];
    _showTextLabel.textAlignment=NSTextAlignmentCenter;
    _showTextLabel.numberOfLines=0;
    
    _showTextLabel.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.8];
    _showTextLabel.layer.cornerRadius=10;
    _showTextLabel.layer.masksToBounds=YES;
    [self addSubview:_showTextLabel];
    
    CGSize size = [QCHUDTool workOutSizeWithStr:_tipText andFont:14 value:[NSValue valueWithCGSize:CGSizeMake(self.frame.size.width-40, 999)]];
    if (size.width>100) {
        _showTextLabel.width=size.width+10;
        _showTextLabel.height=size.height+10;
    }
    
    _showTextLabel.center=CGPointMake(kQCHUD_SCREEN.width/2, kQCHUD_SCREEN.height/2);
    
}
#pragma mark SETORGET
- (void)setTipText:(NSString *)tipText
{
    _tipText = tipText;
    
}
- (void)setType:(QCHUDType)type {
    _type=type;
}



- (void)show:(BOOL)animated view:(UIView *)view
{
    view.hidden = NO;
    if (animated)
    {
        view.transform = CGAffineTransformScale(self.transform,0.2,0.2);
        
        [UIView animateWithDuration:.3 animations:^{
            view.transform = CGAffineTransformScale(self.transform,1.2,1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3 animations:^{
                view.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (void)hide:(BOOL)animated view:(UIView *)view
{
    [UIView animateWithDuration:animated ? .3 : 0 animations:^{
        view.transform = CGAffineTransformScale(self.transform,1.2,1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:animated ? .3 : 0 animations:^{
            view.transform = CGAffineTransformScale(self.transform,0.2,0.2);
        } completion:^(BOOL finished) {
            [view.layer removeAnimationForKey:KEY_ANIMATION_ROTATE];
            //            [self.textLayer removeAnimationForKey:KEY_ANIMATION_TEXT];
            [self removeFromSuperview];
        }];
    }];
}

@end
