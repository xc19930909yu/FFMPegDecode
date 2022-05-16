#FFMpeg编译iOS的静态库，支持armv7,arm64架构，具体的编译步骤以及使用的脚本文件如下：

关于FFMpeg在iOS下的编译可以参考https://www.jianshu.com/p/2b373cdf3bb8，编译脚本用的https://github.com/kewlbear/FFmpeg-iOS-build-script上的，

脚本编译命令
编译i386 armv7 x86_64 arm64 所有架构
 ./build-ffmpeg.sh
编译arm64架构
./build-ffmpeg.sh arm64
编译armv7,x86_64 (64-bit simulator):
./build-ffmpeg.sh armv7 x86_64
从单独的thin库合并出fat库
 ./build-ffmpeg.sh lipo

ffmpeg解码把音频aac解码到pcm,ffmpeg的编译版本为4.3.1，可以生成fat版本和thin版本。

最后使用的库修改了build-ffmpeg.sh文件，去掉了i386,x86_64模拟器支持，只留下真机支持

项目中集成了解码视频和解码音频的功能，分别将MOV视频文件解码为yuv的格式，以及将aac文件解码为pcm原始数据

直接调用AudioDecode的- (void)decodeWithInputFile:(const char* )inputFile  outPutFile:(const char *)outputFile;
以及VideoDecode的- (void)decodeWithInputFile:(const char* )inputFile  outPutFile:(const char *)outputFile;
最后生成的pcm和yuv文件可以通过导出沙盒的方式进行查看。
音频解码过程和视频解码过程参考了《音视频-开发进阶指南》书籍 项目Github地址为https://github.com/zhanxiaokai/iOS-FFmpegDecoder 以及雷神的两篇博客https://blog.csdn.net/leixiaohua1020/article/details/47072257?spm=1001.2014.3001.5502,https://blog.csdn.net/leixiaohua1020/article/details/46890259?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522165270266016782425194413%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fblog.%2522%257D&request_id=165270266016782425194413&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~blog~first_rank_ecpm_v1~rank_v31_ecpm-3-46890259-null-null.nonecase&utm_term=音频解码&spm=1018.2226.3001.4450
关于里面用到的ffmpeg的API具体解释可以参考另外的系列博客https://blog.csdn.net/leixiaohua1020/article/details/12679719?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522165269086116782246482293%2522%252C%2522scm%2522%253A%252220140713.130102334.pc%255Fblog.%2522%257D&request_id=165269086116782246482293&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~blog~first_rank_ecpm_v1~rank_v31_ecpm-1-12679719-null-null.nonecase&utm_term=avcodec_decode_video2&spm=1018.2226.3001.4450。