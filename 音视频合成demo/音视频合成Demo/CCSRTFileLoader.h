//
//  CCSRTFileLoader.h
//  音视频合成Demo
//
//  Created by Summer on 2021/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCSRTFileLoader : NSObject

+ (NSArray<NSDictionary *> *)loadSRTFile;

@end

NS_ASSUME_NONNULL_END
