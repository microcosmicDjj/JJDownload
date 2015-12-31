//
//  JJDowloadFilePath.m
//  JJDownload
//
//  Created by Mac on 15/12/30.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJDowloadFilePath.h"
#import "NSString+JJDownloadMD5.h"

@implementation JJDowloadFilePath

/*
 * MARK: 创建下载的文件夹
 */
+ (NSString *) createDownloadFile
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

/*
 * MARK:文件大小
 */
+ (NSString *) totalLengthFullpath
{
    NSString *totalLengthFullPath = [NSString stringWithFormat:@"%@/%@.ZMJ",self.createDownloadFile,@"6666666"];
    return totalLengthFullPath;
}

/*
 * MARK:存储文件路径
 */
+ (NSString *) filePathUrl:(NSString *) urlStr
{
    NSString *strMD5 = urlStr.MD5;
    NSArray *postfixs = [urlStr.lastPathComponent componentsSeparatedByString:@"."];
    NSString *postfix;
    if (postfixs) {
        postfix = postfixs.lastObject;
    }
    return [NSString stringWithFormat:@"%@/%@.%@",[self createDownloadFile],strMD5,postfix];
}
//
/*
 * MARK:下载文件大小
 */
+ (NSInteger) fileLength:(NSString *) urlStr
{
    NSLog(@"NSFileManager = %d",[[[NSFileManager defaultManager] attributesOfItemAtPath:[self filePathUrl:urlStr] error:nil][NSFileSize] integerValue]);
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:[self filePathUrl:urlStr] error:nil][NSFileSize] integerValue];
}

/*
 * MARK:是否下载完成
 */
+ (BOOL) dowloadSucceedUrlStr:(NSString *) urlStr
{
    NSInteger totalLength = [[NSDictionary dictionaryWithContentsOfFile:[self totalLengthFullpath]][urlStr.MD5] integerValue];
    NSInteger fileLength = [self fileLength:urlStr];
    if (totalLength && totalLength == fileLength) {
        return YES;
    }
    return NO;
}


@end
