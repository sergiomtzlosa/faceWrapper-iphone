//
//  FBGetterObject.m
//  faceWrapper
//
//  Created by sid on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FBGetterObject.h"

@implementation FBGetterObject
@synthesize order;
@synthesize limit;
@synthesize together;
@synthesize attribute;
@synthesize sizeRange;
@synthesize yawRange;
@synthesize rollRange;
@synthesize pitchRange;
@synthesize smilingUDIDs;

+ (FBGetterObject *)objectWithObject:(FBGetterObject *)object
{
    return (FBGetterObject *)[object mutableCopy];
}

- (id)init
{
    if ((self = [super init])) 
    {
        
    }
    
    return self;
}

- (id)initWithFWObject:(FWObject *)fwObject
{
    if ((self = [super init])) 
    {
        self.urls = fwObject.urls;
        self.detector = fwObject.detector;
        self.attributes = fwObject.attributes;
        self.format = fwObject.format;
        self.callback = fwObject.callback;
        self.callback_url = fwObject.callback_url;
        self.isRESTObject = fwObject.isRESTObject;
        self.postImages = fwObject.postImages;
        self.uids = fwObject.uids;
        self.accountNamespace = fwObject.accountNamespace;
        self.fb_user = fwObject.fb_user;
        self.fb_oauth_token = fwObject.fb_oauth_token;
        self.twitter_username = fwObject.twitter_username;
        self.twitter_password = fwObject.twitter_password;
        self.wantRecognition = fwObject.wantRecognition;
        self.twitter_oauth_user = fwObject.twitter_oauth_user;
        self.twitter_oauth_secret = fwObject.twitter_oauth_secret;
        self.twitter_oauth_token = fwObject.twitter_oauth_token;
        self.useFacebook = fwObject.useFacebook;
        self.groupRecognition = fwObject.groupRecognition;
    }
    
    return self;
}


- (id)mutableCopyWithZone:(NSZone*)zone  
{
    FBGetterObject *obj = [[[self class] allocWithZone:zone] init]; 
    
    [obj setUrls:self.urls];
    [obj setDetector:self.detector];
    [obj setAttributes:self.attributes];
    [obj setFormat:self.format];
    [obj setCallback:self.callback];
    [obj setCallback_url:self.callback_url];
    [obj setIsRESTObject:self.isRESTObject];
    [obj setPostImages:self.postImages];
    [obj setUids:self.uids];
    [obj setAccountNamespace:self.accountNamespace];
    [obj setFb_user:self.fb_user];
    [obj setFb_oauth_token:self.fb_oauth_token];
    [obj setTwitter_username:self.twitter_username];
    [obj setTwitter_password:self.twitter_password];
    [obj setWantRecognition:self.wantRecognition];
    [obj setTwitter_oauth_user:self.twitter_oauth_user];
    [obj setTwitter_oauth_secret:self.twitter_oauth_secret];
    [obj setTwitter_oauth_token:self.twitter_oauth_token];
    [obj setUseFacebook:self.useFacebook];
    [obj setGroupRecognition:self.groupRecognition];
    
    [obj setOrder:order];
    [obj setLimit:limit];
    [obj setTogether:together];
    [obj setAttribute:attribute];
    [obj setYawRange:yawRange];
    [obj setSizeRange:sizeRange];
    [obj setRollRange:rollRange];
    [obj setPitchRange:pitchRange];
    [obj setSmilingUDIDs:smilingUDIDs];
    
    return obj;
}

@end
