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
#import "HMKAVCompositeTool.h"
#import <libextobjc/extobjc.h>

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) CCAVPlayer *player;

@property (nonatomic, copy) HMKAVCompositeProgressHandler progressHandler;
@property (nonatomic, copy) HMKAVCompositeCompletionHandler completionHandler;

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
        maker.titleColor(UIColor.redColor, UIControlStateDisabled);
        maker.addTarget(self, @selector(p_buttonAction:), UIControlEventTouchUpInside);
        maker.frame(CGRectMake(0, CGRectGetMaxY(self.imageView.frame), self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(self.imageView.frame)));
        maker.addIntoView(self.view);
    } buttonType:UIButtonTypeCustom];
    
    CALayer *watermarkLayer = [self watermarkLayer];
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_panGesture:)];
    UIView *watermarkView = [[UIView alloc] initWithFrame:CGRectMake(watermarkLayer.frame.origin.x,
                                                                     watermarkLayer.frame.origin.y + 100,
                                                                     watermarkLayer.frame.size.width,
                                                                     watermarkLayer.frame.size.height)];
    [watermarkView addGestureRecognizer:panGes];
    watermarkView.backgroundColor = [UIColor colorWithWhite:.7f alpha:.7f];
    [self.view addSubview:watermarkView];
}

- (void)p_panGesture:(UIPanGestureRecognizer *)sender {
    //返回在横坐标上、纵坐标上拖动了多少像素
    CGPoint point = [sender translationInView:self.view];
    NSLog(@"%f,%f",point.x,point.y);
    CGFloat centerX = sender.view.center.x+point.x;
    CGFloat centerY = sender.view.center.y+point.y;
    sender.view.center = CGPointMake(centerX, centerY);
    //拖动完之后，每次都要用setTranslation:方法置0这样才不至于不受控制般滑动出视图
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)p_buttonAction:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"音视频合成" message:@"选择合成方式" preferredStyle:UIAlertControllerStyleAlert];
    // 音频+视频（无混音）
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"音频+视频（无混音）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSURL *audioURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"raz_map_home_bgm" ofType:@"mp3"]];
            NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test_video_a" ofType:@"mp4"]];
            // 最终合成的输出路径
            NSURL *outputFileURL = [NSURL fileURLWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mergeVideoAndAudio_noMix.mp4"]];
            
            [[HMKAVCompositeTool sharedCompositeTool] compositeAudioAndVideoWithAudioURL:audioURL
                                                                                videoURL:videoURL
                                                                           outputFileURL:outputFileURL
                                                                            needAudioMix:NO
                                                                         progressHandler:self.progressHandler
                                                                       completionHandler:self.completionHandler];
        }];
        action;
    })];
    
    // 音频+视频（混音）
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"音频+视频（混音）" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *audioURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"]];
            NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video03" ofType:@"mp4"]];
            // 最终合成的输出路径
            NSURL *outputFileURL = [NSURL fileURLWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mergeVideoAndAudio_Mix.mp4"]];
            
            [[HMKAVCompositeTool sharedCompositeTool] compositeAudioAndVideoWithAudioURL:audioURL
                                                                                videoURL:videoURL
                                                                           outputFileURL:outputFileURL
                                                                            needAudioMix:YES
                                                                         progressHandler:self.progressHandler
                                                                       completionHandler:self.completionHandler];
        }];
        action;
    })];
    
    // 视频+视频
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"视频+视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSURL *outputFileURL = [NSURL fileURLWithPath:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"mergeVideo.mp4"]];
            NSArray *videoURLs = @[
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp4"]]
            ];
            [[HMKAVCompositeTool sharedCompositeTool] compositeVideosWithVideoURLs:videoURLs
                                                                     outputFileURL:outputFileURL
                                                                   progressHandler:self.progressHandler
                                                                 completionHandler:self.completionHandler];
        }];
        action;
    })];
    
    // 混音
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"混音" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSURL *outputFileURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"audioMix.m4a"]];
            NSArray *audioURLs = @[
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"raz_map_home_bgm" ofType:@"mp3"]]
            ];
            
            [[HMKAVCompositeTool sharedCompositeTool] mixAudiosWithAudioURLs:audioURLs
                                                               outputFileURL:outputFileURL
                                                             progressHandler:self.progressHandler
                                                           completionHandler:self.completionHandler];
        }];
        action;
    })];
    
    // 音频合成
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"音频合成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSURL *outputFileURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"audioComposite.m4a"]];
            NSArray *audioURLs = @[
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"start" ofType:@"mp4"]],
                [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"raz_map_home_bgm" ofType:@"mp3"]]
            ];
            [[HMKAVCompositeTool sharedCompositeTool] compositeAudiosWithAudioURLs:audioURLs
                                                                     outputFileURL:outputFileURL
                                                                   progressHandler:self.progressHandler
                                                                 completionHandler:self.completionHandler];
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
            NSURL *outputFileURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"videoWatermark.mp4"]];
            NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"五环之歌" withExtension:@"mp4"];
            [[HMKAVCompositeTool sharedCompositeTool] addWatermark:[self watermarkLayer]
                                                      playAreaSize:self.imageView.bounds.size
                                                           toVideo:videoURL
                                                     outputFileURL:outputFileURL
                                                   progressHandler:self.progressHandler
                                                 completionHandler:self.completionHandler];
        }];
        action;
    })];
    
    // 视频字幕
    [alertController addAction:({
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"视频字幕" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 最终合成的输出路径
            NSURL *outputFileURL = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"videoSRT.mp4"]];
            NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"五环之歌" withExtension:@"mp4"];
            [[HMKAVCompositeTool sharedCompositeTool] addSRT:[CCSRTFileLoader loadSRTFile]
                                                playAreaSize:self.imageView.bounds.size
                                                     toVideo:videoURL
                                               outputFileURL:outputFileURL
                                             progressHandler:self.progressHandler
                                           completionHandler:self.completionHandler];
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

- (void)updateCompositeProgress:(float)progress {
    self.button.enabled = NO;
    [self.button setTitle:[NSString stringWithFormat:@"合成进度：%.2f%%", progress * 100] forState:UIControlStateDisabled];
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

- (HMKAVCompositeProgressHandler)progressHandler {
    if (!_progressHandler) {
        @weakify(self);
        _progressHandler = ^void(float progress){
            @strongify(self);
            [self updateCompositeProgress:progress];
        };
    }
    return _progressHandler;
}

- (HMKAVCompositeCompletionHandler)completionHandler {
    if (!_completionHandler) {
        @weakify(self);
        _completionHandler = ^void(NSString * _Nullable errorMsg, NSURL *outputFileURL){
            @strongify(self);
            self.button.enabled = YES;
            if (!errorMsg) {
                // 合成完毕 => 开始播放
                [self.player resetWithFileURL:outputFileURL immediatelyPlay:YES];
            } else {
                // toast合成失败
                [self p_showErrorAlert];
            }
        };
    }
    return _completionHandler;
}

- (CALayer *)watermarkLayer {
    CATextLayer *textLayer = [CATextLayer layer];
    NSString *text = @"小猴启蒙";
    CGFloat fontSize = [[UIDevice currentDevice].model isEqualToString:@"iPad"] ? 40 : 20;
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 30)
                                     options:NSStringDrawingUsesFontLeading
                                  attributes:@{
                                      NSFontAttributeName : font
                                  }
                                     context:nil].size;
    textLayer.frame = (CGRect){10, 10, size};
    textLayer.string = text;
    textLayer.foregroundColor = [UIColor redColor].CGColor;
    textLayer.font = (__bridge CFTypeRef _Nullable)font;
    textLayer.fontSize = fontSize;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.backgroundColor = UIColor.whiteColor.CGColor;
    textLayer.contentsScale = UIScreen.mainScreen.scale;
    return textLayer;
}

@end
