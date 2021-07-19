//
//  HMKAVCompositeTool.h
//  音视频合成Demo
//
//  Created by Summer on 2021/5/31.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HMKAVCompositeCompletionHandler)( NSString * _Nullable errorMsg, NSURL *outputFileURL);
typedef void(^HMKAVCompositeProgressHandler)(float progress);

@interface HMKAVCompositeTool : NSObject

+ (instancetype)sharedCompositeTool;

- (void)compositeAudioAndVideoWithAudioURL:(NSURL *)audioURL
                                  videoURL:(NSURL *)videoURL
                             outputFileURL:(NSURL *)outputFileURL
                              needAudioMix:(BOOL)needAudioMix
                           progressHandler:(nullable HMKAVCompositeProgressHandler)progress
                         completionHandler:(nullable HMKAVCompositeCompletionHandler)completion;

- (void)compositeVideosWithVideoURLs:(NSArray<NSURL *> *)videoURLs
                       outputFileURL:(NSURL *)outputFileURL
                     progressHandler:(nullable HMKAVCompositeProgressHandler)progress
                   completionHandler:(nullable HMKAVCompositeCompletionHandler)completion;

- (void)compositeAudiosWithAudioURLs:(NSArray<NSURL *> *)audioURLs
                       outputFileURL:(NSURL *)outputFileURL
                     progressHandler:(nullable HMKAVCompositeProgressHandler)progress
                   completionHandler:(nullable HMKAVCompositeCompletionHandler)completion;

- (void)mixAudiosWithAudioURLs:(NSArray<NSURL *> *)audioURLs
                 outputFileURL:(NSURL *)outputFileURL
               progressHandler:(nullable HMKAVCompositeProgressHandler)progress
             completionHandler:(nullable HMKAVCompositeCompletionHandler)completion;

/**
 给视频添加水印
 */
- (void)addWatermark:(CALayer *)watermarkLayer
        playAreaSize:(CGSize)playAreaSize
             toVideo:(NSURL *)videoURL
       outputFileURL:(NSURL *)outputFileURL
     progressHandler:(HMKAVCompositeProgressHandler)progress
   completionHandler:(HMKAVCompositeCompletionHandler)completion;

/**
 给视频添加字幕
 */
- (void)    addSRT:(NSArray *)srtArray
      playAreaSize:(CGSize)playAreaSize
           toVideo:(NSURL *)videoURL
     outputFileURL:(NSURL *)outputFileURL
   progressHandler:(HMKAVCompositeProgressHandler)progress
 completionHandler:(HMKAVCompositeCompletionHandler)completion;

- (void)cancelComposite;

@end

NS_ASSUME_NONNULL_END
