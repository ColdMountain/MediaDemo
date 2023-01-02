//
//  ViewController.m
//  MediaDemo
//
//  Created by ColdMountain on 2022/4/16.
//

#import "ViewController.h"

#import "CMAuidoPlayer_PCM.h"
#import "CMAudioSession_PCM.h"

@interface ViewController ()<CMAudioSessionPCMDelegate, NSStreamDelegate>
@property (nonatomic, strong) CMAuidoPlayer_PCM  *audioPlayer;
@property (nonatomic, strong) CMAudioSession_PCM *audioSession;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *echoButton;

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSFileHandle  *auidoHandle;

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
//                                        |AVAudioSessionCategoryOptionDefaultToSpeaker
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

- (void)cm_audioUnitBackPCM:(NSData*)audioData selfClass:(CMAudioSession_PCM*)selfClass{
//    [self.auidoHandle writeData:audioData];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.auidoHandle writeData:audioData];
//        [self.audioPlayer cm_playAudioWithData:(char*)[audioData bytes] andLength:audioData.length];
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
        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideNone];
    }else {
        [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
    }
}

- (IBAction)startAction:(id)sender {
//    if (self.audioPlayer == nil) {
//        self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
//    }
    if (self.audioSession == nil) {
        self.audioSession = [[CMAudioSession_PCM alloc]initAudioUnitWithSampleRate:CMAudioPCMSampleRate_44100Hz];
        self.audioSession.delegate = self;
    }
    
    [self.audioSession cm_startAudioUnitRecorder];
    [self.audioSession setOutputAudioPort:AVAudioSessionPortOverrideSpeaker];
}
- (IBAction)stopAction:(id)sender {
    [self.audioPlayer cm_stop];
    [self.audioSession cm_stopAudioUnitRecorder];
}
- (IBAction)closeAction:(id)sender {
    [self.audioPlayer cm_close];
    [self.audioSession cm_closeAudioUnitRecorder];
    [self.auidoHandle closeFile];
//    self.audioSession = nil;
//    self.audioPlayer = nil;
    self.button.selected = NO;
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
