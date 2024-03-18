//
//  ViewController.m
//  MediaDemo
//
//  Created by ColdMountain on 2022/4/16.
//

#import "ViewController.h"
#import "TestViewController.h"

#include "SoundTouch.h"

@interface ViewController ()<NSStreamDelegate>
{
    soundtouch::SoundTouch mSoundTouch; //变声器对象
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
//    mSoundTouch.setSampleRate(8000); //采样率
//    mSoundTouch.setChannels(1);       //设置声音的声道
//    mSoundTouch.setTempoChange(0);//这个就是传说中的变速不变调
//    mSoundTouch.setPitchSemiTones(-6);//设置声音的pitch (集音高变化semi-tones相比原来的音调)
//    mSoundTouch.setRateChange(0);//设置声音的速率
//    
//    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
//    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 15); //寻找帧长
//    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 6);  //重叠帧长
}



- (void)cm_audioUnitBackPCM:(NSData*)audioData selfClass:(CMAudioSession_PCM*)selfClass{
//    if (selfClass == self.audioSession1) {
//        NSLog(@"CMAudioSession_PCM | cm_audioUnitBackPCM: 1、%p", selfClass);
//    }else if (selfClass == self.audioSession2) {
//        NSLog(@"CMAudioSession_PCM | cm_audioUnitBackPCM: 2、%p", selfClass);
//    }else if (selfClass == self.audioSession3) {
//        NSLog(@"CMAudioSession_PCM | cm_audioUnitBackPCM: 3、%p", selfClass);
//    }
    
//    [self.auidoHandle writeData:audioData];
    //变声器相关内容
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int nSamples = (int)audioData.length / 2;
//        int pcmsize = (int)audioData.length;
//        short *samples = new short[pcmsize];
//        
//        self->mSoundTouch.putSamples((short *)[audioData bytes], nSamples);
//        int numSamples = 0;
//        numSamples = self->mSoundTouch.receiveSamples(samples, pcmsize);
//        
////        [self.soundData appendBytes:samples length:numSamples*2];
//
////        [self.auidoHandle writeData:self.soundData];
//        [self.audioPlayer cm_playAudioWithData:(char*)samples andLength:pcmsize];
//    });
}

- (IBAction)startAction:(id)sender {
    AudioUnitController *vc = [[AudioUnitController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)stopAction:(id)sender {
    AudioUnitGraphController *vc = [[AudioUnitGraphController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
