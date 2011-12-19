//
//  FWObject.h
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    DETECTOR_TYPE_DEFAULT = 0,
    DETECTOR_TYPE_NORMAL = 1,
    DETECTOR_TYPE_AGGRESSIVE = 2
}DETECTOR_TYPE;

typedef enum
{
    FORMAT_TYPE_JSON = 0,
    FORMAT_TYPE_XML = 1
}FORMAT_TYPE;

typedef enum
{
    ATTRIBUTE_ALL = 0,
    ATTRIBUTE_NONE = 1,
    ATTRIBUTE_GENDER = 2,
    ATTRIBUTE_GLASSES = 3,
    ATTRIBUTE_SMILING = 4
}ATTRIBUTE;

@interface FWObject : NSObject <NSMutableCopying>
{
    //Detect service params
    FORMAT_TYPE format;
    NSArray *urls;
    DETECTOR_TYPE detector;
    NSMutableArray *attributes;
    NSString *callback;
    NSURL *callback_url;
    BOOL isRESTObject;
    NSMutableArray *postImages;
    
    //Recognition params
    NSArray *uids;
    NSString *accountNamespace;
    NSString *fb_user;
    NSString *fb_oauth_token;
    NSString *twitter_username;
    NSString *twitter_password;
    NSString *twitter_oauth_user;
    NSString *twitter_oauth_secret;
    NSString *twitter_oauth_token;
    BOOL wantRecognition;
    BOOL useFacebook;
    BOOL groupRecognition;
    
    NSArray *tids;
    NSString *taggerID;
    NSString *tagUID;
    NSString *tagLabel;
    NSString *password;
    
    NSString *tagURL;
    int tagX;
    int tagY;
    int tagWidth;
    
}

+ (FWObject *)objectWithObject:(FWObject *)object;

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic) DETECTOR_TYPE detector;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic) FORMAT_TYPE format;
@property (nonatomic, strong) NSString *callback;
@property (nonatomic, strong) NSURL *callback_url;
@property (nonatomic) BOOL isRESTObject;
@property (nonatomic, strong) NSMutableArray *postImages;
@property (nonatomic, strong) NSArray *uids;
@property (nonatomic, strong) NSString *accountNamespace;
@property (nonatomic, strong) NSString *fb_user;
@property (nonatomic, strong) NSString *fb_oauth_token;
@property (nonatomic, strong) NSString *twitter_username;
@property (nonatomic, strong) NSString *twitter_password;
@property (nonatomic) BOOL wantRecognition;
@property (nonatomic, strong) NSString *twitter_oauth_user;
@property (nonatomic, strong) NSString *twitter_oauth_secret;
@property (nonatomic, strong) NSString *twitter_oauth_token;
@property (nonatomic) BOOL useFacebook;
@property (nonatomic) BOOL groupRecognition;
@property (nonatomic, strong) NSArray *tids;
@property (nonatomic, strong) NSString *taggerID;
@property (nonatomic, strong) NSString *tagUID;
@property (nonatomic, strong) NSString *tagLabel;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *tagURL;
@property (nonatomic) int tagX;
@property (nonatomic) int tagY;
@property (nonatomic) int tagWidth;

@end
