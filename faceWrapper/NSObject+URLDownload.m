//
//  NSObject+URLDownload.m
//  Precio Casa
//
//  Created by Sergio on 15/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "NSObject+URLDownload.h"
#import "NSData+NSString.h"

@implementation NSObject (URLDownload)

+ (NSData *)downloadURLWithString:(NSString *)stringURL
{
    NSURL *urlService = [NSURL URLWithString:stringURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:urlService
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                     timeoutInterval:30.0];
    NSError *requestError = nil;
    NSURLResponse *urlResponse;
    NSData *result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&urlResponse 
                                                       error:&requestError];
     
    if (requestError == nil) 
    {
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
            int status = [httpResponse statusCode];

            if ((status >= 200) && (status < 300))
            {
                return result;
            }
        }
    }
    
    return nil;
}

+ (void)downloadURLWithString:(NSString *)stringURL completion:(void (^)(NSData *data))completion
{
    NSURL *urlService = [NSURL URLWithString:stringURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:urlService
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                     timeoutInterval:30.0];
    NSError *requestError = nil;
    NSURLResponse *urlResponse;
    NSData *result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&urlResponse 
                                                       error:&requestError];
    
    if (requestError == nil) 
    {
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
            int status = [httpResponse statusCode];
            
            if ((status >= 200) && (status < 300))
            {
                completion(result);
            }
        }
    }
    
    completion(nil);
}

+ (void)downloadURLWithStringWithStatus:(NSString *)stringURL completion:(void (^)(NSData *data, int status))completion
{
    NSURL *urlService = [NSURL URLWithString:stringURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:urlService
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                     timeoutInterval:30.0];
    NSError *requestError = nil;
    NSURLResponse *urlResponse;
    NSData *result = [NSURLConnection sendSynchronousRequest:req
                                           returningResponse:&urlResponse 
                                                       error:&requestError];
    
    if (requestError == nil) 
    {
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)urlResponse;
            int status = [httpResponse statusCode];
            
            if ((status >= 200) && (status < 401))
            {
                completion(result, status);
            }
        }
    }
    
    completion(nil, 404);
}
@end