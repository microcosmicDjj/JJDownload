//
//  JJDowloadManage.m
//  JJDownload
//
//  Created by Mac on 15/12/30.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJDowloadManage.h"
#import "JJFile.h"
#import "JJDowloadFilePath.h"
#import "UIAlertView+Blocks.h"

@interface JJDowloadManage()

@property (nonatomic, strong) NSMutableArray *urls;

@end

static JJDowloadManage *G_Manage;
@implementation JJDowloadManage

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype) manage
{
    @synchronized(self) {
        if (!G_Manage) {
            G_Manage = [[JJDowloadManage alloc] init];
        }
    }
    return G_Manage;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxDownloadingCount = 3;
        
        //接受通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSucceed:) name:JJdownloadSucceedKey object:nil];
        
        NSArray *urls = [self inquireData:JJDownloadUrlKey];
        
        BOOL isDowload = NO;
        for (NSString *urlStr in urls) {
            if (![JJDowloadFilePath dowloadSucceedUrlStr:urlStr]) {
                isDowload = YES;
            }
        }
        
        for (NSString *urlStr in urls) {
            [self addUrls:urlStr isDowmload:YES];
        }
        if (isDowload == YES) {
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"取消" action:^{

            }];
            RIButtonItem *dowloadItem = [RIButtonItem itemWithLabel:@"继续下载" action:^{
                for (NSString *urlStr in urls) {
                    [self addUrls:urlStr isDowmload:YES];
                }
            }];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"还有未下载完成的，是否继续" message:nil cancelButtonItem:cancelItem otherButtonItems:dowloadItem, nil];
            [alertView show];
        }
    }
    return self;
}

- (void) downloadSucceed:(NSNotification *) obj
{
    [self resumeAllDowload];
    JJFile *file = [obj object];
    
    if ([self.dowloadManageDelegate respondsToSelector:@selector(dowloadSucceed:)]) {
        [self.dowloadManageDelegate dowloadSucceed:file];
    }
}

- (void) addUrls:(NSString *)urlStr isDowmload:(BOOL) isDowmload
{
    //确保没有重复添加
    for (NSString *url in self.urls) {
        if ([urlStr isEqualToString:url]) {
            return;
        }
    }
    
    [self.urls addObject:urlStr];
    [self addUserData:self.urls forKey:JJDownloadUrlKey];
    JJFile *file = [[JJFile alloc] initWithUrlStr:urlStr];
    [self.allDowloads addObject:file];
    if (isDowmload) {
        [self resumeAllDowload];
    }
}
/*全部下载**/
- (void) resumeAllDowload
{
    //正在下载的数组
    NSArray *resumes = [self resumes];
    
    NSInteger numberDowload = _maxDownloadingCount - resumes.count;
    
    NSArray *awaits = [self waits];
    
    if (numberDowload) {
        if (awaits.count >=numberDowload){//如果小于waits.count
            for (int i=0;i<numberDowload; i++) {
                JJFile *file = awaits[i];
                [file resume];
            }
        } else {
            for (int i=0;i<awaits.count; i++) {//如果大于waits.count
                JJFile *file = awaits[i];
                [file resume];
            }
        }
    }
}

//点击一个开始
- (void) succeedUrlStr:(NSString *) urlStr
{
    //从没有下载的数组里面查，如果没有就说明正在下载不必理会
    NSArray *willResumes = [self willResumes];
    
    NSArray *resumes = [self resumes];
    NSInteger difference = (resumes.count - _maxDownloadingCount)+1;
    
    if (difference){
        for (int i=0;i<difference; i++) {
            JJFile *resumeFile = resumes[i];
            [resumeFile suspend];
        }
    }
    
    JJFile *file = [willResumes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"urlStr==%@",urlStr]].lastObject;
    if (file) {
        [file resume];
    }
}
//MARK: 全部暂停
- (void) suspendAllDowlad
{
    NSArray *resumes = [self resumes];
    
    for (JJFile *file in resumes) {
        [file suspend];
    }

}

//MARK: 点击一个暂停
- (void) suspendUrlStr:(NSString *) urlStr
{
    JJFile *file = [self.allDowloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"urlStr==%@",urlStr]].lastObject;
    if (file) {
        [file suspend];
        //设置为暂停
        file.downloadType = JJDownloadTypeSuspened;
    }
}

//连接状态
- (JJUrlDownloadState) urlDownloadState:(NSString *) urlStr
{
    JJUrlDownloadState state = JJUrlDownloadStateDefault;
    
    NSArray *file = [self.allDowloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"urlStr==%@",urlStr]];
    if (file.count > 0) {
        state = JJUrlDownloadStateExist;
    }
    if ([JJDowloadFilePath dowloadSucceedUrlStr:urlStr]) {
        state =  JJUrlDownloadStateSucceed;
    }
    return state;
}

/*
 *MARK: 持久化存储
 */
- (void) addUserData:(id) object forKey:(NSString *) key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    
}
- (id) inquireData:(NSString *) key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id data = [defaults objectForKey:key];
    return data;
}

//MARK: 下载成功的数组
- (NSArray *) succeeds
{
    NSArray *succeeds = [self.allDowloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloadType==%d",JJDownloadTypeSucceed]];
    return succeeds;
}
//MARK: 没有下载完成的数组
- (NSArray *) willResumes
{
    NSArray *willResumes = [self.allDowloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloadType!=%d",JJDownloadTypeSucceed]];
    return willResumes;
}

//MARK: 正在下载的数组
- (NSArray *) resumes
{
    NSArray *resumes = [self.allDowloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloadType==%d && downloadType!=%d",JJDownloadTypeResumed,JJDownloadTypeSucceed]];
    
    return resumes;
}
//MARK: 不在下载的数组
- (NSArray *) waits
{
    NSArray *waits = [self.allDowloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloadType!=%d && downloadType!=%d && downloadType!=%d",JJDownloadTypeResumed,JJDownloadTypeSucceed,JJDownloadTypeSuspened]];
    return waits;
}

- (void) deleteUrlStr:(NSString *) urlStr
{
    JJFile *file = [self.allDowloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"urlStr==%@",urlStr]].lastObject;
    if (file) {
        [self.allDowloads removeObject:file];
        [self.urls removeObject:file.urlStr];
        [self addUserData:self.urls forKey:JJDownloadUrlKey];
        
        //删除文件
        NSFileManager *defaultManager;
        defaultManager = [NSFileManager defaultManager];
        [defaultManager removeItemAtPath:file.filePath error:nil];
        
        file = nil;
        
        [self resumeAllDowload];
    }
}

//MAEK: 是否还在下载
- (BOOL) isSucceedDowload
{
    NSArray *succeeds = [self resumes];
    if (succeeds.count > 0) {
        return YES;
    }
    return NO;
}

/*
 * MARK: 懒加载
 */
- (NSMutableArray *) urls
{
    if (!_urls) {
        _urls = [[NSMutableArray alloc] init];
    }
    return _urls;
}

- (NSMutableArray *) allDowloads
{
    if (!_allDowloads) {
        _allDowloads = [[NSMutableArray alloc] init];
    }
    return _allDowloads;
}


@end
