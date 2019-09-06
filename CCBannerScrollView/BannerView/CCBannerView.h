//
//  CCBannerView.h
//  CCBannerScrollView
//
//  Created by chengcai.zhao on 2019/9/5.
//  Copyright © 2019 chengcai.zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CCBannerViewProtocol <NSObject>
@required
- (NSString *)bannerViewCellIdentifierForDataIndex:(NSInteger)dataIndex;
- (void)bannerViewConfigCell:(__kindof UICollectionViewCell *)cell forDataIndex:(NSInteger)dataIndex;

@optional
- (void)bannerViewWillShowCell:(__kindof UICollectionViewCell *)cell forDataIndex:(NSInteger)dataIndex;
- (void)bannerViewWillHideCell:(__kindof UICollectionViewCell *)cell forDataIndex:(NSInteger)dataIndex;
- (void)bannerViewDidSelectItemAtDataIndex:(NSInteger)dataIndex;
@end


@interface CCBannerView : UIView
+ (instancetype)creatWithFrame:(CGRect)frame itemSize:(CGSize)itemSize delegate:(id<CCBannerViewProtocol>)delegate;
- (void)registerClassAndIdentifier:(NSDictionary<NSString *, Class> *)dic;
- (void)registerNibAndIdentifier:(NSDictionary<NSString *, UINib *> *)dic;
- (void)setDataCount:(NSInteger)dataCount;
- (void)setTimeInterval:(NSTimeInterval)timeInterval;
- (void)startTimer;
- (void)stopTimer;
@end

NS_ASSUME_NONNULL_END
