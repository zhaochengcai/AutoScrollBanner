//
//  CCBannerView.m
//  CCBannerScrollView
//
//  Created by chengcai.zhao on 2019/9/5.
//  Copyright © 2019 chengcai.zhao. All rights reserved.
//

#import "CCBannerView.h"

@interface CCBannerView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (assign, nonatomic) NSInteger totalDataCount;
@property (assign, nonatomic) NSInteger dataCount;
@property (assign, nonatomic) NSInteger curShowingIndex;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSTimeInterval timeInterval;



@property (weak, nonatomic) id<CCBannerViewProtocol> delegate;

@end

@implementation CCBannerView

#pragma mark - public
+ (instancetype)creatWithFrame:(CGRect)frame itemSize:(CGSize)itemSize delegate:(id<CCBannerViewProtocol>)delegate{
    CCBannerView *view = [[CCBannerView alloc] initWithFrame:frame];
    view.flowLayout.itemSize = itemSize;
    view.delegate = delegate;
    return view;
}

- (void)registerClassAndIdentifier:(NSDictionary<NSString *, Class> *)dic {
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.collectionView registerClass:obj forCellWithReuseIdentifier:key];
    }];
}

- (void)registerNibAndIdentifier:(NSDictionary<NSString *, UINib *> *)dic {
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UINib * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.collectionView registerNib:obj forCellWithReuseIdentifier:key];
    }];
}

- (void)setDataCount:(NSInteger)dataCount {
    _dataCount = dataCount;
    self.pageControl.numberOfPages = _dataCount;
    self.totalDataCount = _dataCount * 100;
    [self.collectionView reloadData];
    [self resetPageControlFrame];
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    if (timeInterval == _timeInterval) {
        return;
    }
    _timeInterval = timeInterval;
    [self stopTimer];
    [self startTimer];
}

- (void)startTimer {
    if (self.timer.isValid || self.dataCount <= 0 || self.timeInterval <= 0) {
        return;
    }
    self.timer = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (!self.timer) {
        return;
    }
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - private

- (void)automaticScroll {
    if (0 == _totalDataCount) return;
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex animated:YES];
}

- (void)scrollToIndex:(int)targetIndex animated:(BOOL)animated {
    if (self.dataCount <= 0) {
        return;
    }
    NSLog(@"scrollToIndex: %@  animated: %@", @(targetIndex%self.dataCount), @(animated));
    if (targetIndex >= _totalDataCount) {
        targetIndex = _totalDataCount * 0.5;
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        return;
    }
    
    NSInteger willHideIndex = -1;
    NSInteger willShowIndex = -1;
    if (targetIndex != _curShowingIndex) {
        willHideIndex = _curShowingIndex;
        willShowIndex = targetIndex;
        _curShowingIndex = targetIndex;
    }
    
    // will hide
    if (willHideIndex  >= 0) {
        if ([self.delegate respondsToSelector:@selector(bannerViewWillHideCell:forDataIndex:)]) {
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:willHideIndex inSection:0] ];
            [self.delegate bannerViewWillHideCell:cell forDataIndex:willHideIndex%self.dataCount];
        }
    }
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
    
    // will show
    if (willShowIndex >= 0) {
        if ([self.delegate respondsToSelector:@selector(bannerViewWillShowCell:forDataIndex:)]) {
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:willShowIndex inSection:0] ];
            [self.delegate bannerViewWillShowCell:cell forDataIndex:willShowIndex%self.dataCount];
        }
    }
}

- (int)currentIndex {
    int index = (_collectionView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    return MAX(0, index);
}

- (void)resetPageControlFrame {
    CGSize size = [self.pageControl sizeForNumberOfPages:self.dataCount];
    self.pageControl.frame = CGRectMake((self.bounds.size.width - size.width)/2.0,
                                        self.bounds.size.height - size.height + 5,
                                        size.width, size.height);
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeNoitification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)noti {
    if ([noti.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        if (self.totalDataCount > 0) {
            [self startTimer];
        }
    } else if ([noti.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self stopTimer];
    }
}

#pragma mark - override thing
- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame =  self.bounds;
    [self resetPageControlFrame];
    
    if (_collectionView.contentOffset.x == 0 && _totalDataCount) {
        int targetIndex = _totalDataCount * 0.5;
        [self scrollToIndex:targetIndex animated:NO];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self stopTimer];
    }
}

- (void)dealloc {
    [self removeNoitification];
}

#pragma mark - init thing
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _curShowingIndex = -1;
    [self addSubview:self.collectionView];
    self.collectionView.frame = self.bounds;
    
    [self addSubview:self.pageControl];
    [self resetPageControlFrame];
    
    [self addNotification];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalDataCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    long dataIndex = indexPath.row % self.dataCount;
    NSString *identifier = [self.delegate bannerViewCellIdentifierForDataIndex:dataIndex];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [self.delegate bannerViewConfigCell:cell forDataIndex:dataIndex];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(bannerViewDidSelectItemAtDataIndex:)]) {
        [self.delegate bannerViewDidSelectItemAtDataIndex:indexPath.row%self.dataCount];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.delegate respondsToSelector:@selector(bannerViewWillShowCell:forDataIndex:)]) {
//        [self.delegate bannerViewWillShowCell:cell forDataIndex:indexPath.row%self.dataCount];
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.delegate respondsToSelector:@selector(bannerViewDidHideCell:forDataIndex:)]) {
//        [self.delegate bannerViewDidHideCell:cell forDataIndex:indexPath.row%self.dataCount];
//    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    *targetContentOffset = scrollView.contentOffset;
    int index = [self currentIndex];
    [self scrollToIndex:index animated:YES];
    [self startTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 如有需要可以放到 scrollViewDidScroll: 方法里
    int itemIndex = [self currentIndex];
    int indexOnPageControl = itemIndex % self.dataCount;
    _pageControl.currentPage = indexOnPageControl;
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 0;
        
    }
    return _flowLayout;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

@end
