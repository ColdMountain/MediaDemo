//
//  ViewController.m
//  MediaDemo
//
//  Created by ColdMountain on 2022/4/16.
//

#import "ViewController.h"
#import "TestViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *echoButton;
@property (nonatomic, strong) CMAuidoPlayer_PCM *audioPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if AudioPlayerFile
    
    NSError* error;
    BOOL success;
    //设置成语音视频模式
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                            withOptions:AVAudioSessionCategoryOptionAllowBluetooth|
                                        AVAudioSessionCategoryOptionAllowBluetoothA2DP|
                                        AVAudioSessionCategoryOptionMixWithOthers|
                                        AVAudioSessionCategoryOptionDuckOthers
                                        |AVAudioSessionCategoryOptionDefaultToSpeaker
                                  error:nil];
    success = [audioSession setActive:YES error:&error];
    self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
    [self.audioPlayer cm_play];
#endif

}

#pragma mark - AudioUnit 音频采集播放

- (IBAction)startAction:(id)sender {
    AudioUnitController *vc = [[AudioUnitController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - AudioUnitGraph 音频采集播放、变声

- (IBAction)stopAction:(id)sender {
    AudioUnitGraphController *vc = [[AudioUnitGraphController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
