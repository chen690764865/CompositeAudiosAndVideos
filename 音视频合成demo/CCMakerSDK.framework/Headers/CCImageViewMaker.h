//
//  CCImageViewMaker.h
//  NSAttributedStringDemo
//
//  Created by Summer on 2021/3/23.
//

#import "CCViewMaker.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCImageViewMaker : CCViewMaker

+ (UIImageView *)cc_make:(void(^)(CCImageViewMaker *maker))block;

@property (nonatomic, copy, readonly) CCImageViewMaker *(^image)(UIImage * _Nullable image);
@property (nonatomic, copy, readonly) CCImageViewMaker *(^highlightedImage)(UIImage * _Nullable highlightedImage);
@property (nonatomic, copy, readonly) CCImageViewMaker *(^highlighted)(BOOL highlighted);
@property (nonatomic, copy, readonly) CCImageViewMaker *(^addAnimation)(NSArray<UIImage *> * _Nullable anmationImages, NSTimeInterval animationDuration, NSInteger animationRepeatCount);
@property (nonatomic, copy, readonly) CCImageViewMaker *(^startAnimating)(void);
@property (nonatomic, copy, readonly) CCImageViewMaker *(^stopAnimating)(void);

@property (nonatomic, copy, readonly) CCImageViewMaker *(^animationImages)(NSArray<UIImage *> * _Nullable animationImages);
@property (nonatomic, copy, readonly) CCImageViewMaker *(^highlightedAnimationImages)(NSArray<UIImage *> * _Nullable highlightedAnimationImages);
@property (nonatomic, copy, readonly) CCImageViewMaker *(^animationDuration)(NSTimeInterval animationDuration);
@property (nonatomic, copy, readonly) CCImageViewMaker *(^animationRepeatCount)(NSInteger animationRepeatCount);

@end

NS_ASSUME_NONNULL_END
