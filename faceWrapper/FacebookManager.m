//
//  FacebookManager.m
//  faceWrapper
//
//  Created by sid on 06/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FacebookManager.h"
#import "Constants.h"

static void (^block)(NSString *, NSString *) = nil;

@implementation FacebookManager
@synthesize fbGraph, userId, accessToken;

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
        
    }
    
    return self;
}

- (void)requestTokenWithcompletion:(void (^)(NSString *, NSString *))blockCompletion
{
    block = nil;
    block = [blockCompletion copy];
    
    fbGraph = [[FbGraph alloc] initWithFbClientID:kFacebookAppID];

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
            block(self.accessToken, self.userId);
        }
        else
        {
            block(fbGraph.accessToken, @"");
        }
	}
}

@end
