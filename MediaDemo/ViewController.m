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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_44100Hz];
}

- (void)cm_audioUnitBackPCM:(NSData*)audioData{
    [self.audioPlayer kl_playAudioWithData:(char*)[audioData bytes] andLength:audioData.length];
}

- (IBAction)startAction:(id)sender {
    self.audioSession = [[CMAudioSession_PCM alloc]initAudioUnitWithSampleRate:CMAudioPCMSampleRate_44100Hz];
    self.audioSession.delegate = self;
    [self.audioSession setOutputAudioPort: AVAudioSessionPortOverrideSpeaker];
    [self.audioSession cm_startAudioUnitRecorder];
}
- (IBAction)stopAction:(id)sender {
    [self.audioPlayer kl_stop];
    [self.audioSession cm_stopAudioUnitRecorder];
}
- (IBAction)closeAction:(id)sender {
    [self.audioSession cm_closeAudioUnitRecorder];
    self.audioSession = nil;
}


@end
