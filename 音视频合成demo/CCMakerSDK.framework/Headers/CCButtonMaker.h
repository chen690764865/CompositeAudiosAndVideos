//
//  CCButtonMaker.h
//  UICollectionViewDemo
//
//  Created by Summer on 2021/3/18.
//

#import "CCViewMaker.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCButtonMaker : CCViewMaker

+ (__kindof UIView *)cc_make:(void(^)(CCButtonMaker *maker))block;
+ (__kindof UIView *)cc_make:(void(^)(CCButtonMaker *maker))block buttonType:(UIButtonType)buttonType;

@property (nonatomic, copy, readonly) CCButtonMaker *(^enabled)(BOOL enabled);
@property (nonatomic, copy, readonly) CCButtonMaker *(^highlighted)(BOOL highlighted);
@property (nonatomic, copy, readonly) CCButtonMaker *(^selected)(BOOL selected);
@property (nonatomic, copy, readonly) CCButtonMaker *(^contentVerticalAlignment)(UIControlContentVerticalAlignment alignment);
@property (nonatomic, copy, readonly) CCButtonMaker *(^contentHorizontalAlignment)(UIControlContentHorizontalAlignment alignment);

@property (nonatomic, copy, readonly) CCButtonMaker *(^addTarget)(id target, SEL action, UIControlEvents controlEvents);
@property (nonatomic, copy, readonly) CCButtonMaker *(^removeTarget)(id target, SEL action, UIControlEvents controlEvents);

@property (nonatomic, copy, readonly) CCButtonMaker *(^addAction)(UIAction *action, UIControlEvents controlEvents) API_AVAILABLE(ios(14.0));
@property (nonatomic, copy, readonly) CCButtonMaker *(^removeAction)(UIAction *action, UIControlEvents controlEvents) API_AVAILABLE(ios(14.0));
@property (nonatomic, copy, readonly) CCButtonMaker *(^removeActionForIdentifier)(UIActionIdentifier actionIdentifier, UIControlEvents controlEvents) API_AVAILABLE(ios(14.0));

@property (nonatomic, copy, readonly) CCButtonMaker *(^contentEdgeInsets)(UIEdgeInsets contentEdgeInsets);
@property (nonatomic, copy, readonly) CCButtonMaker *(^titleEdgeInsets)(UIEdgeInsets titleEdgeInsets);
@property (nonatomic, copy, readonly) CCButtonMaker *(^imageEdgeInsets)(UIEdgeInsets imageEdgeInsets);
@property (nonatomic, copy, readonly) CCButtonMaker *(^reversesTitleShadowWhenHighlighted)(BOOL reversesTitleShadowWhenHighlighted);

@property (nonatomic, copy, readonly) CCButtonMaker *(^adjustsImageWhenHighlighted)(BOOL adjustsImageWhenHighlighted);
@property (nonatomic, copy, readonly) CCButtonMaker *(^adjustsImageWhenDisabled)(BOOL adjustsImageWhenDisabled);
@property (nonatomic, copy, readonly) CCButtonMaker *(^showsTouchWhenHighlighted)(BOOL showsTouchWhenHighlighted);
@property (nonatomic, copy, readonly) CCButtonMaker *(^tintColor)(UIColor *tintColor);

@property (nonatomic, copy, readonly) CCButtonMaker *(^title)(NSString *title, UIControlState state);
@property (nonatomic, copy, readonly) CCButtonMaker *(^font)(UIFont *font);
@property (nonatomic, copy, readonly) CCButtonMaker *(^titleColor)(UIColor *color, UIControlState state);
@property (nonatomic, copy, readonly) CCButtonMaker *(^titleShadowColor)(UIColor *color, UIControlState state);
@property (nonatomic, copy, readonly) CCButtonMaker *(^image)(UIImage *image, UIControlState state);
@property (nonatomic, copy, readonly) CCButtonMaker *(^bgImage)(UIImage *bgImage, UIControlState state);
@property (nonatomic, copy, readonly) CCButtonMaker *(^attributedTitle)(NSAttributedString *titleAttributedString, UIControlState state);

@end

NS_ASSUME_NONNULL_END
