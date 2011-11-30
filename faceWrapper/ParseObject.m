//
//  ParseObject.m
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "ParseObject.h"
#import "ParseObject+Enumeration.h"

@interface ParseObject (Private)

+ (NSArray *)stripRootObject:(NSDictionary *)fullResponse;

@end

@implementation ParseObject
@synthesize rootObject, rawDictionary;

+ (void)printObject:(id)object
{
    NSLog(@"%@", object);
}

+ (NSArray *)stripRootObject:(NSDictionary *)fullResponse
{
    @try 
    {
        return (NSArray *)[(NSDictionary *)[(NSArray *)[fullResponse objectForKey:@"photos"] objectAtIndex:0] valueForKey:@"tags"];
    }
    @catch (NSException *exception) 
    {
        return nil;
    }
}

- (id)init
{    
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (id)initWithRawDictionary:(NSDictionary *)raw
{
    if ((self = [super init])) 
    {
        self.rawDictionary = raw;
        self.rootObject = [ParseObject stripRootObject:raw];
    }
    
    return self;
}

@end
