//
//  AudioDecode.h
//  FFmpeg_Test
//
//  Created by 徐超 on 2022/5/16.
//

#import <Foundation/Foundation.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>
#import <libswresample/swresample.h>
#import <libavutil/avutil.h>
#import <libavutil/pixdesc.h>
#import <libavcodec/avcodec.h>
#import <libavdevice/avdevice.h>
#import <libavfilter/avfilter.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioDecode : NSObject

+ (instancetype)shareInstance;


- (void)decodeWithInputFile:(const char* )inputFile  outPutFile:(const char *)outputFile;



@end

NS_ASSUME_NONNULL_END
