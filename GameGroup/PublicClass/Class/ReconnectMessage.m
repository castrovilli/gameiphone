//
//  ReconnectMessage.m
//  GameGroup
//
//  Created by 魏星 on 14-3-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ReconnectMessage.h"
#import "AppDelegate.h"
static ReconnectMessage *my_reconectMessage = NULL;
@implementation ReconnectMessage
{
    Reachability* reach;
}
- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActiveWithNet:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getChatServer) name:@"xmppReconnect_wx_xx" object:nil];
    }
    return self;
}

+ (ReconnectMessage*)singleton
{
    @synchronized(self)
    {
		if (my_reconectMessage == nil)
		{
			my_reconectMessage = [[self alloc] init];
		}
	}
	return my_reconectMessage;
}
- (void)getMyUserInfoFromNet
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:[SFHFKeychainUtils getPasswordForUsername:ACCOUNT andServiceName:LOCALACCOUNT error:nil] forKey:@"username"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"106" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DataStoreManager saveUserInfo:KISDictionaryHaveKey(responseObject, @"user")];
        [self getChatServer];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}

#pragma mark - 获得好友、关注、粉丝列表
-(void)getFriendByHttp
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"StartGetFriendListForNet" object:nil];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    //    [paramDict setObject:@"1" forKey:@"shiptype"];// 1：好友   2：关注  3：粉丝
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:sorttype_1]) {
        [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:sorttype_1] forKey:@"sorttype_1"];
    }
    else
    {
        [paramDict setObject:@"1" forKey:@"sorttype_1"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:sorttype_2]) {
        [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:sorttype_2] forKey:@"sorttype_2"];
    }
    else
    {
        [paramDict setObject:@"1" forKey:@"sorttype_2"];
    }
    [paramDict setObject:@"2" forKey:@"sorttype_3"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"111" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    // [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getFriendListForNet_wx" object:nil];
        [self parseContentListWithData:responseObject];
        
        [[NSUserDefaults standardUserDefaults] setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"3"), @"totalResults")] forKey:FansCount];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //不再请求好友列表
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:isFirstOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getFriendListForNet_wx" object:nil];

    }];
}

- (void)parseContentListWithData:(NSDictionary*)dataDic
{
    [DataStoreManager cleanFriendList];//先清 再存
    [DataStoreManager cleanAttentionList];
    [DataStoreManager cleanFansList];
    
    id friendsList = KISDictionaryHaveKey(dataDic, @"1");
    id attentionList = KISDictionaryHaveKey(dataDic, @"2");
    id fansList = KISDictionaryHaveKey(KISDictionaryHaveKey(dataDic, @"3"), @"users");
    dispatch_queue_t queue = dispatch_queue_create("com.living.game", NULL);
    dispatch_async(queue, ^{
        //   [hud show:YES];
        
        if ([friendsList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [friendsList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [friendsList objectForKey:key]) {
                    //                    [dict setObject:key forKey:@"nameindex"];
                    [DataStoreManager saveUserInfo:dict];
                    if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                        [DataStoreManager saveAllUserWithUserManagerList:dict];
                    }
                    
                }
            }
        }
        else if([friendsList isKindOfClass:[NSArray class]]){
            for (NSDictionary * dict in friendsList) {
                [DataStoreManager saveUserInfo:dict];
                if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                    [DataStoreManager saveAllUserWithUserManagerList:dict];
                }
            }
        }
        //关注
        if ([attentionList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [attentionList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [attentionList objectForKey:key]) {
                    //                    [dict setObject:key forKey:@"nameindex"];
                    [DataStoreManager saveUserAttentionInfo:dict];
                    if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                        [DataStoreManager saveAllUserWithUserManagerList:dict];
                    }
                    
                }
            }
        }
        else if([attentionList isKindOfClass:[NSArray class]])
        {
            for (NSDictionary * dict in attentionList) {
                [DataStoreManager saveUserAttentionInfo:dict];
            }
        }
        //粉丝
        if ([fansList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [fansList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [fansList objectForKey:key]) {
                    [DataStoreManager saveUserFansInfo:dict];
                }
            }
        }
        else if ([fansList isKindOfClass:[NSArray class]]) {
            for (NSDictionary * dict in fansList) {
                [DataStoreManager saveUserFansInfo:dict];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"2"];
            
        });
    });
}

- (void)sendDeviceToken
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* locationDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [locationDict setObject:[GameCommon shareGameCommon].deviceToken forKey:@"deviceToken"];
    [locationDict setObject:appType forKey:@"appType"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[DataStoreManager getMyUserID] forKey:@"userid"];
    [postDict setObject:@"140" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
    }];
}



#pragma mark 进入程序网络变化
- (void)appBecomeActiveWithNet:(NSNotification*)notification
{
    reach = notification.object;
    if ([reach currentReachabilityStatus] != NotReachable  && [[TempData sharedInstance] isHaveLogin]) {//有网
        if (![self.xmpphelper ifXMPPConnected]) {
            [self getChatServer];
        }
    }
}

#pragma mark 登陆xmpp
- (void)getChatServer//自动登陆情况下获得服务器
{
    if (![[TempData sharedInstance] isHaveLogin]){
        return;
    }
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[DataStoreManager getMyUserID] forKey:@"userid"];
    [postDict setObject:@"116" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"服务器数据 %@", responseObject);

        [[TempData sharedInstance] SetServer:KISDictionaryHaveKey(responseObject, @"address") TheDomain:KISDictionaryHaveKey(responseObject, @"name")];//得到域名
        [self logInToChatServer];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectFail" object:nil];
    }];
    
}
-(void)logInToChatServer
{
    NSLog(@"尝试登陆xmpp");
    NSLog(@"%@",[[DataStoreManager getMyUserID] stringByAppendingFormat:@"%@",[[TempData sharedInstance] getDomain]]);
    [self.xmpphelper connect:[[DataStoreManager getMyUserID] stringByAppendingFormat:@"%@",[[TempData sharedInstance] getDomain]] password:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] host:[[TempData sharedInstance] getServer] success:^(void){
        
        NSLog(@"登陆成功xmpp");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectSuccess" object:nil];
        
        
    }fail:^(NSError *result){
        NSLog(@" localizedDescription %@", result.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectFail" object:nil];
    }];
}

@end
