//
//  ViewController.m
//  FFmpeg_Test
//
//  Created by 徐超 on 2022/5/12.
//

#import "ViewController.h"
#import "CommonUtil.h"
#import "AudioDecode.h"
#import "VideoDecode.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;

@property (weak, nonatomic) IBOutlet UIButton *audioBtn;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}


- (IBAction)videoDecodeClick:(id)sender {
    [self videoDecode];
}

- (IBAction)audioDecodeClick:(id)sender {
    [self audioDecode];
}

// 解码具体操作流程// 1.打开文件流 2.解析格式 3.解析流并且打开解码器 4.解码和处理 5.最终关闭所有资源的操作。
- (void)videoDecode {
    const char* movFilePath = [[CommonUtil bundlePath:@"test.MOV"] cStringUsingEncoding:NSUTF8StringEncoding];
    // 以读写方式打开文件
    const char *output_file =  [[CommonUtil documentsPath:@"chao_test2.yuv"] cStringUsingEncoding:NSUTF8StringEncoding]; //"./bb1_test.yuv";
    [[VideoDecode shareInstance] decodeWithInputFile:movFilePath outPutFile:output_file];
}


- (void)audioDecode {
    const char* aacFilePath = [[CommonUtil bundlePath:@"131.aac"] cStringUsingEncoding:NSUTF8StringEncoding];
    // 以读写方式打开文件
    const char *output_file =  [[CommonUtil documentsPath:@"chao_test1.pcm"] cStringUsingEncoding:NSUTF8StringEncoding]; //"./bb1_test.yuv";
    //pcmFile = fopen(output_file, "wb+");

    [[AudioDecode shareInstance] decodeWithInputFile:aacFilePath outPutFile:output_file];
}



@end
