//
//  CCMutableAttributedStringMaker.h
//  UICollectionViewDemo
//
//  Created by Summer on 2021/3/18.
//

#import "CCBaseMaker.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCMutableAttributedStringMaker : CCBaseMaker

+ (NSMutableAttributedString *)cc_make:(void(^)(CCMutableAttributedStringMaker *maker))block text:(NSString *)text;

@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^setAttributes)(NSDictionary<NSAttributedStringKey, id> * _Nullable attrs, NSRange range);

@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^addAttribute)(NSAttributedStringKey name, id value, NSRange range);
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^addAttributes)(NSDictionary<NSAttributedStringKey, id> *attrs, NSRange range);
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^removeAttribute)(NSAttributedStringKey name, NSRange range);
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^insertAttribute)(NSAttributedString *attrString, NSUInteger index);
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^appendAttribute)(NSAttributedString *attrString);


/**
 设置内容字体
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^font)(UIFont *font, NSRange range);

/**
 设置特殊段落效果
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^paragraph)(NSParagraphStyle *paragraphStyle, NSRange range);

/**
 设置内容的字色
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^foregroundColor)(UIColor *color, NSRange range);

/**
 设置内容的背景色
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^backgroundColor)(UIColor *color, NSRange range);

/**
 设置字间距
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^kern)(CGFloat kern, NSRange range);

/**
 给对应NSRange区域的文本添加下划线
 
 style：下划线的样式 NSUnderlineStyle类型
 NSUnderlineStyle官方解释：
 这里定义了NSUnderlineStyleAttributeName和NSStrikethroughStyleAttributeName当前支持的一些值。将这些值放一起来生成下划线/删除线的样式.
 默认情况下，下划线/删除线将使用实线绘制，因此不需要指定NSUnderlineStylePatternSolid.
 typedef NS_OPTIONS(NSInteger, NSUnderlineStyle) {
     // 这里是第一类样式
     NSUnderlineStyleNone                               = 0x00, 不设置下划线
     NSUnderlineStyleSingle                             = 0x01, 细的单线
     NSUnderlineStyleThick API_AVAILABLE                = 0x02, 粗的单线
     NSUnderlineStyleDouble API_AVAILABLE               = 0x09, 细的双线，默认两条双线的间隔比较大，任意设置baselineOffset后间隔变小(固定间距)
     
     // 这里是第二类样式
     NSUnderlineStylePatternSolid API_AVAILABLE         = 0x0000, 实线，默认样式不用指定
     NSUnderlineStylePatternDot API_AVAILABLE           = 0x0100, 虚线样式 如：- - - - - - - - -
     NSUnderlineStylePatternDash API_AVAILABLE          = 0x0200, 破折号样式 如：—— —— —— —— —— ——
     NSUnderlineStylePatternDashDot API_AVAILABLE       = 0x0300, 破折号+虚线 如：—— - —— - —— - ——
     NSUnderlineStylePatternDashDotDot API_AVAILABLE    = 0x0400, 破折号+虚线+虚线 如：—— - - —— - - —— - - —— - - ——
     
     // 这里是第三类样式
     NSUnderlineStyleByWord API_AVAILABLE               = 0x8000, 仅在设置删除线时生效，在有空格的地方不设置删除线
 };
 
 color：下划线的颜色 UIColor, default nil: same as foreground color
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^underline)(NSUnderlineStyle style, UIColor * _Nullable color, NSRange range);

/**
 给对应NSRange区域的文本添加删除线
 style：删除线的样式 NSUnderlineStyle类型，同underline
 color：删除线的颜色 UIColor, default nil: same as foreground color
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^strikethrough)(NSUnderlineStyle style, UIColor * _Nullable color, NSRange range);

/**
 文本添加描边效果
 width：描边的宽度，它代表的是文本字号的百分比，其中正数代表描边，负数代表描边+填充（显示效果就是文字变大）。注：3.0是一个典型的描边值
 color：描边的颜色，UIColor, default nil: same as foreground color
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^stroke)(CGFloat width, UIColor * _Nullable color, NSRange range);

/**
 文本添加阴影效果
 shadowOffset：阴影范围
 shadowBlurRadius：阴影模糊半径，值越大越模糊
 shadowColor：阴影颜色，传nil时使用默认色值(default is black with an alpha value of 1/3)
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^shadow)(CGSize shadowOffset, CGFloat shadowBlurRadius, UIColor * _Nullable shadowColor, NSRange range);

/**
 添加文字效果
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^textEffect)(NSTextEffectStyle style, NSRange range);

/**
 一般用于图文混排，需要传入一个NSTextAttachment对象
 attchment: 图文混排的对象
 index: 插入的位置
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^attachment)(NSTextAttachment *attachment, NSUInteger index);

/**
 方便插入图文对象的方法，与attachment等效
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^attachment2)(UIImage *image, CGRect bounds, NSUInteger index);

/**
 设置文字为链接，点击打开对应url地址
 UILabel使用此属性无效
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^link)(NSURL *linkURL, NSRange range);

/**
 设置基线的偏移量
 注：如果设置了某个范围range内的内容的偏移量offset，那么其他位置的内容同样会根据基线来进行偏移，
 如果想让其他位置内容保持居中则需要设置其他位置的内容偏移量为offset/2
 
 baselineOffset：偏移量，CGFloat类型
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^baselineOffset)(CGFloat baselineOffset, NSRange range);

/**
 设置字体倾斜度
 skew：倾斜角度，如：45°=M_PI_4，30°=M_PI/6 ... 但是不可以设置M_PI/2的奇数倍，因为tan(M_PI/2 ± M_PI)等于正负无穷大
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^obliqueness)(CGFloat skewAngle, NSRange range);

/**
 字体添加拉伸效果
 value：log of expansion factor to be applied to glyphs.default 0: no expansion. 正数拉伸、负数压扁
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^expansion)(CGFloat value, NSRange range);

/**
 设置文字书写方向
 LRE：NSWritingDirectionLeftToRight | NSWritingDirectionEmbedding
 LRO：NSWritingDirectionLeftToRight | NSWritingDirectionOverride
 RLE：NSWritingDirectionRightToLeft | NSWritingDirectionEmbedding
 RLO：NSWritingDirectionRightToLeft | NSWritingDirectionOverride
 direction：如 @[@(NSWritingDirectionLeftToRight | NSWritingDirectionEmbedding)]
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^writingDirection)(NSArray<NSNumber *> *direction, NSRange range);

/**
 文字排版是垂直还是水平
 value：0代表水平，1代表垂直。但是根据官方文档，目前iOS中只有水平方向可用。
 */
@property (nonatomic, copy, readonly) CCMutableAttributedStringMaker *(^vertivalGlyphForm)(NSInteger value, NSRange range);

@end

NS_ASSUME_NONNULL_END
