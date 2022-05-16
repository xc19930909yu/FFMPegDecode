//
//  ViewController.h
//  FFmpeg_Test
//
//  Created by 徐超 on 2022/5/12.
//

#import <UIKit/UIKit.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>
#import <libswresample/swresample.h>
#import <libavutil/avutil.h>
#import <libavutil/pixdesc.h>
#import <libavcodec/avcodec.h>
#import <libavdevice/avdevice.h>
#import <libavfilter/avfilter.h>


#define OUT_PUT_CHANNELS 2
#define CHANNEL_PER_FRAME    2
#define BITS_PER_CHANNEL        16
#define BITS_PER_BYTE        8

#define MAX_AUDIO_FRAME_SIZE 192000 // 1 second of 48khz 32bit audio


@interface ViewController : UIViewController


@end

