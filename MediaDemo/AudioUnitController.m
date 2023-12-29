//
//  AudioUnitController.m
//  MediaDemo
//
//  Created by Cold Mountain on 2023/12/28.
//

#import "AudioUnitController.h"

@interface AudioUnitController ()<CMAudioSessionPCMDelegate>
@property (nonatomic, strong) CMAudioSession_PCM *audioSession;
@property (nonatomic, strong) CMAuidoPlayer_PCM *audioPlayer;

@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic, assign) int playState;
@property (nonatomic, assign) float volumeNum;

@property (weak, nonatomic) IBOutlet UIButton *captureBtn;
@property (weak, nonatomic) IBOutlet UIButton *echoButton;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *agcBtn;
@end

@implementation AudioUnitController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playState = -1;
    self.volumeNum = 0.0;
    
    [self.speakerBtn setTitle:@"听筒" forState:UIControlStateNormal];
    [self.speakerBtn setTitle:@"扬声器" forState:UIControlStateSelected];
    
    self.echoButton.selected = YES;
    [self.echoButton setBackgroundColor:[UIColor systemPurpleColor]];
    [self.echoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.agcBtn setTitleColor:[UIColor systemGrayColor] forState:UIControlStateNormal];
    [self.agcBtn setTitleColor:[UIColor systemRedColor] forState:UIControlStateSelected];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.handle closeFile];
    [self.audioSession cm_stopAudioUnitRecorder];
    [self.audioSession cm_closeAudioUnitRecorder];
#if AudioPlayerEnable
    [self.audioPlayer cm_stop];
    [self.audioPlayer cm_close];
#endif
}

#pragma mark - 开启

- (IBAction)captureAudio:(UIButton *)sender {
#if AudioPlayerEnable
    if (self.audioPlayer == nil) {
        self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
    }
#endif
    int success = -1;
    if (self.audioSession == nil) {
        self.audioSession = [[CMAudioSession_PCM alloc]initAudioUnitWithSampleRate:CMAudioPCMSampleRate_Defalut];
        self.audioSession.delegate = self;
    }
    success = [self.audioSession cm_startAudioUnitRecorder];
    [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
    if (success == noErr) {
        self.playState = 1;
        [self.captureBtn setTitle:@"采集中" forState:UIControlStateNormal];
    }
#if AudioPlayerEnable
    [self.audioPlayer cm_play];
#endif
}

#pragma mark - 停止

- (IBAction)stopCaptureAudio:(UIButton *)sender {
    int success = -1;
    success = [self.audioSession cm_stopAudioUnitRecorder];
    if (success == noErr) {
        self.playState = -1;
        [self.captureBtn setTitle:@"采集" forState:UIControlStateNormal];
    }
}

#pragma mark - 关闭

- (IBAction)closeCaptureAudio:(UIButton *)sender {
    [self.audioSession cm_closeAudioUnitRecorder];
}

#pragma mark - 扬声器/麦克风

- (IBAction)earphoneSpeaker:(UIButton *)sender {
    if (self.playState < 0) {
        [QCHUDView showDpromptText:@"请开始采集音频"];
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideNone];
    }else {
        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
    }
}

#pragma mark - 回音消除

- (IBAction)echoAction:(UIButton *)sender {
    if (self.playState < 0) {
        [QCHUDView showDpromptText:@"请开始采集音频"];
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSession cm_startEchoAudio:0];
        [self.echoButton setBackgroundColor:[UIColor systemPurpleColor]];
        [self.echoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else {
        [self.audioSession cm_startEchoAudio:1];
        [self.echoButton setBackgroundColor:[UIColor clearColor]];
        [self.echoButton setTitleColor:[UIColor systemPurpleColor] forState:UIControlStateNormal];
    }
}

#pragma mark - AGC增益

- (IBAction)agcEnableAction:(UIButton *)sender {
    if (self.playState < 0) {
        [QCHUDView showDpromptText:@"请开始采集音频"];
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSession cm_startAGC:1];
    }else{
        [self.audioSession cm_startAGC:0];
    }
}

#pragma mark - 输出音量大小

- (IBAction)setVolume:(UIButton *)sender {
//    if (self.volumeNum < 0) {
//        return;
//    }
//    if (sender.tag == 0) {
//        self.volumeNum += 0.1;
//        [self.audioSession cm_mixerVolume:self.volumeNum];
//    }else if (sender.tag == 1){
//        self.volumeNum -= 0.1;
//        [self.audioSession cm_mixerVolume:self.volumeNum];
//    }
//    NSLog(@"输入音量大小: %.2f",self.volumeNum);
}

#pragma mark - 音频采集回调

- (void)cm_audioUnitBackPCM:(NSData*)audioData selfClass:(CMAudioSession_PCM*)selfClass{
#if LocalEnable
    self.handle = [[AudioFileManager createFileHandle] writeData:audioData];
#endif
#if AudioPlayerEnable
    [self.audioPlayer cm_playAudioWithData:(char*)[audioData bytes] andLength:audioData.length];
#endif
}


@end
