//
//  ViewController.m
//  CCBannerScrollView
//
//  Created by chengcai.zhao on 2019/9/5.
//  Copyright © 2019 chengcai.zhao. All rights reserved.
//

#import "ViewController.h"
#import "BannerView/CCBannerView.h"
#import "CCBannerCell.h"
#import "CCBannerCell_1.h"

@interface ViewController () <CCBannerViewProtocol>
@property (strong, nonatomic) NSArray<UIColor *> *dataArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArr = @[[UIColor redColor],
                     [UIColor yellowColor],
                     [UIColor orangeColor],
                     [UIColor brownColor],
                     [UIColor cyanColor],
                     [UIColor purpleColor],
                     [UIColor grayColor],
                     [UIColor blueColor],];
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CCBannerView *bannerView = [CCBannerView creatWithFrame:CGRectMake(0, 100, sw, 200) itemSize:CGSizeMake(sw*.82, 200) delegate:self];
    [bannerView registerClassAndIdentifier:@{@"CCBannerCell": [CCBannerCell class],
                                             @"CCBannerCell_1" : [CCBannerCell_1 class],
                                             }];
    [bannerView setDataCount:self.dataArr.count];
    [bannerView setTimeInterval:3.0];
    [self.view addSubview:bannerView];
}


#pragma mark - CCBannerViewProtocol required
- (NSString *)bannerViewCellIdentifierForDataIndex:(NSInteger)dataIndex {
    if (dataIndex <= 2) {
        return @"CCBannerCell_1";
    }
    return @"CCBannerCell";
}

- (void)bannerViewConfigCell:(__kindof UICollectionViewCell *)cell forDataIndex:(NSInteger)dataIndex {
    if (dataIndex <= 2) {
        [(CCBannerCell_1 *)cell setColor:self.dataArr[dataIndex] index:dataIndex];
        return;
    }
    [(CCBannerCell *)cell setColor:self.dataArr[dataIndex] index:dataIndex];
}

#pragma mark - CCBannerViewProtocol optional
- (void)bannerViewWillShowCell:(__kindof UICollectionViewCell *)cell forDataIndex:(NSInteger)dataIndex {
    NSLog(@"bannerViewWillShowCell : %@", @(dataIndex));
}

- (void)bannerViewWillHideCell:(__kindof UICollectionViewCell *)cell forDataIndex:(NSInteger)dataIndex {
    NSLog(@"bannerViewWillHideCell : %@", @(dataIndex));
}

- (void)bannerViewDidSelectItemAtDataIndex:(NSInteger)dataIndex {
    NSLog(@"bannerViewDidSelectItemAtDataIndex : %@", @(dataIndex));
}



@end
