//
//  VideoDecode.m
//  FFmpeg_Test
//
//  Created by 徐超 on 2022/5/16.
//

#import "VideoDecode.h"
static id instance;
@interface VideoDecode() {

    AVFormatContext *pFormatCtx;
    int                i, videoindex;
    AVCodecContext    *pCodecCtx;
    AVCodec            *pCodec;
    AVFrame    *pFrame,*pFrameYUV;
    uint8_t *out_buffer;
    AVPacket *packet;
    int y_size;
    int ret, got_picture;
    struct SwsContext *img_convert_ctx;
    FILE *fp_yuv;
    int frame_cnt;
    clock_t time_start, time_finish;
    double  time_duration;
    
}

@end

@implementation VideoDecode


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
    time_duration = 0.0;
//    char input_str_full[500] ={0};
//    char output_str_full[500] ={0};
    char info[1000] ={0};
    
    av_register_all();
    avformat_network_init();
    pFormatCtx = avformat_alloc_context();
    
    if (avformat_open_input(&pFormatCtx, inputFile, NULL, NULL) != 0) {
        NSLog(@"Couldn't open input stream.\n");
        return;
    }
    
    if (avformat_find_stream_info(pFormatCtx, NULL) < 0) {
        NSLog(@"Couldn't find stream information.\n");
        return;
    }
    
    videoindex=-1;
    for (int i=0; i<pFormatCtx->nb_streams; i++) {
        if (pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
            videoindex=i;
            break;
        }
    }
    if (videoindex==-1) {
        NSLog(@"Couldn't find a video stream.\n");
        return;
    }
    pCodecCtx = pFormatCtx->streams[videoindex]->codec;
    pCodec=avcodec_find_decoder(pCodecCtx->codec_id);
    if (pCodec==NULL) {
        NSLog(@"Couldn't find Codec.\n");
        return;
    }
    if (avcodec_open2(pCodecCtx, pCodec, NULL)<0) {
        NSLog(@"Couldn't open codec.\n");
        return;
    }
    pFrame=av_frame_alloc();
    pFrameYUV=av_frame_alloc();
    out_buffer=(uint8_t *)av_malloc(avpicture_get_size(AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height));
    avpicture_fill((AVPicture *)pFrameYUV, out_buffer, AV_PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height);
    packet=(AVPacket*)av_malloc(sizeof(AVPacket));
    
    img_convert_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt, pCodecCtx->width, pCodecCtx->height, AV_PIX_FMT_YUV420P, SWS_BICUBIC, NULL, NULL, NULL);
    
    sprintf(info, "%s[Format    ]%s\n",info, pFormatCtx->iformat->name);
    sprintf(info, "%s[Codec     ]%s\n",info, pCodecCtx->codec->name);
    sprintf(info, "%s[Resolution]%dx%d\n",info, pCodecCtx->width,pCodecCtx->height);
    
    fp_yuv=fopen(outputFile, "wb+");
    if (fp_yuv==NULL) {
        NSLog(@"Cannot open output file.\n");
        return;
    }
    
    frame_cnt=0;
    time_start=clock();
    
    while (av_read_frame(pFormatCtx, packet)>=0) {
        if (packet->stream_index==videoindex) {
            ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
            if (ret < 0) {
                NSLog(@"Decode Error.\n");
                return;
            }
            if (got_picture) {
                sws_scale(img_convert_ctx, (const uint8_t* const*)pFrame->data, pFrame->linesize, 0, pCodecCtx->height, pFrameYUV->data, pFrameYUV->linesize);
                
                y_size=pCodecCtx->width*pCodecCtx->height;
                fwrite(pFrameYUV->data[0], 1, y_size, fp_yuv);   //Y
                fwrite(pFrameYUV->data[1], 1, y_size/4,fp_yuv);  //U
                fwrite(pFrameYUV->data[2], 1, y_size/4, fp_yuv); //V
                //Output info
                char pictype_str[10]={0};
                switch (pFrame->pict_type) {
                    case AV_PICTURE_TYPE_I: sprintf(pictype_str,"I");break;
                    case AV_PICTURE_TYPE_P: sprintf(pictype_str, "P");break;
                    case AV_PICTURE_TYPE_B: sprintf(pictype_str, "B");break;
                    default: sprintf(pictype_str, "Other");break;
                }
                printf("Frame Index: %5d. Type:%s\n",frame_cnt, pictype_str);
                frame_cnt++;
            }
        }
        av_free_packet(packet);
    }
    //flush decoder
    //FIX:Flush Frames remained in Codec
    while (1) {
        ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
        if (ret < 0)
            break;
        if (!got_picture)
            break;
        sws_scale(img_convert_ctx, (const uint8_t* const*)pFrame->data, pFrame->linesize, 0, pCodecCtx->height, pFrameYUV->data, pFrameYUV->linesize);
        int y_size=pCodecCtx->width*pCodecCtx->height;
        fwrite(pFrameYUV->data[0], 1, y_size, fp_yuv); //Y
        fwrite(pFrameYUV->data[1], 1, y_size, fp_yuv); //U
        fwrite(pFrameYUV->data[2], 1, y_size, fp_yuv); //V
        //Output info
        char pictype_str[10]={0};
        switch (pFrame->pict_type) {
            case AV_PICTURE_TYPE_I: sprintf(pictype_str, "I"); break;
            case AV_PICTURE_TYPE_P: sprintf(pictype_str, "P"); break;
            case AV_PICTURE_TYPE_B: sprintf(pictype_str, "B"); break;
            default: sprintf(pictype_str, "Other");  break;
        }
        printf("Frame Index: %5d. Type:%s\n",frame_cnt,pictype_str);
        frame_cnt++;
    }
    time_finish = clock();
    time_duration=(double)(time_finish - time_start);
    
    sprintf(info, "%s[Time    ]%fus\n",info, time_duration);
    sprintf(info, "%s[Count     ]%d\n", info,frame_cnt);
    
    sws_freeContext(img_convert_ctx);
    
    fclose(fp_yuv);
    
    av_frame_free(&pFrameYUV);
    av_frame_free(&pFrame);
    avcodec_close(pCodecCtx);
    avformat_close_input(&pFormatCtx);
    
    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    
    NSLog(@"info:%@", info_ns);
    
    NSLog(@"After decode");
}

@end
