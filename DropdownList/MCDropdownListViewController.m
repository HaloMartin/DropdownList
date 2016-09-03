//
//  MCDropdownListViewController.m
//  DropdownList
//
//  Created by 朱进林 on 9/3/16.
//  Copyright © 2016 Martin Choo. All rights reserved.
//

#import "MCDropdownListViewController.h"

#define HeightForHeader 40
#define HeightForCell 50

//自定义一个类型，用于表示列表的展开／缩回状态
typedef NS_ENUM(NSUInteger,MCDropdownListSectionStatu) {
    MCDropdownListSectionStatuOpen = 1,
    MCDropdownListSectionStatuClose = 0,
};

@interface MCDropdownListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView* _tableV;//列表
    NSDictionary* _sectionDetailDict;//分组详细信息，key为当前分组头信息，必须是唯一的；value为数组，包含分组下的信息
    NSMutableDictionary* _sectionOpenDict;//分组展开／缩回信息
    NSArray* _sectionOrderArray;//分组顺序信息，包含分组顺序信息
}

@end

@implementation MCDropdownListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    const CGFloat screenWidth = self.view.bounds.size.width;
    const CGFloat screenHeight = self.view.bounds.size.height;
    //Table
    UITableView* table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStyleGrouped];
    table.dataSource = self;
    table.delegate = self;
    _tableV = table;
    [self.view addSubview:table];
    
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    //获取数据，这里我直接把数组写死，可以在这里自定义，如果获取过程缓慢，可以使用GCD异步获取
    {
        NSDictionary* dict = @{@"单姓":@[@"赵",@"钱",@"孙",@"李",@"王"]
                               ,@"复姓":@[@"欧阳",@"慕容",@"司马",@"长孙",@"令狐",@"尉迟",@"太史",@"南宫"]
                               ,@"三字姓":@[@"东关正",@"颜莫己"]};
        _sectionDetailDict = dict;
        //默认展开列表
        NSMutableDictionary* openOrNotDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithUnsignedInteger: MCDropdownListSectionStatuOpen],@"单姓",
                                              [NSNumber numberWithUnsignedInteger:MCDropdownListSectionStatuOpen],@"复姓",
                                              [NSNumber numberWithUnsignedInteger:MCDropdownListSectionStatuOpen],@"三字姓",
                                              nil];
        _sectionOpenDict = openOrNotDict;
        //分组顺序信息
        _sectionOrderArray = @[@"单姓",@"复姓",@"三字姓"];
        //排序
        [_sectionOrderArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 intValue] > [obj2 intValue]) {
                return NSOrderedDescending;
            }
            if ([obj1 intValue] < [obj2 intValue]) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
    }
    //刷新
    [_tableV reloadData];
}

#pragma mark - action
-(void)onExpandSection:(UIButton*)button
{
    //获取分组信息
    NSString* section = [_sectionOrderArray objectAtIndex:button.tag];
    //获取分组展开／缩回的状态
    MCDropdownListSectionStatu openOrNot = [[_sectionOpenDict objectForKey:section] unsignedIntegerValue];
    if (MCDropdownListSectionStatuClose == openOrNot) {
        NSLog(@"点击事件，展开分组：%@",section);
        //原先是缩回的，现在展开
        [_sectionOpenDict setObject:[NSNumber numberWithUnsignedInteger:MCDropdownListSectionStatuOpen] forKey:section];
    }else {
        NSLog(@"点击事件，缩回分组：%@",section);
        //原先是展开的，现在缩回
        [_sectionOpenDict setObject:[NSNumber numberWithUnsignedInteger:MCDropdownListSectionStatuClose] forKey:section];
    }
    //刷新列表，展示结果（刷新单独的section会有卡顿的情况，我这直接改用刷新整个列表）
//    [_tableV reloadSections:[NSIndexSet indexSetWithIndex:button.tag] withRowAnimation:UITableViewRowAnimationNone];
    [_tableV reloadData];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //因为section顺序信息会被用在header中， 使用_sectionOrderArray保持一致，易于阅读
    return _sectionOrderArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //先取section信息
    NSNumber* key = [_sectionOrderArray objectAtIndex:section];
    //再取section的展开／缩回状态,展开时，返回实际的分组数量；缩回时，返回0，以实现不展开
    MCDropdownListSectionStatu openOrNot = [[_sectionOpenDict objectForKey:key] unsignedIntegerValue];
    if (openOrNot == MCDropdownListSectionStatuOpen) {
        //列表展开，取分组实际数量，并返回
        NSArray* arr = [_sectionDetailDict objectForKey:key];
        return arr.count;
    }
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"cell";
    UITableViewCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //
    cell.textLabel.text =[[_sectionDetailDict objectForKey:[_sectionOrderArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    //
    return cell;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = nil;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HeightForHeader)];
    UIButton* btn = [[UIButton alloc] initWithFrame:headerView.frame];
    [headerView addSubview:btn];
    //分组名
    UILabel* sectionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, (btn.bounds.size.width-10)*2/3, btn.bounds.size.height)];
    sectionNameLabel.text = [_sectionOrderArray objectAtIndex:section];
    [btn addSubview:sectionNameLabel];
    //分组下Cell的数量
    UILabel* qtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (btn.bounds.size.width-10)/3, btn.bounds.size.height)];
    qtyLabel.center = CGPointMake(tableView.bounds.size.width-10-qtyLabel.bounds.size.width/2, btn.bounds.size.height/2);
    qtyLabel.text = [NSString stringWithFormat:@"%d个",(int)[[_sectionDetailDict objectForKey:[_sectionOrderArray objectAtIndex:section]] count]];
    qtyLabel.textAlignment = NSTextAlignmentRight;
    [btn addSubview:qtyLabel];
    //添加点击处理
    [btn addTarget:self action:@selector(onExpandSection:) forControlEvents:UIControlEventTouchUpInside];
    //标记，用于处理点击事件
    btn.tag = section;
    //
    return headerView;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 5)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //点击，输出选中信息
    NSLog(@"UITableViewDelegate indexPath.row = %d,indexPath.section = %d, Section Name:%@, Cell:%@",(int)indexPath.row,(int)indexPath.section,[_sectionOrderArray objectAtIndex:indexPath.section], [[_sectionDetailDict objectForKey:[_sectionOrderArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]);
//    //这部分有bug，每次刷新section后，选中的项会变化，需要添加一个成员，用于记忆选中的信息
//    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
//    if (UITableViewCellAccessoryCheckmark == cell.accessoryType) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }else {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HeightForCell+15;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HeightForHeader;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
@end
