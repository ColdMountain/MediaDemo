//
//  CMAudioSession_PCM.h
//  Player_PCM
//
//  Created by ColdMountain on 2020/11/24.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@class CMAudioSession_PCM;

typedef enum {
    CMAudioPCMSampleRate_Defalut = 8000,
    CMAudioPCMSampleRate_16000Hz = 16000,
    CMAudioPCMSampleRate_22050Hz = 22050,
    CMAudioPCMSampleRate_24000Hz = 24000,
    CMAudioPCMSampleRate_32000Hz = 32000,
    CMAudioPCMSampleRate_44100Hz = 44100,
} CMAudioPCMSampleRate;

@protocol CMAudioSessionPCMDelegate <NSObject>

@optional

- (void)cm_audioUnitBackPCM:(NSData*)audioData selfClass:(CMAudioSession_PCM*)selfClass;

@end

@interface CMAudioSession_PCM : NSObject
- (instancetype)initAudioUnitWithSampleRate:(CMAudioPCMSampleRate)audioRate;
- (void)setOutputAudioPort:(AVAudioSessionPortOverride)audioSessionPortOverride;
- (void)cm_startEchoAudio:(int)echoStatus;
- (void)cm_startAGC:(int)agcStatus;
- (int)cm_startAudioUnitRecorder;
- (int)cm_stopAudioUnitRecorder;
- (void)cm_closeAudioUnitRecorder;
- (void)initAudioComponent;

@property (nonatomic, weak) id<CMAudioSessionPCMDelegate>delegate;
@property (nonatomic, assign) CMAudioPCMSampleRate audioRate;
@end

