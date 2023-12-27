//
//  ViewController.m
//  MediaDemo
//
//  Created by ColdMountain on 2022/4/16.
//

#import "ViewController.h"

#import "CMAuidoPlayer_PCM.h"
#import "CMAudioSession_PCM.h"
#import "CMAudioSessionSpeed.h"

#include "SoundTouch.h"

@interface ViewController ()<CMAudioSessionPCMDelegate, CMAudioSessionSpeedDelegate, NSStreamDelegate>
{
    soundtouch::SoundTouch mSoundTouch; //变声器对象
}
@property (nonatomic, strong) CMAuidoPlayer_PCM  *audioPlayer;
@property (nonatomic, strong) CMAudioSession_PCM *audioSession;
@property (nonatomic, strong) CMAudioSessionSpeed *audioSpeed;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *echoButton;

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSFileHandle  *auidoHandle;
@property (nonatomic, strong) NSMutableData *soundData;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, assign) int num;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.num = -1;
    
    [self createPCMFile];
    [self.button setTitle:@"听筒" forState:UIControlStateNormal];
    [self.button setTitle:@"扬声器" forState:UIControlStateSelected];
    
    self.echoButton.selected = YES;
    [self.echoButton setBackgroundColor:[UIColor redColor]];
    
    self.soundData = [[NSMutableData alloc]init];
    
    mSoundTouch.setSampleRate(8000); //采样率
    mSoundTouch.setChannels(1);       //设置声音的声道
    mSoundTouch.setTempoChange(0);//这个就是传说中的变速不变调
    mSoundTouch.setPitchSemiTones(-6);//设置声音的pitch (集音高变化semi-tones相比原来的音调)
    mSoundTouch.setRateChange(0);//设置声音的速率
    
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 15); //寻找帧长
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 6);  //重叠帧长
    
//    NSError* error;
//    BOOL success;
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//
//
//    success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
//                            withOptions:AVAudioSessionCategoryOptionAllowBluetooth|
//                                        AVAudioSessionCategoryOptionAllowBluetoothA2DP|
//                                        AVAudioSessionCategoryOptionMixWithOthers|
//                                        AVAudioSessionCategoryOptionDuckOthers
////                                        |AVAudioSessionCategoryOptionDefaultToSpeaker
//                                  error:nil];
//    success = [audioSession setActive:YES error:&error];
//    if (self.audioPlayer == nil) {
//        self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
//    }
}

//- (void)stream:(NSInputStream *)stream handleEvent:(NSStreamEvent)eventCode {
//
//    switch(eventCode) {
//        case NSStreamEventOpenCompleted: // 文件打开成功
//            NSLog(@"文件打开,准备读取数据");
//            break;
//        case NSStreamEventHasBytesAvailable: // 读取到数据
//        {
//            //每次读取2048个字节数据
//            //因为AAC编码特性需要1024个采样点的数据一个采样点是2个字节
//            //所以每次固定获取2048个字节的数据传入编码器
//            uint8_t buf[2048];
//            NSInteger readLength = [stream read:buf maxLength:2048];
//            NSLog(@"输入的数据长度:%ld",readLength);
//            if (readLength > 0) {
//                [self.audioPlayer cm_playAudioWithData:(char*)buf andLength:readLength];
//            }else {
//                NSLog(@"未读取到数据");
//            }
//            break;
//        }
//        case NSStreamEventEndEncountered: // 文件读取结束
//        {
//            NSLog(@"数据读取结束");
//            [self.auidoHandle closeFile];
//            [stream close];
//            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
//                              forMode:NSDefaultRunLoopMode];
//            stream = nil;
//            break;
//        }
//        default:
//        break;
//    }
//
//}

- (void)audioUnitBackPCM:(NSData*)audioData{
    [self.auidoHandle writeData:audioData];
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
//        [self.soundData appendBytes:samples length:numSamples*2];
//
////        [self.auidoHandle writeData:self.soundData];
//        [self.audioPlayer cm_playAudioWithData:(char*)samples andLength:pcmsize];
//    });
}
- (IBAction)echoAction:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSession cm_startEchoAudio:0];
        [self.echoButton setBackgroundColor:[UIColor redColor]];
    }else {
        [self.audioSession cm_startEchoAudio:1];
        [self.echoButton setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)receiverAndSpeaker:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
//        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideNone];
        [self.audioSpeed setOutputAudioPort:AVAudioSessionPortOverrideNone];
    }else {
//        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
        [self.audioSpeed setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
    }
}

- (IBAction)startAction:(id)sender {
//    if (self.audioPlayer == nil) {
//        self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
//    }
    
#if 0
    if (self.audioSession == nil) {
        self.audioSession = [[CMAudioSession_PCM alloc]initAudioUnitWithSampleRate:CMAudioPCMSampleRate_Defalut];
        self.audioSession.delegate = self;
    }
    [self.audioSession cm_startAudioUnitRecorder];
    [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
#else
    if (self.audioSpeed == nil) {
        self.audioSpeed = [[CMAudioSessionSpeed alloc]initAudioUnitSpeedWithSampleRate:CMAudioSpeedSampleRate_Defalut];
        self.audioSpeed.delegate = self;
    }
    [self.audioSpeed start];
    [self.audioSpeed startEchoAudio:0];
//    [self.audioSpeed pitchEnable:1];
#endif
    
}
- (IBAction)stopAction:(id)sender {
    [self.audioPlayer cm_stop];
    [self.audioSpeed stop];
    [self.audioSession cm_stopAudioUnitRecorder];
//    self.audioSession.audioRate = CMAudioPCMSampleRate_44100Hz;
//    [self.audioSession initAudioComponent];
    [self.auidoHandle closeFile];
}
- (IBAction)closeAction:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioSpeed pitchEnable:1];
    }else{
        [self.audioSpeed pitchEnable:0];
    }
//    [self.audioPlayer cm_close];
//    [self.audioSession cm_closeAudioUnitRecorder];
//    [self.auidoHandle closeFile];
//    self.audioSession = nil;
//    self.audioPlayer = nil;
//    self.button.selected = NO;
}

- (void)createPCMFile{
    // /Applications/VLC.app/Contents/MacOS/VLC --demux=rawaud --rawaud-channels 1 --rawaud-samplerate 48000
    self.fileManager = [NSFileManager defaultManager];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [path objectAtIndex:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *pcmPath = [NSString stringWithFormat:@"Auido_%@.pcm", dateStr];
    
//    [self.fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:pcmPath] error: nil];
    [self.fileManager createFileAtPath:[documentsDirectory stringByAppendingPathComponent:pcmPath] contents:nil attributes:nil];

    self.auidoHandle = [NSFileHandle fileHandleForWritingAtPath:[documentsDirectory stringByAppendingPathComponent:pcmPath]];
}


@end
