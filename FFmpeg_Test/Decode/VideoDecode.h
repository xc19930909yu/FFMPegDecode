//
//  VideoDecode.h
//  FFmpeg_Test
//
//  Created by 徐超 on 2022/5/16.
//

#import <Foundation/Foundation.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>


NS_ASSUME_NONNULL_BEGIN

@interface VideoDecode : NSObject


+ (instancetype)shareInstance;
- (void)decodeWithInputFile:(const char* )inputFile  outPutFile:(const char *)outputFile;
@end

NS_ASSUME_NONNULL_END
