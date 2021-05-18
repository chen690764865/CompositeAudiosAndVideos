//
//  CCViewMaker.h
//  UICollectionViewDemo
//
//  Created by Summer on 2021/3/17.
//

#import "CCBaseMaker.h"

NS_ASSUME_NONNULL_BEGIN

#define CCSystemFont(fontSize) [UIFont systemFontOfSize:fontSize]
#define CCBoldSystemFont(fontSize) [UIFont boldSystemFontOfSize:fontSize]
#define CCItalicSystemFont(fontSize) [UIFont italicSystemFontOfSize:fontSize]

/**
 Tips: 为了节省内存开销，所有的Maker在视图创建完毕后都会直接销毁！！！
 */
@interface CCViewMaker : CCBaseMaker

@property (nonatomic, strong, readonly) __kindof UIView *bindingView;

+ (__kindof UIView *)cc_make:(void(^)(__kindof CCViewMaker *maker))block;

/**
 子控件添加、插入、sizeToFit等
 */
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^addIntoView)(__kindof UIView *superView);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^insertIntoView)(__kindof UIView *superView, NSInteger index);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^insertBelowSubview)(__kindof UIView *superView, __kindof UIView *siblingSubview);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^insertAboveSubview)(__kindof UIView *superView, __kindof UIView *siblingSubview);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^sizeToFit)(void);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^addGestureRecognizer)(UIGestureRecognizer *gestureRecognizer);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^addTapGesture)(NSUInteger numberOfTapsRequired, NSUInteger numberOfTouchesRequired, dispatch_block_t tapBlock);

/**
 UIView基本属性
 */
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^backgroundColor)(UIColor *backgroundColor);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^userInteractionEnabled)(BOOL userInteractionEnabled);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^tag)(NSInteger tag);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^exclusiveTouch)(BOOL exclusiveTouch);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^contentMode)(UIViewContentMode contentMode);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^alpha)(CGFloat alpha);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^opaque)(BOOL opaque);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^hidden)(BOOL hidden);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^tintColor)(UIColor *tintColor);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^autoresizingMask)(UIViewAutoresizing autoresizingMask);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^autoresizesSubviews)(BOOL autoresizesSubviews);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^clipsToBounds)(BOOL clipsToBounds);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^layerMasksToBounds)(BOOL autoresizesSubviews);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^layerCornerRadius)(CGFloat layerCornerRadius);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^border)(CGFloat borderWidth, UIColor *borderColor);
/**
 shadowColor:The color of the shadow.
 shadowOpacity:The opacity of the shadow. Defaults to 0. Specifying a value outside the [0,1] range will give undefined results. Animatable.
 shadowOffset:The shadow offset. Defaults to (0, -3). Animatable.
 shadowRadius:The blur radius used to create the shadow. Defaults to 3. Animatable.
 */
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^shadow)(UIColor *shadowColor, CGSize shadowOffset, CGFloat shadowOpacity, CGFloat shadowRadius);

/**
 设置frame相关
 */
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^frame)(CGRect frame);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^center)(CGPoint center);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^centerX)(CGFloat centerX);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^centerY)(CGFloat centerY);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^origin)(CGPoint origin);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^size)(CGSize size);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^width)(CGFloat width);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^height)(CGFloat height);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^top)(CGFloat top);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^left)(CGFloat left);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^bottom)(CGFloat bottom);
@property (nonatomic, copy, readonly) __kindof CCViewMaker *(^right)(CGFloat right);

@end

NS_ASSUME_NONNULL_END
