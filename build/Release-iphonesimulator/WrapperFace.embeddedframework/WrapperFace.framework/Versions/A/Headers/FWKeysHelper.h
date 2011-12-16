//
//  FWKeysHelper.h
//  faceWrapper
//
//  Created by Sergio on 16/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FWKeysHelper : NSObject
{
    NSString *kFaceAPI;
    NSString *kFaceSecretAPI;

    NSString *kTwitterConsumerKey;
    NSString *kTwitterConsumerSecret;
    
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
