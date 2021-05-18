//
//  CCTextAttachmentMaker.h
//  NSAttributedStringDemo
//
//  Created by Summer on 2021/3/23.
//

#import "CCBaseMaker.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCTextAttachmentMaker : CCBaseMaker

+ (NSTextAttachment *)cc_make:(void(^)(CCTextAttachmentMaker *maker))block;

@property (nonatomic, copy, readonly) CCTextAttachmentMaker *(^image)(UIImage *image);
@property (nonatomic, copy, readonly) CCTextAttachmentMaker *(^bounds)(CGRect bounds);

@end

NS_ASSUME_NONNULL_END
