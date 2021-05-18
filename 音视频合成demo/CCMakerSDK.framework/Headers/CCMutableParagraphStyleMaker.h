//
//  CCMutableParagraphStyleMaker.h
//  NSAttributedStringDemo
//
//  Created by Summer on 2021/3/23.
//

#import "CCBaseMaker.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCMutableParagraphStyleMaker : CCBaseMaker

+ (NSMutableParagraphStyle *)cc_make:(void(^)(CCMutableParagraphStyleMaker *maker))block;

@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^lineSpacing)(CGFloat lineSpacing);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^paragraphSpacing)(CGFloat paragraphSpacing);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^alignment)(NSTextAlignment alignment);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^firstLineHeadIndent)(CGFloat firstLineHeadIndent);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^headIndent)(CGFloat headIndent);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^tailIndent)(CGFloat tailIndent);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^lineBreakMode)(NSLineBreakMode lineBreakMode);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^minimumLineHeight)(CGFloat minimumLineHeight);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^maximumLineHeight)(CGFloat maximumLineHeight);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^baseWritingDirection)(NSWritingDirection baseWritingDirection);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^lineHeightMultiple)(CGFloat lineHeightMultiple);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^paragraphSpacingBefore)(CGFloat paragraphSpacingBefore);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^hyphenationFactor)(float hyphenationFactor);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^tabStops)(NSArray<NSTextTab *> *tabStops);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^defaultTabInterval)(CGFloat defaultTabInterval);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^allowsDefaultTighteningForTruncation)(BOOL allowsDefaultTighteningForTruncation);
@property (nonatomic, copy, readonly) CCMutableParagraphStyleMaker *(^lineBreakStrategy)(NSLineBreakStrategy lineBreakStrategy);

@end

NS_ASSUME_NONNULL_END
