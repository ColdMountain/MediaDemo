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
@property (weak, nonatomic) IBOutlet UIButton *echoButton;

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSFileHandle  *auidoHandle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createPCMFile];
    [self.button setTitle:@"听筒" forState:UIControlStateNormal];
    [self.button setTitle:@"扬声器" forState:UIControlStateSelected];
    
    self.echoButton.selected = YES;
    [self.echoButton setBackgroundColor:[UIColor redColor]];
}

- (void)cm_audioUnitBackPCM:(NSData*)audioData{
//    [self.auidoHandle writeData:audioData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.auidoHandle writeData:audioData];
//        [self.audioPlayer cm_playAudioWithData:(char*)[audioData bytes] andLength:audioData.length];
    });
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
    self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
    
    self.audioSession = [[CMAudioSession_PCM alloc]initAudioUnitWithSampleRate:CMAudioPCMSampleRate_Defalut];
    self.audioSession.delegate = self;
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
    self.audioSession = nil;
    self.audioPlayer = nil;
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
