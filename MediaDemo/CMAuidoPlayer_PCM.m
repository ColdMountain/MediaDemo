//
//  CMAuidoPlayer_PCM.m
//  iOS面试Dem
//
//  Created by ColdMountain on 2020/10/12.
//  Copyright © 2020 ColdMountain. All rights reserved.
//

#import "CMAuidoPlayer_PCM.h"
#import <AudioToolbox/AudioToolbox.h>

@interface CMAuidoPlayer_PCM()
{
    AudioUnit _outAudioUinit;
    AudioBufferList *_renderBufferList;
    AudioFileStreamID _audioFileStreamID;
    AudioConverterRef _converter;
    AudioStreamBasicDescription _streamDescription;
    NSInteger _readedPacketIndex;
    UInt32 _renderBufferSize;
    NSInputStream *inputStream;
}
@property (nonatomic, strong) NSMutableArray<NSData*> *paketsArray;
@end

@implementation CMAuidoPlayer_PCM
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
#if 0
        _renderBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
        _renderBufferList->mBuffers[0].mNumberChannels = 1;
        _renderBufferList->mBuffers[0].mDataByteSize = 2048*2*10;
        _renderBufferList->mBuffers[0].mData = malloc(2048*2*10);
#endif
        _readedPacketIndex = 0;
        _paketsArray = [NSMutableArray arrayWithCapacity:0];
        [self setupOutAudioUnit];
        
#if 0
        NSString *paths = [[NSBundle mainBundle] pathForResource:@"Auido_8000" ofType:@"pcm"];
        NSData *localData = [[NSData alloc] initWithContentsOfFile:paths];
        
        inputStream = [NSInputStream inputStreamWithData:localData];
        
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        
        [self cm_play];
#endif
    }
    return self;
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

OSStatus  CMAURenderCallback(void *                      inRefCon,
                             AudioUnitRenderActionFlags* ioActionFlags,
                             const AudioTimeStamp*       inTimeStamp,
                             UInt32                      inBusNumber,
                             UInt32                      inNumberFrames,
                             AudioBufferList*            __nullable ioData){
    CMAuidoPlayer_PCM * self = (__bridge CMAuidoPlayer_PCM *)(inRefCon);
    
#if 0
//    ioData->mBuffers[0].mDataByteSize = self->_renderBufferList->mBuffers[0].mDataByteSize;
//    ioData->mBuffers[0].mData = self->_renderBufferList->mBuffers[0].mData;
    
    ioData->mBuffers[0].mDataByteSize = (UInt32)[self->inputStream read:ioData->mBuffers[0].mData maxLength:(NSInteger)ioData->mBuffers[0].mDataByteSize];
    if (ioData->mBuffers[0].mDataByteSize <= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self cm_stop];
            });
        }
    
#else
    @synchronized (self) {
//        if (self->_paketsArray.count >= self->_readedPacketIndex) {
            @autoreleasepool {
                NSData *packet = self->_paketsArray[self->_readedPacketIndex];
                ioData->mBuffers[0].mDataByteSize = (UInt32)packet.length;
                ioData->mBuffers[0].mData = (char*)packet.bytes;
                self->_readedPacketIndex++;
//                NSLog(@"当时数据个数:%ld=====渲染数据个数:%ld",self->_paketsArray.count, self->_readedPacketIndex);
//                NSLog(@"out size: %u", (unsigned int)ioData->mBuffers[0].mDataByteSize);
//                NSLog(@"out data: %s", ioData->mBuffers[0].mData);
            }
//        }
        if (ioData->mBuffers[0].mDataByteSize <= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self cm_stop];
            });
        }
        
    }
#endif
    
    return noErr;
}

#pragma mark - 传入数据

- (void)cm_playAudioWithData:(char*)pBuf andLength:(ssize_t)length{
#if 1
    NSData *pcmData = [NSData dataWithBytes:pBuf length:length];
    [self.paketsArray addObject:pcmData];
#else
    AudioBuffer buffer;
    buffer.mData = pBuf;
    buffer.mDataByteSize = (UInt32)length;
    buffer.mNumberChannels = 1;

    _renderBufferList->mNumberBuffers = 1;
    _renderBufferList->mBuffers[0] = buffer;
#endif
    [self cm_play];
}

- (void)cm_play{
    OSStatus status = AudioOutputUnitStart(_outAudioUinit);
    assert(status == noErr);
}

- (void)cm_stop{
    OSStatus status = AudioOutputUnitStop(_outAudioUinit);
    assert(status == noErr);
    [self.paketsArray removeAllObjects];
    self->_readedPacketIndex = 0;
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
