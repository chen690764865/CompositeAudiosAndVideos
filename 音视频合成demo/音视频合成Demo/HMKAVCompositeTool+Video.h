//
//  HMKAVCompositeTool+Video.h
//  音视频合成Demo
//
//  Created by Summer on 2021/6/9.
//

#import "HMKAVCompositeTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMKAVCompositeTool (Video)

- (nullable NSString *)hmk_addVideoTrackFromAsset:(AVURLAsset *)videoAsset
                                 specialTimeRange:(CMTimeRange)specialTimeRange
                                      composition:(AVMutableComposition *)composition;

@end

NS_ASSUME_NONNULL_END
