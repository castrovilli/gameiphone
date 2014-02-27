//
//  EncoXHViewController.m
//  GameGroup 
//
//  Created by admin on 14-2-27.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//


/*
 
 //打招呼  158
 [paramDict setObject:self.gameId forKey:@"gameid"];
 [paramDict setObject:self.characterId forKey:@"characterid"];
 [paramDict setObject:KISDictionaryHaveKey(getDic, @"userid") forKey:@"touserid"];
 [paramDict setObject:KISDictionaryHaveKey(getDic,@"roll") forKey:@"roll"];
 
 //邂逅  149
 [paramDict setObject:self.gameId forKey:@"gameid"];
 [paramDict setObject:self.characterId forKey:@"characterid"];

 
 //角色列表 125
 [paramDict setObject:[DataStoreManager getMyUserID] forKey:@"userid"];

 */


#import "EncoXHViewController.h"
#import "HostInfo.h"
#import "EnteroCell.h"
#import "EGOImageView.h"
@interface EncoXHViewController ()

@end

@implementation EncoXHViewController
{
    UIButton *sayHelloBtn;
    UIButton *inABtn;
    EGOImageView *headImageView;
    UIImageView *clazzImageView;
    UILabel *NickNameLabel;
    UILabel *customLabel;
    UITextView *promptLabel;
    NSDictionary *getDic;
    
    NSMutableArray *m_characterArray;
    HostInfo     *m_hostInfo;
    UITableView *m_tableView;

    
    
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
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
    [paramDict setObject:[DataStoreManager getMyUserID] forKey:@"userid"];
    [self getSayHelloForNetWithDictionary:paramDict method:@"125" prompt:@"获取中..." type:3];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
     getDic = [[NSDictionary alloc]init];
    m_characterArray = [[NSMutableArray alloc]init];
    [self setTopViewWithTitle:@"邂逅" withBackButton:YES];
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height -startX)];
    
    backgroundImageView.image =KUIImage(@"meet_bg_img.jpg");
    backgroundImageView.userInteractionEnabled = YES;
    [self.view addSubview:backgroundImageView];
    hud = [[MBProgressHUD alloc]initWithView:self.view];

    [self buildTableView];
    
}


-(void)buildTableView
{
    m_tableView = [[UITableView alloc]initWithFrame:CGRectMake(45, 100+startX, 230, 230) style:UITableViewStylePlain];
    m_tableView.layer.masksToBounds = YES;
    m_tableView.layer.cornerRadius = 6.0;
    m_tableView.layer.borderWidth = 0.1;
    m_tableView.layer.borderColor = [[UIColor whiteColor] CGColor];

    m_tableView.rowHeight = 70;
    m_tableView.delegate = self;
    m_tableView.dataSource = self;
    m_tableView.backgroundColor = [UIColor clearColor];
    m_tableView.showsVerticalScrollIndicator = NO;
    m_tableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:m_tableView];

}


#pragma mark ---创建邂逅界面
-(void)bulidEncounterView
{
    clazzImageView = [[UIImageView alloc]initWithFrame:CGRectMake(266,startX+ 6, 40, 40)];
    
    clazzImageView.image = KUIImage(@"ceshi.jpg");
    clazzImageView.layer.masksToBounds = YES;
    clazzImageView.layer.cornerRadius = 20;
    clazzImageView.layer.borderWidth = 2.0;
    clazzImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.view addSubview:clazzImageView];
    
    
    headImageView = [[EGOImageView alloc]init];
    
    headImageView.image = KUIImage(@"ceshi.jpg");
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = 80;
    headImageView.layer.borderWidth = 2.0;
    headImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.view addSubview:headImageView];
    
    
    NickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startX+251, 320, 20)];
    NickNameLabel.backgroundColor = [UIColor clearColor];
    NickNameLabel.font = [UIFont systemFontOfSize:18];
    NickNameLabel.textAlignment = NSTextAlignmentCenter;
    NickNameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:NickNameLabel];
    
    customLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, startX+276, 320, 15)];
    customLabel.backgroundColor = [UIColor clearColor];
    customLabel.font = [UIFont systemFontOfSize:18];
    customLabel.textAlignment = NSTextAlignmentCenter;
    customLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:customLabel];
    
    
    promptLabel = [[UITextView alloc]initWithFrame:CGRectMake(0, startX+318, 320, 30)];
    promptLabel.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
    promptLabel.textColor = UIColorFromRGBA(0xc3c3c3, 1);
    promptLabel.textAlignment =NSTextAlignmentCenter;
    promptLabel.userInteractionEnabled = NO;
    promptLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.view addSubview:promptLabel];
    
    
    inABtn =[UIButton buttonWithType:UIButtonTypeCustom];
    inABtn.frame = CGRectMake(20, kScreenHeigth-80, 120, 44);
    [inABtn setBackgroundImage:KUIImage(@"white_onclick") forState:UIControlStateNormal];
    [inABtn setBackgroundImage:KUIImage(@"white") forState:UIControlStateHighlighted];
    [inABtn addTarget:self action:@selector(changeOtherOne) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inABtn];
    
    
    sayHelloBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    sayHelloBtn.frame = CGRectMake(180, kScreenHeigth-80, 120, 44);
    [sayHelloBtn setBackgroundImage:KUIImage(@"green_onclick") forState:UIControlStateNormal];
    [sayHelloBtn setBackgroundImage:KUIImage(@"green_onclick") forState:UIControlStateHighlighted];
    [sayHelloBtn addTarget:self action:@selector(sayHiToYou:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sayHelloBtn];

}
-(void)changeOtherOne
{
    NickNameLabel.text = nil;
    customLabel.text = nil;
    promptLabel.text =nil;
    
    headImageView.frame = CGRectMake(0, 400, 0, 0);
    NSMutableDictionary *paramDict =[[NSMutableDictionary alloc]init];
    
    [paramDict setObject:@"1" forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];

    [self getSayHelloForNetWithDictionary:paramDict method:@"149" prompt:@"邂逅中..." type:1];
}

-(void)sayHiToYou:(UIButton *)sender
{
    NSMutableDictionary *paramDict =[[NSMutableDictionary alloc]init];
    [paramDict setObject:@"1" forKey:@"gameid"];
    [paramDict setObject:self.characterId forKey:@"characterid"];
    [paramDict setObject:KISDictionaryHaveKey(getDic, @"userid") forKey:@"touserid"];
    [paramDict setObject:KISDictionaryHaveKey(getDic,@"roll") forKey:@"roll"];

    [self getSayHelloForNetWithDictionary:paramDict method:@"158" prompt:@"打招呼ING" type:2];
}




#pragma mark ---网络请求
- (void)getSayHelloForNetWithDictionary:(NSDictionary *)dic method:(NSString *)method prompt:(NSString *)prompt type:(NSInteger)COME_TYPE
{
    hud.labelText = prompt;
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    
    [postDict setObject:dic forKey:@"params"];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict TheController:self success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        
        if (COME_TYPE ==1) {
            getDic = nil;
            getDic = [NSDictionary dictionaryWithDictionary:responseObject];
            NSLog(@"getDic%@",getDic);
            
            //男♀♂
            NSString *str = nil;
            if ([KISDictionaryHaveKey(getDic, @"gender")isEqualToString:@"1"]) {
                str= @"♂";
            }else{
                str = @"♀";
            }
            NickNameLabel.text = KISDictionaryHaveKey(getDic, @"nickname");
            customLabel.text = [NSString stringWithFormat:@"%@ %@|%@",str,KISDictionaryHaveKey(getDic, @"age"),KISDictionaryHaveKey(getDic, @"constellation")];
            
            promptLabel.text =KISDictionaryHaveKey(getDic, @"prompt");
            NSInteger i;
            i= promptLabel.text.length/23;
            headImageView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@",KISDictionaryHaveKey(getDic, @"img")]];

            headImageView.frame = CGRectMake(80, startX+ 76, 160, 160);
            promptLabel.frame = CGRectMake(0, startX+318, 320, 30+15*i);
            inABtn.frame =CGRectMake(20, startX+363+15*i, 120, 44);
            sayHelloBtn.frame =CGRectMake(180, startX+363+15*i, 120, 44);
            
        }
        if (COME_TYPE ==2) {
            NSLog(@"打招呼成功");
            [self showMessageWindowWithContent:@"打招呼成功" imageType:0];
            
            [self changeOtherOne];
            
        }
        if (COME_TYPE ==3) {
            if ([KISDictionaryHaveKey(responseObject, @"1") isKindOfClass:[NSArray class]]) {
                NSLog(@"responseObject%@",responseObject);
                [m_characterArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"1")];
                NSLog(@"m_characterArray%@",m_characterArray);
                [m_tableView reloadData];

        }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                 [hud hide:YES];
            }
        }
    }];
}


#pragma mark --tableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_characterArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCharacter";
    EnteroCell *cell = (EnteroCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[EnteroCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
    
    NSDictionary* tempDic = [m_characterArray objectAtIndex:indexPath.row];
    
    int imageId = [KISDictionaryHaveKey(tempDic, @"clazz") intValue];
    if (imageId > 0 && imageId < 12) {//1~11
        cell.headerImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_%d", imageId]];
    }
    else
        cell.headerImageView.image = [UIImage imageNamed:@"clazz_0.png"];
    
    NSString* realm = [KISDictionaryHaveKey(tempDic, @"raceObj") isKindOfClass:[NSDictionary class]] ? KISDictionaryHaveKey(KISDictionaryHaveKey(tempDic, @"raceObj"), @"sidename") : @"";
    
    cell.serverLabel.text = [KISDictionaryHaveKey(tempDic, @"realm") stringByAppendingString:realm];
    cell.titleLabel.text = KISDictionaryHaveKey(tempDic, @"name");
    
//
//    cell.editBtn.hidden = YES;
//    //        cell.authBtn.hidden = NO;
//    
//    cell.myIndexPath = indexPath;
//    cell.gameImg.image = KUIImage(@"wow");
//    cell.nameLabel.text = KISDictionaryHaveKey(tempDic, @"name");
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* tempDic = [m_characterArray objectAtIndex:indexPath.row];
    NSMutableDictionary *paramDict =[[NSMutableDictionary alloc]init];
    self.characterId =KISDictionaryHaveKey(tempDic, @"id");
    [paramDict setObject:@"1" forKey:@"gameid"];
    [paramDict setObject:KISDictionaryHaveKey(tempDic, @"id") forKey:@"characterid"];
    tableView.hidden = YES;
    [self bulidEncounterView];
    [self getSayHelloForNetWithDictionary:paramDict method:@"149" prompt:@"邂逅中..." type:1];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
