//
//  FWObject.m
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "FWObject.h"

@implementation FWObject
@synthesize urls;
@synthesize detector;
@synthesize attributes;
@synthesize format;
@synthesize callback;
@synthesize callback_url;
@synthesize isRESTObject;
@synthesize postImages;
@synthesize uids;
@synthesize accountNamespace;
@synthesize fb_user;
@synthesize fb_oauth_token;
@synthesize twitter_username;
@synthesize twitter_password;
@synthesize wantRecognition;
@synthesize twitter_oauth_user;
@synthesize twitter_oauth_secret;
@synthesize twitter_oauth_token;
@synthesize useFacebook;
@synthesize groupRecognition;
@synthesize tids;
@synthesize taggerID;
@synthesize tagUID;
@synthesize tagLabel;
@synthesize password;
@synthesize tagURL;
@synthesize tagX;
@synthesize tagY;
@synthesize tagWidth;

+ (FWObject *)objectWithObject:(FWObject *)object
{
    return (FWObject *)[object mutableCopy];
}

- (id)init
{
    if ((self = [super init])) 
    {
        
    }
    
    return self;
}

- (id)mutableCopyWithZone:(NSZone*) zone  
{  
    FWObject *obj = [[[self class] allocWithZone:zone] init]; 
    
    [obj setUrls:urls];
    [obj setDetector:detector];
    [obj setAttributes:attributes];
    [obj setFormat:format];
    [obj setCallback:callback];
    [obj setCallback_url:callback_url];
    [obj setIsRESTObject:isRESTObject];
    [obj setPostImages:postImages];
    [obj setUids:uids];
    [obj setAccountNamespace:accountNamespace];
    [obj setFb_user:fb_user];
    [obj setFb_oauth_token:fb_oauth_token];
    [obj setTwitter_username:twitter_username];
    [obj setTwitter_password:twitter_password];
    [obj setWantRecognition:wantRecognition];
    [obj setTwitter_oauth_user:twitter_oauth_user];
    [obj setTwitter_oauth_secret:twitter_oauth_secret];
    [obj setTwitter_oauth_token:twitter_oauth_token];
    [obj setUseFacebook:useFacebook];
    [obj setGroupRecognition:groupRecognition];
    [obj setTids:tids];
    [obj setTaggerID:taggerID];
    [obj setTagUID:tagUID];
    [obj setTagLabel:tagLabel];
    [obj setPassword:password];
    [obj setTagURL:tagURL];
    [obj setTagX:tagX];
    [obj setTagY:tagY];
    [obj setTagWidth:tagWidth];

    return obj;
}

@end
