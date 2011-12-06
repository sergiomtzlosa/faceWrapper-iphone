//
//  NSObject+POST.m
//  faceWrapper
//
//  Created by Sergio on 29/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "NSObject+POST.h"
#import "FWImage.h"

@interface NSObject (InternalHelper)

+ (NSMutableData *)generatePostBody:(NSDictionary *)data withImage:(NSArray *)imageData andBoundary:(NSString *)boundary;
- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data;

@end

@implementation NSObject (InternalHelper)

+ (NSMutableData *)generatePostBody:(NSDictionary *)data withImage:(NSArray *)imageData andBoundary:(NSString *)boundary
{
	NSMutableData *body = [NSMutableData data];
	NSString* endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
	
	[self utfAppendBody:body data:[NSString stringWithFormat:@"--%@\r\n", boundary]];
	
	for (id key in [data keyEnumerator]) 
    {
        /*
        //Check for user_auth field on recognition service
        if ([key isEqualToString:@"user_auth"])
        {
            NSArray *items = [(NSString *)[data valueForKey:key] componentsSeparatedByString:@","];
            
            for (NSString *component in items)
            {
                NSString *key = [[component componentsSeparatedByString:@":"] objectAtIndex:0];
                NSString *value = [[component componentsSeparatedByString:@":"] objectAtIndex:1];
                
                [self utfAppendBody:body
                               data:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]];
                [self utfAppendBody:body data:value];
                [self utfAppendBody:body data:endLine];
            }
        }
        else
        {
        }
        */
        
        [self utfAppendBody:body
                       data:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]];
        [self utfAppendBody:body data:[data valueForKey:key]];
        [self utfAppendBody:body data:endLine];
	}
	
    for (FWImage *fwImage in imageData)
    {
        [self utfAppendBody:body
                       data:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.%@\"\r\n", fwImage.imageName, fwImage.imageName, [fwImage.extension uppercaseString]]];
        [self utfAppendBody:body
                       data:[NSString stringWithString:@"Content-Type: image/jpg\r\n\r\n"]];
        //[self utfAppendBody:body
        //               data:[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n\r\n"]];
       
        [body appendData:UIImageJPEGRepresentation([FWImage imageWithData:fwImage.data], 1.0)];
        [self utfAppendBody:body data:endLine];
    }
	
    //rNSString *string = [[NSString alloc] initWithData:body encoding:NSASCIIStringEncoding];
    //NSLog(@"responseData: %@", string);

	return body;
}

- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data 
{
	[body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

@implementation NSObject (POST)

+ (void)sendPOSTWithURL:(NSURL *)url withParams:(NSString *)params images:(NSArray *)images completion:(void (^)(NSData *))block
{
    for (id object in images)
    {
        if (![object isKindOfClass:[FWImage class]]) 
        {
            [NSException exceptionWithName:@"Invalid object" reason:@"Object is not kind of FWImage" userInfo:nil];
        }
    }
    
    params = [params substringFromIndex:1];
    
    NSMutableDictionary *attribute = [NSMutableDictionary new];
    
    NSArray *trimParams = [params componentsSeparatedByString:@"&"];
    
    for (NSString *str in trimParams)
    {
        NSArray *splitValues = [str componentsSeparatedByString:@"="];
        [attribute setValue:[splitValues objectAtIndex:1] forKey:[splitValues objectAtIndex:0]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:180.0];

    
    NSString *boundary = @"boundary";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSObject generatePostBody:attribute withImage:images andBoundary:boundary]];

    NSError *error = nil;
    NSURLResponse *response;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request 
                                            returningResponse:&response 
                                                        error:&error];

    ((urlData == nil) || (error != nil)) ? block(nil) : block(urlData);
}

@end
