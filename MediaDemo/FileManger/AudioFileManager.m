//
//  AudioFileManager.m
//  MediaDemo
//
//  Created by Cold Mountain on 2023/12/28.
//

#import "AudioFileManager.h"

@implementation AudioFileManager

+ (NSFileHandle*)createFileHandle{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [path objectAtIndex:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *pcmPath = [NSString stringWithFormat:@"Auido_%@.pcm", dateStr];
    
//    [self.fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:pcmPath] error: nil];
    [fileManager createFileAtPath:[documentsDirectory stringByAppendingPathComponent:pcmPath] contents:nil attributes:nil];

    NSFileHandle *auidoHandle = [NSFileHandle fileHandleForWritingAtPath:[documentsDirectory stringByAppendingPathComponent:pcmPath]];
    return auidoHandle;
}


@end
