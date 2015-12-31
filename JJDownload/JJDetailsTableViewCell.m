//
//  JJDetailsTableViewCell.m
//  JJDownload
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJDetailsTableViewCell.h"
#import "JJFile.h"

@implementation JJDetailsTableViewCell


- (void) setFile:(JJFile *)file
{
    _file = file;
    
    __weak typeof(self) weakSelf = self;
    [_file setFileBlock:^(id file) {
        [weakSelf showCellProgress:file];
    }];
    [self showCellProgress:file];
}


- (void) showCellProgress:(JJFile *) file
{
    //显示进度
    self.progressView.progress = (float)file.writeBytesSize/(float)file.allBytesSize;
    //设置状态
    self.downloadStateLabel.text = [self stateType:file.downloadType];
//    NSLog(@"JJDownloadTypeResumed = %d",file.downloadType);
    self.downloadSizeLabel.text = [NSString stringWithFormat:@"%.2f/%.2fMB",(file.writeBytesSize/1024.0/1024.0),(file.allBytesSize/1024.0/1024.0)];
    self.fileNameLabel.text = file.urlStr.lastPathComponent;
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
