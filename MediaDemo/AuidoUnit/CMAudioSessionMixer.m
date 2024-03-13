//
//  CMAudioSessionSpeed.m
//  MediaDemo
//
//  Created by Cold Mountain on 2023/12/20.
//

#import "CMAudioSessionMixer.h"

@interface CMAudioSessionMixer()
{
    AVAudioSession *audioSession;
    AudioBufferList *buffList;
    AUGraph graph;
    AudioUnit IOUnit;
    AudioUnit formatUnit;
    AudioUnit mixerUnit;
    AUNode outputNode;
    AUNode mixerNode;
    AUNode timePitchNode;
    Byte *recorderBuffer;
}
@end

@implementation CMAudioSessionMixer

#pragma mark - 音频采集

static OSStatus CMRecordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    CMAudioSessionMixer *session = (__bridge CMAudioSessionMixer *)inRefCon;
    OSStatus status = noErr;
    uint8_t  kAudioCaptureData[inNumberFrames*2];
    int32_t  kAudioCaptureSize = inNumberFrames * 2;
    
    session->buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    session->buffList->mNumberBuffers = 1;
    session->buffList->mBuffers[0].mNumberChannels = 1;
    session->buffList->mBuffers[0].mDataByteSize = kAudioCaptureSize;
    session->buffList->mBuffers[0].mData = kAudioCaptureData;
    status = AudioUnitRender(session->IOUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             session->buffList);
    if (status != noErr) {
        NSLog(@"CMAudioSessionSpeed | AudioUnitRender error: %d",status);
    }
    if ([session.delegate respondsToSelector:@selector(audioUnitBackPCM:)]) {
        NSData *pcmData = [NSData dataWithBytes:session->buffList->mBuffers[0].mData
                                   length:session->buffList->mBuffers[0].mDataByteSize];
        [session.delegate audioUnitBackPCM:pcmData];
    }
//    NSLog(@"mDataByteSize %d", session->buffList->mBuffers[0].mDataByteSize);
    memcpy(session->recorderBuffer, session->buffList->mBuffers[0].mData, session->buffList->mBuffers[0].mDataByteSize);
    
    return noErr;
}

#pragma mark - 音频播放

static OSStatus CMRenderCallback(void *                      inRefCon,
                                  AudioUnitRenderActionFlags* ioActionFlags,
                                  const AudioTimeStamp*       inTimeStamp,
                                  UInt32                      inBusNumber,
                                  UInt32                      inNumberFrames,
                                  AudioBufferList*            __nullable ioData){
    CMAudioSessionMixer * session = (__bridge CMAudioSessionMixer *)(inRefCon);
    memcpy(ioData->mBuffers[0].mData, session->recorderBuffer, ioData->mBuffers[0].mDataByteSize);
    return noErr;
}


- (instancetype)initAudioUnitMixerWithSampleRate:(CMAudioMixerSampleRate)audioRate{
    self = [super init];
    if (self) {
        self.audioRate = audioRate;
        recorderBuffer = malloc(100*1024*1024);
        [self createAUGraph];
        [self setAudioUnit];
        [self relocationAudio];
    }
    return self;
}

#pragma mark - 设置AVAudioSession

- (void)relocationAudio{
    // /Applications/VLC.app/Contents/MacOS/VLC --demux=rawaud --rawaud-channels 1 --rawaud-samplerate 8000
    NSError* error;
    BOOL success;
    //设置成语音视频模式
    audioSession = [AVAudioSession sharedInstance];
    
    success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                            withOptions:AVAudioSessionCategoryOptionAllowBluetooth|
                                        AVAudioSessionCategoryOptionAllowBluetoothA2DP|
                                        AVAudioSessionCategoryOptionMixWithOthers|
                                        AVAudioSessionCategoryOptionDuckOthers
//                                        |AVAudioSessionCategoryOptionDefaultToSpeaker
                                  error:nil];
    
    success = [audioSession setActive:YES error:&error];
}

#pragma mark - 设置AUGraph链接Node

- (void)createAUGraph{
    OSStatus status;
#if 1
    AudioComponentDescription timePitchACD = [self.class timePitchACD];
    AudioComponentDescription mixerACD = [self.class mixerACD];
#endif
    AudioComponentDescription outputACD = [self.class outputACD];
    
    status = NewAUGraph(&graph);
    
    AUGraphAddNode(graph, &outputACD, &outputNode);
    AUGraphAddNode(graph, &timePitchACD, &timePitchNode);
    AUGraphAddNode(graph, &mixerACD, &mixerNode);
    AUGraphConnectNodeInput(graph, mixerNode, 0, timePitchNode, 0);
    AUGraphConnectNodeInput(graph, timePitchNode, 0, outputNode, 0);
    AUGraphOpen(graph);
    AUGraphNodeInfo(graph, outputNode, &outputACD, &IOUnit);
    AUGraphNodeInfo(graph, mixerNode, &mixerACD, &mixerUnit);
    AUGraphNodeInfo(graph, timePitchNode, &timePitchACD, &formatUnit);
}

#pragma mark - 设置AudioUnit

- (void)setAudioUnit{
    int success = -1;
    UInt32 enableFlag = 1;
    success = AudioUnitSetProperty(IOUnit,
                                   kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Input,
                                   1,
                                   &enableFlag,
                                   sizeof(enableFlag));
    if (noErr != success) {
        CheckStatus(success,@"CMAudioSessionSpeed | kAudioOutputUnitProperty_EnableIO Input is Failed", YES);
        return;
    }
    
    success = AudioUnitSetProperty(IOUnit,
                                   kAudioOutputUnitProperty_EnableIO,
                                   kAudioUnitScope_Output,
                                   0,
                                   &enableFlag,
                                   sizeof(enableFlag));
    if (noErr != success) {
        CheckStatus(success,@"CMAudioSessionSpeed | kAudioOutputUnitProperty_EnableIO Output is Failed", YES);
        return;
    }
    
    
    AudioStreamBasicDescription inputFormat;
    inputFormat.mSampleRate       = self.audioRate;
    inputFormat.mFormatID         = kAudioFormatLinearPCM;
    inputFormat.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsNonInterleaved;
    inputFormat.mFramesPerPacket  = 1;
    inputFormat.mChannelsPerFrame = 1;
    inputFormat.mBitsPerChannel   = 16;
    inputFormat.mBytesPerFrame    = (inputFormat.mBitsPerChannel / 8) * inputFormat.mChannelsPerFrame;
    inputFormat.mBytesPerPacket   = inputFormat.mBytesPerFrame;
    [self printAudioStreamBasicDescription:inputFormat];
    
    
    AudioUnitSetProperty(mixerUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &inputFormat,
                         sizeof(inputFormat));
    if (noErr != success) {
        CheckStatus(success,@"CMAudioSessionSpeed | mixerUnit kAudioUnitProperty_StreamFormat Input is Failed", YES);
        return;
    }
    AudioUnitSetProperty(mixerUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         0,
                         &inputFormat,
                         sizeof(inputFormat));//Mixer的输出流格式。
    if (noErr != success) {
        CheckStatus(success,@"CMAudioSessionSpeed | mixerUnit kAudioUnitProperty_StreamFormat Output is Failed", YES);
        return;
    }
    success = AudioUnitSetProperty(IOUnit,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   0,
                                   &inputFormat,
                                   sizeof(inputFormat));
    if (noErr != success) {
        CheckStatus(success,@"CMAudioSessionSpeed | IOUnit kAudioUnitProperty_StreamFormat Input is Failed", YES);
        return;
    }
    
    success = AudioUnitSetProperty(IOUnit,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Output,
                                   1,
                                   &inputFormat,
                                   sizeof(inputFormat));
    if (noErr != success) {
        CheckStatus(success,@"CMAudioSessionSpeed | IOUnit kAudioUnitProperty_StreamFormat Output is Failed", YES);
        return;
    }
    
    //将音频单元设置为每片处理最多4096帧 不设置Air Pods 采集音频会报错 kAudioUnitErr_TooManyFramesToProcess
    UInt32 value = 4096;
    UInt32 size = sizeof(value);
    AudioUnitScope scope = kAudioUnitScope_Global;
    AudioUnitPropertyID param = kAudioUnitProperty_MaximumFramesPerSlice;
    AudioUnitSetProperty(mixerUnit, param, scope, 0, &value, size);
    AudioUnitSetProperty(formatUnit, param, scope, 0, &value, size);
    AudioUnitSetProperty(IOUnit, param, scope, 0, &value, size);
    
    //设置数据采集回调函数
    AURenderCallbackStruct recordCallback;
    recordCallback.inputProc = CMRecordingCallback;
    recordCallback.inputProcRefCon = (__bridge void *)self;
    success = AudioUnitSetProperty(IOUnit,
                                   kAudioOutputUnitProperty_SetInputCallback,
                                   kAudioUnitScope_Output,
                                   1,
                                   &recordCallback,
                                   sizeof(recordCallback));
    if (success != noErr) {
        CheckStatus(success,@"CMAudioSessionSpeed | kAudioOutputUnitProperty_SetInputCallback is Failed", YES);
    }
    
//    AUGraphSetNodeInputCallback(graph, outputNode, 0, &recordCallback);
//    AudioUnitAddRenderNotify(formatUnit, CMRenderCallback, (__bridge void *)self);

    //设置数据播放回调
    AURenderCallbackStruct callBackStruct;
    callBackStruct.inputProc       = CMRenderCallback;
    callBackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    success = AudioUnitSetProperty(mixerUnit,
                                   kAudioUnitProperty_SetRenderCallback,
                                   kAudioUnitScope_Input,
                                   0,
                                   &callBackStruct,
                                   sizeof(callBackStruct));
    
    if (success != noErr) {
        CheckStatus(success,@"CMAudioSessionSpeed | kAudioUnitProperty_SetRenderCallback is Failed", YES);
    }
}

#pragma mark - 回音消除

- (void)startEchoAudio:(int)echoStatus{
    OSStatus status;
    UInt32 echoCancellation;
    UInt32 size = sizeof(echoCancellation);
    status = AudioUnitGetProperty(IOUnit,
                                  kAUVoiceIOProperty_BypassVoiceProcessing,
                                  kAudioUnitScope_Global,
                                  0,
                                  &echoCancellation,
                                  &size);
    if (status != noErr){
        CheckStatus(status,@"CMAudioSessionSpeed | kAUVoiceIOProperty_BypassVoiceProcessing is Failed", YES);
    }
    
    if (echoStatus == echoCancellation){
        return;
    }
    status = AudioUnitSetProperty(IOUnit,
                                  kAUVoiceIOProperty_BypassVoiceProcessing,
                                  kAudioUnitScope_Global,
                                  0,
                                  &echoStatus,
                                  sizeof(echoStatus));
    if (status != noErr){
        CheckStatus(status,@"CMAudioSessionSpeed | kAUVoiceIOProperty_BypassVoiceProcessing is Failed", YES);
    }
}

#pragma mark - 设置变声参数

- (void)pitchEnable:(int)pitchEnable{
    OSStatus status;
    if (pitchEnable == 0) {
        status = AudioUnitSetParameter(formatUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, 0.0, 0);
    }else{
        status = AudioUnitSetParameter(formatUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, (Float32)1000.0, 0);
    }
//    status = AudioUnitSetParameter(formatUnit, kNewTimePitchParam_Rate, kAudioUnitScope_Global, 0, (Float32)20.0, 0);
//    status = AudioUnitSetParameter(formatUnit, kVarispeedParam_PlaybackRate, kAudioUnitScope_Global, 0, 2.5, 0);
//    status = AudioUnitSetParameter(formatUnit, kVarispeedParam_PlaybackCents, kAudioUnitScope_Global, 0, (Float32)-200, 0);
}

#pragma mark - 设置输出音量大小

- (void)mixerVolume:(int)volume{
    AudioUnitSetParameter(mixerUnit, kMatrixMixerParam_Volume, kAudioUnitScope_Output, 0, volume, 0);
}

#pragma mark - 开启采集

- (int)startAudioUnitRecorder{
    int success = -1;
    success = AUGraphInitialize(graph);
    if (noErr != success) {
        CheckStatus(success,@"CMAudioSessionSpeed | AUGraphInitialize is Failed", YES);
    }

    success = AUGraphStart(graph);
    if (noErr != success) {
        CheckStatus(success,@"CMAudioSessionSpeed | AUGraphStart is Failed", YES);
    }
    return success;
}

#pragma mark - 停止采集

- (int)stopAudioUnitRecorder{
    if (!graph) {
        return -1;
    }
    OSStatus status = AUGraphStop(graph);
    if (status == noErr) {
        NSLog(@"停止音频");
        NSLog(@"CMAudioSessionSpeed | AUGraphStop");
    }else{
        NSLog(@"CMAudioSessionSpeed | AUGraphStop: %d", status);
    }
    return status;
}

#pragma mark - 关闭采集

- (void)closeAudioUnitRecorder{
    if (!graph) {
        return;
    }
    OSStatus status = AUGraphClose(graph);
    if (buffList != NULL) {
        if (buffList->mBuffers[0].mData) {
//            free(buffList->mBuffers[0].mData);
            buffList->mBuffers[0].mData = NULL;
        }
        free(buffList);
        buffList = NULL;
    }
    if (status == noErr) {
        NSLog(@"CMAudioSessionSpeed | 关闭音频采集");
        graph = NULL;
    }
}

#pragma mark - 设置听筒/扬声器

- (void)setOutputAudioPort:(AVAudioSessionPortOverride)audioSessionPortOverride{
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *portDesc in [currentRoute outputs])
    {
        if([portDesc.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]){
            [audioSession overrideOutputAudioPort:audioSessionPortOverride error:nil];
            NSLog(@"当前输出:%@========== 设置输出:%lu",portDesc.portName,(unsigned long)audioSessionPortOverride);
            break;
        }else if ([portDesc.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]){
            [audioSession overrideOutputAudioPort:audioSessionPortOverride error:nil];
            NSLog(@"当前输出:%@========== 设置输出:%lu",portDesc.portName,(unsigned long)audioSessionPortOverride);
            break;
        }
    }
}


static void CheckStatus(OSStatus status, NSString *message, BOOL fatal)
{
    if(status != noErr)
    {
        char fourCC[16];
        *(UInt32 *)fourCC = CFSwapInt32HostToBig(status);
        fourCC[4] = '\0';
        
        if(isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3]))
            NSLog(@"%@: %s", message, fourCC);
        else
            NSLog(@"%@: %d", message, (int)status);
        
//        if(fatal)
//            exit(-1);
    }
}


+ (AudioComponentDescription)timePitchACD
{
    AudioComponentDescription acd;
    acd.componentType = kAudioUnitType_FormatConverter;
    acd.componentSubType = kAudioUnitSubType_NewTimePitch;
    acd.componentManufacturer = kAudioUnitManufacturer_Apple;
    acd.componentFlags        = 0;
    acd.componentFlagsMask    = 0;
    return acd;
}

+ (AudioComponentDescription)mixerACD{
    AudioComponentDescription mixerDesc;
    mixerDesc.componentType = kAudioUnitType_Mixer;
    mixerDesc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixerDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    return mixerDesc;
}

+ (AudioComponentDescription)outputACD{
    AudioComponentDescription desc;
    desc.componentType         = kAudioUnitType_Output;
    desc.componentSubType      = kAudioUnitSubType_VoiceProcessingIO;//    kAudioUnitSubType_VoiceProcessingIO, kAudioUnitSubType_RemoteIO
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags        = 0;
    desc.componentFlagsMask    = 0;
    
    return desc;
}

- (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("************PCM采集************\n");
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
