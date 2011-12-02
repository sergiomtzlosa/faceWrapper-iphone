//
//  FWAccount.m
//  faceWrapper
//
//  Created by Sergio on 02/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "FWAccount.h"
#import "NSObject+URLDownload.h"
#import "Constants.h"
#import "NSObject+Block.h"

#define kNamespaces @"http://api.face.com/account/namespaces.json?api_key=%@&api_secret=%@"

#define kLimits @"http://api.face.com/account/limits.json?api_key=%@&api_secret=%@"

#define kUsers @"http://api.face.com/account/users.json?api_key=%@&api_secret=%@&namespaces=%@"

@interface FWAccount (Private)

+ (NSDictionary *)serviceManager:(NSString *)url;

@end

@implementation FWAccount

+ (NSDictionary *)serviceManager:(NSString *)url
{
    __block NSDictionary *dictionary = nil;
    void (^execution)(NSString *url);
    
    execution = ^(NSString *url) {
        
        @synchronized(dictionary) 
        { 
            NSData *data = [NSObject downloadURLWithString:url];
            
            NSError *jsonParsingError = nil;
            NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0 
                                                                         error:&jsonParsingError];
            
            if ((![NSJSONSerialization isValidJSONObject:parsedJSON]) || (jsonParsingError != nil))
            {
                dictionary = nil;
            }
            else
            {
                dictionary = parsedJSON;
            }
        }  
    };
    
    execution(url);
    
    return dictionary;
}

+ (NSDictionary *)namespacesFromCurrentAccount
{
    NSString *url = [NSString stringWithFormat:kNamespaces, kFaceAPI, kFaceSecretAPI];

    return [FWAccount serviceManager:url];
}

+ (NSDictionary *)limitsFromCurrentAccount
{
    NSString *url = [NSString stringWithFormat:kLimits, kFaceAPI, kFaceSecretAPI];

    return [FWAccount serviceManager:url];
}

+ (NSDictionary *)usersFromCurrentAccountForNameSpaces:(NSArray *)namespaces
{
    __block NSString *spaces = @"";
    
    @synchronized(spaces)
    {
        [namespaces enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (idx == [namespaces count] - 1) 
                spaces = [spaces stringByAppendingFormat:@"%@", obj]; 
            else
                spaces = [spaces stringByAppendingFormat:@"%@,", obj];
        }];
    }
    
    NSString *url = [NSString stringWithFormat:kUsers, kFaceAPI, kFaceSecretAPI, spaces];

    return [FWAccount serviceManager:url];
}

@end