//
//  FacebookManager.m
//  faceWrapper
//
//  Created by sid on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookManager.h"
#import "Constants.h"
#import "FWKeysHelper.h"

static void (^block)(NSString *, NSString *) = nil;
static void (^trainBlock)(NSString *, NSString *) = nil;
static void (^statusBlock)(NSString *, NSString *) = nil;

@implementation FacebookManager
@synthesize fbGraph, userId, accessToken, train, simple, status;

+ (FacebookManager *)instance
{
    static dispatch_once_t pred;
    static FacebookManager *singleton;
    dispatch_once(&pred, ^{
        
        singleton = [[FacebookManager alloc] init];
    });
    
    return singleton;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.train = self.status = self.simple = NO;
    }
    
    return self;
}

- (void)responseBlockForTrain:(void (^)(NSString *, NSString *))blockCompletion
{
    trainBlock = nil;
    trainBlock = [blockCompletion copy];
    self.train = YES;
    self.simple = NO;
    self.status = NO;
}

- (void)responseBlockForStatus:(void (^)(NSString *, NSString *))blockCompletion
{
    statusBlock = nil;
    statusBlock = [blockCompletion copy];
    self.status = YES;
    self.simple = NO;
    self.train = NO;
}

- (void)requestTokenWithcompletion:(void (^)(NSString *, NSString *))simpleBlock
{
    block = nil;
    block = [simpleBlock copy];
    self.simple = YES;
    self.status = NO;
    self.train = NO;
    [self requestToken];
}

- (void)requestToken
{
    fbGraph = [[FbGraph alloc] initWithFbClientID:[FWKeysHelper facebookAppID]];
    
	[fbGraph authenticateUserWithCallbackObject:self
                                    andSelector:@selector(fbGraphCallback:) 
						 andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access,user_checkins,friends_checkins"];
}

- (void)fbGraphCallback:(id)sender 
{	
	if ((fbGraph.accessToken == nil) || ([fbGraph.accessToken length] == 0))
    {
		[fbGraph authenticateUserWithCallbackObject:self 
                                        andSelector:@selector(fbGraphCallback:) 
							 andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access,user_checkins,friends_checkins"];
        
	} 
    else 
    {
        FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me" withGetVars:nil];
        
        self.accessToken = fbGraph.accessToken;
        
        NSData *data = [fb_graph_response.htmlResponse dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *facebook_response = [NSJSONSerialization JSONObjectWithData:data  
                                                                          options:0
                                                                            error:nil];	
        
        if ([NSJSONSerialization isValidJSONObject:facebook_response])
        {
            self.userId = (NSString *)[facebook_response objectForKey:@"id"];
            
            //NSLog(@"%@, %@", self.accessToken, self.userId);
            if (simple)
            {
                self.simple = NO;
                block(self.accessToken, self.userId);
                block = nil;
            }
            else if (train)
            {
                self.train = NO;
                trainBlock(self.accessToken, self.userId);
                trainBlock = nil;
            }
            else if (status)
            {
                self.status = NO;
                statusBlock(self.accessToken, self.userId);
                statusBlock = nil;
            }
        }
        else
        {
            if (simple)
            {
                self.simple = NO;
                block(fbGraph.accessToken, @"");
                block = nil;
            }
            else if (train)
            {
                self.train = NO;
                trainBlock(fbGraph.accessToken, @"");
                trainBlock = nil;
            }
            else if (status)
            {
                self.status = NO;
                statusBlock(fbGraph.accessToken, @"");
                statusBlock = nil;
            }
        }
	}
}

@end
