//
//  CCAVPlayer.m
//  音视频合成Demo
//
//  Created by Summer on 2021/5/6.
//

#import "CCAVPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface CCAVPlayer ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation CCAVPlayer

- (void)resetWithFileURL:(NSURL *)fileURL immediatelyPlay:(BOOL)immediatelyPlay {
    [self stop];
    
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.parentView.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.parentView.layer addSublayer:self.playerLayer];
    
    //KVO监听playerItem的status属性的变化，来获知视频是否可以播放的状态
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
}

- (void)play {
    [self.player play];
}

- (void)pause {
    
}

- (void)resume {
    
}

- (void)stop {
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

//MARK: - Lazy
- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

//MARK: - KVO监听playItem的status的值的变化
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    NSLog(@"🐥🐥🐥🐥🐥🐥🐥 keyPath=%@, value=%@", keyPath, [self.playerItem valueForKey:keyPath]);
    if ([keyPath isEqualToString:@"status"]) {
        
        //取出status的新值
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
                
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"准备好播放视频了");
                [self.player play];
            }
                break;
                
            default:
                
                break;
        }
        
    }
    
}

@end
