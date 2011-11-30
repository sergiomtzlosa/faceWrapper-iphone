//
//  FaceWrapper.m
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "FaceWrapper.h"
#import "NSArray+TypeChecker.h"
#import "NSObject+Block.h"
#import "NSObject+URLDownload.h"
#import "NSObject+Conditional.h"
#import "NSObject+POST.h"
#import "NSData+NSString.h"
#import "XMLReader.h"

@interface FaceWrapper (Private)

+ (void)checkAPIKeys:(NSString *)apiKey secret:(NSString *)apiSecret;
+ (void)throwExceptionWithName:(NSString *)name reason:(NSString *)reason;

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
    return [self new];
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
                completionData:(void (^)(NSDictionary *))block
{
    [FaceWrapper checkAPIKeys:kFaceAPI secret:kFaceSecretAPI];
 
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
                                                                         reason:@"Array object is not an ATTRIBUTE object, addAttributeToArray: from NSMutableArray"] : @"";
    
    __block NSString *baseURL = @"";
    __block NSString *postURL = @"";
    
    if (object.isRESTObject)
    {
        baseURL = [NSString stringWithFormat:@"http://api.face.com/faces/detect.%@", (object.format == FORMAT_TYPE_XML) ? @"xml?" : @"json?"];
    }
    else
    {
        postURL = [NSString stringWithFormat:@"http://api.face.com/faces/detect.%@", (object.format == FORMAT_TYPE_XML) ? @"xml" : @"json"];
    }
    
    baseURL = [baseURL stringByAppendingFormat:@"&api_key=%@", kFaceAPI];
    baseURL = [baseURL stringByAppendingFormat:@"&api_secret=%@", kFaceSecretAPI];
    
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

    void (^restBlock)(void) = ^{ 
        
        if (background)
        {
            [NSObject performBlockInBackground:^{
               
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
            }];
        }
        else
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
    };
    
    void (^postBlock)(void) = ^{ 
        
        if (background)
        {
            [NSObject performBlockInBackground:^{
                
                [NSObject sendPOSTWithURL:[NSURL URLWithString:postURL] withParams:baseURL images:object.postImages completion:^(NSData *data) {
                   
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
            }];
        }
        else
        {
            [NSObject sendPOSTWithURL:[NSURL URLWithString:postURL] withParams:baseURL images:object.postImages completion:^(NSData *data) {
                
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
    };
    
    [NSObject ifEvaluate:object.isRESTObject isTrue:restBlock isFalse:postBlock];
}

@end