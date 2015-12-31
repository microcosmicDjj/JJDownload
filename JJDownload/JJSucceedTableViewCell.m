//
//  JJSucceedTableViewCell.m
//  JJDownload
//
//  Created by Mac on 15/12/29.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJSucceedTableViewCell.h"

@implementation JJSucceedTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setUrlStr:(NSString *)urlStr
{
    _urlStr = [urlStr copy];
    self.textLabel.text = _urlStr.lastPathComponent;
}

@end
