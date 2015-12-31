//
//  JJDownloadSucceedTableViewController.m
//  JJDownload
//
//  Created by Mac on 15/12/30.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJDownloadSucceedTableViewController.h"
#import "JJDowloadManage.h"
#import "JJSucceedTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>

@interface JJDownloadSucceedTableViewController () <JJDowloadManageDelegate>

@property (nonatomic, strong) JJDowloadManage *manage;

@end

@implementation JJDownloadSucceedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _manage = [JJDowloadManage manage];
    self.title = @"下载完成";
    NSLog(@"[_manage succeeds].count %ld",(long)[_manage succeeds].count);
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


//下载成功的回调
- (void) dowloadSucceed:(JJFile *) file
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCellEditingStyle result = UITableViewCellEditingStyleDelete;
    return result;
}


-(void)setEditing:(BOOL)editing animated:(BOOL)animated{//设置是否显示一个可编辑视图的视图控制器。
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];//切换接收者的进入和退出编辑模式。
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{//请求数据源提交的插入或删除指定行接收者。
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        JJSucceedTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [_manage deleteUrlStr:cell.urlStr];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_manage succeeds].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JJSucceedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJSucceedTableViewCell"];

    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"JJSucceedTableViewCell" owner:self options:nil].lastObject;
    }

    JJFile *download = [_manage succeeds][indexPath.row];
    cell.urlStr = download.urlStr;
    cell.filePath = download.filePath;

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJSucceedTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSURL *url = [NSURL fileURLWithPath:cell.filePath];
    
    MPMoviePlayerViewController *playerViewController =
    [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    playerViewController.moviePlayer.scalingMode=MPMovieScalingModeAspectFit;//窗口模式设置
    playerViewController.moviePlayer.controlStyle=MPMovieControlStyleFullscreen;//一共有四种，
    [self presentMoviePlayerViewControllerAnimated:playerViewController];
}

@end
