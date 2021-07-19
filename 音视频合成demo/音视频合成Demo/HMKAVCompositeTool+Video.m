//
//  HMKAVCompositeTool+Video.m
//  音视频合成Demo
//
//  Created by Summer on 2021/6/9.
//

#import "HMKAVCompositeTool+Video.h"

@implementation HMKAVCompositeTool (Video)

- (nullable NSString *)hmk_addVideoTrackFromAsset:(AVURLAsset *)videoAsset
                                 specialTimeRange:(CMTimeRange)specialTimeRange
                                      composition:(AVMutableComposition *)composition {
    if (![videoAsset tracksWithMediaType:AVMediaTypeVideo].count) {
        return @"视频素材AVAssetTrack不存在";
    }
    
    AVMutableCompositionTrack *videoCompositionTrack;
    if ([composition tracksWithMediaType:AVMediaTypeVideo].count > 0) {
        videoCompositionTrack = [composition tracksWithMediaType:AVMediaTypeVideo].firstObject;
    } else {
        videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                         preferredTrackID:kCMPersistentTrackID_Invalid];
    }
    
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (CMTIMERANGE_IS_EMPTY(specialTimeRange)) {
        specialTimeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration);
    }
    
    NSError *error;
    [videoCompositionTrack insertTimeRange:specialTimeRange
                                   ofTrack:videoAssetTrack
                                    atTime:kCMTimeZero
                                     error:&error];
    return error ? error.localizedDescription : nil;
}

@end
