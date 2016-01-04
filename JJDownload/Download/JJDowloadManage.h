//
//  JJDowloadManage.h
//  JJDownload
//
//  Created by Mac on 15/12/30.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJFile.h"

@protocol JJDowloadManageDelegate <NSObject>
@optional
- (void) dowloadSucceed:(JJFile *) file;
@end

typedef NS_ENUM(NSInteger, JJUrlDownloadState) {
    JJUrlDownloadStateDefault, //没有下载
    JJUrlDownloadStateExist, //已经在下载列表
    JJUrlDownloadStateSucceed //下载成功
};

@interface JJDowloadManage : NSObject
/*全部下载的**/
@property (nonatomic, strong) NSMutableArray *allDowloads;
/*最大下载数**/
@property (nonatomic) NSInteger maxDownloadingCount;
/*代理**/
@property (nonatomic, weak) id<JJDowloadManageDelegate> dowloadManageDelegate;

+ (instancetype) manage;

//MARK: 开始
- (void) succeedUrlStr:(NSString *) urlStr;
//MARK: 暂停
- (void) suspendUrlStr:(NSString *) urlStr;
//MARK: 连接状态
- (JJUrlDownloadState) urlDownloadState:(NSString *) urlStr;

//MARK: 添加一个下载路径
- (void) addUrls:(NSString *)urlStr isDowmload:(BOOL) isDowmload;
//MARK: 开启全部下载
- (void) resumeAllDowload;
//MARK: 全部暂停
- (void) suspendAllDowlad;
//MARK: 删除一个下载
- (void) deleteUrlStr:(NSString *) urlStr;

//MARK: 下载成功的数组
- (NSArray *) succeeds;
//MARK: 没有下载完成的数组
- (NSArray *) willResumes;
//MAEK: 是否还在下载
- (BOOL) isSucceedDowload;

@end
