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

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSFileHandle  *auidoHandle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fileManager = [NSFileManager defaultManager];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [path objectAtIndex:0];
    NSString *audio = [documentsDirectory stringByAppendingPathComponent:@"test_pcm.pcm"];
    [self.fileManager removeItemAtPath:audio error:nil];
    [self.fileManager createFileAtPath:audio contents:nil attributes:nil];
    self.auidoHandle = [NSFileHandle fileHandleForWritingAtPath:audio];
    
    [self.button setTitle:@"听筒" forState:UIControlStateNormal];
    [self.button setTitle:@"扬声器" forState:UIControlStateSelected];
}

- (void)cm_audioUnitBackPCM:(NSData*)audioData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.auidoHandle writeData:audioData];
        [self.audioPlayer cm_playAudioWithData:(char*)[audioData bytes] andLength:audioData.length];
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
    self.audioPlayer = [[CMAuidoPlayer_PCM alloc]initWithAudioUnitPlayerSampleRate:CMAudioPlayerSampleRate_Defalut];
    
    self.audioSession = [[CMAudioSession_PCM alloc]initAudioUnitWithSampleRate:CMAudioPCMSampleRate_Defalut];
    self.audioSession.delegate = self;
    [self.audioSession cm_startAudioUnitRecorder];
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


@end
