//
//  JJTableViewCell.h
//  JJDownload
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class JJDownload;
@interface JJTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (copy, nonatomic) NSString *urlStr;
//@property (strong, nonatomic) JJDownload *download;

@end
