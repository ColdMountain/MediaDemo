//
//  AudioFileManager.h
//  MediaDemo
//
//  Created by Cold Mountain on 2023/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioFileManager : NSObject

+ (NSFileHandle*)createFileHandle;

@end

NS_ASSUME_NONNULL_END
