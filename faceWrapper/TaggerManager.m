//
//  TaggerManager.m
//  faceWrapper
//
//  Created by Sergio on 07/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "TaggerManager.h"
#import "FaceWrapper.h"
#import "FWKeysHelper.h"
#import "XAuthAutenticator.h"
#import "FacebookManager.h"
#import "NSString+StringChecker.h"
#import "NSObject+URLDownload.h"

static Block myBlock;

@interface TaggerManager (Private)

+ (void)checkAPIKeys:(NSString *)apiKey secret:(NSString *)apiSecret;

+ (void)doRESTRequestWithBaseURL:(NSString *)baseURL 
                      withObject:(FWObject *)object;

@end

@implementation TaggerManager

+ (void)checkAPIKeys:(NSString *)apiKey secret:(NSString *)apiSecret
{
    if ([apiKey isEqualToString:@""])
    {
        [FaceWrapper throwExceptionWithName:@"APIKey exception" reason:@"APIKey undefined"];
    }
    
    if ([apiSecret isEqualToString:@""])
    {
        [FaceWrapper throwExceptionWithName:@"APISecret exception" reason:@"APISecret undefined"];
    }
}

+ (TaggerManager *)sharedInstance
{
    static dispatch_once_t pred;
    static TaggerManager *singleton;
    dispatch_once(&pred, ^{
        
        singleton = [[TaggerManager alloc] init];
    });
    
    return singleton;
}

- (void)actionTagWithObject:(FWObject *)object doAction:(TAG_ACTION)action blockCompletion:(Block)completion
{
    //REST
    
    [TaggerManager checkAPIKeys:[FWKeysHelper faceAPI] secret:[FWKeysHelper faceSecretAPI]];

    ([object.tids count] == 0) ? [FaceWrapper throwExceptionWithName:@"TIDS array items exception" 
                                                              reason:@"TIDS array cannot be null"] : nil;
    
    (![object.tids arrayIsTypeOf:[NSNumber class]]) ? [FaceWrapper throwExceptionWithName:@"TIDS array type exception" 
                                                                                   reason:@"Array object is not an TIDS object, addTidToArray: from NSMutableArray"] : nil;
    
    myBlock = nil;
    myBlock = [completion copy];
    
    __block NSString *baseURL = @"";
    
    baseURL = [NSString stringWithFormat:@"http://api.face.com/tags/save.%@", (object.format == FORMAT_TYPE_XML) ? @"xml?" : @"json?"];
    
    baseURL = [baseURL stringByAppendingFormat:@"api_key=%@", [FWKeysHelper faceAPI]];
    baseURL = [baseURL stringByAppendingFormat:@"&api_secret=%@", [FWKeysHelper faceSecretAPI]];
    
    if (action == TAG_ACTION_SAVE)
    {
        baseURL = [baseURL stringByAppendingFormat:@"&uid=%@", object.tagUID];
        
        if (![object.taggerID isEqualToString:@""])
            baseURL = [baseURL stringByAppendingFormat:@"&tagger_id=%@", object.taggerID];
        
        if (![object.tagLabel isEqualToString:@""])
            baseURL = [baseURL stringByAppendingFormat:@"&label=%@", object.tagLabel];
    }
   
    NSString *callback = object.callback;
    
    if (![callback isEqualToString:@""])
        baseURL = [baseURL stringByAppendingFormat:@"&callback=%@", callback];
    
    if (![object.password isEqualToString:@""])
        baseURL = [baseURL stringByAppendingFormat:@"&password=%@", object.password];
    
    baseURL = [baseURL stringByAppendingFormat:@"&tids="];
    
    [object.tids enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx == [object.tids count] - 1)
            baseURL = [baseURL stringByAppendingFormat:@"%@", obj];
        else
            baseURL = [baseURL stringByAppendingFormat:@"%@,", obj];
    }];
    
    baseURL = [baseURL stringByAppendingFormat:@"&user_auth="];
    
    if (((id)object.twitter_username != nil) && ((id)object.twitter_password != nil))
    {
        static NSString *oAuthString = @"Lock2";
        
        void (^twitterBlock)(void) = ^{
            
            @synchronized(oAuthString)
            {
                //Generate tokens
                [[XAuthAutenticator sharedInstance] executeWithUsername:object.twitter_username 
                                                               password:object.twitter_password];
                
                [[XAuthAutenticator sharedInstance] completionBlock:^(NSString *oauth_token, NSString *oauth_token_secret, NSString *oauth_user) {
                    
                    //NSLog(@"%@, %@, %@", oauth_token, oauth_token_secret, oauth_user);
                    
                    object.twitter_oauth_user = oauth_user;
                    object.twitter_oauth_secret = oauth_token_secret;
                    object.twitter_oauth_token = oauth_token;
                    
                    //Check tokens
                    if ((object.twitter_oauth_user != @"") &&
                        (object.twitter_oauth_secret != @"") && 
                        (object.twitter_oauth_token != @""))
                    {
                        //assign to URL
                        
                        baseURL = [baseURL stringByAppendingFormat:@"twitter_oauth_user:%@,twitter_oauth_secret:%@,twitter_oauth_token:%@", object.twitter_oauth_user, object.twitter_oauth_secret, object.twitter_oauth_token];
                        
                        NSLog(@"%@", baseURL);
                        
                        [TaggerManager doRESTRequestWithBaseURL:baseURL withObject:object];
                    }
                    else
                        [FaceWrapper throwExceptionWithName:@"Credential Exception" reason:@"Wrong twitter credentials"]; 
                }
                completionError:^(NSError *error) {
                                                        
                   //NSLog(@"%@", [error description]);
                   [FaceWrapper throwExceptionWithName:[error description] reason:[error description]];
                }];
            }
        };
        
        twitterBlock();
    }
    else if (([FWKeysHelper facebookAppID] != @"") && (object.useFacebook == YES))
    {
        //Generate tokens
        [[FacebookManager instance] responseBlockForTrain:^(NSString *access_token, NSString *userID) {
            
            object.fb_oauth_token = access_token;
            object.fb_user = userID;
            
            //Check tokens
            if ((object.fb_user != @"") || (object.fb_oauth_token != @""))
            {
                //assign to URL
                
                if ((![baseURL containsString:[@"fb_user:" stringByAppendingFormat:@"%@", object.fb_user]]) && 
                    (![baseURL containsString:[@"fb_oauth_token:" stringByAppendingFormat:@"%@", object.fb_oauth_token]]))
                {
                    baseURL = [baseURL stringByAppendingFormat:@"fb_user:%@,fb_oauth_token:%@", object.fb_user, object.fb_oauth_token];
                    
                    NSLog(@"%@", baseURL);
                    
                    [TaggerManager doRESTRequestWithBaseURL:baseURL withObject:object];
                }
            }
        }];
        
        [[FacebookManager instance] requestToken];
    }
    else
    {
        [FaceWrapper throwExceptionWithName:@"Credentials exception"
                                     reason:@"Wrong credential, please check your Facebook or Twitter credentials"];
    }
}

- (void)addTagWithObject:(FWObject *)object blockCompletion:(Block)completion
{
    //REST
    
    [TaggerManager checkAPIKeys:[FWKeysHelper faceAPI] secret:[FWKeysHelper faceSecretAPI]];
    
    if ((object.tagX < 0) || (object.tagX > 100))
    {
        [FaceWrapper throwExceptionWithName:@"X parameter exception"
                                     reason:@"X param MUST be between 0 and 100"];
    }
    
    if ((object.tagY < 0) || (object.tagY > 100))
    {
        [FaceWrapper throwExceptionWithName:@"Y parameter exception"
                                     reason:@"Y param MUST be between 0 and 100"];
    }
    
    if ((object.tagWidth < 0) || (object.tagWidth > 100))
    {
        [FaceWrapper throwExceptionWithName:@"WIDTH parameter exception"
                                     reason:@"WIDTH param MUST be between 0 and 100"];
    }
    
    myBlock = nil;
    myBlock = [completion copy];
    
    __block NSString *baseURL = @"";
    
    baseURL = [NSString stringWithFormat:@"http://api.face.com/tags/add.%@", (object.format == FORMAT_TYPE_XML) ? @"xml?" : @"json?"];
    
    baseURL = [baseURL stringByAppendingFormat:@"api_key=%@", [FWKeysHelper faceAPI]];
    baseURL = [baseURL stringByAppendingFormat:@"&api_secret=%@", [FWKeysHelper faceSecretAPI]];
    baseURL = [baseURL stringByAppendingFormat:@"&url=%@", object.tagURL];
    baseURL = [baseURL stringByAppendingFormat:@"&x=%d", object.tagX];
    baseURL = [baseURL stringByAppendingFormat:@"&y=%d", object.tagY];
    baseURL = [baseURL stringByAppendingFormat:@"&width=%d", object.tagWidth];
    baseURL = [baseURL stringByAppendingFormat:@"&uid=%@", object.tagUID];
    baseURL = [baseURL stringByAppendingFormat:@"&tagger_id=%@", object.taggerID];
    
    if (![object.tagLabel isEqualToString:@""])
        baseURL = [baseURL stringByAppendingFormat:@"&label=%@", object.tagLabel];
    
    NSString *callback = object.callback;
    
    if (![callback isEqualToString:@""])
        baseURL = [baseURL stringByAppendingFormat:@"&callback=%@", callback];
    
    if (![object.password isEqualToString:@""])
        baseURL = [baseURL stringByAppendingFormat:@"&password=%@", object.password];
    
    baseURL = [baseURL stringByAppendingFormat:@"&user_auth="];
    
    if (((id)object.twitter_username != nil) && ((id)object.twitter_password != nil))
    {
        static NSString *oAuthString = @"Lock2";
        
        void (^twitterBlock)(void) = ^{
            
            @synchronized(oAuthString)
            {
                //Generate tokens
                [[XAuthAutenticator sharedInstance] executeWithUsername:object.twitter_username 
                                                               password:object.twitter_password];
                
                [[XAuthAutenticator sharedInstance] completionBlock:^(NSString *oauth_token, NSString *oauth_token_secret, NSString *oauth_user) {
                    
                    //NSLog(@"%@, %@, %@", oauth_token, oauth_token_secret, oauth_user);
                    
                    object.twitter_oauth_user = oauth_user;
                    object.twitter_oauth_secret = oauth_token_secret;
                    object.twitter_oauth_token = oauth_token;
                    
                    //Check tokens
                    if ((object.twitter_oauth_user != @"") &&
                        (object.twitter_oauth_secret != @"") && 
                        (object.twitter_oauth_token != @""))
                    {
                        //assign to URL
                        
                        baseURL = [baseURL stringByAppendingFormat:@"twitter_oauth_user:%@,twitter_oauth_secret:%@,twitter_oauth_token:%@", object.twitter_oauth_user, object.twitter_oauth_secret, object.twitter_oauth_token];
                        
                        NSLog(@"%@", baseURL);
                        
                        [TaggerManager doRESTRequestWithBaseURL:baseURL withObject:object];
                    }
                    else
                        [FaceWrapper throwExceptionWithName:@"Credential Exception" reason:@"Wrong twitter credentials"]; 
                }
                completionError:^(NSError *error) {
                                                        
                    //NSLog(@"%@", [error description]);
                    [FaceWrapper throwExceptionWithName:[error description] reason:[error description]];
                }];
            }
        };
        
        twitterBlock();
    }
    else if (([FWKeysHelper facebookAppID] != @"") && (object.useFacebook == YES))
    {
        //Generate tokens
        [[FacebookManager instance] responseBlockForTrain:^(NSString *access_token, NSString *userID) {
            
            object.fb_oauth_token = access_token;
            object.fb_user = userID;
            
            //Check tokens
            if ((object.fb_user != @"") || (object.fb_oauth_token != @""))
            {
                //assign to URL
                
                if ((![baseURL containsString:[@"fb_user:" stringByAppendingFormat:@"%@", object.fb_user]]) && 
                    (![baseURL containsString:[@"fb_oauth_token:" stringByAppendingFormat:@"%@", object.fb_oauth_token]]))
                {
                    baseURL = [baseURL stringByAppendingFormat:@"fb_user:%@,fb_oauth_token:%@", object.fb_user, object.fb_oauth_token];
                    
                    NSLog(@"%@", baseURL);
                    
                    [TaggerManager doRESTRequestWithBaseURL:baseURL withObject:object];
                }
            }
        }];
        
        [[FacebookManager instance] requestToken];
    }
    else
    {
        [FaceWrapper throwExceptionWithName:@"Credentials exception"
                                     reason:@"Wrong credential, please check your Facebook or Twitter credentials"];
    }
}

- (void)getTagsWithObject:(FWObject *)object blockCompletion:(Block)completion
{
    //REST or POST
}

#pragma mark
#pragma mark Utils

+ (void)doRESTRequestWithBaseURL:(NSString *)baseURL 
                      withObject:(FWObject *)object
{
    NSData *data = [NSObject downloadURLWithString:baseURL];
        
    if (data == nil) 
    {
        [FaceWrapper throwExceptionWithName:@"Data Exception" reason:@"Returned data is NIL"];
    }
    else
    {
        if (object.format == FORMAT_TYPE_JSON) 
        {
            NSError *jsonParsingError = nil;
            NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0 
                                                                         error:&jsonParsingError];
            
            if ((![NSJSONSerialization isValidJSONObject:parsedJSON]) || (jsonParsingError != nil))
            {
                myBlock(nil);
            }
            else
            {
                myBlock(parsedJSON);
            }
        }
        else
        {
            //XML
            myBlock([FaceWrapper parseFaceXML:data]);
        }
    }
}

@end
