//
//  CMAuidoPlayer_PCM.m
//  iOS面试Dem
//
//  Created by ColdMountain on 2020/10/12.
//  Copyright © 2020 ColdMountain. All rights reserved.
//

#import "CMAuidoPlayer_PCM.h"
#import <AudioToolbox/AudioToolbox.h>

#include "SoundTouch.h"

@interface CMAuidoPlayer_PCM()<NSStreamDelegate>
{
    AudioUnit _outAudioUinit;
    AudioBufferList *renderBufferList;
    AudioFileStreamID _audioFileStreamID;
    AudioConverterRef _converter;
    AudioStreamBasicDescription _streamDescription;
    NSInteger _readedPacketIndex;
    UInt32 _renderBufferSize;
    NSInputStream *inputStream;
    
    Byte *recorderBuffer;
    soundtouch::SoundTouch mSoundTouch; //变声器对象
}
@property (nonatomic, strong) NSMutableArray<NSData*> *paketsArray;
@end

@implementation CMAuidoPlayer_PCM

OSStatus  CMAURenderCallback(void *                      inRefCon,
                             AudioUnitRenderActionFlags* ioActionFlags,
                             const AudioTimeStamp*       inTimeStamp,
                             UInt32                      inBusNumber,
                             UInt32                      inNumberFrames,
                             AudioBufferList*            __nullable ioData){
    CMAuidoPlayer_PCM * self = (__bridge CMAuidoPlayer_PCM *)(inRefCon);
#if AudioPlayerFile
#if 1
    //原声
    ioData->mBuffers[0].mDataByteSize = (UInt32)[self->inputStream read:(uint8_t *)ioData->mBuffers[0].mData maxLength:(NSInteger)ioData->mBuffers[0].mDataByteSize];
#else
    //变声
    NSInteger audioSize = 0;
    uint8_t *audioData;
    audioData = (uint8_t *)malloc(ioData->mBuffers[0].mDataByteSize * sizeof(uint8_t));
    audioSize = [self->inputStream read:audioData maxLength:ioData->mBuffers[0].mDataByteSize];

    dispatch_async(dispatch_get_main_queue(), ^{
        int nSamples = (int)ioData->mBuffers[0].mDataByteSize / 2;
        int pcmsize = (int)ioData->mBuffers[0].mDataByteSize;
        short *samples = new short[pcmsize];

        self->mSoundTouch.putSamples((short *)audioData, nSamples);
        int numSamples = 0;
        numSamples = self->mSoundTouch.receiveSamples((short *)ioData->mBuffers[0].mData, ioData->mBuffers[0].mDataByteSize);
    });
#endif
    if (ioData->mBuffers[0].mDataByteSize <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cm_stop];
        });
    }
#else
    memcpy(ioData->mBuffers[0].mData, self->recorderBuffer, ioData->mBuffers[0].mDataByteSize);
#endif
    return noErr;
}

static AudioStreamBasicDescription PCMStreamDescription(void*inData)
{
    CMAuidoPlayer_PCM *player = (__bridge CMAuidoPlayer_PCM*)(inData);
    AudioStreamBasicDescription description;
    description.mSampleRate       = player.audioRate;
    description.mFormatID         = kAudioFormatLinearPCM;
    description.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved;
    description.mFramesPerPacket  = 1;// 每帧只有1个packet
    description.mChannelsPerFrame = 1;// 声道数
    description.mBitsPerChannel   = 16;// 位深
    description.mBytesPerFrame    = (description.mBitsPerChannel / 8) * description.mChannelsPerFrame;
    description.mBytesPerPacket   = description.mBytesPerFrame;
    return description;
}

#pragma mark - 首先进行初始化操作

- (instancetype)initWithAudioUnitPlayerSampleRate:(CMAudioPlayerSampleRate)sampleRate{
    if (self = [super init]) {
        self.audioRate = sampleRate;
        recorderBuffer = (Byte *)malloc(100*1024*1024);
        [self setSoundTouch];
        [self setupOutAudioUnit];
#if AudioPlayerFile
        [self openFile];
#endif
    }
    return self;
}

#pragma mark - 加载本地播放文件

- (void)openFile{
    NSString *paths = [[NSBundle mainBundle] pathForResource:FileName ofType:@"pcm"];
    NSData *localData = [[NSData alloc] initWithContentsOfFile:paths];
    
    inputStream = [NSInputStream inputStreamWithData:localData];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    if (!inputStream) {
        NSLog(@"打开文件失败 %@", paths);
    }
    else {
        [inputStream open];
    }
}

#pragma mark - 变声器初始化

- (void)setSoundTouch{
    mSoundTouch.setSampleRate(self.audioRate); //采样率
    mSoundTouch.setChannels(1);       //设置声音的声道
    mSoundTouch.setTempoChange(0);//这个就是传说中的变速不变调
    mSoundTouch.setPitchSemiTones(6);//设置声音的pitch (集音高变化semi-tones相比原来的音调)
    mSoundTouch.setRateChange(0);//设置声音的速率
    
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 15); //寻找帧长
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 6);  //重叠帧长
}

#pragma mark - 设置播放时的AudioUnit属性

- (void)setupOutAudioUnit{
    AudioComponentDescription outputUinitDesc;
    memset(&outputUinitDesc, 0, sizeof(AudioComponentDescription));
    outputUinitDesc.componentType         = kAudioUnitType_Output;
    outputUinitDesc.componentSubType      = kAudioUnitSubType_VoiceProcessingIO;
    outputUinitDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputUinitDesc.componentFlags        = 0;
    outputUinitDesc.componentFlagsMask    = 0;

    AudioComponent outComponent = AudioComponentFindNext(NULL, &outputUinitDesc);
    OSStatus status = AudioComponentInstanceNew(outComponent, &_outAudioUinit);
    assert(status == noErr);
    
    UInt32 flag = 1;
    if (flag) {
        OSStatus status = AudioUnitSetProperty(_outAudioUinit,
                                               kAudioOutputUnitProperty_EnableIO,
                                               kAudioUnitScope_Output,
                                               0,
                                               &flag,
                                               sizeof(flag));
        if (status) {
            NSLog(@"AudioUnitSetProperty error with status:%d", (int)status);
        }
    }
    
    AudioStreamBasicDescription pcmStreamDesc = PCMStreamDescription((__bridge void*)(self));
    [self printAudioStreamBasicDescription:pcmStreamDesc];
    
    AudioUnitSetProperty(_outAudioUinit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &pcmStreamDesc,
                         sizeof(pcmStreamDesc));
    
    AURenderCallbackStruct callBackStruct;
    callBackStruct.inputProc       = CMAURenderCallback;
    callBackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    AudioUnitSetProperty(_outAudioUinit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         0,
                         &callBackStruct,
                         sizeof(callBackStruct));
}

#pragma mark - 传入数据

- (void)cm_playAudioWithData:(char*)pBuf andLength:(ssize_t)length{
    self->renderBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    self->renderBufferList->mNumberBuffers = 1;
    self->renderBufferList->mBuffers[0].mNumberChannels = 1;
    self->renderBufferList->mBuffers[0].mDataByteSize = (UInt32)length;
    self->renderBufferList->mBuffers[0].mData = pBuf;
    memcpy(self->recorderBuffer, self->renderBufferList->mBuffers[0].mData, self->renderBufferList->mBuffers[0].mDataByteSize);
    [self cm_play];
}

- (void)cm_play{
    OSStatus status = AudioOutputUnitStart(_outAudioUinit);
    assert(status == noErr);
}

- (void)cm_stop{
    OSStatus status = AudioOutputUnitStop(_outAudioUinit);
    assert(status == noErr);
    if (status == noErr) {
        NSLog(@"停止播放器");
    }
}

- (void)cm_close{
    OSStatus status = AudioUnitUninitialize(_outAudioUinit);
    status = AudioComponentInstanceDispose(_outAudioUinit);
    assert(status == noErr);
    if (status == noErr) {
        NSLog(@"关闭播放器");
    }
}

- (void)dealloc{
    NSLog(@"AudioPlayer销毁");
}

- (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("************AudioUnit音频播放************\n");
    printf("Sample Rate:         %10.0f\n",  asbd.mSampleRate);
    printf("Format ID:           %10s\n",    formatID);
    printf("Format Flags:        %10X\n",    (unsigned int)asbd.mFormatFlags);
    printf("Bytes per Packet:    %10d\n",    (unsigned int)asbd.mBytesPerPacket);
    printf("Frames per Packet:   %10d\n",    (unsigned int)asbd.mFramesPerPacket);
    printf("Bytes per Frame:     %10d\n",    (unsigned int)asbd.mBytesPerFrame);
    printf("Channels per Frame:  %10d\n",    (unsigned int)asbd.mChannelsPerFrame);
    printf("Bits per Channel:    %10d\n",    (unsigned int)asbd.mBitsPerChannel);
    printf("\n");
}

@end
