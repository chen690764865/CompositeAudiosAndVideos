//
//  HMKAVCompositeTool+Audio.m
//  音视频合成Demo
//
//  Created by Summer on 2021/6/9.
//

#import "HMKAVCompositeTool+Audio.h"

@implementation HMKAVCompositeTool (Audio)

- (nullable NSString *)hmk_addAudioTrackFromAsset:(AVURLAsset *)audioAsset
                                 specialTimeRange:(CMTimeRange)specialTimeRange
                                   needEmptyTrack:(BOOL)needEmptyTrack
                                      composition:(AVMutableComposition *)composition {
    if (![audioAsset tracksWithMediaType:AVMediaTypeAudio].count && !needEmptyTrack) {
        return [NSString stringWithFormat:@"音频素材AVAssetTrack不存在, %@", audioAsset];
    }
    
    AVMutableCompositionTrack *audioCompositionTrack;
    AVMediaType mediaType = AVMediaTypeAudio;
    if ([composition tracksWithMediaType:mediaType].count > 0) {
        audioCompositionTrack = [composition tracksWithMediaType:mediaType].firstObject;
    } else {
        audioCompositionTrack = [composition addMutableTrackWithMediaType:mediaType
                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    
    AVAssetTrack *audioAssetTrack = [audioAsset tracksWithMediaType:mediaType].firstObject;
    NSError *error;
    if (CMTIMERANGE_IS_EMPTY(specialTimeRange)) {
        specialTimeRange = CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration);
    }
    
    if (audioAssetTrack) {
        [audioCompositionTrack insertTimeRange:specialTimeRange
                                       ofTrack:audioAssetTrack
                                        atTime:kCMTimeZero
                                         error:&error];
    } else if (needEmptyTrack) {
        [audioCompositionTrack insertEmptyTimeRange:specialTimeRange];
    }
    return error ? error.localizedDescription : nil;
}

- (AVMutableAudioMix *)hmk_mixAudios:(NSArray<AVURLAsset *> *)audioAssets
                    specialTimeRange:(CMTimeRange)specialTimeRange
                         composition:(AVMutableComposition *)composition {
    AVMediaType mediaType = AVMediaTypeAudio;
    __block NSError *outError;
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    NSMutableArray<AVMutableAudioMixInputParameters *> *inputParamtersArrayM = [NSMutableArray array];
    
    /**
     混音的流程
     1.遍历待混音集合
     2.音频素材插入音频合成轨道；
     3.从音频合成轨道获取混音输入参数
     4.输入参数设置音量等设置
     5.给AVMutableAudioMix赋值inputParameters
     */
    [audioAssets enumerateObjectsUsingBlock:^(AVURLAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:AVURLAsset.class] && [obj tracksWithMediaType:AVMediaTypeAudio].count) {
            AVAssetTrack *audioAssetTrack = [obj tracksWithMediaType:mediaType].firstObject;
            AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:mediaType preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioCompositionTrack insertTimeRange:CMTIMERANGE_IS_EMPTY(specialTimeRange) ? CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration) : specialTimeRange
                                           ofTrack:audioAssetTrack
                                            atTime:kCMTimeZero
                                             error:&outError];
            if (!outError) {
                AVMutableAudioMixInputParameters *inputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompositionTrack];
                [inputParameters setVolume:1.f atTime:kCMTimeZero];
                [inputParamtersArrayM addObject:inputParameters];
            }
        }
    }];
    
    audioMix.inputParameters = inputParamtersArrayM;
    return audioMix;
}

@end
