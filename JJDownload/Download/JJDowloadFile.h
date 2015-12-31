//
//  JJDowloadFile.h
//  JJDownload
//
//  Created by Mac on 15/12/30.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJFile.h"

@protocol JJDowloadFileDelegate <NSObject>
@optional
- (void) dowloadFileType:(JJDownloadType) type;

@end

@class JJFile;
@interface JJDowloadFile : NSObject

/*file对象**/
@property (nonatomic, strong) JJFile *file;

@property (nonatomic, weak) id<JJDowloadFileDelegate> dowloadFileDelegate;

- (instancetype)initWithFile:(JJFile *) file;
/*
 * MARK: 开启下载
 */
- (void) resume;
/*
 * MARK: 暂停下载
 */
- (void) suspend;
@end
