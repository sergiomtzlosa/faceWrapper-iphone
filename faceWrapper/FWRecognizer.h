//
//  FWRecognizer.h
//  faceWrapper
//
//  Created by sid on 02/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FWObject.h"

@interface FWRecognizer : FWObject
{
    NSArray *uids;
    NSString *accountNamespace;
    NSString *fb_user;
    NSString *fb_oauth_token;
    NSString *twitter_username;
    NSString *twitter_password;
}

@property (nonatomic, strong) NSArray *uids;
@property (nonatomic, strong) NSString *accountNamespace;
@property (nonatomic, strong) NSString *fb_user;
@property (nonatomic, strong) NSString *fb_oauth_token;
@property (nonatomic, strong) NSString *twitter_username;
@property (nonatomic, strong) NSString *twitter_password;

@end