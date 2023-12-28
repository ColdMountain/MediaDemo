//
//  QCHUDTool.m
//  QCloud
//
//  Created by WangBing on 2018/5/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

#import "QCHUDTool.h"

@implementation QCHUDTool
+ (instancetype)shared {
    static QCHUDTool *sharedPublic=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPublic=[[QCHUDTool alloc]init];
    });
    return sharedPublic;
}
- (id)init{
    if (self=[super init]) {
        
    }
    return self;
}
//动态计算高度
+ (CGSize)workOutSizeWithStr:(NSString *)str andFont:(NSInteger)fontSize value:(NSValue *)value{
    if (!str) {
        str = @"";
    }
    CGSize size = CGSizeMake(0, 0);
    if (str) {
        if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0) {
            NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontSize],NSFontAttributeName, nil];
            size=[str boundingRectWithSize:[value CGSizeValue] options:NSStringDrawingUsesFontLeading |NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
        }
    }
    
    return size;
}
+ (UIImage *)UIImageWithColor:(UIColor *)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
+ (UITabBarItem *)getItemWithTitle:(NSString *)title defaultImageName:(NSString *)defaultImageName  selectedImageName:(NSString *)selectedImageName{
//    UITabBarItem *item;
//    NSShadow *shadow=[[NSShadow alloc]init];
//    item=[[UITabBarItem alloc]initWithTitle:title image:[UIImage imageNamed:defaultImageName] selectedImage:[UIImage imageNamed:selectedImageName]];
//    item.image=[item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    item.selectedImage=[item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[UIFont fontWithName:@"Arial" size:TABBAR_TITLE_FONT], NSFontAttributeName, nil] forState:UIControlStateSelected];
//    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[UIFont fontWithName:@"Arial" size:TABBAR_TITLE_FONT], NSFontAttributeName, nil] forState:UIControlStateNormal];
//    return item;
    return nil;
}
+ (UIColor *)colorFromHex:(NSString *)hexString alpha:(CGFloat)alpha{
    if (hexString.length==0) {
        return nil;
    }
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]]scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]]scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexString substringWithRange:range]]scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green / 255.0f) blue:(float)(blue / 255.0f)alpha:alpha];
}
///字符串转时间
+ (NSDate *)dateFromString:(NSString *)dateString DateForatter:(NSString *)dateforatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT+0000"];
    [dateFormatter  setTimeZone:timeZone];
    [dateFormatter setDateFormat:dateforatter];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}
///时间转字符串
+ (NSString *)setDate:(NSDate *)date DateForatter:(NSString *)dateforatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateforatter];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT+0000"];
    [dateFormatter setTimeZone:timeZone];//设置时区
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}
@end
