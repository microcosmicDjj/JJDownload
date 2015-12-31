//
//  JJFile.h
//  JJDownload
//
//  Created by Mac on 15/12/30.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, JJDownloadType) {
    JJDownloadTypeDefault, //没有状态
    JJDownloadTypeResumed, //正在下载
    JJDownloadTypeWillResume,    //等待下载
    JJDownloadTypeSuspened, //暂停
    JJDownloadTypeSucceed, //成功
    JJDownloadTypeErrer //出错
};

typedef void(^JJFileBlock) (id file);
@interface JJFile : NSObject

/*一共有多少字节**/
@property (nonatomic) NSInteger allBytesSize;
/*写入了多少字节**/
@property (nonatomic) NSInteger writeBytesSize;
/*文件的地址**/
@property (nonatomic, copy) NSString *filePath;
/*下载的地址**/
@property (nonatomic, copy) NSString *urlStr;
/*下载状态**/
@property (nonatomic) JJDownloadType downloadType;
/*下载文件的大小**/
@property (nonatomic) NSInteger fileLength;
/*是否下载成功**/
@property (nonatomic) BOOL dowloadSucceed;
/*回调block**/
@property (nonatomic, strong) JJFileBlock block;

- (instancetype)initWithUrlStr:(NSString *) urlStr;

- (void) setFileBlock:(JJFileBlock) block;

/*
 * MARK:保存总大小
 */
- (void) saveAllBytesSize:(NSInteger) allBytesSize;
/*
 * MARK:下载文件大小
 */
- (NSInteger) fileLength;
/*
 * MARK: 开启下载
 */
- (void) resume;
/*
 * MARK: 暂停下载
 */
- (void) suspend;

@end
