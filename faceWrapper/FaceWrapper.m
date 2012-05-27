//
//  FaceWrapper.m
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "FaceWrapper.h"
#import "NSObject+URLDownload.h"
#import "NSObject+Conditional.h"
#import "NSObject+POST.h"
#import "NSData+NSString.h"
#import "XMLReader.h"
#import "XAuthAutenticator.h"
#import "FacebookManager.h"
#import "NSString+StringChecker.h"
#import "FWKeysHelper.h"

@interface FaceWrapper (Private)

+ (void)checkAPIKeys:(NSString *)apiKey secret:(NSString *)apiSecret;

+ (void)doRESTRequestWithURL:(NSString *)baseURL 
                  withObject:(FWObject *)object
               responseBlock:(void (^)(NSDictionary *, int))block;

+ (void)doPOSTRequestWithURL:(NSString *)postURL 
                  baseParams:(NSString *)baseURL
                  withObject:(FWObject *)object
               responseBlock:(void (^)(NSDictionary *, int))block;

+ (void)doRESTRequestForTrainWithBaseURL:(NSString *)baseURL 
                              withObject:(FWObject *)object 
                              inDelegate:(id)delegate;

+ (void)doPOSTRequestForTrainWithBaseURL:(NSString *)postURL
                              baseParams:(NSString *)baseURL
                              withObject:(FWObject *)object 
                              inDelegate:(id)delegate;

+ (void)doPOSTRequestForStatusWithBaseURL:(NSString *)postURL
                               baseParams:(NSString *)baseURL 
                               withObject:(FWObject *)object 
                               inDelegate:(id)delegate;

@end

@implementation FaceWrapper

#pragma -
#pragma Checker+Utilities methods

+ (NSDictionary *)parseFaceXML:(NSData *)xml
{
    NSString *stringXML = [[NSString alloc] initWithData:xml encoding:NSUTF8StringEncoding];
    
    NSError __autoreleasing **error = nil;
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:stringXML error:error];
    
    if ((xml == nil) || (error != nil) || (xmlDictionary == nil))
        return nil;
    else
        return xmlDictionary;
}

+ (FaceWrapper *)instance
{    
    static dispatch_once_t pred;
    static FaceWrapper *singleton;
    dispatch_once(&pred, ^{
        
        singleton = [[FaceWrapper alloc] init];
    });
    
    return singleton;
}

+ (void)throwExceptionWithName:(NSString *)name reason:(NSString *)reason
{
    [NSException exceptionWithName:name
                            reason:reason
                          userInfo:nil]; 
}

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

#pragma -
#pragma Service methods

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)detectFaceWithFWObject:(FWObject *)object 
               runInBackground:(BOOL)background 
                completionData:(void (^)(NSDictionary *, int))block
{
    [FaceWrapper checkAPIKeys:[FWKeysHelper faceAPI] secret:[FWKeysHelper faceSecretAPI]];
    
    if (object.isRESTObject) 
    {
        ([object.urls count] == 0) ? [FaceWrapper throwExceptionWithName:@"URL array items exception" 
                                                                  reason:@"URL array cannot be null"] : nil;
        
        (![object.urls arrayIsTypeOf:[NSURL class]]) ? [FaceWrapper throwExceptionWithName:@"URL array type exception" 
                                                                                    reason:@"Array object is not an NSURL object, addURLsToArray: from NSMutableArray"]: nil;
    }
    else
    {
        ([object.postImages count] == 0) ? [FaceWrapper throwExceptionWithName:@"POST images array items exception" 
                                                                        reason:@"POST images array cannot be null"] : nil;
        
        (![object.postImages arrayIsTypeOf:[FWImage class]]) ? [FaceWrapper throwExceptionWithName:@"FWImage array type exception" 
                                                                                            reason:@"Array object is not an FWImage object, addImagePOSTToArray: from NSMutableArray"]: nil; 
    }
    
    
    ([object.attributes count] == 0) ? [FaceWrapper throwExceptionWithName:@"Attributes array items exception" 
                                                                    reason:@"Attributes array cannot be null"] : nil;
    
    (![object.attributes arrayIsTypeOf:[NSNumber class]]) ? [FaceWrapper throwExceptionWithName:@"ATTRIBUTE array type exception" 
                                                                                         reason:@"Array object is not an ATTRIBUTE object, addAttributeToArray: from NSMutableArray"] : nil;
    
    __block NSString *baseURL = @"";
    __block NSString *postURL = @"";
    
    if (object.isRESTObject)
    {
        if (object.groupRecognition)
            baseURL = [NSString stringWithFormat:@"http://api.face.com/faces/group.%@", (object.format == FORMAT_TYPE_XML) ? @"xml?" : @"json?"];
        else
            baseURL = [NSString stringWithFormat:@"http://api.face.com/faces/group.%@", (object.format == FORMAT_TYPE_XML) ? @"xml?" : @"json?"];
            
    }
    else
    {
        if (object.groupRecognition)
            baseURL = [NSString stringWithFormat:@"http://api.face.com/faces/group.%@", (object.format == FORMAT_TYPE_XML) ? @"xml" : @"json"];
        else
            baseURL = [NSString stringWithFormat:@"http://api.face.com/faces/%@.%@", (object.wantRecognition) ? @"recognize" : @"detect", (object.format == FORMAT_TYPE_XML) ? @"xml" : @"json"];
        
        postURL = baseURL;
    }
    
    baseURL = [baseURL stringByAppendingFormat:@"&api_key=%@", [FWKeysHelper faceAPI]];
    baseURL = [baseURL stringByAppendingFormat:@"&api_secret=%@", [FWKeysHelper faceSecretAPI]];
    
    baseURL = [baseURL stringByAppendingFormat:@"&urls="];
    
    if (object.isRESTObject) 
    {
        [object.urls enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (idx == [object.urls count] - 1)
                baseURL = [baseURL stringByAppendingFormat:@"%@", obj];
            else
                baseURL = [baseURL stringByAppendingFormat:@"%@,", obj];
        }];
    }
    else
    {
        [object.postImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            FWImage *image = (FWImage *)obj;
            
            if (idx == [object.postImages count] - 1)
                baseURL = [baseURL stringByAppendingFormat:@"%@", image.pathPostImage];
            else
                baseURL = [baseURL stringByAppendingFormat:@"%@,", image.pathPostImage];
        }];
    }
    
    NSString *detection;
    
    if (object.detector == DETECTOR_TYPE_NORMAL)
    {
        detection = @"Normal";
    }
    else if (object.detector == DETECTOR_TYPE_AGGRESSIVE)
    {
        detection = @"Aggressive";
    }
    else
    {
        detection = @"Normal";
    }
    
    baseURL = [baseURL stringByAppendingFormat:@"&detector=%@", detection];
    
    baseURL = [baseURL stringByAppendingString:@"&attributes="];
    
    __block NSString *attribute;
    
    [object.attributes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([(NSNumber *)obj intValue] == ATTRIBUTE_ALL)
        {
            attribute = @"all";
            return;
        }
        else if ([(NSNumber *)obj intValue] == ATTRIBUTE_NONE)
        {
            attribute = @"none";
            return;
        }
        else if ([(NSNumber *)obj intValue] == ATTRIBUTE_GENDER)
        {
            attribute = @"gender";
        }
        else if ([(NSNumber *)obj intValue] == ATTRIBUTE_GLASSES)
        {
            attribute = @"glasses";
        }
        else
        {
            attribute = @"smiling";
        }
        
        if (idx == [object.attributes count] - 1) 
            baseURL = [baseURL stringByAppendingFormat:@"%@", attribute]; 
        else
            baseURL = [baseURL stringByAppendingFormat:@"%@,", attribute];
    }];
    
    NSString *callback = object.callback;
    
    if ((object.format == FORMAT_TYPE_JSON) && (![callback isEqualToString:@""]))
        baseURL = [baseURL stringByAppendingFormat:@"&callback=%@", callback];
    
    NSString *callback_url = [object.callback_url absoluteString];
    
    if (object.callback_url != nil)
        baseURL = [baseURL stringByAppendingFormat:@"&callback_url=%@", callback_url]; 
    
    NSLog(@"%@", baseURL);
    
    void (^restBlock)(void) = ^{ 
        
        if (background)
        {
            [NSObject performBlockInBackground:^{
                
                [FaceWrapper doRESTRequestWithURL:baseURL withObject:object responseBlock:block];
            }];
        }
        else
        {
            [FaceWrapper doRESTRequestWithURL:baseURL withObject:object responseBlock:block];
        }
    };
    
    void (^postBlock)(void) = ^{ 
        
        if (background)
        {
            [NSObject performBlockInBackground:^{
                
                [FaceWrapper doPOSTRequestWithURL:postURL baseParams:baseURL withObject:object responseBlock:block];
                
            }];
        }
        else
        {
            [FaceWrapper doPOSTRequestWithURL:postURL baseParams:baseURL withObject:object responseBlock:block];
        }
    };
    
    if ((object.wantRecognition) || (object.groupRecognition))
    {
        ([object.uids count] == 0) ? [FaceWrapper throwExceptionWithName:@"UIDS array items exception" 
                                                                  reason:@"UIDS array cannot be null"] : nil;
        
        (![object.uids arrayIsTypeOf:[NSString class]]) ? [FaceWrapper throwExceptionWithName:@"UIDS array type exception" 
                                                                                       reason:@"Array object is not an NSString object, addUIDsToArray: from NSMutableArray"]: nil;
        
        baseURL = [baseURL stringByAppendingFormat:@"&uids="];
        
        [object.uids enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (idx == [object.uids count] - 1)
                baseURL = [baseURL stringByAppendingFormat:@"%@", obj];
            else
                baseURL = [baseURL stringByAppendingFormat:@"%@,", obj];
        }];
        
        if (![object.accountNamespace isEqualToString:@""])
            baseURL = [baseURL stringByAppendingFormat:[NSString stringWithFormat:@"&namespace=%@", object.accountNamespace]];
        
        baseURL = [baseURL stringByAppendingFormat:@"&user_auth="];
        
        if (((id)object.twitter_username != nil) && ((id)object.twitter_password != nil))
        {
            __block NSString *oAuthString = @"";
            
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
                            
                            //NSLog(@"%@", baseURL);
                            //[[XAuthAutenticator sharedInstance] authenticateWithToken:object.twitter_oauth_token];
                            [NSObject ifEvaluate:object.isRESTObject isTrue:restBlock isFalse:postBlock];
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
            [[FacebookManager instance] requestTokenWithcompletion:^(NSString *access_token, NSString *userID) {
                
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
                    }
                    
                    [NSObject ifEvaluate:object.isRESTObject isTrue:restBlock isFalse:postBlock];
                }
            }];
        }
        else
        {
            [FaceWrapper throwExceptionWithName:@"Credentials exception"
                                         reason:@"Wrong credential, please check your Facebook or Twitter credentials"];
        }
        
        return;
    }
    
    [NSObject ifEvaluate:object.isRESTObject isTrue:restBlock isFalse:postBlock];
}

- (void)trainFaceWithFWObject:(FWObject *)object
                     delegate:(id<FaceWrapperDelegate>)delegate
              runInBackground:(BOOL)background 
{
    [FaceWrapper checkAPIKeys:[FWKeysHelper faceAPI] secret:[FWKeysHelper faceSecretAPI]];
    
    if (object.isRESTObject) 
    {
        ([object.urls count] == 0) ? [FaceWrapper throwExceptionWithName:@"URL array items exception" 
                                                                  reason:@"URL array cannot be null"] : nil;
        
        (![object.urls arrayIsTypeOf:[NSURL class]]) ? [FaceWrapper throwExceptionWithName:@"URL array type exception" 
                                                                                    reason:@"Array object is not an NSURL object, addURLsToArray: from NSMutableArray"]: nil;
    }
    else
    {
        ([object.postImages count] == 0) ? [FaceWrapper throwExceptionWithName:@"POST images array items exception" 
                                                                        reason:@"POST images array cannot be null"] : nil;
        
        (![object.postImages arrayIsTypeOf:[FWImage class]]) ? [FaceWrapper throwExceptionWithName:@"FWImage array type exception" 
                                                                                            reason:@"Array object is not an FWImage object, addImagePOSTToArray: from NSMutableArray"]: nil; 
    }
    
    
    ([object.attributes count] == 0) ? [FaceWrapper throwExceptionWithName:@"Attributes array items exception" 
                                                                    reason:@"Attributes array cannot be null"] : nil;
    
    (![object.attributes arrayIsTypeOf:[NSNumber class]]) ? [FaceWrapper throwExceptionWithName:@"ATTRIBUTE array type exception" 
                                                                                         reason:@"Array object is not an ATTRIBUTE object, addAttributeToArray: from NSMutableArray"] : nil;
    
    __block NSString *baseURL = @"";
    __block NSString *postURL = @"";
    
    if (object.isRESTObject)
    {
        baseURL = [NSString stringWithFormat:@"http://api.face.com/faces/train.%@", (object.format == FORMAT_TYPE_XML) ? @"xml?" : @"json?"];
    }
    else
    {
        postURL = [NSString stringWithFormat:@"http://api.face.com/faces/train.%@", (object.format == FORMAT_TYPE_XML) ? @"xml" : @"json"];
    }
    
    baseURL = [baseURL stringByAppendingFormat:@"&api_key=%@", [FWKeysHelper faceAPI]];
    baseURL = [baseURL stringByAppendingFormat:@"&api_secret=%@", [FWKeysHelper faceSecretAPI]];
    
    baseURL = [baseURL stringByAppendingFormat:@"&uids="];
    
    [object.uids enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx == [object.uids count] - 1)
            baseURL = [baseURL stringByAppendingFormat:@"%@", obj];
        else
            baseURL = [baseURL stringByAppendingFormat:@"%@,", obj];
    }];
    
    if (![object.accountNamespace isEqualToString:@""])
        baseURL = [baseURL stringByAppendingFormat:[NSString stringWithFormat:@"&namespace=%@", object.accountNamespace]];
    
    NSString *callback = object.callback;
    
    if ((object.format == FORMAT_TYPE_JSON) && (![callback isEqualToString:@""]))
        baseURL = [baseURL stringByAppendingFormat:@"&callback=%@", callback];
    
    NSString *callback_url = [object.callback_url absoluteString];
    
    if (object.callback_url != nil)
        baseURL = [baseURL stringByAppendingFormat:@"&callback_url=%@", callback_url]; 
    
    void (^restBlock)(void) = ^{ 
        
        if (background)
        {
            [NSObject performBlockInBackground:^{
                
                [FaceWrapper doRESTRequestForTrainWithBaseURL:baseURL withObject:object inDelegate:delegate];
            }];
        }
        else
        {
            [FaceWrapper doRESTRequestForTrainWithBaseURL:baseURL withObject:object inDelegate:delegate];
        }
    };
    
    void (^postBlock)(void) = ^{ 
        
        if (background)
        {
            [NSObject performBlockInBackground:^{
                
                [FaceWrapper doPOSTRequestForTrainWithBaseURL:postURL baseParams:baseURL withObject:object inDelegate:delegate];
            }];
        }
        else
        {
            [FaceWrapper doPOSTRequestForTrainWithBaseURL:postURL baseParams:baseURL withObject:object inDelegate:delegate];
        }
    };
    
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
                    
                    NSLog(@"%@, %@, %@", oauth_token, oauth_token_secret, oauth_user);
                    
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
                        
                        //NSLog(@"%@", baseURL);
                        //[[XAuthAutenticator sharedInstance] authenticateWithToken:object.twitter_oauth_token];
                        [NSObject ifEvaluate:object.isRESTObject isTrue:restBlock isFalse:postBlock];
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
                }
                
                [NSObject ifEvaluate:object.isRESTObject isTrue:restBlock isFalse:postBlock];
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

- (void)statusFaceWithFWObject:(FWObject *)object delegate:(id<FaceWrapperDelegate>)delegate
{
    [FaceWrapper checkAPIKeys:[FWKeysHelper faceAPI] secret:[FWKeysHelper faceSecretAPI]];
    
    if (object.isRESTObject) 
    {
        ([object.urls count] == 0) ? [FaceWrapper throwExceptionWithName:@"URL array items exception" 
                                                                  reason:@"URL array cannot be null"] : nil;
        
        (![object.urls arrayIsTypeOf:[NSURL class]]) ? [FaceWrapper throwExceptionWithName:@"URL array type exception" 
                                                                                    reason:@"Array object is not an NSURL object, addURLsToArray: from NSMutableArray"]: nil;
    }
    else
    {
        ([object.postImages count] == 0) ? [FaceWrapper throwExceptionWithName:@"POST images array items exception" 
                                                                        reason:@"POST images array cannot be null"] : nil;
        
        (![object.postImages arrayIsTypeOf:[FWImage class]]) ? [FaceWrapper throwExceptionWithName:@"FWImage array type exception" 
                                                                                            reason:@"Array object is not an FWImage object, addImagePOSTToArray: from NSMutableArray"]: nil; 
    }
    
    
    ([object.attributes count] == 0) ? [FaceWrapper throwExceptionWithName:@"Attributes array items exception" 
                                                                    reason:@"Attributes array cannot be null"] : nil;
    
    (![object.attributes arrayIsTypeOf:[NSNumber class]]) ? [FaceWrapper throwExceptionWithName:@"ATTRIBUTE array type exception" 
                                                                                         reason:@"Array object is not an ATTRIBUTE object, addAttributeToArray: from NSMutableArray"] : nil;
    
    __block NSString *baseURL = @"";
    __block NSString *postURL = @"";
    
    
    if (object.isRESTObject)
    {
        baseURL = [NSString stringWithFormat:@"http://api.face.com/faces/status.%@", (object.format == FORMAT_TYPE_XML) ? @"xml?" : @"json?"];
    }
    else
    {
        postURL = [NSString stringWithFormat:@"http://api.face.com/faces/status.%@", (object.format == FORMAT_TYPE_XML) ? @"xml" : @"json"];
    }
    
    baseURL = [baseURL stringByAppendingFormat:@"&api_key=%@", [FWKeysHelper faceAPI]];
    baseURL = [baseURL stringByAppendingFormat:@"&api_secret=%@", [FWKeysHelper faceSecretAPI]];
    
    baseURL = [baseURL stringByAppendingFormat:@"&uids="];
    
    [object.uids enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx == [object.uids count] - 1)
            baseURL = [baseURL stringByAppendingFormat:@"%@", obj];
        else
            baseURL = [baseURL stringByAppendingFormat:@"%@,", obj];
    }];
    
    if (![object.accountNamespace isEqualToString:@""])
        baseURL = [baseURL stringByAppendingFormat:[NSString stringWithFormat:@"&namespace=%@", object.accountNamespace]];
    
    NSString *callback = object.callback;
    
    if ((object.format == FORMAT_TYPE_JSON) && (![callback isEqualToString:@""]))
        baseURL = [baseURL stringByAppendingFormat:@"&callback=%@", callback];
    
    NSString *callback_url = [object.callback_url absoluteString];
    
    if (object.callback_url != nil)
        baseURL = [baseURL stringByAppendingFormat:@"&callback_url=%@", callback_url];
    
    baseURL = [baseURL stringByAppendingFormat:@"&user_auth="];
    
    void (^postBlockStatus)(void) = ^{
        
        [FaceWrapper doPOSTRequestForStatusWithBaseURL:postURL baseParams:baseURL withObject:object inDelegate:delegate];
    };
    
    if (((id)object.twitter_username != nil) && ((id)object.twitter_password != nil))
    {
        void (^twitterBlock)(void) = ^{
            
            //Generate tokens
            [[XAuthAutenticator sharedInstance] executeWithUsername:object.twitter_username 
                                                           password:object.twitter_password];
            
            [[XAuthAutenticator sharedInstance] completionBlock:^(NSString *oauth_token, NSString *oauth_token_secret, NSString *oauth_user) {
                
                NSLog(@"%@, %@, %@", oauth_token, oauth_token_secret, oauth_user);
                
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
                    
                    
                    //[[XAuthAutenticator sharedInstance] authenticateWithToken:object.twitter_oauth_token];
                    postBlockStatus();
                }
                else
                    [FaceWrapper throwExceptionWithName:@"Credential Exception" reason:@"Wrong twitter credentials"]; 
            }
            completionError:^(NSError *error) {
                                                    
              //NSLog(@"%@", [error description]);
              [FaceWrapper throwExceptionWithName:[error description] reason:[error description]];
            }];
        };
        
        twitterBlock();
    }
    else if (([FWKeysHelper facebookAppID] != @"") && (object.useFacebook == YES))
    {
        //Generate tokens
        [[FacebookManager instance] responseBlockForStatus:^(NSString *access_token, NSString *userID) {
            
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
                }
                
                postBlockStatus();
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

#pragma mark -
#pragma Mark Utils

+ (void)doRESTRequestWithURL:(NSString *)baseURL withObject:(FWObject *)object responseBlock:(void (^)(NSDictionary *, int))block
{
    [NSObject downloadURLWithStringWithStatus:baseURL completion:^(NSData *data, int status) {
        
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
                    block(nil, -1);
                }
                else
                {
                    block(parsedJSON, -1);
                }
            }
            else
            {
                //XML 
                block([FaceWrapper parseFaceXML:data], -1); 
            }
        }
    }];
}

+ (void)doPOSTRequestWithURL:(NSString *)postURL 
                  baseParams:(NSString *)baseURL
                  withObject:(FWObject *)object
               responseBlock:(void (^)(NSDictionary *, int))block
{
    [object.postImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
       
        [NSObject sendPOSTWithURL:[NSURL URLWithString:postURL] 
                       withParams:baseURL 
                           images:[NSArray arrayWithObject:(FWImage *)obj] 
                       completion:^(NSData *data) {
                               
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
                           block(nil, -1);
                       }
                       else
                       {
                           block(parsedJSON, [(FWImage *)obj tag]);
                       }
                   }
                   else
                   {
                       //XML 
                       block([FaceWrapper parseFaceXML:data], [(FWImage *)obj tag]);
                   }
               }
         }];
    }];
}

+ (void)doRESTRequestForTrainWithBaseURL:(NSString *)baseURL 
                              withObject:(FWObject *)object
                              inDelegate:(id)delegate
{
    [NSObject downloadURLWithStringWithStatus:baseURL completion:^(NSData *data, int status) {
        
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
                    NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperTrainFaceSuccess:photoTag:));
                    
                    [stringSEL selectorDidRespondInClass:delegate execute:^{
                        
                        [delegate faceWrapperTrainFaceSuccess:nil photoTag:-1];
                    }];
                }
                else
                {
                    NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperTrainFaceSuccess:photoTag:));
                    
                    [stringSEL selectorDidRespondInClass:delegate execute:^{
                        
                        [delegate faceWrapperTrainFaceSuccess:parsedJSON photoTag:-1];
                    }];
                }
            }
            else
            {
                //XML 
                NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperTrainFaceSuccess:photoTag:));
                
                [stringSEL selectorDidRespondInClass:delegate execute:^{
                    
                    [delegate faceWrapperTrainFaceSuccess:[FaceWrapper parseFaceXML:data] photoTag:-1];
                }];
            }
        }
    }];
}

+ (void)doPOSTRequestForTrainWithBaseURL:(NSString *)postURL
                              baseParams:(NSString *)baseURL
                              withObject:(FWObject *)object 
                              inDelegate:(id)delegate
{
    [object.postImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [NSObject sendPOSTWithURL:[NSURL URLWithString:postURL] 
                       withParams:baseURL 
                           images:[NSArray arrayWithObject:(FWImage *)obj] 
                       completion:^(NSData *data) {
                               
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
                       NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperTrainFaceSuccess:photoTag:));
                       
                       [stringSEL selectorDidRespondInClass:delegate execute:^{
                           
                           [delegate faceWrapperTrainFaceSuccess:nil photoTag:-1];
                       }];
                   }
                   else
                   {
                       NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperTrainFaceSuccess:photoTag:));
                       
                       [stringSEL selectorDidRespondInClass:delegate
                                                    execute:^{
                                                        
                                                        [delegate faceWrapperTrainFaceSuccess:parsedJSON 
                                                                                     photoTag:[(FWImage *)obj tag]];
                                                    }];
                   }
               }
               else
               {
                   //XML 
                   NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperTrainFaceSuccess:photoTag:));
                   
                   [stringSEL selectorDidRespondInClass:delegate execute:^{
                       
                       [delegate faceWrapperTrainFaceSuccess:[FaceWrapper parseFaceXML:data] 
                                                    photoTag:[(FWImage *)obj tag]];
                   }];
               }
           }
       }];
    }];
}

+ (void)doPOSTRequestForStatusWithBaseURL:(NSString *)postURL
                               baseParams:(NSString *)baseURL 
                               withObject:(FWObject *)object 
                               inDelegate:(id)delegate
{
    [object.postImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [NSObject sendPOSTWithURL:[NSURL URLWithString:postURL]
                       withParams:baseURL 
                           images:[NSArray arrayWithObject:(FWImage *)obj]
                       completion:^(NSData *data) {
                           
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
                       NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperStatusFacing:photoTag:));
                       
                       [stringSEL selectorDidRespondInClass:delegate execute:^{
                           
                           [delegate faceWrapperStatusFacing:parsedJSON photoTag:-1];
                       }];
                   }
                   else
                   {
                       NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperStatusFacing:photoTag:));
                       
                       [stringSEL selectorDidRespondInClass:delegate execute:^{
                           
                           [delegate faceWrapperStatusFacing:parsedJSON photoTag:[(FWImage *)obj tag]];
                       }];
                   }
               }
               else
               {
                   //XML 
                   NSString *stringSEL = NSStringFromSelector(@selector(faceWrapperStatusFacing:photoTag:));
                   
                   [stringSEL selectorDidRespondInClass:delegate execute:^{
                       
                       [delegate faceWrapperStatusFacing:[FaceWrapper parseFaceXML:data] photoTag:[(FWImage *)obj tag]];
                   }];
               }
           }
       }];
    }];
}

@end