//
//  CCLabelMaker.h
//  UICollectionViewDemo
//
//  Created by Summer on 2021/3/17.
//

#import "CCViewMaker.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCLabelMaker : CCViewMaker

+ (UILabel *)cc_make:(void(^)(CCLabelMaker *maker))block;

@property (nonatomic, copy, readonly) CCLabelMaker *(^text)(NSString *text);
@property (nonatomic, copy, readonly) CCLabelMaker *(^font)(UIFont *font);
@property (nonatomic, copy, readonly) CCLabelMaker *(^systemFont)(CGFloat fontSize);
@property (nonatomic, copy, readonly) CCLabelMaker *(^boldSystemFont)(CGFloat fontSize);
@property (nonatomic, copy, readonly) CCLabelMaker *(^italicSystemFont)(CGFloat fontSize);
@property (nonatomic, copy, readonly) CCLabelMaker *(^textColor)(UIColor *textColor);
@property (nonatomic, copy, readonly) CCLabelMaker *(^textAlignment)(NSTextAlignment textAlignment);
@property (nonatomic, copy, readonly) CCLabelMaker *(^lineBreakMode)(NSLineBreakMode lineBreakMode);
@property (nonatomic, copy, readonly) CCLabelMaker *(^numberOfLines)(NSInteger numberOfLines);
@property (nonatomic, copy, readonly) CCLabelMaker *(^adjustsFontSizeToFitWidth)(BOOL adjustsFontSizeToFitWidth);
@property (nonatomic, copy, readonly) CCLabelMaker *(^baselineAdjustment)(UIBaselineAdjustment baselineAdjustment);
@property (nonatomic, copy, readonly) CCLabelMaker *(^minimumScaleFactor)(CGFloat minimumScaleFactor);
@property (nonatomic, copy, readonly) CCLabelMaker *(^attributedText)(NSAttributedString *attributedText);

@end

NS_ASSUME_NONNULL_END
