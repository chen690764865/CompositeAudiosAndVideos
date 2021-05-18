//
//  CCAVPlayer.h
//  音视频合成Demo
//
//  Created by Summer on 2021/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCAVPlayer : NSObject

@property (nonatomic, strong) __kindof UIView *parentView;

- (void)resetWithFileURL:(NSURL *)fileURL immediatelyPlay:(BOOL)immediatelyPlay;

- (void)play;

- (void)pause;

- (void)resume;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
