//
//  CCCollectionViewMaker.h
//  UICollectionViewDemo
//
//  Created by Summer on 2021/3/16.
//

#import "CCViewMaker.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CCItemClickBlock)(NSIndexPath *itemIndexPath);

@interface CCCollectionViewMaker : CCViewMaker

// UICollectionViewLayout相关参数
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

// UICollectionViewDataSource相关参数
@property (nonatomic, strong) NSArray<NSArray<id> *> *dataSource;
@property (nonatomic, assign) Class toRegisterClass;

// UICollectionViewDelegate相关参数
@property (nonatomic, copy) void(^itemClickBlock)(NSIndexPath *itemIndexPath);

@end

NS_ASSUME_NONNULL_END
