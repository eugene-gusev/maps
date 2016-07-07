//
//  AuthHelper.m
//  maps
//
//  Created by Eugene Gusev on 11.06.16.
//  Copyright © 2016 Eugene Gusev. All rights reserved.
//

#import "AuthHelper.h"
#import "SSKeychain.h"

@implementation AuthHelper

-(void) updateUserLoggedInFlag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"loggedIn" forKey:@"userLoggedIn"];
    [userDefaults synchronize];
}

-(void)logout {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"userLoggedIn"];
    [userDefaults setObject:nil forKey:@"userHasOrder"];
    [userDefaults setObject:nil forKey:@"userHasRoute"];
    [SSKeychain deletePasswordForService:@"MapsService" account:@"Auth_Token"];
    [SSKeychain deletePasswordForService:@"MapsService" account:@"Auth_Token_Exiry"];
    [userDefaults synchronize];
}

-(void) saveApiTokenInKeychainWithDictionary:(NSDictionary *)tokenDict {
    [tokenDict enumerateKeysAndObjectsUsingBlock:^(id dictKey,id dictObj,BOOL *stopBool){
        if ([(NSString *)dictKey  isEqual: @"api_authtoken"]) {
         [SSKeychain setPassword:(NSString *)dictObj forService:@"MapsService" account:@"Auth_Token"];
        }
        if ([(NSString *)dictKey  isEqual: @"authtoken_expiry"]) {
            [SSKeychain setPassword:(NSString *)dictObj forService:@"MapsService" account:@"Auth_Token_Expiry"];
        }
        }];
}

-(NSString*) getApiToken {    
    return [SSKeychain passwordForService:@"MapsService" account:@"Auth_Token"];
}

-(BOOL) loginWithUsername:(NSString*)username andPassword:(NSString*)password {
    NSString *post = [NSString stringWithFormat:@"username=%@&password=%@",@"1",@"2"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://46.101.141.190:2000/addsubroute?%@",post]]];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSLog(@"hey");
        }
        
    }];
    [dataTask resume];
    return true;
}


-(BOOL)checkLoginWithUsername:(NSString*)username andPassword:(NSString*)password {
//    KeychainWrapper *keychain = [[KeychainWrapper alloc]init];
//    if ([password isEqualToString:(NSString*)[keychain myObjectForKey:@"v_Data"]] && [username isEqualToString:(NSString*)[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]]) {
//        return true;
//    }
    return false;
}
@end
