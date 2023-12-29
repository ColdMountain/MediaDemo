//
//  CMAudioSessionSpeed.h
//  MediaDemo
//
//  Created by Cold Mountain on 2023/12/20.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    CMAudioSpeedSampleRate_Defalut = 8000,
    CMAudioSpeedSampleRate_16000Hz = 16000,
    CMAudioSpeedSampleRate_22050Hz = 22050,
    CMAudioSpeedSampleRate_24000Hz = 24000,
    CMAudioSpeedSampleRate_32000Hz = 32000,
    CMAudioSpeedSampleRate_44100Hz = 44100,
} CMAudioSpeedSampleRate;
@protocol CMAudioSessionSpeedDelegate <NSObject>

@optional

- (void)audioUnitBackPCM:(NSData*)audioData;

@end

@interface CMAudioSessionSpeed : NSObject
- (instancetype)initAudioUnitSpeedWithSampleRate:(CMAudioSpeedSampleRate)audioRate;
- (void)setOutputAudioPort:(AVAudioSessionPortOverride)audioSessionPortOverride;
- (int)startAudioUnitRecorder;
- (int)stopAudioUnitRecorder;
- (void)closeAudioUnitRecorder;
- (void)startEchoAudio:(int)echoStatus;
- (void)pitchEnable:(int)pitchEnable;
- (void)mixerVolume:(int)volume;
@property (nonatomic, assign) id<CMAudioSessionSpeedDelegate>delegate;
@property (nonatomic, assign) CMAudioSpeedSampleRate audioRate;
@end


