//
//  JJDetailsTableViewCell.m
//  JJDownload
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJDetailsTableViewCell.h"
#import "JJFile.h"

@interface JJDetailsTableViewCell()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation JJDetailsTableViewCell

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}

- (void) setFile:(JJFile *)file
{
    _file = file;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(showCellProgress:) userInfo:self repeats:YES];
    [self showCellProgress:_timer];
}


- (void) showCellProgress:(NSTimer *) timer
{
    //显示进度
    self.progressView.progress = (float)_file.writeBytesSize/(float)_file.allBytesSize;
    //设置状态
    self.downloadStateLabel.text = [self stateType:_file.downloadType];
    self.downloadSizeLabel.text = [NSString stringWithFormat:@"%.2f/%.2fMB",(_file.writeBytesSize/1024.0/1024.0),(_file.allBytesSize/1024.0/1024.0)];
    self.fileNameLabel.text = _file.urlStr.lastPathComponent;
    if ([self.downloadSizeLabel.text isEqualToString:JJDownloadSucceed]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (NSString *) stateType:(JJDownloadType) type
{
    NSString *state = @"";
    switch (type) {
        case JJDownloadTypeDefault:
            state = JJDownloadWillResume;
            break;
        case JJDownloadTypeResumed: //正在下载
            state = JJDownloadResumed;
            break;
        case JJDownloadTypeWillResume: //等待下载
            state = JJDownloadWillResume;
            break;
        case JJDownloadTypeSuspened: //暂停
            state = JJDownloadSuspened;
            break;
        case JJDownloadTypeSucceed: //下载成功
            state = JJDownloadSucceed;
            break;
        case JJDownloadTypeErrer:
            state = @"失败";
            break;
        default:
            break;
    }
    return state;
}


@end
