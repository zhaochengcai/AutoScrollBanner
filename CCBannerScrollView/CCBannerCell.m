//
//  CCBannerCell.m
//  CCBannerScrollView
//
//  Created by chengcai.zhao on 2019/9/5.
//  Copyright © 2019 chengcai.zhao. All rights reserved.
//

#import "CCBannerCell.h"

@interface CCBannerCell ()
@property (strong, nonatomic) UILabel *label;
@end


@implementation CCBannerCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSLog(@"CCBannerCell init");
    }
    return self;
}

- (void)setColor:(UIColor *)color index:(NSInteger)index {
    self.backgroundColor = color;
    self.label.text = [NSString stringWithFormat:@"CCBannerCell : %@", @(index)];
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.frame = CGRectMake(20, 20, 200, 100);
        [self.contentView addSubview:_label];
    }
    return _label;
}

@end
