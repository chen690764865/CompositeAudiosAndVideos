//
//  HMKAVCompositeTool.m
//  音视频合成Demo
//
//  Created by Summer on 2021/5/31.
//

#import "HMKAVCompositeTool.h"
#import "HMKAVCompositeTool+Audio.h"
#import "HMKAVCompositeTool+Video.h"
#import <UIKit/UIKit.h>

@interface HMKAVCompositeTool ()

@property (nonatomic, strong) AVAssetExportSession *exportSession;

@property (nonatomic, copy) HMKAVCompositeProgressHandler progressHandler;
@property (nonatomic, strong) NSTimer *progressTimer;

@end

@implementation HMKAVCompositeTool

+ (instancetype)sharedCompositeTool {
    static HMKAVCompositeTool *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[HMKAVCompositeTool alloc] init];
    });
    return tool;
}

- (void)cancelComposite {
    if (self.exportSession && (self.exportSession.status == AVAssetExportSessionStatusWaiting || self.exportSession.status == AVAssetExportSessionStatusExporting)) {
        [self.exportSession cancelExport];
        [self p_releaseProgressTimer];
    }
}

//MARK: - 合成音频和视频
- (void)compositeAudioAndVideoWithAudioURL:(NSURL *)audioURL
                                  videoURL:(NSURL *)videoURL
                             outputFileURL:(NSURL *)outputFileURL
                              needAudioMix:(BOOL)needAudioMix
                           progressHandler:(HMKAVCompositeProgressHandler)progress
                         completionHandler:(HMKAVCompositeCompletionHandler)completion {
    [self cancelComposite];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    NSString *errorMsg;
    
    // 添加视频合成轨道并将视频素材插入到轨道中
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    errorMsg = [self hmk_addVideoTrackFromAsset:videoAsset specialTimeRange:kCMTimeRangeZero composition:composition];
    if (errorMsg) {
        !completion ?: completion(errorMsg, outputFileURL);
        return;
    }
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero,
                                            [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject.timeRange.duration);
    NSArray<AVURLAsset *> *audioAssets;
    if (needAudioMix) {
        // 混音
        audioAssets = @[
            videoAsset,
            [AVURLAsset URLAssetWithURL:audioURL options:options]
        ];
    } else {
        // 不混音
        audioAssets = @[
            [AVURLAsset URLAssetWithURL:audioURL options:options]
        ];
    }
    AVMutableAudioMix *audioMix = [self hmk_mixAudios:audioAssets specialTimeRange:timeRange composition:composition];
    if (audioMix.inputParameters.count < audioAssets.count) {
        // 音频混合缺失某段音频 => do something？
    }
    
    // 导出视频
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFileURL
                                     audioMix:audioMix
                             videoComposition:nil
                                     progress:progress
                                   completion:completion];
}

- (void)compositeVideosWithVideoURLs:(NSArray<NSURL *> *)videoURLs
                       outputFileURL:(NSURL *)outputFileURL
                     progressHandler:(nullable HMKAVCompositeProgressHandler)progress
                   completionHandler:(nullable HMKAVCompositeCompletionHandler)completion {
    [self cancelComposite];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    __block NSString *errorMsg;
    
    // 添加视频合成轨道并将视频素材插入到轨道中
    [videoURLs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSURL * _Nonnull videoURL,
                                                                             NSUInteger idx,
                                                                             BOOL * _Nonnull stop) {
        if ([videoURL isKindOfClass:NSURL.class]) {
            AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
            errorMsg = [self hmk_addVideoTrackFromAsset:videoAsset specialTimeRange:kCMTimeRangeZero composition:composition];
            if (errorMsg) {
                !completion ?: completion(errorMsg, outputFileURL);
                *stop = YES;
                return;
            }
            
            CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero,
                                                    [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject.timeRange.duration);
            errorMsg =  [self hmk_addAudioTrackFromAsset:videoAsset
                                        specialTimeRange:timeRange
                                          needEmptyTrack:YES
                                             composition:composition];
            if (errorMsg) {
                !completion ?: completion(errorMsg, outputFileURL);
                *stop = YES;
                return;
            }
        }
    }];
    
    // 导出视频
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFileURL
                                     audioMix:nil
                             videoComposition:nil
                                     progress:progress
                                   completion:completion];
}

- (void)compositeAudiosWithAudioURLs:(NSArray<NSURL *> *)audioURLs
                       outputFileURL:(NSURL *)outputFileURL
                     progressHandler:(HMKAVCompositeProgressHandler)progress
                   completionHandler:(HMKAVCompositeCompletionHandler)completion {
    [self cancelComposite];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    __block NSString *errorMsg;
    
    // 添加视频合成轨道并将视频素材插入到轨道中
    [audioURLs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSURL * _Nonnull obj,
                                                                             NSUInteger idx,
                                                                             BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSURL.class]) {
            AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:obj options:options];
            errorMsg = [self hmk_addAudioTrackFromAsset:audioAsset
                                       specialTimeRange:kCMTimeRangeZero
                                         needEmptyTrack:YES
                                            composition:composition];
            if (errorMsg) {
                !completion ?: completion(errorMsg, outputFileURL);
                *stop = YES;
                return;
            }
        }
    }];
    
    // 导出视频
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:AVAssetExportPresetAppleM4A
                               outputFileType:AVFileTypeAppleM4A
                                    outputURL:outputFileURL
                                     audioMix:nil
                             videoComposition:nil
                                     progress:progress
                                   completion:completion];
}

- (void)mixAudiosWithAudioURLs:(NSArray<NSURL *> *)audioURLs
                 outputFileURL:(NSURL *)outputFileURL
               progressHandler:(HMKAVCompositeProgressHandler)progress
             completionHandler:(HMKAVCompositeCompletionHandler)completion {
    [self cancelComposite];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    
    NSMutableArray<AVURLAsset *> *audioAssets = [NSMutableArray array];
    [audioURLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSURL.class]) {
            AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:obj options:options];
            [audioAssets addObject:audioAsset];
        }
    }];
    
    AVMutableAudioMix *audioMix = [self hmk_mixAudios:audioAssets specialTimeRange:kCMTimeRangeZero composition:composition];
    if (audioMix.inputParameters.count < audioAssets.count) {
        // 音频混合缺失某段音频 => do something？
    }
    
    // 导出视频
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:AVAssetExportPresetAppleM4A
                               outputFileType:AVFileTypeAppleM4A
                                    outputURL:outputFileURL
                                     audioMix:audioMix
                             videoComposition:nil
                                     progress:progress
                                   completion:completion];
}

- (void)addWatermark:(CALayer *)watermarkLayer
        playAreaSize:(CGSize)playAreaSize
             toVideo:(NSURL *)videoURL
       outputFileURL:(NSURL *)outputFileURL
     progressHandler:(HMKAVCompositeProgressHandler)progress
   completionHandler:(HMKAVCompositeCompletionHandler)completion {
    
    [self cancelComposite];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    NSString *errorMsg;
    
    // 添加视频合成轨道并将视频素材插入到轨道中
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    errorMsg = [self hmk_addVideoTrackFromAsset:videoAsset specialTimeRange:kCMTimeRangeZero composition:composition];
    if (errorMsg) {
        !completion ?: completion(errorMsg, outputFileURL);
        return;
    }
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero,
                                            [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject.timeRange.duration);
    NSArray<AVURLAsset *> *audioAssets= @[
                                            [AVURLAsset URLAssetWithURL:videoURL options:options]
                                        ];
    AVMutableAudioMix *audioMix = [self hmk_mixAudios:audioAssets specialTimeRange:timeRange composition:composition];
    if (audioMix.inputParameters.count < audioAssets.count) {
        // 音频混合缺失某段音频 => do something？
    }
    
    // 添加水印
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    {
        videoComposition.renderSize = videoAssetTrack.naturalSize;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = videoAssetTrack.timeRange;

        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:[composition tracksWithMediaType:AVMediaTypeVideo][0]];

        instruction.layerInstructions = @[layerInstruction];
        videoComposition.instructions = @[instruction];
        
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = (CGRect){0, 0, videoAssetTrack.naturalSize};
        videoLayer.frame = (CGRect){0, 0, videoAssetTrack.naturalSize};
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:watermarkLayer];
        
        // 需要重新计算水印的frame
        CGFloat scale = videoAssetTrack.naturalSize.width / playAreaSize.width;
        if (videoAssetTrack.naturalSize.height / scale > playAreaSize.height) {
            scale = videoAssetTrack.naturalSize.height / playAreaSize.height;
        }
        CGRect frame = watermarkLayer.frame;
        watermarkLayer.anchorPoint = CGPointMake(0, 0);
        watermarkLayer.frame = CGRectMake(frame.origin.x * scale, frame.origin.y * scale, frame.size.width, frame.size.height);
        watermarkLayer.transform = CATransform3DMakeScale(scale, scale, 1);
        
//        CAKeyframeAnimation *breatheAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//        breatheAnimation.values = @[
//            [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)],
//            [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale * 1.1, scale * 1.1, 1)],
//            [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)]
//        ];
//        breatheAnimation.keyTimes = @[ @0, @0.714, @1 ];
//        breatheAnimation.duration = 0.7;
//        breatheAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        breatheAnimation.repeatCount = INFINITY;
//        breatheAnimation.fillMode = kCAFillModeForwards;
//
//        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//        animationGroup.animations = @[breatheAnimation];
//        animationGroup.beginTime = 0.01;
//        animationGroup.duration = MAXFLOAT;
//        [watermarkLayer addAnimation:animationGroup forKey:@"breatheAnimation"];
        
        videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
    
    // 导出视频
    [self exportAsynchronouslyWithComposition:composition
                                   presetName:nil
                               outputFileType:AVFileTypeMPEG4
                                    outputURL:outputFileURL
                                     audioMix:audioMix
                             videoComposition:videoComposition
                                     progress:progress
                                   completion:completion];
}

//MARK: - 给视频添加字幕
/**
 给视频添加字幕
 */
- (void)    addSRT:(NSArray *)srtArray
      playAreaSize:(CGSize)playAreaSize
           toVideo:(NSURL *)videoURL
     outputFileURL:(NSURL *)outputFileURL
   progressHandler:(HMKAVCompositeProgressHandler)progress
 completionHandler:(HMKAVCompositeCompletionHandler)completion {
    [self cancelComposite];
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    NSString *errorMsg;
    
    // 添加视频合成轨道并将视频素材插入到轨道中
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    errorMsg = [self hmk_addVideoTrackFromAsset:videoAsset specialTimeRange:kCMTimeRangeZero composition:composition];
    if (errorMsg) {
        !completion ?: completion(errorMsg, outputFileURL);
        return;
    }
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero,
                                            [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject.timeRange.duration);
    NSArray<AVURLAsset *> *audioAssets= @[
                                            [AVURLAsset URLAssetWithURL:videoURL options:options]
                                        ];
    AVMutableAudioMix *audioMix = [self hmk_mixAudios:audioAssets specialTimeRange:timeRange composition:composition];
    if (audioMix.inputParameters.count < audioAssets.count) {
        // 音频混合缺失某段音频 => do something？
    }
    
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = videoAssetTrack.naturalSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *videoInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoInstruction.timeRange = videoAssetTrack.timeRange;
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:[composition tracksWithMediaType:AVMediaTypeVideo].firstObject];
    
    videoInstruction.layerInstructions = @[videoLayerInstruction];
    videoComposition.instructions = @[videoInstruction];
    
    /*
     添加字幕
     原理：字幕其实就是放在视频layer层上的文字，但是它们都是隐藏的，并且在指定时间出现又在指定时间消失。
     也就是说要给这个layer加上一个动画组，第一个动画是将透明度变为1，第二个动画将透明度变为0（第二个动画可以省略）
     */
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = (CGRect){0, 0, videoAssetTrack.naturalSize};
    videoLayer.frame = (CGRect){0, 0, videoAssetTrack.naturalSize};
    [parentLayer addSublayer:videoLayer];
    [srtArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat start = [obj[@"start"] doubleValue];
        CGFloat end = [obj[@"end"] doubleValue];
        NSString *content = obj[@"content"];
        
        CATextLayer *textLayer = [CATextLayer layer];
        NSString *text = content;
        CGFloat fontSize = [[UIDevice currentDevice].model isEqualToString:@"iPad"] ? 40 : 20;
        
        UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
        CGSize size = [text boundingRectWithSize:CGSizeMake(videoAssetTrack.naturalSize.width, MAXFLOAT)
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
        
        // 需要重新计算水印的frame
        CGFloat scale = videoAssetTrack.naturalSize.width / playAreaSize.width;
        if (videoAssetTrack.naturalSize.height / scale > playAreaSize.height) {
            scale = videoAssetTrack.naturalSize.height / playAreaSize.height;
        }
        CGRect frame = textLayer.frame;
        textLayer.anchorPoint = CGPointMake(0, 0);
//        if (idx % 2 == 0) {
//            // 居左
//            textLayer.anchorPoint = CGPointMake(0, 0);
//            textLayer.frame = CGRectMake(frame.origin.x * scale, frame.origin.y * scale, frame.size.width, frame.size.height);
//        } else {
//            // 居右
//            textLayer.anchorPoint = CGPointMake(1, 0);
//            textLayer.frame = CGRectMake(videoAssetTrack.naturalSize.width - frame.size.width - frame.origin.x * scale,
//                                         frame.origin.y * scale,
//                                         frame.size.width,
//                                         frame.size.height);
//        }
        textLayer.frame = CGRectMake(frame.origin.x * scale, frame.origin.y * scale, frame.size.width, frame.size.height);
        textLayer.transform = CATransform3DMakeScale(scale, scale, 1);

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
                                    outputURL:outputFileURL
                                     audioMix:audioMix
                             videoComposition:videoComposition
                                     progress:progress
                                   completion:completion];
}

//MARK: - 音视频合成输出
- (void)exportAsynchronouslyWithComposition:(AVMutableComposition *)composition
                                 presetName:(nullable NSString *)presetName
                             outputFileType:(AVFileType)outputFileType
                                  outputURL:(NSURL *)outputURL
                                   audioMix:(nullable AVMutableAudioMix *)audioMix
                           videoComposition:(nullable AVMutableVideoComposition *)videoComposition
                                   progress:(nullable HMKAVCompositeProgressHandler)progress
                                 completion:(nullable HMKAVCompositeCompletionHandler)completionHandler {
    // 创建视频输出
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:composition
                                                           presetName:presetName ?: AVAssetExportPresetPassthrough];
    self.exportSession.outputFileType = outputFileType;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.outputURL = outputURL;
    if (audioMix) {
        self.exportSession.audioMix = audioMix;
    }
    if (videoComposition) {
        self.exportSession.videoComposition = videoComposition;
    }
    NSLog(@"文件输出路径是：%@", outputURL);
    
    // 删除旧文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    }
    
    if (progress) {
        self.progressHandler = progress;
        [self p_initProgressTimer];
    }
    
    // 开启异步输出
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        // 合成完毕
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"\n\n\nstatus=%@, error=%@, duration=%.2f",
                  @(self.exportSession.status),
                  self.exportSession.error,
                  CFAbsoluteTimeGetCurrent() - startTime);
            [self p_releaseProgressTimer];
            NSString *errorMsg = (self.exportSession.status == AVAssetExportSessionStatusCompleted) ? nil : self.exportSession.error.localizedDescription;
            !completionHandler ?: completionHandler(errorMsg, outputURL);
        });
    }];
}

//MARK: - 初始化&销毁合成进度的计时器
- (void)p_initProgressTimer {
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 repeats:YES block:^(NSTimer * _Nonnull timer) {
        // 回到主线程刷新UI
        if (self.exportSession.status == AVAssetExportSessionStatusExporting || self.exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"合成进度：%@，当前合成输出器状态status=%@", @(self.exportSession.progress), @(self.exportSession.status));
            !self.progressHandler ?: self.progressHandler(self.exportSession.progress);
        }
    }];
}

- (void)p_releaseProgressTimer {
    if (self.progressTimer && self.progressTimer.isValid) {
        NSLog(@"销毁定时器");
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}

@end

