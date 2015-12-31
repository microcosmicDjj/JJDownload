//
//  JJDetailsTableViewCell.h
//  JJDownload
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJFile.h"
@interface JJDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadSizeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView  *progressView;

@property (strong, nonatomic) JJFile *file;

@end
