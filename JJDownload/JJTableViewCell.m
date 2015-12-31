//
//  JJTableViewCell.m
//  JJDownload
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJTableViewCell.h"

@interface JJTableViewCell()

@end

@implementation JJTableViewCell

- (void) setUrlStr:(NSString *)urlStr
{
    _urlStr = [urlStr copy];
    self.fileNameLabel.text = _urlStr.lastPathComponent;
}


@end
