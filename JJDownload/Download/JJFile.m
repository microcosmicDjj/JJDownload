//
//  JJFile.m
//  JJDownload
//
//  Created by Mac on 15/12/30.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJFile.h"
#import "NSString+JJDownloadMD5.h"
#import "JJDowloadFile.h"
#import "JJDowloadFilePath.h"

@interface JJFile() <JJDowloadFileDelegate>

@property (nonatomic, copy) NSString *createFile;
@property (nonatomic, strong) JJDowloadFile *dowloadFile;

@end

@implementation JJFile
- (instancetype)initWithUrlStr:(NSString *) urlStr
{
    self = [super init];
    if (self) {
        //得到下载路径
        _urlStr = urlStr;
        //创建文件夹
        _createFile = [self createDownloadFile];
        //得到文件路径
        _filePath = [self filePath];

        if (self.dowloadSucceed) {
            self.downloadType = JJDownloadTypeSucceed;
        } else {
            self.downloadType = JJDownloadTypeWillResume;
        }
    }
    return self;
}
//回调方法
- (void) dowloadFileType:(JJDownloadType) type
{
    self.downloadType = type;
    
    //添加到主线程运行，否则可能出现ui刷新的bug
    dispatch_queue_t queue=dispatch_get_main_queue();
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        if (weakSelf.block) {
            weakSelf.block(self);
        }
    });
    
    if (type == JJDownloadTypeSucceed) {
        dispatch_queue_t queue=dispatch_get_main_queue();
        __weak typeof(self) weakSelf = self;
        dispatch_async(queue, ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:JJdownloadSucceedKey object:weakSelf];
        });
    }
}

- (void) setFileBlock:(JJFileBlock) block
{
    _block = block;
}

/*
 * MARK:下载文件大小
 */
- (NSInteger) fileLength
{
    _fileLength = [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil][NSFileSize] integerValue];
    return _fileLength;
}

/*是否下载成功**/
- (BOOL) dowloadSucceed
{
    NSInteger totalLength = [self totalAllLength];
    NSInteger fileLength = [self fileLength];
    if (totalLength && totalLength == fileLength) {
        _dowloadSucceed = YES;
        //如果下载成功，设置为下载成功
        self.downloadType = JJDownloadTypeSucceed;
    } else {
        _dowloadSucceed = NO;
        //如果没有下载成功，设置为等待下载
        self.downloadType = JJDownloadTypeWillResume;
    }
    return _dowloadSucceed;
}

/*
 * MARK: 总大小
 */
- (NSInteger) totalAllLength
{
    NSDictionary *fileLength =[NSDictionary dictionaryWithContentsOfFile:[self totalLengthFullpath]];
    return [fileLength[_urlStr.MD5] integerValue];
}

/*
 * MARK:得到文件路径
 */
- (NSString *) filePath
{
    NSString *strMD5 = _urlStr.MD5;
    NSArray *postfixs = [_urlStr.lastPathComponent componentsSeparatedByString:@"."];
    NSString *postfix;
    if (postfixs) {
        postfix = postfixs.lastObject;
    }
    return [NSString stringWithFormat:@"%@/%@.%@",_createFile,strMD5,postfix];
}

/*
 * MARK:创建下载的文件夹
 */
- (NSString *) createDownloadFile
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *pathDocuments=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *createPath=[NSString stringWithFormat:@"%@/file",pathDocuments];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else {
    }
    return createPath;
}


//保存总大小
- (void) saveAllBytesSize:(NSInteger) allBytesSize
{
    _allBytesSize = allBytesSize;
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self totalLengthFullpath]];
    
    // 如果字典为空，创建一个字典
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    
    // 设置文件对应的文件长度
    dict[_urlStr.MD5] = @(_allBytesSize);
    
    // 将文件长度信息存入沙盒文件
    [dict writeToFile:[self totalLengthFullpath] atomically:YES];
}

//存储文件
- (NSString *) totalLengthFullpath
{
    NSString *totalLengthFullPath = [NSString stringWithFormat:@"%@/%@",_createFile,@"6666666.ZMJ"];
    return totalLengthFullPath;
}

//写入多少字节
- (NSInteger) writeBytesSize
{
    //写入多少字节
    _writeBytesSize = [self fileLength];
    return _writeBytesSize;
}

//总大小
- (NSInteger) allBytesSize
{
    //总大小
    _allBytesSize = [self totalAllLength];
    return _allBytesSize;
}

//
- (void) setDownloadType:(JJDownloadType) downloadType
{
    _downloadType = downloadType;
    
    //添加到主线程运行，否则可能出现ui刷新的bug
    dispatch_queue_t queue=dispatch_get_main_queue();
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue, ^{
        if (weakSelf.block) {
            weakSelf.block(self);
        }
    });
}

/*
 * MARK: 开启下载
 */
- (void) resume
{
    [self.dowloadFile resume];
    self.downloadType = JJDownloadTypeResumed;
    if (self.block) {
        self.block(self);
    }
}
/*
 * MARK: 暂停下载
 */
- (void) suspend
{
    [self.dowloadFile suspend];
    self.downloadType = JJDownloadTypeWillResume;
    if (self.block) {
        self.block(self);
    }
}

- (JJDowloadFile *) dowloadFile
{
    if (!_dowloadFile) {
        _dowloadFile = [[JJDowloadFile alloc] initWithFile:self];
        _dowloadFile.dowloadFileDelegate = self;
    }
    return _dowloadFile;
}

@end
