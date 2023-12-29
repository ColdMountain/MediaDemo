//
//  AudioUnitGraphController.m
//  MediaDemo
//
//  Created by Cold Mountain on 2023/12/28.
//

#import "AudioUnitGraphController.h"

@interface AudioUnitGraphController ()<CMAudioSessionSpeedDelegate>
@property (nonatomic, strong) CMAudioSessionSpeed *audioSession;

@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic, assign) int playState;
@property (nonatomic, assign) int volumeNum;

@property (weak, nonatomic) IBOutlet UIButton *captureBtn;
@property (weak, nonatomic) IBOutlet UIButton *echoButton;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *voiceChangeBtn;
@end

@implementation AudioUnitGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playState = -1;
    self.volumeNum = 0;
    
    [self.speakerBtn setTitle:@"听筒" forState:UIControlStateNormal];
    [self.speakerBtn setTitle:@"扬声器" forState:UIControlStateSelected];
    
    [self.voiceChangeBtn setTitleColor:[UIColor systemGrayColor] forState:UIControlStateNormal];
    [self.voiceChangeBtn setTitleColor:[UIColor systemRedColor] forState:UIControlStateSelected];
    
    self.echoButton.selected = YES;
    [self.echoButton setBackgroundColor:[UIColor systemPurpleColor]];
    [self.echoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.handle closeFile];
    [self.audioSession stopAudioUnitRecorder];
    [self.audioSession closeAudioUnitRecorder];
}

#pragma mark - 开启

- (IBAction)captureAudio:(UIButton *)sender {
    int success = -1;
    if (self.audioSession == nil) {
        self.audioSession = [[CMAudioSessionSpeed alloc]initAudioUnitSpeedWithSampleRate:CMAudioSpeedSampleRate_Defalut];
        self.audioSession.delegate = self;
    }
    success = [self.audioSession startAudioUnitRecorder];
    [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
    if (success == noErr) {
        self.playState = 1;
        [self.captureBtn setTitle:@"采集中" forState:UIControlStateNormal];
    }
}

#pragma mark - 停止

- (IBAction)stopCaptureAudio:(UIButton *)sender {
    int success = -1;
    success = [self.audioSession stopAudioUnitRecorder];
    if (success == noErr) {
        self.playState = -1;
        [self.captureBtn setTitle:@"采集" forState:UIControlStateNormal];
    }
}

#pragma mark - 关闭

- (IBAction)closeCaptureAudio:(UIButton *)sender {
    [self.audioSession closeAudioUnitRecorder];
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
        [self.audioSession startEchoAudio:0];
        [self.echoButton setBackgroundColor:[UIColor systemPurpleColor]];
        [self.echoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else {
        [self.audioSession startEchoAudio:1];
        [self.echoButton setBackgroundColor:[UIColor clearColor]];
        [self.echoButton setTitleColor:[UIColor systemPurpleColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 变声

- (IBAction)soundTouch:(UIButton *)sender {
    if (self.playState < 0) {
        [QCHUDView showDpromptText:@"请开始采集音频"];
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSession pitchEnable:1];
    }else{
        [self.audioSession pitchEnable:0];
    }
}

#pragma mark - 输出音量大小

- (IBAction)setVolume:(UIButton *)sender {
    if (self.volumeNum < 0) {
        return;
    }
    if (sender.tag == 0) {
        self.volumeNum += 1;
        [self.audioSession mixerVolume:self.volumeNum];
    }else if (sender.tag == 1){
        self.volumeNum -= 1;
        [self.audioSession mixerVolume:self.volumeNum];
    }
    NSLog(@"输入音量大小: %d",self.volumeNum);
}

#pragma mark - 音频采集回调

- (void)audioUnitBackPCM:(NSData*)audioData{
#if 0
    self.handle = [[AudioFileManager createFileHandle] writeData:audioData];
#endif
}
@end
