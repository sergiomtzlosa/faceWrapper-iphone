//
//  FWKeysHelper.h
//  faceWrapper
//
//  Created by macpocket1 on 16/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

//#error Define your keys

#import <Foundation/Foundation.h>

@interface FWKeysHelper : NSObject
{
    //Define your API from skybiometry.com --> https://www.skybiometry.com/Account
    
    NSString *kFaceAPI;
    NSString *kFaceSecretAPI;
    
    //Define your xAuth Tokens at developer.twitter.com and set them in your skybiometry.com account
    
    NSString *kTwitterConsumerKey;
    NSString *kTwitterConsumerSecret;
    
    //Define your Facebook Tokens at https://developers.facebook.com and set them in your skybiometry.com account

    NSString *kFacebookAppID;
    
}

+ (NSString *)faceAPI;
+ (void)setFaceAPI:(NSString *)value;

+ (NSString *)faceSecretAPI;
+ (void)setFaceSecretAPI:(NSString *)value;

+ (NSString *)twitterConsumerKey;
+ (void)setTwitterConsumerKey:(NSString *)value;

+ (NSString *)twitterConsumerSecret;
+ (void)setTwitterConsumerSecret:(NSString *)value;

+ (NSString *)facebookAppID;
+ (void)setFacebookAppID:(NSString *)value;

@property (nonatomic, retain) NSString *kFaceAPI;
@property (nonatomic, retain) NSString *kFaceSecretAPI;
@property (nonatomic, retain) NSString *kTwitterConsumerKey;
@property (nonatomic, retain) NSString *kTwitterConsumerSecret;
@property (nonatomic, retain) NSString *kFacebookAppID;

@end
