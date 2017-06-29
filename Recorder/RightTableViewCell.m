//
//  RightTableViewCell.m
//  Recorder
//
//  Created by liuxu on 2017/6/28.
//  Copyright © 2017年 liuxu. All rights reserved.
//

#import "RightTableViewCell.h"

@interface RightTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timerLabel;

@end

@implementation RightTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(15);
        }];
        
        _timeLabel = [UILabel new];
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-10);
            make.left.equalTo(self.titleLabel);
        }];

        _timerLabel = [UILabel new];
        _timerLabel.textColor = [UIColor blackColor];
        _timerLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_timerLabel];
        [_timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setCellWithDictonary:(NSDictionary *)dic {
    _titleLabel.text = dic[@"title"];
    _timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", [dic[@"timerBetween"] integerValue]/60, [dic[@"timerBetween"] integerValue] % 60];
    _timeLabel.text = [self getTimeString:[dic[@"time"] longLongValue]];
}

- (NSString *)getTimeString:(long long)timeMillis {
    if (timeMillis > 0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeMillis/1000];
        NSString* time;
        NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        time = [formatter stringFromDate:date];
        return time;
    } else {
        return @"";
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
