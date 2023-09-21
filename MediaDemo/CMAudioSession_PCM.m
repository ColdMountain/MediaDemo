//
//  CMAudioSession_PCM.m
//  Player_PCM
//
//  Created by ColdMountain on 2020/11/24.
//

#import "CMAudioSession_PCM.h"

#define INPUT_BUS 1
#define OUTPUT_BUS 0

@interface CMAudioSession_PCM()
{
    OSStatus status;
    AudioUnit audioUnit;
    AudioBufferList *buffList;
    AudioStreamBasicDescription  dataFormat;
    AVAudioPlayer *audioPlayer;
    AVAudioSession *audioSession;
    int failed_initalize;
    Byte *recorderBuffer;
}
@end


@implementation CMAudioSession_PCM
- (instancetype)initAudioUnitWithSampleRate:(CMAudioPCMSampleRate)audioRate{
    self = [super init];
    if (self) {
        failed_initalize = 0;
        recorderBuffer = malloc(0x10000);
        self.audioRate = audioRate;
        [self relocationAudio];
        [self initAudioComponent];
    }
    return self;
}

- (void)relocationAudio{
    // /Applications/VLC.app/Contents/MacOS/VLC --demux=rawaud --rawaud-channels 1 --rawaud-samplerate 8000
    NSError* error;
    BOOL success;
    //设置成语音视频模式
    audioSession = [AVAudioSession sharedInstance];
//    success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                            withOptions:AVAudioSessionCategoryOptionAllowBluetooth|
                                        AVAudioSessionCategoryOptionAllowBluetoothA2DP|
                                        AVAudioSessionCategoryOptionMixWithOthers|
                                        AVAudioSessionCategoryOptionDuckOthers
//                                        |AVAudioSessionCategoryOptionDefaultToSpeaker
                                  error:nil];
    
//    success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
//                                   mode:AVAudioSessionModeVideoChat
//                                options:
//                                        AVAudioSessionCategoryOptionAllowBluetooth|
//                                        AVAudioSessionCategoryOptionAllowBluetoothA2DP|
//                                        AVAudioSessionCategoryOptionDuckOthers
////                                        |AVAudioSessionCategoryOptionDefaultToSpeaker
//                                  error:nil];
    //需要加入设置采样率 声道数 每采样一次的时间
//    [audioSession setPreferredSampleRate:8000 error:&error];
//    [audioSession setPreferredInputNumberOfChannels:1 error:&error];
//    [audioSession setPreferredIOBufferDuration:0.125 error:&error];
    
//    success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    success = [audioSession setActive:YES error:&error];
    
#if 0
    int isSuccess = -1;
    NSArray *inputs = audioSession.availableInputs;

    AVAudioSessionPortDescription *builtInputMic = nil;

    for (AVAudioSessionPortDescription* port in inputs) {
        NSLog(@"%@",port.portType);
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic])
        {
            builtInputMic = port;
            break;
        }
    }
    AVAudioSessionDataSourceDescription * frontDataSource = nil;
    for (AVAudioSessionDataSourceDescription* source in builtInputMic.dataSources)
    {
        NSLog(@"%@",source.orientation);
        NSLog(@"%@",source.supportedPolarPatterns);
        if ([source.orientation isEqual:AVAudioSessionOrientationBottom]){
            frontDataSource = source;
            isSuccess = [frontDataSource setPreferredPolarPattern:AVAudioSessionPolarPatternCardioid error:nil];
            NSLog(@"设置属性 %d",isSuccess);
            break;
        }
    }

    if (frontDataSource){
        NSLog(@"Currently selected source is \"%@\" for port \"%@\"", builtInputMic.selectedDataSource.dataSourceName, builtInputMic.portName);
        NSLog(@"Attempting to select source \"%@\" on port \"%@\"  \"%@\" \"%@\"", frontDataSource, builtInputMic.portName, frontDataSource.selectedPolarPattern, frontDataSource.preferredPolarPattern);
        [builtInputMic setPreferredDataSource:frontDataSource error:nil];
    }
#endif
}

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

- (void)initAudioComponent{
    // 描述音频元件
    AudioComponentDescription desc;
    desc.componentType         = kAudioUnitType_Output;
    desc.componentSubType      = kAudioUnitSubType_VoiceProcessingIO;
//    kAudioUnitSubType_VoiceProcessingIO, kAudioUnitSubType_RemoteIO
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags        = 0;
    desc.componentFlagsMask    = 0;
    // 获得一个元件
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    // 获得 Audio Unit
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    if (status != noErr) {
        NSLog(@"1、AudioUnitGetProperty error, ret: %d", (int)status);
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
    
    //录音输入
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  INPUT_BUS,
                                  &inputFormat,
                                  sizeof(inputFormat));
    if (status != noErr) {
        NSLog(@"2、AudioUnitGetProperty error, ret: %d", (int)status);
    }
    //播放输出
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  OUTPUT_BUS,
                                  &inputFormat,
                                  sizeof(inputFormat));
    if (status != noErr) {
        NSLog(@"3、AudioUnitGetProperty error, ret: %d", (int)status);
    }
    
    AudioStreamBasicDescription outputFormat = inputFormat;
    
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  OUTPUT_BUS,
                                  &flag,
                                  sizeof(flag));

     if (status != noErr) {
         NSLog(@"4、AudioUnitGetProperty error, ret: %d", (int)status);
     }
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  INPUT_BUS,
                                  &flag,
                                  sizeof(flag));
    if (status != noErr) {
        NSLog(@"5、AudioUnitGetProperty error, ret: %d", (int)status);
    }
        
    //AGC 增益 依赖 kAudioUnitSubType_VoiceProcessingIO
    UInt32 enable_agc = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAUVoiceIOProperty_VoiceProcessingEnableAGC,
                                  kAudioUnitScope_Global,
                                  INPUT_BUS,
                                  &enable_agc,
                                  sizeof(enable_agc));
    if (status != noErr) {
        NSLog(@"Failed to enable the built-in AGC. " "Error=%d", (int)status);
    }
    
    
    //设置数据采集回调函数
    AURenderCallbackStruct recordCallback;
    recordCallback.inputProc = RecordingCallback;
    recordCallback.inputProcRefCon = (__bridge void *)self;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Output,
                                  INPUT_BUS,
                                  &recordCallback,
                                  sizeof(recordCallback));
    if (status != noErr) {
        NSLog(@"6、AudioUnitGetProperty error, ret: %d", (int)status);
    }

    //设置数据播放回调
    AURenderCallbackStruct callBackStruct;
    callBackStruct.inputProc       = CMRenderCallback;
    callBackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  OUTPUT_BUS,
                                  &callBackStruct,
                                  sizeof(callBackStruct));

    if (status != noErr) {
        NSLog(@"7、AudioUnitGetProperty error, ret: %d", (int)status);
    }
//    NSLog(@"AudioUnitInitialize: %p", audioUnit);
//    OSStatus result = AudioUnitInitialize(audioUnit);
//    NSLog(@"result %d", (int)result);
}

#pragma mark - 采集音频回调

static OSStatus RecordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    CMAudioSession_PCM *session = (__bridge CMAudioSession_PCM *)inRefCon;
    OSStatus status = noErr;
    UInt16 numSamples = inNumberFrames*1;
    
//    uint8_t  kAudioCaptureData[4*1024];//numSamples * sizeof(UInt16)
    uint8_t  kAudioCaptureData[numSamples * sizeof(UInt32)];
    int32_t  kAudioCaptureSize           = inNumberFrames * 2;
    
     if (inNumberFrames > 0) {
         session->buffList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
         session->buffList->mNumberBuffers = 1;
         session->buffList->mBuffers[0].mNumberChannels = 1;
         session->buffList->mBuffers[0].mDataByteSize = kAudioCaptureSize;
         session->buffList->mBuffers[0].mData = kAudioCaptureData;
         
         
//         session->buffList->mBuffers[0].mDataByteSize = numSamples * sizeof(UInt16);
//         session->buffList->mBuffers[0].mData = malloc(numSamples * sizeof(UInt16));
         
//         NSLog(@"mData %lu", numSamples * sizeof(UInt16));
//         NSLog(@"size = %d", kAudioCaptureSize);
         status = AudioUnitRender(session->audioUnit,
                                  ioActionFlags,
                                  inTimeStamp,
                                  inBusNumber,
                                  inNumberFrames,
                                  session->buffList);
         
         NSData *pcmData = [NSData dataWithBytes:session->buffList->mBuffers[0].mData
                                    length:session->buffList->mBuffers[0].mDataByteSize];
         
         memcpy(session->recorderBuffer, session->buffList->mBuffers[0].mData, session->buffList->mBuffers[0].mDataByteSize);
         
         if ([session.delegate respondsToSelector:@selector(cm_audioUnitBackPCM:selfClass:)]) {
             char* speexByte = (char*)[pcmData bytes];
             NSData *data = [NSData dataWithBytes:speexByte length:pcmData.length];
             [session.delegate cm_audioUnitBackPCM:data selfClass:session];
         }
     } else {
         NSLog(@"inNumberFrames is %u", (unsigned int)inNumberFrames);
     }
    
    
    return noErr;
}

#pragma mark - 播放音频回调

OSStatus  CMRenderCallback(void *                      inRefCon,
                           AudioUnitRenderActionFlags* ioActionFlags,
                           const AudioTimeStamp*       inTimeStamp,
                           UInt32                      inBusNumber,
                           UInt32                      inNumberFrames,
                           AudioBufferList*            __nullable ioData){
    CMAudioSession_PCM * session = (__bridge CMAudioSession_PCM *)(inRefCon);
    memcpy(ioData->mBuffers[0].mData, session->recorderBuffer, ioData->mBuffers[0].mDataByteSize);
    return noErr;
}

//回音消除
- (void)cm_startEchoAudio:(int)echoStatus{
    OSStatus status;
    UInt32 echoCancellation;
    UInt32 size = sizeof(echoCancellation);
    status = AudioUnitGetProperty(audioUnit,
                                  kAUVoiceIOProperty_BypassVoiceProcessing,
                                  kAudioUnitScope_Global,
                                  OUTPUT_BUS,
                                  &echoCancellation,
                                  &size);
    if (status != noErr){
        NSLog(@"kAUVoiceIOProperty_BypassVoiceProcessing failed %d", (int)status);
    }
    
    if (echoStatus == echoCancellation){
        return;
    }
    status = AudioUnitSetProperty(audioUnit,
                                  kAUVoiceIOProperty_BypassVoiceProcessing,
                                  kAudioUnitScope_Global,
                                  OUTPUT_BUS,
                                  &echoStatus,
                                  sizeof(echoStatus));
    if (status != noErr){
        NSLog(@"kAUVoiceIOProperty_BypassVoiceProcessing failed %d", (int)status);
    }
}


//开启AudioUnit
- (void)cm_startAudioUnitRecorder {
    OSStatus status;
    status = AudioUnitInitialize(audioUnit);
    
    while (status != noErr) {
        NSLog(@"Failed to initialize the Voice Processing I/O unit. "
                     "Error=%ld.",
                    (long)status);
        failed_initalize++;
        if (failed_initalize == 5) {
            //重试5次
          // Max number of initialization attempts exceeded, hence abort.
        }
        [NSThread sleepForTimeInterval:0.1f];
        status = AudioUnitInitialize(audioUnit);
      }
    status = AudioOutputUnitStart(audioUnit);
    
    if (status == noErr) {
        NSLog(@"开启音频");
        NSLog(@"CMAudioSession_PCM | AudioUnitInitialize: %p", audioUnit);
        NSLog(@"CMAudioSession_PCM | AudioOutputUnitStart: %p", audioUnit);
    }else{
        NSLog(@"CMAudioSession_PCM | AudioUnitInitialize: %p %d", audioUnit, status);
        NSLog(@"CMAudioSession_PCM | AudioOutputUnitStart: %p %d", audioUnit, status);
    }
}

//关闭AudioUnit
- (void)cm_stopAudioUnitRecorder{
    OSStatus status = AudioOutputUnitStop(audioUnit);
    if (status == noErr) {
        NSLog(@"停止音频");
        NSLog(@"CMAudioSession_PCM | AudioOutputUnitStop: %p", audioUnit);
    }else{
        NSLog(@"CMAudioSession_PCM | AudioOutputUnitStop: %p %d", audioUnit, status);
    }
}

- (void)cm_closeAudioUnitRecorder{
    AudioUnitUninitialize(audioUnit);
    if (buffList != NULL) {
        if (buffList->mBuffers[0].mData) {
            free(buffList->mBuffers[0].mData);
            buffList->mBuffers[0].mData = NULL;
        }
        free(buffList);
        buffList = NULL;
    }
    OSStatus status = AudioComponentInstanceDispose(audioUnit);
    if (status == noErr) {
        NSLog(@"关闭音频");
    }
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
