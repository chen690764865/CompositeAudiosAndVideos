//
//  CCAVCompositeTool.h
//  音视频合成Demo
//
//  Created by Summer on 2021/4/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CCAVCompositeCompletionBlock)(BOOL success, NSURL *outputFileURL);

/// 音视频合成工具
@interface CCAVCompositeTool : NSObject

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
            completion:(CCAVCompositeCompletionBlock)completionBlock;

/**
 合成多段视频
 
 @param videoURLs 视频URL地址集合
 @param outputFilePath 合成视频输出路径
 @param completionBlock 合成结果回调
 */
+ (void)compositeVideos:(NSArray<NSURL *> *)videoURLs
     withOutputFilePath:(NSURL *)outputFilePath
             completion:(CCAVCompositeCompletionBlock)completionBlock;
/**
 混音
 */
+ (void)mixAudiosWith:(NSArray<NSURL *> *)audioURLs
   withOutputFilePath:(nullable NSURL *)outputFilePath
           completion:(CCAVCompositeCompletionBlock)completionBlock;

/**
 音频合成
 */
+ (void)compositeAudiosWith:(NSArray<NSURL *> *)audioURLs
         withOutputFilePath:(nullable NSURL *)outputFilePath
                 completion:(CCAVCompositeCompletionBlock)completionBlock;

/**
 视频剪切
 */
+ (void)trimVideoWith:(NSURL *)videoURL
   withOutputFilePath:(nullable NSURL *)outputFilePath
           completion:(CCAVCompositeCompletionBlock)completionBlock;

/**
 视频旋转
 */
+ (void)rotateVideoWith:(NSURL *)videoURL
     withOutputFilePath:(nullable NSURL *)outputFilePath
             completion:(CCAVCompositeCompletionBlock)completionBlock;

/**
 视频添加水印
 */
+ (void)addWatermarkToVideo:(NSURL *)videoURL
         withOutputFilePath:(nullable NSURL *)outputFilePath
                 completion:(CCAVCompositeCompletionBlock)completionBlock;

/**
 给视频添加字幕
 */
+ (void)addSRT:(NSArray *)srtArray toVideo:(NSURL *)videoURL withOutputFilePath:(nullable NSURL *)outputFilePath
    completion:(CCAVCompositeCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
