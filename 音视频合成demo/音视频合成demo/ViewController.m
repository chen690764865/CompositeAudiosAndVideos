//
//  ViewController.m
//  音视频合成Demo
//
//  Created by Summer on 2021/4/12.
//

#import "ViewController.h"
#import "CCAVCompositeTool.h"
#import <CCMakerSDK/CCMakerSDK.h>
#import "CCAVPlayer.h"
#import "CCSRTFileLoader.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) CCAVPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView = [CCImageViewMaker cc_make:^(CCImageViewMaker * _Nonnull maker) {
        maker.frame(CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*.9f)).backgroundColor(UIColor.darkGrayColor);
        maker.addIntoView(self.view);
    }];
    
    self.button = [CCButtonMaker cc_make:^(CCButtonMaker * _Nonnull maker) {
        maker.title(@"合成并播放", UIControlStateNormal).titleColor(UIColor.blueColor, UIControlStateNormal).font([UIFont boldSystemFontOfSize:30]);
        maker.addTarget(self, @selector(p_buttonAction:), UIControlEventTouchUpInside);
        maker.sizeToFit().center(CGPointMake(self.imageView.center.x, (self.view.bounds.size.height + self.imageView.bounds.size.height)/2.f)).addIntoView(self.view);
    } buttonType:UIButtonTypeSystem];
}

- (void)p_buttonAction:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"音视频合成" message:@"选择合成方式" preferredStyle:UIAlertControllerStyleActionSheet];
    // 音频+视频（无混音）
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"音频+视频（无混音）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mergeVideoAndAudio.mp4"];
            NSURL *audioURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"]];
            NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video03" ofType:@"mp4"]];
//            NSURL *videoURL = [NSURL fileURLWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mergeVideo.mp4"]];
            [CCAVCompositeTool compositeAudio:audioURL andVideo:videoURL needAudioMix:NO withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕 => 开始播放
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // toast合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    // 音频+视频（混音）
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"音频+视频（混音）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mergeVideoAndAudio.mp4"];
            NSURL *audioURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"]];
            NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video03" ofType:@"mp4"]];
            [CCAVCompositeTool compositeAudio:audioURL andVideo:videoURL needAudioMix:YES withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕 => 开始播放
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // toast合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    // 视频+视频
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"视频+视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mergeVideo.mp4"];
            NSLog(@"合成文件的输出路径是：%@", outputFilePath);
            NSArray *videoURLs = @[
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"abctime_start" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"myPlayer" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video03" ofType:@"mp4"]]
            ];
            [CCAVCompositeTool compositeVideos:videoURLs withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕 => 开始播放
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // toast合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    // 混音
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"混音" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"audioMix.m4a"];
            NSLog(@"混音文件输出路径是：%@", outputFilePath);
            NSArray *audioURLs = @[
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"raz_map_home_bgm" ofType:@"mp3"]]
            ];
            [CCAVCompositeTool mixAudiosWith:audioURLs withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // 合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    // 音频合成
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"音频合成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"audioComposite.m4a"];
            NSArray *audioURLs = @[
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"raz_map_home_bgm" ofType:@"mp3"]]
            ];
            [CCAVCompositeTool compositeAudiosWith:audioURLs withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // 合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    // 视频剪切
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"视频剪切" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"videoTrim.mp4"];
            NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"abctime_start" withExtension:@"mp4"];
            [CCAVCompositeTool trimVideoWith:videoURL withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // 合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    // 视频旋转
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"视频旋转" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"videoRotate.mp4"];
            NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"abctime_start" withExtension:@"mp4"];
            [CCAVCompositeTool rotateVideoWith:videoURL withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // 合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    // 视频水印
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"视频水印" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"videoWatermark.mp4"];
            NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"abctime_start" withExtension:@"mp4"];
            [CCAVCompositeTool addWatermarkToVideo:videoURL withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // 合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    // 视频字幕
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"视频字幕" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSString *outputFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"videoSRT.mp4"];
            NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"五环之歌" withExtension:@"mp4"];
            [CCAVCompositeTool addSRT:[CCSRTFileLoader loadSRTFile] toVideo:videoURL withOutputFilePath:[NSURL fileURLWithPath:outputFilePath] completion:^(BOOL success, NSURL * _Nonnull outputFileURL) {
                if (success) {
                    // 合成完毕
                    [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
                } else {
                    // 合成失败
                    [self p_showErrorAlert];
                }
            }];
        }];
        action;
    })];
    
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        action;
    })];
    
    // present
    [self presentViewController:alertController animated:YES completion:nil];
}

- (CCAVPlayer *)player {
    if (!_player) {
        _player = [[CCAVPlayer alloc] init];
        _player.parentView = self.imageView;
    }
    return _player;
}

- (void)p_showErrorAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"合成失败" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        action;
    })];
    
    // present
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
