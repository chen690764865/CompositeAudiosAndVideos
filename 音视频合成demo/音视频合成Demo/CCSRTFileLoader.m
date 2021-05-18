//
//  CCSRTFileLoader.m
//  音视频合成Demo
//
//  Created by Summer on 2021/5/11.
//

#import "CCSRTFileLoader.h"

@implementation CCSRTFileLoader

+ (NSArray<NSDictionary *> *)loadSRTFile {
    NSString *srtText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"五环之歌.srt" ofType:nil]
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    NSArray<NSString *> *srtArray = [srtText componentsSeparatedByString:@"\n"];
    NSMutableArray *srtResultArrayM = [NSMutableArray array];
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@":,"];
    
    // 每4个为一组
    [srtArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx / 4 == srtResultArrayM.count) {
            [srtResultArrayM addObject:[NSMutableDictionary dictionary]];
        }
        NSMutableDictionary *tmpDicM = [srtResultArrayM objectAtIndex:idx/4];
        if (idx % 4 == 0) {
            // 行号
            [tmpDicM setValue:obj forKey:@"index"];
        } else if (idx % 4 == 1) {
            // 时间 格式：xx:xx:xx,xxx --> xx:xx:xx,xxx
            NSArray *tmpArray = [obj componentsSeparatedByString:@" --> "];
            NSArray<NSString *> *startArray = [tmpArray[0] componentsSeparatedByCharactersInSet:characterSet];
            NSArray<NSString *> *endArray = [tmpArray[1] componentsSeparatedByCharactersInSet:characterSet];
            [tmpDicM setValue:@([startArray[0] integerValue]*3600 + [startArray[1] integerValue]*60 + [startArray[2] integerValue] + [startArray[3] integerValue]/1000.f)
                       forKey:@"start"];
            [tmpDicM setValue:@([endArray[0] integerValue]*3600 + [endArray[1] integerValue]*60 + [endArray[2] integerValue] + [endArray[3] integerValue]/1000.f)
                       forKey:@"end"];
        } else if (idx % 4 == 2) {
            // 字幕内容
            [tmpDicM setValue:obj forKey:@"content"];
        } else if (idx % 4 == 3) {
            // 空格
        } 
    }];
    
    return [NSArray arrayWithArray:srtResultArrayM];
}

@end
