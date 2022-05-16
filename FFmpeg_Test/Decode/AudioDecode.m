//
//  AudioDecode.m
//  FFmpeg_Test
//
//  Created by 徐超 on 2022/5/16.
//

#import "AudioDecode.h"
// 保存在常量区
static id instance;

#define MAX_AUDIO_FRAME_SIZE 192000 // 1 second of 48khz 32bit audio

@interface AudioDecode()

{
    AVFormatContext* avFormatContext;
    AVFrame *videoFrame;
    AVFrame *audioFrame;
    AVCodecContext *audioCodecCtx;
    AVCodecContext *videoCodecCtx;
    AVCodec *pCodec;
    AVPacket *packet;
    uint8_t *out_buffer;
    int64_t in_channel_layout;
    struct SwrContext *au_convert_ctx;
    int ret;
    int got_picture;
    int index;
    
    int videoStreamIndex,audioStreamIndex;
    FILE *pcmFile;
    
}

@end

@implementation AudioDecode

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]  init];
    });
    return instance;
}


- (void)decodeWithInputFile:(const char* )inputFile  outPutFile:(const char *)outputFile
{
    
    NSLog(@"Before decode");
    const char* aacFilePath =  inputFile; //[[CommonUtil bundlePath:@"131.aac"] cStringUsingEncoding:NSUTF8StringEncoding];
    // 以读写方式打开文件
    const char *output_file =  outputFile; //[[CommonUtil documentsPath:@"chao_test1.pcm"] cStringUsingEncoding:NSUTF8StringEncoding]; //"./bb1_test.yuv";
    pcmFile = fopen(output_file, "wb+");
    
    // 1.注册协议、格式与编解码器,网络协议注册
    av_register_all();
    avformat_network_init();
    
    // 2.打开对应的媒体文件，本地磁盘的文件，网络媒体的链接，RTMP,HTTP协议的视频源
    avFormatContext = avformat_alloc_context();
    // open
    if (avformat_open_input(&avFormatContext, aacFilePath, NULL, NULL) != 0) {
        NSLog(@"Couldn't open input stream.\n");
        return ;
    }
    
    // Retrive stream information
    if (avformat_find_stream_info(avFormatContext, NULL) < 0) {
        NSLog(@"Couldn't find stream information.\n");
        return;
    }
    
    // Dump valid information onto standard error
    av_dump_format(avFormatContext, 0, aacFilePath, NO);
    
    
    // Find the first audio stream
    audioStreamIndex = -1;
    for (int i =0; i < avFormatContext->nb_streams; i++) {
        if (avFormatContext->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO) {
            audioStreamIndex = i;
            break;
        }
    }

    if (audioStreamIndex==-1) {
        NSLog(@"Didn't find a audio stream.\n");
        return ;
    }
    
    // Get a pointer to the codec context for the audio stream
    audioCodecCtx = avFormatContext->streams[audioStreamIndex]->codec;
    
    // Find the decoder for the audio stream
    pCodec = avcodec_find_decoder(audioCodecCtx->codec_id);
    if (pCodec==NULL) {
        NSLog(@"Codec not found.\n");
        return;
    }
    
    // Open codec
    if (avcodec_open2(audioCodecCtx, pCodec, NULL) < 0) {
        NSLog(@"Could not open codec. \n");
        return ;
    }
    
    packet = (AVPacket *)av_malloc(sizeof(AVPacket));
    av_init_packet(packet);
    
    //Out Audio Param
    uint64_t out_channel_layout = AV_CH_LAYOUT_STEREO;
    //nb_smaples: AAC-1024 MP3-1152
    int out_nb_samples = audioCodecCtx->frame_size;
    enum AVSampleFormat out_sample_fmt = AV_SAMPLE_FMT_S16;
    int out_sample_rate = 44100;
    int out_channels = av_get_channel_layout_nb_channels(out_channel_layout);
    //Out Buffer Size
    int out_buffer_size = av_samples_get_buffer_size(NULL, out_channels, out_nb_samples, out_sample_fmt, 1);
    
    out_buffer = (uint8_t *)av_malloc(MAX_AUDIO_FRAME_SIZE * 2);
    audioFrame = av_frame_alloc();
    
    //FIX:Some Codec's Context Information is missing
    in_channel_layout = av_get_default_channel_layout(audioCodecCtx->channels);
    // Swr
    au_convert_ctx = swr_alloc();
    au_convert_ctx = swr_alloc_set_opts(au_convert_ctx, out_channel_layout, out_sample_fmt, out_sample_rate, in_channel_layout, audioCodecCtx->sample_fmt, audioCodecCtx->sample_rate, 0, NULL);
    swr_init(au_convert_ctx);
    
    while (av_read_frame(avFormatContext, packet) >= 0) {
        if (packet->stream_index == audioStreamIndex) {
            
            ret = avcodec_decode_audio4(audioCodecCtx, audioFrame, &got_picture, packet);
            if (ret < 0) {
                NSLog(@"Error in decoding audio frame.\n");
                return;
            }
            
            if (got_picture > 0) {
                swr_convert(au_convert_ctx, &out_buffer, MAX_AUDIO_FRAME_SIZE, (const uint8_t **)audioFrame->data,  audioFrame->nb_samples);
                NSLog(@"index:%d, pts:%lld,packet size:%d\n", index, packet->pts,packet->size);
                // write PCM
                fwrite(out_buffer, 1, out_buffer_size, pcmFile);
                index++;
            
            }
        }
        av_free_packet(packet);
    }
    
    NSLog(@"After decode");

    if (au_convert_ctx) {
        swr_free(&au_convert_ctx);
        au_convert_ctx = NULL;
    }
    
    if (NULL != out_buffer) {
        av_free(out_buffer);
        out_buffer = NULL;
    }
    
    if (NULL != audioCodecCtx) {
        // Close the codec
        avcodec_close(audioCodecCtx);
        audioCodecCtx = NULL;
    }
    
    // 关闭连接资源
    if (NULL != avFormatContext) {
        // Close the video file
        avformat_close_input(&avFormatContext);
        avFormatContext = NULL;
    }
    
    if (NULL != pcmFile) {
        fclose(pcmFile);
        pcmFile = NULL;
    }
    
}


@end
