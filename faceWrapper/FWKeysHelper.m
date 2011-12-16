//
//  FWKeysHelper.m
//  faceWrapper
//
//  Created by Sergio on 16/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "FWKeysHelper.h"

@implementation FWKeysHelper
@synthesize kFaceAPI;
@synthesize kFaceSecretAPI;
@synthesize kTwitterConsumerKey;
@synthesize kTwitterConsumerSecret;
@synthesize kFacebookAppID;

+ (NSString *)faceAPI
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"kFaceAPI"];
}

+ (void)setFaceAPI:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"kFaceAPI"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)faceSecretAPI
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"kFaceSecretAPI"];
}

+ (void)setFaceSecretAPI:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"kFaceSecretAPI"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)twitterConsumerKey
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"kTwitterConsumerKey"];
}

+ (void)setTwitterConsumerKey:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"kTwitterConsumerKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)twitterConsumerSecret
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"kTwitterConsumerSecret"];
}

+ (void)setTwitterConsumerSecret:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"kTwitterConsumerSecret"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)facebookAppID
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"kFacebookAppID"];
}

+ (void)setFacebookAppID:(NSString *)value
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"kFacebookAppID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end