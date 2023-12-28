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

@property (weak, nonatomic) IBOutlet UIButton *echoButton;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *voiceChangeBtn;
@end

@implementation AudioUnitGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (IBAction)captureAudio:(UIButton *)sender {
    if (self.audioSession == nil) {
        self.audioSession = [[CMAudioSessionSpeed alloc]initAudioUnitSpeedWithSampleRate:CMAudioSpeedSampleRate_Defalut];
        self.audioSession.delegate = self;
    }
    [self.audioSession startAudioUnitRecorder];
    [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
}

- (IBAction)stopCaptureAudio:(UIButton *)sender {
    [self.audioSession stopAudioUnitRecorder];
}

- (IBAction)closeCaptureAudio:(UIButton *)sender {
    [self.audioSession closeAudioUnitRecorder];
}

- (IBAction)earphoneSpeaker:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideNone];
    }else {
        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
    }
}
- (IBAction)echoAction:(UIButton *)sender {
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
- (IBAction)soundTouch:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSession pitchEnable:1];
    }else{
        [self.audioSession pitchEnable:0];
    }
}

- (void)audioUnitBackPCM:(NSData*)audioData{
#if 0
    self.handle = [[AudioFileManager createFileHandle] writeData:audioData];
#endif
}
@end
