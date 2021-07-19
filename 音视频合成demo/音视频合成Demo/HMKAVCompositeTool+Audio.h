//
//  HMKAVCompositeTool+Audio.h
//  音视频合成Demo
//
//  Created by Summer on 2021/6/9.
//

#import "HMKAVCompositeTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface HMKAVCompositeTool (Audio)

- (nullable NSString *)hmk_addAudioTrackFromAsset:(AVURLAsset *)audioAsset
                                 specialTimeRange:(CMTimeRange)specialTimeRange
                                   needEmptyTrack:(BOOL)needEmptyTrack
                                      composition:(AVMutableComposition *)composition;

- (AVMutableAudioMix *)hmk_mixAudios:(NSArray<AVURLAsset *> *)audioAssets
                    specialTimeRange:(CMTimeRange)specialTimeRange
                         composition:(AVMutableComposition *)composition;

@end

NS_ASSUME_NONNULL_END
