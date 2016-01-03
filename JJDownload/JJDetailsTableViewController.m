//
//  JJDetailsTableViewController.m
//  JJDownload
//
//  Created by Mac on 15/12/28.
//  Copyright © 2015年 DJJ. All rights reserved.
//

#import "JJDetailsTableViewController.h"
#import "JJDetailsTableViewCell.h"
#import "JJDownloadSucceedTableViewController.h"
#import "UIActionSheet+Blocks.h"
#import "JJDowloadManage.h"

@interface  JJDetailsTableViewController () <JJDowloadManageDelegate>

@property (nonatomic, strong) JJDowloadManage *manage;

@end

@implementation JJDetailsTableViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    _manage = [JJDowloadManage manage];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_manage willResumes].count;
}

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
        JJDetailsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [_manage deleteUrlStr:cell.file.urlStr];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellStr = @"JJDetailsTableViewCell";
    JJDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];

    JJFile *file = [_manage willResumes][indexPath.row];
    cell.file = file;

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JJDetailsTableViewCell *cell = (JJDetailsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.file.downloadType != JJDownloadTypeResumed) {
        [_manage succeedUrlStr:cell.file.urlStr];
    } else {
        [_manage suspendUrlStr:cell.file.urlStr];
    }
}

- (IBAction)menuItem:(id)sender {
    RIButtonItem *downloadSucceItem = [RIButtonItem itemWithLabel:@"下载完成" action:^{
        JJDownloadSucceedTableViewController *dowloadSucceed =  [[JJDownloadSucceedTableViewController alloc] init];
        [self.navigationController pushViewController:dowloadSucceed animated:YES];
    }];
    
    RIButtonItem *allSuspendItem = [RIButtonItem itemWithLabel:@"全部停止" action:^{
        [_manage suspendAllDowlad];
    }];
    
    RIButtonItem *allResumeItem = [RIButtonItem itemWithLabel:@"全部下载" action:^{
        [_manage resumeAllDowload];
    }];
    
    RIButtonItem *canceItem = [RIButtonItem itemWithLabel:@"取消"];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" cancelButtonItem:canceItem destructiveButtonItem:nil otherButtonItems:allResumeItem,allSuspendItem,downloadSucceItem, nil];
    [sheet showInView:self.view];
}

@end
