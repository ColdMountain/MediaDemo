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
@property (weak, nonatomic) IBOutlet UIButton *echoButton;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@end

@implementation AudioUnitController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.speakerBtn setTitle:@"听筒" forState:UIControlStateNormal];
    [self.speakerBtn setTitle:@"扬声器" forState:UIControlStateSelected];
    
    self.echoButton.selected = YES;
    [self.echoButton setBackgroundColor:[UIColor systemPurpleColor]];
    [self.echoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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

- (IBAction)captureAudio:(UIButton *)sender {
#if AudioPlayerEnable
    if (self.audioPlayer == nil) {
        self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
    }
#endif
    if (self.audioSession == nil) {
        self.audioSession = [[CMAudioSession_PCM alloc]initAudioUnitWithSampleRate:CMAudioPCMSampleRate_Defalut];
        self.audioSession.delegate = self;
    }
    [self.audioSession cm_startAudioUnitRecorder];
    [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
#if AudioPlayerEnable
    [self.audioPlayer cm_play];
#endif
}

- (IBAction)stopCaptureAudio:(UIButton *)sender {
    [self.audioSession cm_stopAudioUnitRecorder];
}

- (IBAction)closeCaptureAudio:(UIButton *)sender {
    [self.audioSession cm_closeAudioUnitRecorder];
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
        [self.audioSession cm_startEchoAudio:0];
        [self.echoButton setBackgroundColor:[UIColor systemPurpleColor]];
        [self.echoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else {
        [self.audioSession cm_startEchoAudio:1];
        [self.echoButton setBackgroundColor:[UIColor clearColor]];
        [self.echoButton setTitleColor:[UIColor systemPurpleColor] forState:UIControlStateNormal];
    }
}

- (void)cm_audioUnitBackPCM:(NSData*)audioData selfClass:(CMAudioSession_PCM*)selfClass{
#if LocalEnable
    self.handle = [[AudioFileManager createFileHandle] writeData:audioData];
#endif
#if AudioPlayerEnable
    [self.audioPlayer cm_playAudioWithData:(char*)[audioData bytes] andLength:audioData.length];
#endif
}


@end
