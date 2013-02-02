//
//  FBGetter.m
//  faceWrapper
//
//  Created by sid on 15/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FBGetterManager.h"
#import "FacebookManager.h"
#import "FaceWrapper.h"
#import "NSString+StringChecker.h"
#import "NSObject+URLDownload.h"
#import "Constants.h"
#import "FWKeysHelper.h"

@interface FBGetterManager (Private)

+ (void)checkAPIKeys:(NSString *)apiKey secret:(NSString *)apiSecret;

@end

@implementation FBGetterManager

+ (NSNumber *)objectFromFBAttribute:(FBATTRIBUTE)attr
{
    return [NSNumber numberWithInt:attr];
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

+ (void)requestForFacebookWithObject:(FBGetterObject *)object completionBlock:(void (^)(NSDictionary *))block
{
    [FBGetterManager checkAPIKeys:[FWKeysHelper faceAPI] 
                           secret:[FWKeysHelper faceSecretAPI]];
    
    __block NSString *baseURL = [NSString stringWithFormat:@"http://api.skybiometry.com/fc/facebook/get.%@", (object.format == FORMAT_TYPE_XML) ? @"xml?" : @"json?"];
    
    baseURL = [baseURL stringByAppendingFormat:@"api_key=%@", [FWKeysHelper faceAPI]];
    baseURL = [baseURL stringByAppendingFormat:@"&api_secret=%@", [FWKeysHelper faceSecretAPI]];
    
    baseURL = [baseURL stringByAppendingFormat:@"&uids="];
    
    [object.uids enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (idx == [object.uids count] - 1)
            baseURL = [baseURL stringByAppendingFormat:@"%@", obj];
        else
            baseURL = [baseURL stringByAppendingFormat:@"%@,", obj];
    }];

    baseURL = [baseURL stringByAppendingFormat:@"&order=%@", (object.order == (ORDER_DEFAULT || ORDER_RECENT)) ? @"recent" : @"random"];
    
    int limit = 5;
    
    if ((object.limit != LIMIT_DEFAULT) && (object.limit > 0))
        limit = object.limit;
    
    baseURL = [baseURL stringByAppendingFormat:@"&limit=%d", limit];
    
    baseURL = [baseURL stringByAppendingFormat:@"&together=%d", (object.together) ? @"true" : @"false"];
    
    NSString *callback_url = [object.callback_url absoluteString];
    
    if (object.callback_url != nil)
        baseURL = [baseURL stringByAppendingFormat:@"&callback_url=%@", callback_url];
    
    if ([object.attributes count] > 0)
    {
        baseURL = [baseURL stringByAppendingString:@"&filter="];
        
        __block NSString *attribute;
    
        [object.attributes enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if ([(NSNumber *)obj intValue] == FBATTRIBUTE_GENDER_MALE)
            {
                attribute = @"gender:male";
            }
            if ([(NSNumber *)obj intValue] == FBATTRIBUTE_GENDER_FEMALE)
            {
                attribute = @"gender:female";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_GLASSES_TRUE)
            {
                attribute = @"glasses:true";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_GLASSES_FALSE)
            {
                attribute = @"glasses:false";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_SMILING_TRUE)
            {
                attribute = [NSString stringWithFormat:@"smiling:true"];
                
                [object.smilingUDIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    attribute = [attribute stringByAppendingFormat:@"|%@", (NSString *)obj];
                }];
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_SMILING_TRUE)
            {
                attribute = [NSString stringWithFormat:@"smiling:false"];
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_YAW_LEFT)
            {
                attribute = @"yaw:left";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_YAW_RIGHT)
            {
                attribute = @"yaw:right";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_YAW_CENTER)
            {
                attribute = @"yaw:center";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_YAW_RANGE)
            {
                attribute = [NSString stringWithFormat:@"yaw:%d~%d", ((int)object.yawRange.x > 0) ? (int)object.yawRange.x : 1, ((int)object.yawRange.y > 0) ? (int)object.yawRange.y : 1];
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_ROLL_LEFT)
            {
                attribute = @"roll:left";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_ROLL_RIGHT)
            {
                attribute = @"roll:right";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_ROLL_CENTER)
            {
                attribute = @"roll:center";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_ROLL_RANGE)
            {
                attribute = [NSString stringWithFormat:@"roll:%d~%d", ((int)object.rollRange.x > 0) ? (int)object.rollRange.x : 1, ((int)object.rollRange.y > 0) ? (int)object.rollRange.y : 1];
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_PITCH_LEFT)
            {
                attribute = @"pitch:left";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_PITCH_RIGHT)
            {
                attribute = @"pitch:right";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_PITCH_CENTER)
            {
                attribute = @"pitch:center";
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_PITCH_RANGE)
            {
                attribute = [NSString stringWithFormat:@"pitch:%d~%d", ((int)object.pitchRange.x > 0) ? (int)object.pitchRange.x : 1, ((int)object.pitchRange.y > 0) ? (int)object.pitchRange.y : 1];
            }
            else if ([(NSNumber *)obj intValue] == FBATTRIBUTE_SIZE_RANGE)
            {
                attribute = [NSString stringWithFormat:@"range:%d~%d", ((int)object.sizeRange.x > 0) ? (int)object.sizeRange.x : 1, ((int)object.sizeRange.y > 0) ? (int)object.sizeRange.y : 1];
            }
            
            if (idx == [object.attributes count] - 1) 
                baseURL = [baseURL stringByAppendingFormat:@"%@", attribute]; 
            else
                baseURL = [baseURL stringByAppendingFormat:@"%@,", attribute];
        }];
    }
    
    /*
     
     gender - male/female
     glasses - true/false
     smiling - true/false
     yaw - left/right/center OR range (x~y) of angle
     roll - left/right/center OR range (x~y) of angle
     pitch - up/down/center OR range (x~y) of angle
     size - range (x~y) of size in pixels
     
     Separators:
     :  separates key:value pair
     ,  separates filter component
     |  separates filter set for new person/group
     ~ range (i.e. 40~100)
     
     */
    
    if ([FWKeysHelper facebookAppID] != @"")
    {
        baseURL = [baseURL stringByAppendingFormat:@"&user_auth="];
        
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
                
                NSLog(@"URL FINAL: %@", baseURL);
                
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
                                block(nil);
                            }
                            else
                            {
                                block(parsedJSON);
                            }
                        }
                        else
                        {
                            //XML 
                            block([FaceWrapper parseFaceXML:data]); 
                        }
                    }
                }];
            }
            else
            {
                [FaceWrapper throwExceptionWithName:@"Credentials exception"
                                             reason:@"Wrong credential, please check your Facebook or Twitter credentials"]; 
            }
        }];
    }
    else
    {
        [FaceWrapper throwExceptionWithName:@"Credentials exception"
                                     reason:@"Wrong credential, please check your Facebook or Twitter credentials"];
    }
}

@end
