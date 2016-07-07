//
//  AuthHelper.h
//  maps
//
//  Created by Eugene Gusev on 11.06.16.
//  Copyright © 2016 Eugene Gusev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthHelper : NSObject

-(void)updateUserLoggedInFlag;
-(BOOL)checkLoginWithUsername:(NSString*)username andPassword:(NSString*)password;
-(void) saveApiTokenInKeychainWithDictionary:(NSDictionary *)tokenDict;
-(NSString*) getApiToken;
-(void) logout;

@end
