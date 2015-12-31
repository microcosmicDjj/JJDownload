//
//  NSString+JJDownload.m
//  JJDownload
//
//  Created by Mac on 15/12/26.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "NSString+JJDownloadMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (JJDownloadMD5)

//得到md5
- (NSString *)MD5
{
    const char *cstring = self.UTF8String;
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cstring, (CC_LONG)strlen(cstring), bytes);
    
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x", bytes[i]];
    }
    return md5String;
}

@end
