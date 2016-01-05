//
//  JJTableViewController.m
//  JJDownload
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJTableViewController.h"
#import "JJTableViewCell.h"
#import "JJDowloadManage.h"

@interface JJTableViewController () <JJDowloadManageDelegate>

@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, strong) JJDowloadManage *manage;

@end


@implementation JJTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.urls = [NSMutableArray array];
    //下载地址为本地，需要换成外网的才可使用
    for (int i = 1; i<=10; i++) {
        [self.urls addObject:[NSString stringWithFormat:@"http://120.25.226.186:32812/resources/videos/minion_%02d.mp4", i]];
    }
    _manage = [JJDowloadManage manage];
    //最大下载为2，默认为3
    _manage.maxDownloadingCount = 2;
    
    [_manage detectionSucceedDowload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _manage.dowloadManageDelegate = self;
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _manage.dowloadManageDelegate = nil;
}

- (void) dowloadSucceed:(JJFile *) file
{
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"JJTableViewCell";
    JJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    cell.urlStr = self.urls[indexPath.row];
    
    NSString *btnTitle = [self urlDowlodeState:[_manage urlDownloadState:cell.urlStr]];
    [cell.downloadBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    [cell.downloadBtn addTarget:self action:@selector(downloadBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSString *) urlDowlodeState:(JJUrlDownloadState) state
{
    NSString *stateStr = @"";
    switch (state) {
        case JJUrlDownloadStateDefault:
            stateStr = JJDownloadSateDefault;
            break;
        case JJUrlDownloadStateExist:
            stateStr = JJDownloadSateAddSucceed;
            break;
        case JJUrlDownloadStateSucceed:
            stateStr = JJDownloadSateDownloadSucceed;
            break;
        default:
            break;
    }
    return stateStr;
}

- (void) downloadBtn:(UIButton *) btn
{
    if ([btn.titleLabel.text isEqualToString:JJDownloadSateDefault]) {
        JJTableViewCell *cell = (JJTableViewCell *)btn.superview.superview;
    
        [_manage addUrls:cell.urlStr isDowmload:YES];
        [btn setTitle:JJDownloadSateAddSucceed forState:UIControlStateNormal];
    } else if ([btn.titleLabel.text isEqualToString:JJDownloadSateAddSucceed]) {
    
    } else if ([btn.titleLabel.text isEqualToString:JJDownloadSateDownloadSucceed]) {
        
    }
//    [NSRunLoop currentRunLoop] 
}

- (NSMutableArray *) urls
{
    if (!_urls) {
        _urls = [[NSMutableArray alloc] init];
    }
    return _urls;
}

@end
