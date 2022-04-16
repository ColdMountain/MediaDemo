//
//  ViewController.m
//  MediaDemo
//
//  Created by ColdMountain on 2022/4/16.
//

#import "ViewController.h"

#import "CMAuidoPlayer_PCM.h"
#import "CMAudioSession_PCM.h"

@interface ViewController ()<CMAudioSessionPCMDelegate>
@property (nonatomic, strong) CMAuidoPlayer_PCM *audioPlayer;
@property (nonatomic, strong) CMAudioSession_PCM*audioSession;
@property (weak, nonatomic) IBOutlet UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.button setTitle:@"听筒" forState:UIControlStateNormal];
    [self.button setTitle:@"扬声器" forState:UIControlStateSelected];
    
    self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
}

- (void)cm_audioUnitBackPCM:(NSData*)audioData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.audioPlayer kl_playAudioWithData:(char*)[audioData bytes] andLength:audioData.length];
    });
}

- (IBAction)receiverAndSpeaker:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
    }else {
        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideNone];
    }
}

- (IBAction)startAction:(id)sender {
    self.audioSession = [[CMAudioSession_PCM alloc]initAudioUnitWithSampleRate:CMAudioPCMSampleRate_Defalut];
    self.audioSession.delegate = self;
    [self.audioSession cm_startAudioUnitRecorder];
}
- (IBAction)stopAction:(id)sender {
    [self.audioPlayer kl_stop];
    [self.audioSession cm_stopAudioUnitRecorder];
}
- (IBAction)closeAction:(id)sender {
    [self.audioSession cm_closeAudioUnitRecorder];
    self.audioSession = nil;
    self.button.selected = NO;
}


@end
