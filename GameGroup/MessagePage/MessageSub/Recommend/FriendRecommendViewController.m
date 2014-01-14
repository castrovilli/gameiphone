//
//  FriendRecommendViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-31.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "FriendRecommendViewController.h"
#import "AddContactViewController.h"
#import "DSRecommendList.h"
#import "AppDelegate.h"
#import "PersonDetailViewController.h"

@interface FriendRecommendViewController ()
{
    UITableView*   m_myTableView;
    
    NSMutableArray*       m_tableData;
    NSInteger      m_pageIndex;
    
    PullUpRefreshView      *refreshView;
}
@end

@implementation FriendRecommendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTopViewWithTitle:@"好友推荐" withBackButton:YES];
    
    m_tableData = [[NSMutableArray alloc] initWithCapacity:1];
    
    m_pageIndex = 0;
    
    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame=CGRectMake(270, startX - 44, 50, 44);
    [addButton setBackgroundImage:KUIImage(@"add_button_normal") forState:UIControlStateNormal];
    [addButton setBackgroundImage:KUIImage(@"add_button_click") forState:UIControlStateHighlighted];
    [self.view addSubview:addButton];
    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    refreshView = [[PullUpRefreshView alloc] initWithFrame:CGRectMake(0, kScreenHeigth - startX-(KISHighVersion_7?0:20), 320, REFRESH_HEADER_HEIGHT)];//上拉加载
    [m_myTableView addSubview:refreshView];
    refreshView.pullUpDelegate = self;
    refreshView.myScrollView = m_myTableView;
    [refreshView stopLoading:NO];
    
    [self getDataByStore];
}

- (void)getDataByStore
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * dRecommend = [DSRecommendList MR_findAllInContext:localContext];
        for (DSRecommendList* Recommend in dRecommend) {
            NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:Recommend.headImgID, @"headImgID", Recommend.nickName, @"nickname", Recommend.userName, @"username", Recommend.state, @"state", Recommend.fromID, @"type", Recommend.fromStr,@"dis",nil];
//            [m_tableData addObject:tempDic];
            [m_tableData insertObject:tempDic atIndex:0];
        }
        m_pageIndex = [m_tableData count] > 20?20:[m_tableData count];
        [m_myTableView reloadData];
        [refreshView setRefreshViewFrame];
    }];
}

#pragma mark -添加好友
- (void)addButtonClick:(id)sender
{
    AddContactViewController * addV = [[AddContactViewController alloc] init];
    [self.navigationController pushViewController:addV animated:YES];
}

#pragma mark 表格
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_tableData count] < 20 ? [m_tableData count] : m_pageIndex;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCharacter";
    RecommendCell *cell = (RecommendCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[RecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary* tempDic = [m_tableData objectAtIndex:indexPath.row];
    cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];

    NSURL * theUrl = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@",[GameCommon getHeardImgId:KISDictionaryHaveKey(tempDic, @"headImgID")]]];
    cell.headImageV.imageURL = theUrl;
    
    cell.nameLabel.text = KISDictionaryHaveKey(tempDic, @"nickname");
    
    if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"1"]) {
        cell.fromImage.image = KUIImage(@"recommend_phone");
    }
    else if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"2"]) {
        cell.fromImage.image = KUIImage(@"recommend_star");
    }
    else  {
        cell.fromImage.image = KUIImage(@"recommend_wow");
    }
    
    cell.fromLabel.text = KISDictionaryHaveKey(tempDic, @"dis");
    
    if ([KISDictionaryHaveKey(tempDic, @"state") isEqualToString:@"0"]) {
        cell.statusButton.backgroundColor = kColorWithRGB(51, 164, 31, 1.0);
        [cell.statusButton setTitle:@"添加" forState:UIControlStateNormal];
        [cell.statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        cell.statusButton.backgroundColor = [UIColor clearColor];
        [cell.statusButton setTitle:@"已添加" forState:UIControlStateNormal];
        [cell.statusButton setTitleColor:kColorWithRGB(102, 102, 102, 1.0) forState:UIControlStateNormal];
    }
    cell.myDelegate = self;
    cell.myIndexPath = indexPath;
    
    return cell;
}

- (void)cellHeardImgClick:(RecommendCell*)myCell
{
    NSDictionary* tempDict = [m_tableData objectAtIndex:myCell.myIndexPath.row];

    PersonDetailViewController* detailV = [[PersonDetailViewController alloc] init];
    detailV.userName = KISDictionaryHaveKey(tempDict, @"username");
    detailV.nickName = KISDictionaryHaveKey(tempDict, @"nickname");
    detailV.isChatPage = NO;
    [self.navigationController pushViewController:detailV animated:YES];
}

- (void)cellAddButtonClick:(RecommendCell*)myCell
{
    NSInteger row = myCell.myIndexPath.row;
    NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [tempDic addEntriesFromDictionary:[m_tableData objectAtIndex:row]];
    
    if ([DataStoreManager ifHaveThisFriend:KISDictionaryHaveKey(tempDic, @"username")]) {
        [self showAlertViewWithTitle:@"提示" message:@"您们已是朋友关系，不能重复添加！" buttonTitle:@"确定"];
        [tempDic setObject:@"1" forKey:@"state"];
        [m_tableData replaceObjectAtIndex:row withObject:tempDic];
        [DataStoreManager updateRecommendStatus:@"1" ForPerson:KISDictionaryHaveKey(tempDic, @"username")];
        [m_myTableView reloadData];
        return;
    }
    if ([DataStoreManager ifIsAttentionWithUserName:KISDictionaryHaveKey(tempDic, @"username")]) {
        [self showAlertViewWithTitle:@"提示" message:@"您已关注过了，不能重复添加！" buttonTitle:@"确定"];
        [tempDic setObject:@"1" forKey:@"state"];
        [m_tableData replaceObjectAtIndex:row withObject:tempDic];
        [DataStoreManager updateRecommendStatus:@"1" ForPerson:KISDictionaryHaveKey(tempDic, @"username")];
        [m_myTableView reloadData];
        return;
    }
    AppDelegate* appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDel.xmppHelper addFriend:KISDictionaryHaveKey(tempDic, @"username")];//添加好友请求
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];

    [body setStringValue:[NSString stringWithFormat:@"%@关注了您，回复任意字符即可成为朋友",[DataStoreManager queryNickNameForUser:[SFHFKeychainUtils getPasswordForUsername:ACCOUNT andServiceName:LOCALACCOUNT error:nil]]]];
    
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //   [mes addAttributeWithName:@"nickname" stringValue:@"aaaa"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:[KISDictionaryHaveKey(tempDic, @"username") stringByAppendingString:[[TempData sharedInstance] getDomain]]];
    
    //   NSLog(@"chatWithUser:%@",chatWithUser);
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:[[SFHFKeychainUtils getPasswordForUsername:ACCOUNT andServiceName:LOCALACCOUNT error:nil] stringByAppendingString:[[TempData sharedInstance] getDomain]]];
    
    [mes addAttributeWithName:@"img" stringValue:[GameCommon getHeardImgId:KISDictionaryHaveKey(tempDic, @"img")]];
    [mes addAttributeWithName:@"nickname" stringValue:[KISDictionaryHaveKey(tempDic, @"alias")isEqualToString:@""] ? KISDictionaryHaveKey(tempDic, @"nickname") : KISDictionaryHaveKey(tempDic, @"alias")];
    
    [mes addAttributeWithName:@"msgtype" stringValue:@"normalchat"];
    [mes addAttributeWithName:@"fileType" stringValue:@"text"];  //如果发送图片音频改这里
    [mes addAttributeWithName:@"msgTime" stringValue:[GameCommon getCurrentTime]];//时间
    [mes addChild:body];
    
    if (![appDel.xmppHelper sendMessage:mes]) {
        [KGStatusBar showSuccessWithStatus:@"网络有点问题，稍后再试吧" Controller:self];
        return;
    }
    [DataStoreManager updateRecommendStatus:@"1" ForPerson:KISDictionaryHaveKey(tempDic, @"username")];
    [DataStoreManager saveUserAttentionInfo:tempDic];
    
    [tempDic setObject:@"1" forKey:@"state"];
    [m_tableData replaceObjectAtIndex:row withObject:tempDic];
    [m_myTableView reloadData];
}
#pragma mark  scrollView  delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (m_myTableView.contentSize.height < m_myTableView.frame.size.height) {
        refreshView.viewMaxY = 0;
    }
    else
        refreshView.viewMaxY = m_myTableView.contentSize.height - m_myTableView.frame.size.height;
    [refreshView viewdidScroll:scrollView];
}

#pragma mark pull up refresh
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == m_myTableView)
    {
        [refreshView viewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == m_myTableView)
    {
        [refreshView didEndDragging:scrollView];
    }
}

- (void)PullUpStartRefresh
{
    NSLog(@"start");
  
    m_pageIndex += ([m_tableData count] - m_pageIndex) < 20 ? ([m_tableData count] - m_pageIndex) : 20;
    [m_myTableView reloadData];
    [refreshView setRefreshViewFrame];
    [refreshView stopLoading:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
