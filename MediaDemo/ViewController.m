//
//  ViewController.m
//  MediaDemo
//
//  Created by ColdMountain on 2022/4/16.
//

#import "ViewController.h"
#import "TestViewController.h"

@interface ViewController ()<NSStreamDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *echoButton;
@property (nonatomic, strong) CMAuidoPlayer_PCM *audioPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if AudioPlayerFile
    self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_16000Hz];
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
