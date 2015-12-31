//
//  JJDowloadFile.m
//  JJDownload
//
//  Created by Mac on 15/12/30.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJDowloadFile.h"
#import "NSString+JJDownloadMD5.h"
#import "JJFile.h"

@interface JJDowloadFile () <NSURLSessionDelegate>

/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *task;
/** session */
@property (nonatomic, strong) NSURLSession *session;
/** 写文件的流对象 */
@property (nonatomic, strong) NSOutputStream *stream;
/**nsurl 文件的url*/
@property (nonatomic, strong) NSURL *url;

@end

@implementation JJDowloadFile

- (instancetype)initWithFile:(JJFile *) file;
{
    self = [super init];
    if (self) {
        
        _file = file;
        //文件的url
        _url = [NSURL URLWithString:file.urlStr];
        
    }
    return self;
}

/*
 * MARK: 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 打开流
    [self.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger allBytesSize = [response.allHeaderFields[@"Content-Length"] integerValue] + [_file fileLength];
    //存储总大小
    [_file saveAllBytesSize:allBytesSize];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
    if ([self.dowloadFileDelegate respondsToSelector:@selector(dowloadFileType:)]) {
        [self.dowloadFileDelegate dowloadFileType:JJDownloadTypeResumed];
    }
}

// 接收到服务器返回的数据,写入磁盘
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 写入数据
    [self.stream write:data.bytes maxLength:data.length];
    
    //记录写入量
    _file.writeBytesSize = [_file fileLength];
    
    _file.downloadType = JJDownloadTypeResumed;
    
    if ([self.dowloadFileDelegate respondsToSelector:@selector(dowloadFileType:)]) {
        [self.dowloadFileDelegate dowloadFileType:JJDownloadTypeResumed];
    }
}

// 请求完毕
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error){
        NSLog(@"网络出错，或者其它原因 %@",error.localizedDescription);
    }
    
    _file.writeBytesSize = [_file fileLength];
    
    if (_file.dowloadSucceed) {
        if ([self.dowloadFileDelegate respondsToSelector:@selector(dowloadFileType:)]) {
            [self.dowloadFileDelegate dowloadFileType:JJDownloadTypeSucceed];
        }
    } else {
        if ([self.dowloadFileDelegate respondsToSelector:@selector(dowloadFileType:)]) {
            [self.dowloadFileDelegate dowloadFileType:JJDownloadTypeErrer];
        }
    }
    
    // 关闭流
    [self.stream close];
    self.stream = nil;
    
    // 清除任务
    self.task = nil;
}

/*
 * MARK: 开启下载
 */
- (void) resume
{
    _file.downloadType = JJDownloadTypeResumed;
    [self.task resume];
    if ([self.dowloadFileDelegate respondsToSelector:@selector(dowloadFileType:)]) {
        [self.dowloadFileDelegate dowloadFileType:JJDownloadTypeResumed];
    }
}
/*
 * MARK: 暂停下载
 */
- (void) suspend
{
    _file.downloadType = JJDownloadTypeSuspened;
    [self.task suspend];
    if ([self.dowloadFileDelegate respondsToSelector:@selector(dowloadFileType:)]) {
        [self.dowloadFileDelegate dowloadFileType:JJDownloadTypeSuspened];
    }
}

/*
 * MARK: 懒加载
 */
- (NSURLSession *)session
{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:_file.filePath append:YES];
    }
    return _stream;
}

- (NSURLSessionDataTask *)task
{
    if (!_task) {
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
        
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", _file.fileLength];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        _task = [self.session dataTaskWithRequest:request];
    }
    return _task;
}


@end
