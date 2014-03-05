//
//  CharacterDetailsViewController.m
//  GameGroup
//
//  Created by admin on 14-2-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CharacterDetailsViewController.h"
#import "CharaInfo.h"
#import "CharacterDetailsView.h"
#import "CharaDaCell.h"
#import "RankingViewController.h"

@interface CharacterDetailsViewController ()

@end

@implementation CharacterDetailsViewController
{
    UITableView          * m_contentTableView;
    UITableView          * m_reamlTableView;
    UITableView          * m_countryTableView;
    CharaInfo            * m_charaInfo;
    CharacterDetailsView * m_charaDetailsView;
    NSMutableArray       * titleImageArray;
    NSArray              * titleArray;
    NSInteger              m_pageNum;
    float startX;
    NSString           *m_serverStr;//储存服务器名称
    NSString           *m_characterId;
    NSString           *m_zhiyeId;
    BOOL            isInTheQueue;//获取刷新数据队列中
    
    BOOL            isGoToNextPage;
    
    UIActivityIndicatorView   *loginActivity;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isInTheQueue =NO;
    isGoToNextPage = YES;
    [self getUserInfoByNet];
    
    
    UIImageView* topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, KISHighVersion_7 ? 64 : 44)];
    topImageView.image = KUIImage(@"nav_bg");
    topImageView.userInteractionEnabled = YES;
    topImageView.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
    [self.view addSubview:topImageView];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTopViewClick:)];
    tapGesture.delegate = self;
    [topImageView addGestureRecognizer:tapGesture];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"角色详情";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:titleLabel];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, KISHighVersion_7 ? 27 : 7, 37, 30)];
    [backButton setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
    [backButton setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    
    // [self setTopViewWithTitle:@"角色详情" withBackButton:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
    
    startX = KISHighVersion_7 ? 64 : 44;
    

    
    
    m_charaDetailsView =[[CharacterDetailsView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX)];

    m_charaDetailsView.contentSize = CGSizeMake(320, 610);
    //m_charaDetailsView.bounces = NO;
    m_charaDetailsView.myCharaterDelegate = self;
    
    
    if (self.myViewType ==CHARA_INFO_MYSELF) {
        [m_charaDetailsView comeFromMy];
    }else if(self.myViewType ==CHARA_INFO_PERSON){
        [m_charaDetailsView comeFromPerson];
    }
    
    [self.view addSubview:m_charaDetailsView];
    
    

    
    [self buildScrollView];//创建下面的表格
    
    
    titleImageArray =[NSMutableArray array];
    [titleImageArray addObject:KUIImage(@"PVE.png")];
    [titleImageArray addObject:KUIImage(@"killer.png")];
    [titleImageArray addObject:KUIImage(@"itemserver.png")];
    [titleImageArray addObject:KUIImage(@"achievementCount.png")];
    [titleImageArray addObject:KUIImage(@"Wjjc.png")];
    //PVE战斗力  荣誉击杀数  装备等级 成就点数  PVP竞技场）
    titleArray = [NSMutableArray arrayWithObjects:@"PVE战斗力",@"荣誉击杀",@"装备等级",@"成就点数",@"PVP竞技场", nil];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];

//    hud1 =[[MBProgressHUD alloc]initWithView:m_charaDetailsView];
//    [self.view addSubview:hud1];
    
    
    loginActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [m_charaDetailsView addSubview:loginActivity];
    loginActivity.center = CGPointMake(160, 290);
    loginActivity.color = [UIColor blackColor];
    [loginActivity startAnimating];

    
    //(0, 306, 320, 55)
}

-(void)buildScrollView
{
    
    if (self.myViewType ==CHARA_INFO_MYSELF) {
        m_charaDetailsView.isComeTo = YES;
        m_contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_contentTableView];
        m_contentTableView.dataSource = self;
        m_contentTableView.delegate = self;
        m_contentTableView.bounces = NO;
        m_contentTableView.rowHeight = 55;
        
        m_countryTableView = [[UITableView alloc] initWithFrame:CGRectMake(640, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_countryTableView];
        m_countryTableView.dataSource = self;
        m_countryTableView.delegate = self;
        m_countryTableView.bounces = NO;
        m_countryTableView.rowHeight = 55;
        
        m_reamlTableView = [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_reamlTableView];
        m_reamlTableView.dataSource = self;
        m_reamlTableView.delegate = self;
        m_reamlTableView.bounces = NO;
        m_reamlTableView.rowHeight = 55;
        
    }else if(self.myViewType ==CHARA_INFO_PERSON){
        m_charaDetailsView.isComeTo = NO;
        m_contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_contentTableView];
        m_contentTableView.dataSource = self;
        m_contentTableView.delegate = self;
        m_contentTableView.bounces = NO;
        m_contentTableView.rowHeight = 60;
        m_contentTableView.hidden =YES;
        
        
        m_countryTableView = [[UITableView alloc] initWithFrame:CGRectMake(320, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_countryTableView];
        m_countryTableView.dataSource = self;
        m_countryTableView.delegate = self;
        m_countryTableView.bounces = NO;
        m_countryTableView.rowHeight = 60;
        
        
        m_reamlTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStylePlain];
        [m_charaDetailsView.listScrollView addSubview:m_reamlTableView];
        m_reamlTableView.dataSource = self;
        m_reamlTableView.delegate = self;
        m_reamlTableView.bounces = NO;
        m_reamlTableView.rowHeight = 60;
     
        
        
    }
    
    m_contentTableView.hidden =YES;
    m_reamlTableView.hidden = YES;
    m_countryTableView.hidden =YES;
}

//获取网络数据
- (void)getUserInfoByNet
{
    
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"146" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict TheController:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        m_contentTableView.hidden =NO;
        m_reamlTableView.hidden = NO;
        m_countryTableView.hidden =NO;

        [loginActivity stopAnimating];
        [loginActivity removeFromSuperview];

        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            m_charaInfo = [[CharaInfo alloc] initWithCharaInfo:responseObject];
            m_charaDetailsView.NickNameLabel.text = m_charaInfo.roleNickName;
            m_charaDetailsView.guildLabel.text =[NSString stringWithFormat:@"<%@>", m_charaInfo.guild];
            if ([m_charaInfo.guild isEqualToString:@""]) {
                m_charaDetailsView.guildLabel.text =@"<无工会>";
            }
            //计算view的franme
            NSString *str =[NSString stringWithFormat:@"%@ %@",m_charaInfo.realm,m_charaInfo.sidename];
            m_charaDetailsView.rightPView.frame = CGRectMake(295-str.length*11, 5, str.length*11+20,20 );
            m_charaDetailsView.realmView.frame = CGRectMake(18, 0, str.length*11, 20);
            m_serverStr = m_charaInfo.realm;
            m_characterId = m_charaInfo.characterid;
            m_zhiyeId = m_charaInfo.professionalId;
            
            m_charaDetailsView.realmView.text = [NSString stringWithFormat:@"%@ %@", m_charaInfo.realm,m_charaInfo.sidename];
            
            // m_charaDetailsView.realmView.text = m_charaInfo.realm;
            m_charaDetailsView.levelLabel.text =[NSString stringWithFormat:@"Lv.%@ %@", m_charaInfo.level,m_charaInfo.professionalName];
            
            m_charaDetailsView.levelLabel.frame =
            CGRectMake(323-m_charaDetailsView.levelLabel.text.length*9,
                       8,
                       m_charaDetailsView.levelLabel.text.length*9,
                       25);
            NSLog(@"长度%u",m_charaDetailsView.levelLabel.text.length*12);
            
            
            m_charaDetailsView.itemlevelView.text = [NSString stringWithFormat:@"%@/%@",m_charaInfo.itemlevelequipped,m_charaInfo.itemlevel] ;//
            m_charaDetailsView.clazzImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_%@",m_charaInfo.professionalId]];
            m_charaDetailsView.headerImageView.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
            m_charaDetailsView.headerImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@",m_charaInfo.thumbnail]];
            
            if ([m_charaInfo.auth isEqualToString:@"1"]) {
                m_charaDetailsView.certificationImage.image = KUIImage(@"6");
            }else
            {
                m_charaDetailsView.certificationImage.image = KUIImage(@"5");
            }
            //获取表格信息
            
            
            
            [m_contentTableView reloadData];
            [m_countryTableView reloadData];
            [m_reamlTableView reloadData];
            
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
    
}


//队列
-(void)getUserLineInfoByNet
{
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"159" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    //[hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict TheController:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;
        NSLog(@"res%@",responseObject);
        if ([KISDictionaryHaveKey(responseObject, @"systemstate")isEqualToString:@"ok"]) {
            
            [self reLoadingUserInfoFromNet];
        }
        
            if ([[responseObject allKeys]containsObject:@"entity"]) {
                m_charaDetailsView.reloadingBtn.userInteractionEnabled = YES;
                m_charaInfo = [[CharaInfo alloc] initWithReLoadingInfo:responseObject];
                hud.labelText = @"正拼命从英雄榜获取中...";
                [hud showAnimated:YES whileExecutingBlock:^{
                    sleep(2);
                    hud.labelText = @"获取成功";
                    sleep(2);
                }];

            }
        
        if ([KISDictionaryHaveKey(responseObject, @"systemstate")isEqualToString:@"busy"]) {
            m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;
            //KISDictionaryHaveKey(responseObject, @"time") ;
            
            NSString *timeStr =[GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"time") ]];
            NSString *indexStr = KISDictionaryHaveKey(responseObject, @"index");
            hud.labelText = [NSString stringWithFormat:@"进入更新队列，目前队列位置：%@，预计更新时间：%@",
                              indexStr,timeStr];
            [hud showAnimated:YES whileExecutingBlock:^{
                sleep(5);
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;

        [hud hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];

}
//刷新数据
-(void)reLoadingUserInfoFromNet
{
//    hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
    hud.labelText = @"正拼命从英雄榜获取中...";
    
    m_charaDetailsView.reloadingBtn.userInteractionEnabled =NO;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"160" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict TheController:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_charaInfo = [[CharaInfo alloc] initWithReLoadingInfo:responseObject];
            
            [hud hide:YES];
            
            [m_contentTableView reloadData];
            [m_countryTableView reloadData];
            [m_reamlTableView reloadData];
            
            NSString *changeBtnTitle =[NSString stringWithFormat:@"上次更新时间：%@",[GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"rankingtime")]]];
            
            [[NSUserDefaults standardUserDefaults]setObject:KISDictionaryHaveKey(responseObject, @"rankingtime") forKey:@"WX_reloadBtnTitle_wx"];
            
            [m_charaDetailsView.reloadingBtn setTitle:changeBtnTitle forState:UIControlStateNormal];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        m_charaDetailsView.reloadingBtn.userInteractionEnabled =YES;

      //  [hud hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                
            }
        }
    }];

}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView ==m_contentTableView) {
        return m_charaInfo.firstCompArray.count;
    }else if (tableView ==m_countryTableView)
    {
        return m_charaInfo.secondCompArray.count;
    }else{
        return m_charaInfo.thirdCompArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"userCell";
    CharaDaCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CharaDaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.titleImgView.image = [titleImageArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.topImgView.image = KUIImage(@"paiming_ico");
    
    
    if (tableView ==m_contentTableView) {
        cell.CountLabel.text = [NSString stringWithFormat:@"%@",[m_charaInfo.firstValueArray objectAtIndex:indexPath.row]];
        cell.rankingLabel.text = [NSString stringWithFormat:@"%@",[m_charaInfo.firstRankArray objectAtIndex:indexPath.row]];
        NSString *str =[m_charaInfo.firstCompArray objectAtIndex:indexPath.row];
        if (str==0) {
            cell.upDowmImgView.image = KUIImage(@"die");
        }else {
            cell.upDowmImgView.image = KUIImage(@"zhang");
        }
        //
    }
    if (tableView ==m_countryTableView){
        cell.CountLabel.text = [NSString stringWithFormat:@"%@",[m_charaInfo.secondValueArray objectAtIndex:indexPath.row]];
        cell.rankingLabel.text = [NSString stringWithFormat:@"%@",[m_charaInfo.secondRankArray objectAtIndex:indexPath.row]];
        NSString *str =[m_charaInfo.firstCompArray objectAtIndex:indexPath.row];
        if (str==0) {
            cell.upDowmImgView.image = KUIImage(@"die");
        }else {
            cell.upDowmImgView.image = KUIImage(@"zhang");
        }
        
    }
    if (tableView ==m_reamlTableView) {
        cell.CountLabel.text = [NSString stringWithFormat:@"%@",[m_charaInfo.thirdValueArray objectAtIndex:indexPath.row]];
        
        cell.rankingLabel.text = [NSString stringWithFormat:@"%@",[m_charaInfo.thirdRankArray objectAtIndex:indexPath.row]];
        NSString *str =[m_charaInfo.firstCompArray objectAtIndex:indexPath.row];
        if (str==0) {
            cell.upDowmImgView.image = KUIImage(@"die");
        }else {
            cell.upDowmImgView.image = KUIImage(@"zhang");
        }
        
    }
    
    if ([cell.rankingLabel.text isEqualToString:@"0"]) {
        cell.rankingLabel.text =@"--";
        cell.upDowmImgView.hidden = YES;
    }

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    NSString *alertTitle =nil;
    alertTitle =[titleArray objectAtIndex:indexPath.row];

    RankingViewController *ranking = [[RankingViewController alloc]init] ;
    
    if (tableView ==m_contentTableView) {
        ranking.cRankvaltype = @"1" ;
        NSInteger i =[[m_charaInfo.firstRankArray objectAtIndex:indexPath.row]intValue];
        if (i==0) {
            isGoToNextPage = NO;
        }
        
    }
    if (tableView ==m_countryTableView) {
        ranking.cRankvaltype = @"3" ;
        NSInteger i =[[m_charaInfo.secondRankArray objectAtIndex:indexPath.row]intValue];
        if (i==0) {
            isGoToNextPage = NO;
        }

    }
    if (tableView ==m_reamlTableView) {
        ranking.cRankvaltype = @"2" ;
        NSInteger i =[[m_charaInfo.thirdRankArray objectAtIndex:indexPath.row]intValue];
        if (i==0) {
            isGoToNextPage = NO;
        }

    }

    if (isGoToNextPage ==YES) {
        ranking.characterid =m_characterId;
        ranking.custType = m_zhiyeId;
        ranking.server = m_serverStr;
        
        ranking.pageCount1 = -1;
        ranking.pageCount2 = -1;
        ranking.pageCount3 = -1;
        ranking.characterName =m_charaInfo.roleNickName;
        ranking. titleOfRanking = [titleArray objectAtIndex:indexPath.row];
        NSArray *array = [m_charaInfo.friendOfRanking allKeys];
        NSLog(@"array%@",array);
        /*
         pvpScore,
         pveScore,
         itemlevel,
         totalHonorableKills,
         achievementPoints
         */
        
        switch (indexPath.row) {
            case 0:
                ranking.dRankvaltype = @"pveScore";
                break;
            case 1:
                ranking.dRankvaltype = @"totalHonorableKills";
                break;
            case 2:
                ranking.dRankvaltype = @"itemlevel";
                break;
            case 3:
                ranking.dRankvaltype = @"achievementPoints";
                break;
            case 4:
                ranking.dRankvaltype = @"pvpScore";
                break;
                
            default:
                break;
        }
        
        ranking.COME_FROM =[NSString stringWithFormat:@"%u",self.myViewType];
        NSLog(@"COME_FROM%@",ranking.COME_FROM);
        [self.navigationController pushViewController:ranking animated:YES];

    }else{
        
        [self showAlertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"该角色尚未进入“%@”排行",alertTitle] buttonTitle:@"确定"];
        isGoToNextPage =YES;
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"contentOfjuese" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"typePerson" object:nil];
    
    
}
- (void)reLoadingList:(CharacterDetailsView *)characterdetailsView
{
    m_charaDetailsView.reloadingBtn.userInteractionEnabled =NO;
        [self getUserLineInfoByNet];
        NSLog(@"刷新数据");
    
}

@end
