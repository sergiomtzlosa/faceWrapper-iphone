//
//  XAuthAutenticator.h
//  iphone_xauth
//
//  Created by Sergio on 05/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XAuthAutenticator : NSObject
{
    NSString *oauth_consumer_key;
    NSString *oauth_consumer_secret;
    NSString *username;
    NSString *password;
    
@private
    NSString *oauth_token; 
    NSString *oauth_token_secret;
    NSString *oauth_user;
    int statusCode;
    NSURLConnection *connection;
    NSMutableData *dataReceived;
}


@property (nonatomic, retain) NSString *oauth_token; 
@property (nonatomic, retain) NSString *oauth_token_secret;
@property (nonatomic, retain) NSString *oauth_user;
@property (nonatomic) int statusCode;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *dataReceived;

+ (XAuthAutenticator *)sharedInstance;
+ (void)clearTokens;
- (void)completionBlock:(void (^)(NSString *, NSString *, NSString *))block completionError:(void (^)(NSError *))error;
- (void)executeWithUsername:(NSString *)user password:(NSString *)pass;
- (void)authenticateWithToken:(NSString *)token;

@end
