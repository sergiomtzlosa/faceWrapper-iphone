//
//  TwitterAccount.m
//  faceWrapper
//
//  Created by sid on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterAccount.h"

static void (^block)(NSDictionary *);

@implementation TwitterAccount

+ (TwitterAccount *)sharedInstance
{
    static dispatch_once_t pred;
    static TwitterAccount *singleton;
    dispatch_once(&pred, ^{
        
        singleton = [[TwitterAccount alloc] init];
    });
    
    return singleton;
}

- (void)reverseInfoFromUsername:(NSString *)twitterScreenName infoCompletion:(void (^)(NSDictionary *))infoUsername
{
    block = nil;
    block = [infoUsername copy];
    
    NSString *url = [NSString stringWithFormat:@"http://api.twitter.com/users/show/%@.json", twitterScreenName];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	responseData = [NSMutableData new];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] 
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad 
                                         timeoutInterval:180.0];
    
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)cancelRequest
{
	[connection cancel];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[self handleError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

	if((responseString == nil) || ([responseString isEqualToString:@""])) 
    {
        block(nil);
		return;
	}
    
	if([[responseString substringToIndex:8] compare:@"notFound"] == NSOrderedSame)
    {
        block(nil);
        return;
	} 
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    
    if ([NSJSONSerialization isValidJSONObject:dictionary])
    {
        block(dictionary);
    }
    else
        block(nil);
}

- (void)handleError:(NSError *)error
{
    block(nil);
}

@end
