//
//  QCHUDView.h
//  QCloud
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, QCHUDType) {
    QCHUDLoadingType,//加载中
    QCHUDSuccessfulAnimatedType,//加载成功动画
    QCHUDErrorAnimatedType,//加载错误动画
    QCHUDpromptTextType,//提示文字
};
@interface QCHUDView : UIView
@property (nonatomic,strong) NSString *tipText;
@property(nonatomic,strong)  UILabel * showTextLabel;
@property (nonatomic,strong) UIView *toast;
@property(nonatomic,assign)  QCHUDType type;

- (void)show:(BOOL)animated view:(UIView *)view;

- (void)hide:(BOOL)animated view:(UIView *)view;

- (instancetype)initWithFrame:(CGRect)frame
                     showText:(NSString *)showText
                      HUDType:(QCHUDType)type;
///加载类型
+ (instancetype)showHUDShowText:(NSString *)showText;
//加载成功提示
+ (instancetype)showSuccessfulAnimatedText:(NSString *)ShowText;
//错误提示
+ (instancetype)showErrorAnimatedText:(NSString *)ShowText;
//文字提示
+ (instancetype)showDpromptText:(NSString *)showText;
//隐藏
+ (NSUInteger)hideAllHUDAnimated:(BOOL)animated;

@end
