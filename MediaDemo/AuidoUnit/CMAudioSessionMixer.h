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
    CMAudioMixerSampleRate_Defalut = 8000,
    CMAudioMixerSampleRate_16000Hz = 16000,
    CMAudioMixerSampleRate_22050Hz = 22050,
    CMAudioMixerSampleRate_24000Hz = 24000,
    CMAudioMixerSampleRate_32000Hz = 32000,
    CMAudioMixerSampleRate_44100Hz = 44100,
} CMAudioMixerSampleRate;
@protocol CMAudioSessionMixerDelegate <NSObject>

@optional

- (void)audioUnitBackPCM:(NSData*)audioData;

@end

@interface CMAudioSessionMixer : NSObject
- (instancetype)initAudioUnitMixerWithSampleRate:(CMAudioMixerSampleRate)audioRate;
- (void)setOutputAudioPort:(AVAudioSessionPortOverride)audioSessionPortOverride;
- (int)startAudioUnitRecorder;
- (int)stopAudioUnitRecorder;
- (void)closeAudioUnitRecorder;
- (void)startEchoAudio:(int)echoStatus;
- (void)pitchEnable:(int)pitchEnable;
- (void)mixerVolume:(int)volume;
@property (nonatomic, assign) id<CMAudioSessionMixerDelegate>delegate;
@property (nonatomic, assign) CMAudioMixerSampleRate audioRate;
@end


