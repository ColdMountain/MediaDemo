//
//  QCHUDTool.h
//  QCloud
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface QCHUDTool : NSObject
+ (instancetype)shared;
//动态计算高度
+ (CGSize)workOutSizeWithStr:(NSString *)str andFont:(NSInteger)fontSize value:(NSValue *)value;
///颜色转图片
+ (UIImage *)UIImageWithColor:(UIColor *)color;
///tabBar 图片和标题点击颜色
+ (UITabBarItem *)getItemWithTitle:(NSString *)title defaultImageName:(NSString *)defaultImageName  selectedImageName:(NSString *)selectedImageName;
+ (UIColor *)colorFromHex:(NSString *)hexString alpha:(CGFloat)alpha;
///字符串转时间
+ (NSDate *)dateFromString:(NSString *)dateString DateForatter:(NSString *)dateforatter;
///时间转字符串
+ (NSString *)setDate:(NSDate *)date DateForatter:(NSString *)dateforatter;
@end
