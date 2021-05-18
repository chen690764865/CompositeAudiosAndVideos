//
//  CCAVCompositeTool.m
//  音视频合成Demo
//
//  Created by Summer on 2021/4/12.
//

#import "CCAVCompositeTool.h"
#import <AVFoundation/AVFoundation.h>
#import <CCMakerSDK/CCMakerSDK.h>

@implementation CCAVCompositeTool

/**
 合成音频和视频
 
 @param audioURL 音频地址
 @param videoURL 视频地址
 @param needAudioMix 是否需要混音
 @param outputFilePath 合成文件输出路径
 @param completionBlock 合成结果回调
 */
+ (void)compositeAudio:(NSURL *)audioURL
              andVideo:(NSURL *)videoURL
          needAudioMix:(BOOL)needAudioMix
    withOutputFilePath:(NSURL *)outputFilePath
            completion:(CCAVCompositeCompletionBlock)completionBlock {
    // 初始化一个用于合成音视频的工具
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 添加视频合成轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    NSError *error;
    
    // 获取视频资源
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    // 获取视频轨道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    // 视频时长范围
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration);
    // 视频轨道插入到视频合成轨道中
    [videoCompositionTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:&error];
    
    if (error) {
        !completionBlock ?: completionBlock(NO, outputFilePath);
        return;
    };
    
    // 处理视频原音和需要加入的音频
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    NSMutableArray<AVMutableAudioMixInputParameters *> *audioInputParamtersM = [NSMutableArray array];
    
    if (needAudioMix) {
        // 视频原音
        AVMutableCompositionTrack *originalAudioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *originalAudioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        // 插入到合成音轨中
        [originalAudioCompositionTrack insertTimeRange:videoTimeRange ofTrack:originalAudioAssetTrack atTime:kCMTimeZero error:&error];
        if (!error) {
            AVMutableAudioMixInputParameters *originalAudioInputParamters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:originalAudioCompositionTrack];
            // 设置音量
            [originalAudioInputParamters setVolume:.2f atTime:kCMTimeZero];
            [audioInputParamtersM addObject:originalAudioInputParamters];
        }
    }
    
    {
        // 新加入的音频
        AVMutableCompositionTrack *newAudioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVURLAsset *newAudioAsset = [AVURLAsset URLAssetWithURL:audioURL options:options];
        AVAssetTrack *newAudioAssetTrack = [[newAudioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [newAudioCompositionTrack insertTimeRange:videoTimeRange ofTrack:newAudioAssetTrack atTime:kCMTimeZero error:&error];
        if (!error) {
            AVMutableAudioMixInputParameters *newAudioInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:newAudioCompositionTrack];
            // 设置音量
            [newAudioInputParameters setVolume:1.f atTime:kCMTimeZero];
            [audioInputParamtersM addObject:newAudioInputParameters];
        }
    }
    audioMix.inputParameters = [NSArray arrayWithArray:audioInputParamtersM];
    
    // 异步输出
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFilePath
                                     audioMix:audioMix
                             videoComposition:nil
                            completionHandler:completionBlock];
}

/**
 合成多段视频
 
 @param videoURLs 视频URL地址集合
 @param outputFilePath 合成视频输出路径
 @param completionBlock 合成结果回调
 */
+ (void)compositeVideos:(NSArray<NSURL *> *)videoURLs
     withOutputFilePath:(NSURL *)outputFilePath
             completion:(CCAVCompositeCompletionBlock)completionBlock {
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 添加一个视频合成轨道
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

    // 添加一个音频合成轨道
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    __block NSError *error;
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    [videoURLs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSURL * _Nonnull url,
                                                                             NSUInteger idx,
                                                                             BOOL * _Nonnull stop) {
        // Asset资源
        AVURLAsset *resourceAsset = [[AVURLAsset alloc] initWithURL:url options:options];
        // 拿到视频轨道
        AVAssetTrack *videoAssetTrack = [resourceAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        // 视频时间范围(注意duration要取视频轨道的，不能用asset的，因为asset的时长是音视频轨道中较长的一个)
        CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration);
        // 插入到视频合成轨道中
        BOOL res = [videoCompositionTrack insertTimeRange:videoTimeRange
                                                  ofTrack:videoAssetTrack
                                                   atTime:kCMTimeZero
                                                    error:&error];
        if (error || !res) {
            NSLog(@"insert失败, %@", error);
        } else {
            // 视频插入轨道成功 => 添加音轨
            // 拿到音频轨道
            AVAssetTrack *audioAssetTrack = [resourceAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
            if (audioAssetTrack) {
                // 有声音 => 插入到声音合成轨道中
                [audioCompositionTrack insertTimeRange:videoTimeRange
                                               ofTrack:audioAssetTrack
                                                atTime:kCMTimeZero
                                                 error:nil];
            } else {
                // 没声音 => 插入空音频轨道(因为这里是倒序插入的视频，如果这里不插入一个空音频轨道的话，后续音频都会错位)
                [audioCompositionTrack insertEmptyTimeRange:videoTimeRange];
            }
        }
    }];

    // 异步输出
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFilePath
                                     audioMix:nil
                             videoComposition:nil
                            completionHandler:completionBlock];
}

+ (void)mixAudiosWith:(NSArray<NSURL *> *)audioURLs withOutputFilePath:(nullable NSURL *)outputFilePath completion:(CCAVCompositeCompletionBlock)completionBlock {
    // 初始化合成音频的工具
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 初始化混音工具
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    __block NSError *error;
    NSMutableArray<AVMutableAudioMixInputParameters *> *audioInputParamters = [NSMutableArray array];
    
    [audioURLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull fileURL, NSUInteger idx, BOOL * _Nonnull stop) {
        // 添加音频合成轨道
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        // 获取资源文件
        AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:options];
        // 获取音频轨道
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        // 插入到音频合成轨道中
        [audioCompositionTrack insertTimeRange:audioAssetTrack.timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
        if (!error) {
            AVMutableAudioMixInputParameters *inputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompositionTrack];
            [inputParameters setVolume:.2f atTime:kCMTimeZero];
            [audioInputParamters addObject:inputParameters];
        } else {
            NSLog(@"error=%@, fileURL=%@, idx=%@", error, fileURL, @(idx));
        }
    }];
    
    audioMix.inputParameters = [NSArray arrayWithArray:audioInputParamters];
    
    // 音频输出路径
    NSURL *outputMixAudioURL = outputFilePath ?: [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMixAudio.m4a"]];
    
    // 异步输出
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:AVAssetExportPresetAppleM4A
                               outputFileType:AVFileTypeAppleM4A
                                    outputURL:outputMixAudioURL
                                     audioMix:audioMix
                             videoComposition:nil
                            completionHandler:completionBlock];
}

+ (void)compositeAudiosWith:(NSArray<NSURL *> *)audioURLs withOutputFilePath:(NSURL *)outputFilePath completion:(CCAVCompositeCompletionBlock)completionBlock {
    // 初始化合成音频的工具
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    // 添加一条合成音频的轨道
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    __block NSError *error;
    
    [audioURLs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSURL * _Nonnull fileURL, NSUInteger idx, BOOL * _Nonnull stop) {
        // 获取资源文件
        AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:options];
        // 获取音频轨道
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        // 插入到音频合成轨道中
        [audioCompositionTrack insertTimeRange:audioAssetTrack.timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
        if (!error) {
//            AVMutableAudioMixInputParameters *inputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompositionTrack];
//            [inputParameters setVolume:.5f atTime:kCMTimeZero];
        } else {
            NSLog(@"error=%@, fileURL=%@, idx=%@", error, fileURL, @(idx));
        }
    }];
    
    // 异步输出
    NSURL *outputMixAudioURL = outputFilePath ?: [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMixAudio.m4a"]];
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:AVAssetExportPresetAppleM4A
                               outputFileType:AVFileTypeAppleM4A
                                    outputURL:outputMixAudioURL
                                     audioMix:nil
                             videoComposition:nil
                            completionHandler:completionBlock];
}

//MARK: - 视频混合
/**
 视频剪切
 */
+ (void)trimVideoWith:(NSURL *)videoURL
   withOutputFilePath:(nullable NSURL *)outputFilePath
           completion:(CCAVCompositeCompletionBlock)completionBlock {
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    __block NSError *error;
    // 获取视频资源
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    // 获取视频轨道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    // 获取音频轨道
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(4, 1),
                                            CMTimeMakeWithSeconds(CMTimeGetSeconds(videoAssetTrack.timeRange.duration)/2.f, 1));
    if (videoAssetTrack) {
        AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:&error];
    }
    if (audioAssetTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
    }
    
    // 异步输出
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFilePath
                                     audioMix:nil
                             videoComposition:nil
                            completionHandler:completionBlock];
}

/**
 视频旋转
 */
+ (void)rotateVideoWith:(NSURL *)videoURL
     withOutputFilePath:(nullable NSURL *)outputFilePath
             completion:(CCAVCompositeCompletionBlock)completionBlock {
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    __block NSError *error;
    
    // 获取视频资源
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    // 获取视频轨道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    // 获取音频轨道
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    CMTimeRange timeRange = videoAssetTrack.timeRange;
    if (videoAssetTrack) {
        AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        // 出入视频轨道
        [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:&error];
    }
    if (audioAssetTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        // 插入音频轨道
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
    }
    
    // 这里处理视频旋转
    CGAffineTransform t1, t2;
    CGSize renderSize;
    AVMutableVideoCompositionInstruction *videoInstruction;
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction;
    
    NSInteger degree = 90; //顺时针旋转角度
    switch (degree % 360) {
        case 90:
            // Translate the composition to compensate the movement caused by rotation (since rotation would cause it to move out of frame)
            t1 = CGAffineTransformMakeTranslation(videoAssetTrack.naturalSize.height, 0.0);
            // Rotate transformation
            t2 = CGAffineTransformRotate(t1, M_PI_2);
            renderSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
            break;
        case 180:
            t1 = CGAffineTransformMakeTranslation(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
            t2 = CGAffineTransformRotate(t1, M_PI);
            renderSize = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
            break;
        case 270:
            t1 = CGAffineTransformMakeTranslation(0.0, videoAssetTrack.naturalSize.width);
            t2 = CGAffineTransformRotate(t1, M_PI_2 * 3);
            renderSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
            break;
        default:
            t1 = CGAffineTransformMakeTranslation(0.0, 0.0);
            t2 = CGAffineTransformRotate(t1, 0);
            renderSize = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
            break;
    }
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = renderSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoInstruction.timeRange = videoAssetTrack.timeRange;
    // 创建视频图层指令
    videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:[composition tracksWithMediaType:AVMediaTypeVideo][0]];
    [videoLayerInstruction setTransform:t2 atTime:kCMTimeZero];
    
    // 第四步
    videoInstruction.layerInstructions = @[videoLayerInstruction];
    videoComposition.instructions = @[videoInstruction];
    
    // 异步输出
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFilePath
                                     audioMix:nil
                             videoComposition:videoComposition
                            completionHandler:completionBlock];
}

//MARK: - 给视频添加水印效果
/**
 视频添加水印
 */
+ (void)addWatermarkToVideo:(NSURL *)videoURL
         withOutputFilePath:(nullable NSURL *)outputFilePath
                 completion:(CCAVCompositeCompletionBlock)completionBlock {
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    __block NSError *error;
    
    // 获取视频资源
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    // 获取视频轨道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    // 获取音频轨道
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    CMTimeRange timeRange = videoAssetTrack.timeRange;
    if (videoAssetTrack) {
        AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        // 出入视频轨道
        [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:&error];
    }
    if (audioAssetTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        // 插入音频轨道
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
    }
    
    // 添加水印
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    {
        videoComposition.renderSize = videoAssetTrack.naturalSize;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = videoAssetTrack.timeRange;

        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:[composition tracksWithMediaType:AVMediaTypeVideo][0]];

        instruction.layerInstructions = @[layerInstruction];
        videoComposition.instructions = @[instruction];
        
        CALayer *watermarkLayer = [self watermarkLayerForVideoSize:videoAssetTrack.naturalSize];
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = (CGRect){0, 0, videoAssetTrack.naturalSize};
        videoLayer.frame = (CGRect){0, 0, videoAssetTrack.naturalSize};
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:watermarkLayer];
        videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
    
    // 异步输出
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFilePath
                                     audioMix:nil
                             videoComposition:videoComposition
                            completionHandler:completionBlock];
}

//MARK: - 给视频添加字幕
/**
 给视频添加字幕
 */
+ (void)addSRT:(NSArray *)srtArray toVideo:(NSURL *)videoURL withOutputFilePath:(nullable NSURL *)outputFilePath
    completion:(CCAVCompositeCompletionBlock)completionBlock {
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    __block NSError *error;
    
    // 获取视频资源
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    // 获取视频轨道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    // 获取音频轨道
    AVAssetTrack *audioAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    CMTimeRange timeRange = videoAssetTrack.timeRange;
    if (videoAssetTrack) {
        AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        // 出入视频轨道
        [videoCompositionTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:&error];
    }
    if (audioAssetTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        // 插入音频轨道
        AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[[NSBundle mainBundle] URLForResource:@"五环之歌" withExtension:@"mp3"] options:options];
        [audioCompositionTrack insertTimeRange:timeRange ofTrack:[audioAsset tracksWithMediaType:AVMediaTypeAudio][0] atTime:kCMTimeZero error:&error];
//        [audioCompositionTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
    }
    
    CGSize renderSize = videoAssetTrack.naturalSize;
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = renderSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *videoInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoInstruction.timeRange = videoAssetTrack.timeRange;
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:[composition tracksWithMediaType:AVMediaTypeVideo][0]];
    
    videoInstruction.layerInstructions = @[videoLayerInstruction];
    videoComposition.instructions = @[videoInstruction];
    
    /*
     添加字幕
     原理：字幕其实就是放在视频layer层上的文字，但是它们都是隐藏的，并且在指定时间出现又在指定时间消失。
     也就是说要给这个layer加上一个动画组，第一个动画是将透明度变为1，第二个动画将透明度变为0（第二个动画可以省略）
     */
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = (CGRect){0, 0, renderSize};
    videoLayer.frame = (CGRect){0, 0, renderSize};
    [parentLayer addSublayer:videoLayer];
    [srtArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat start = [obj[@"start"] doubleValue];
        CGFloat end = [obj[@"end"] doubleValue];
        NSString *content = obj[@"content"];
        
        CATextLayer *textLayer = [CATextLayer layer];
        NSString *text = content;
        CGFloat fontSize = 50;
        UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
        CGSize size = [text boundingRectWithSize:CGSizeMake(renderSize.width, MAXFLOAT)
                                         options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{
                                          NSFontAttributeName : font
                                      }
                                         context:nil].size;
        textLayer.frame = (CGRect){20, 20, size};
        // 允许多行展示
        textLayer.wrapped = YES;
        textLayer.string = text;
        textLayer.foregroundColor = [UIColor redColor].CGColor;
        textLayer.font = (__bridge CFTypeRef _Nullable)font;
        textLayer.fontSize = fontSize;
        // 默认是隐藏的，在指定时间出现
        textLayer.opacity = 0;

        // 这个是透明度动画主要是使在插入的才显示，其它时候都是不显示的
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = @1;
        opacityAnim.toValue = @1;
        opacityAnim.removedOnCompletion = NO;

        CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
        groupAnimation.animations = @[opacityAnim];

        CGFloat beginTime = MAX(start, 0.01);
        groupAnimation.beginTime = beginTime;
        groupAnimation.duration = end - beginTime;
        [textLayer addAnimation:groupAnimation forKey:@"groupAnimationKey"];
        [parentLayer addSublayer: textLayer];
    }];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    // 异步输出
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFilePath
                                     audioMix:nil
                             videoComposition:videoComposition
                            completionHandler:completionBlock];
}

//MARK: - 音视频合成输出
+ (void)exportAsynchronouslyWithComposition:(AVMutableComposition *)composition
                                 presetName:(nullable NSString *)presetName
                             outputFileType:(AVFileType)outputFileType
                                  outputURL:(NSURL *)outputURL
                                   audioMix:(nullable AVMutableAudioMix *)audioMix
                           videoComposition:(nullable AVMutableVideoComposition *)videoComposition
                          completionHandler:(CCAVCompositeCompletionBlock)completionHandler {
    // 创建视频输出
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition
                                                                            presetName:presetName ?: AVAssetExportPresetMediumQuality];
    exportSession.outputFileType = outputFileType;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = outputURL;
    if (audioMix) exportSession.audioMix = audioMix;
    if (videoComposition) exportSession.videoComposition = videoComposition;
    NSLog(@"文件输出路径是：%@", outputURL);
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    }
    
    // 开启异步输出
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        // 合成完毕
        NSLog(@"\n\n\nstatus=%@, error=%@", @(exportSession.status), exportSession.error);
        dispatch_async(dispatch_get_main_queue(), ^{
            !completionHandler ?: completionHandler(exportSession.status == AVAssetExportSessionStatusCompleted, outputURL);
        });
    }];
}

+ (CALayer *)watermarkLayerForVideoSize:(CGSize)videoSize {
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    
    CATextLayer *textLayer = [CATextLayer layer];
    NSString *text = @"小猴启蒙";
    CGFloat fontSize = 80;
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 30)
                                     options:NSStringDrawingUsesFontLeading
                                  attributes:@{
                                      NSFontAttributeName : font
                                  }
                                     context:nil].size;
    textLayer.frame = (CGRect){20, 20, size};
    textLayer.string = text;
    textLayer.foregroundColor = [UIColor redColor].CGColor;
    textLayer.font = (__bridge CFTypeRef _Nullable)font;
    textLayer.fontSize = fontSize;
    textLayer.alignmentMode = kCAAlignmentCenter;

    ////An infinity animation
    CAKeyframeAnimation *breatheAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    breatheAnimation.values = @[
        [NSValue valueWithCATransform3D:CATransform3DIdentity],
        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
        [NSValue valueWithCATransform3D:CATransform3DIdentity]
    ];
    breatheAnimation.keyTimes = @[ @0, @0.714, @1 ];
    breatheAnimation.duration = 0.7;
    breatheAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    breatheAnimation.repeatCount = INFINITY;
    breatheAnimation.fillMode = kCAFillModeForwards;

    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[breatheAnimation];
    animationGroup.beginTime = 0.01;
    animationGroup.duration = MAXFLOAT;
    
    [textLayer addAnimation:animationGroup forKey:@"breatheAnimation"];
    
    [layer addSublayer:textLayer];
    return layer;
}
@end
