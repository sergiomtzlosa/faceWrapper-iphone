//
//  XAuthAutenticator.m
//  iphone_xauth
//
//  Created by Sergio on 05/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "XAuthAutenticator.h"
#include <CommonCrypto/CommonHMAC.h>
#import "Constants.h"
#import "FWKeysHelper.h"

@interface NSData (TwitterUtils)

+ (NSString *)encodeData:(NSData *)data;
+ (NSData *)generateSignatureOverString:(NSString *)string withSecret:(NSData *)secret;
+ (NSString *)formEncodeString: (NSString *)string;
+ (NSString *)formDecodeString: (NSString *)string;

@end

@implementation NSData (TwitterUtils)

static const char sBase64Digits[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (NSString *)encodeData:(NSData *)data
{
    if (data == nil)
        return nil;
    
    NSUInteger dataLength = [data length];
    const UInt8 *dataBytePtr = [data bytes];
    
    NSUInteger encodedLength = (dataLength / 3) * 4;
    if ((dataLength % 3) != 0)
        encodedLength += 4;
    
    NSMutableString* string = [NSMutableString stringWithCapacity:encodedLength];
    
    char buffer[5];
    
    while (dataLength >= 3)
    {
        buffer[0] = sBase64Digits[dataBytePtr[0] >> 2];
        buffer[1] = sBase64Digits[((dataBytePtr[0] << 4) & 0x30) | (dataBytePtr[1] >> 4)];
        buffer[2] = sBase64Digits[((dataBytePtr[1] << 2) & 0x3c) | (dataBytePtr[2] >> 6)];
        buffer[3] = sBase64Digits[dataBytePtr[2] & 0x3f];
        buffer[4] = 0x00;
        
        [string appendString: [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding]];
        
        dataBytePtr += 3;
        dataLength -= 3;
    }
    
    if (dataLength > 0)
    {
        char fragment = (dataBytePtr[0] << 4) & 0x30;
        if (dataLength > 1) 
        {
            fragment |= dataBytePtr[1] >> 4;
        }
        
        buffer[0] = sBase64Digits[dataBytePtr[0] >> 2];
        buffer[1] = sBase64Digits[(int) fragment];
        buffer[2] = (dataLength < 2) ? '=' : sBase64Digits[(dataBytePtr[1] << 2) & 0x3c];
        buffer[3] = '=';
        buffer[4] = 0x00;
        
        [string appendString: [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding]];
    }
    
    return string;
}

+ (NSData *)generateSignatureOverString:(NSString*)string withSecret:(NSData *)secret
{
	CCHmacContext context;
	CCHmacInit(&context, kCCHmacAlgSHA1, [secret bytes], [secret length]);	
	
	NSData *data = [string dataUsingEncoding: NSASCIIStringEncoding];
	CCHmacUpdate(&context, [data bytes], [data length]);
    
	unsigned char digestBytes[CC_SHA1_DIGEST_LENGTH];
	CCHmacFinal(&context, digestBytes);
	
	return [NSData dataWithBytes:digestBytes length:CC_SHA1_DIGEST_LENGTH];
}

+ (NSString *)formEncodeString:(NSString *)string
{
    NSString *encoded = (__bridge NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef) string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    
    return encoded;
}

+ (NSString *)formDecodeString: (NSString*) string
{
	NSString *decoded = (__bridge NSString*) CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef) string, NULL);
    
	return decoded;
}

@end

@interface XAuthAutenticator (Private)

- (NSString *)generateNonce;
- (NSString *)generateTimestamp;
- (NSString *)formEncodeString: (NSString*) string;

@end

static void (^completion)(NSString *, NSString *, NSString *) = nil;
static void (^errorBlock)(NSError *) = nil;

@implementation XAuthAutenticator
@synthesize oauth_token, oauth_token_secret, oauth_user, statusCode, connection, dataReceived;

- (void)completionBlock:(void (^)(NSString *, NSString *, NSString *))block completionError:(void (^)(NSError *))error;
{
    completion = nil;
    completion = [block copy];
    
    errorBlock = nil;
    errorBlock = [error copy];
}

+ (XAuthAutenticator *)sharedInstance
{
    static dispatch_once_t pred;
    static XAuthAutenticator *singleton;
    dispatch_once(&pred, ^{
        
        singleton = [[XAuthAutenticator alloc] init];
    });
    
    return singleton;
}

- (NSString *)generateTimestamp
{
	return [NSString stringWithFormat: @"%d", time(NULL)];
}

- (NSString *)generateNonce
{
	NSString *nonce = nil;
    
	CFUUIDRef uuid = CFUUIDCreate(nil);
	if (uuid != NULL)
    {
		nonce = (__bridge NSString*) CFUUIDCreateString(nil, uuid);
		CFRelease(uuid);
	}
    
    return nonce;
}

- (NSString *)formEncodeString: (NSString*) string
{
	NSString *encoded = (__bridge NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                     (__bridge CFStringRef) string, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	return encoded;
}

- (void)executeWithUsername:(NSString *)user password:(NSString *)pass
{
    oauth_consumer_key = [FWKeysHelper twitterConsumerKey];//kTwitterConsumerKey;
    oauth_consumer_secret = [FWKeysHelper twitterConsumerSecret];//kTwitterConsumerSecret;
    username = user;
    password = pass;
    
    dataReceived = [NSMutableData new];
    NSString* timestamp = [self generateTimestamp];
    NSString* nonce = [self generateNonce];
    
    NSDictionary *build = [NSDictionary dictionaryWithObjectsAndKeys:
                           username, @"x_auth_username",
                           password, @"x_auth_password",
                           @"client_auth", @"x_auth_mode",
                           nil];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:build];
    
    [parameters setValue:oauth_consumer_key forKey:@"oauth_consumer_key"];
    [parameters setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
    [parameters setValue:timestamp forKey:@"oauth_timestamp"];
    [parameters setValue:nonce forKey:@"oauth_nonce"];
    [parameters setValue:@"1.0" forKey:@"oauth_version"];
    
    if ((id)self.oauth_token != nil)
        [parameters setValue:self.oauth_token forKey: @"oauth_token"];
    
    NSMutableString *normalizedRequestParameters = [NSMutableString string];
    
    for (NSString *key in [[parameters allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)])
    {
        if ([normalizedRequestParameters length] != 0) 
        {
            [normalizedRequestParameters appendString:@"&"];
        }
        
        [normalizedRequestParameters appendString:key];
        [normalizedRequestParameters appendString:@"="];
        [normalizedRequestParameters appendString:[self formEncodeString:[parameters objectForKey:key]]];
    }
    
    //NSLog(@"XXX normalizedRequestParameters = %@", normalizedRequestParameters);
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
    
    NSString* signatureBaseString = [NSString stringWithFormat: @"%@&%@&%@", @"POST", [self formEncodeString:[NSString stringWithFormat:@"%@://%@%@", [url scheme], [url host], [url path]]],
                                     [self formEncodeString: normalizedRequestParameters]];
    
    //NSLog(@"XXX signatureBaseString = %@", signatureBaseString);
    
    // Create the secret
    NSString *secret = nil;
    
    if (oauth_token_secret != nil)
    {
        secret = [NSString stringWithFormat:@"%@&%@", [self formEncodeString:oauth_consumer_secret], [self formEncodeString:oauth_token_secret]];
    }
    else 
    {
        secret = [NSString stringWithFormat:@"%@&", [self formEncodeString: oauth_consumer_secret]];
    }
    
    //NSLog(@"XXX Secret = %@", secret);
    
    NSString *signatureString = [NSData encodeData:[NSData generateSignatureOverString:signatureBaseString withSecret:[secret dataUsingEncoding:NSASCIIStringEncoding]]];
    
    normalizedRequestParameters = [NSMutableString string];
    
    for (NSString *key in [[build allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)])
    {
        if ([normalizedRequestParameters length] != 0) 
        {
            [normalizedRequestParameters appendString: @"&"];
        }
        
        [normalizedRequestParameters appendString:key];
        [normalizedRequestParameters appendString:@"="];
        [normalizedRequestParameters appendString:[self formEncodeString:[build objectForKey: key]]];
    }
    
    //NSLog(@"XXX POST Data = %@", normalizedRequestParameters);
    
    NSData *requestData = [normalizedRequestParameters dataUsingEncoding:NSUTF8StringEncoding];
    
    // Setup the Authorization header
    NSMutableDictionary *authorizationParameters = [NSMutableDictionary dictionary];
    
    [authorizationParameters setValue:nonce forKey:@"oauth_nonce"];
    [authorizationParameters setValue:timestamp forKey:@"oauth_timestamp"];
    [authorizationParameters setValue:signatureString forKey:@"oauth_signature"];
    [authorizationParameters setValue:@"HMAC-SHA1" forKey:@"oauth_signature_method"];
    [authorizationParameters setValue:@"1.0" forKey:@"oauth_version"];
    [authorizationParameters setValue:oauth_consumer_key forKey:@"oauth_consumer_key"];
    
    if ((id)self.oauth_token != nil)
    {
        [authorizationParameters setValue:oauth_token forKey:@"oauth_token"];			
    }
    
    NSMutableString *authorization = [NSMutableString stringWithString:@"OAuth realm=\"\""];
    
    
    for (NSString *key in [authorizationParameters allKeys])
    {
        [authorization appendString:@", "];
        [authorization appendString:key];
        [authorization appendString:@"="];
        [authorization appendString:@"\""];
        [authorization appendString:[self formEncodeString:[authorizationParameters objectForKey:key]]];
        [authorization appendString:@"\""];
    }
    
    //NSLog(@"Authorization: %@", authorization);
    
    // Setup the request and connection
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                       timeoutInterval:15.0];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    self.connection = [NSURLConnection connectionWithRequest: request delegate: self];
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[dataReceived appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	statusCode = [response statusCode];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //NSLog(@"%@", error);
    errorBlock(error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString* response = [[NSString alloc] initWithData: dataReceived encoding: NSUTF8StringEncoding];
    
    if (response == nil)
        response = [[NSString alloc] initWithData: dataReceived encoding: NSASCIIStringEncoding];
    
	if (statusCode != 200) 
    {
        NSLog(@"Response = %@ - status code %d", response, statusCode);
        
        if (statusCode == 401)
        {
            completion(oauth_token, oauth_token_secret, oauth_user);
        }
        else 
            completion(response, response, response);
	}
    else 
    {
        if (response == nil) 
        {
            completion(response, response, response);
            return;
        }
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        NSArray *pairs = [response componentsSeparatedByString: @"&"];
        
        for (NSString *pair in pairs)
        {
            NSArray *nameValue = [pair componentsSeparatedByString: @"="];
            
            if ([nameValue count] == 2)
            {
                [parameters setValue:[NSData formDecodeString:[nameValue objectAtIndex:1]]
                              forKey:[nameValue objectAtIndex:0]];
            }
        }
        
        oauth_token = [parameters valueForKey:@"oauth_token"];
        oauth_token_secret = [parameters valueForKey:@"oauth_token_secret"];
        oauth_user = [parameters valueForKey:@"user_id"];
        
        completion(oauth_token, oauth_token_secret, oauth_user);
	}
	
	self.dataReceived = nil;
}

- (void)authenticateWithToken:(NSString *)token
{
    NSString *stringURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authenticate?oauth_token=%@", token];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
}

+ (void)clearTokens
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:@"oauth_token"];
    [defaults setValue:nil forKey:@"oauth_token_secret"];
    [defaults synchronize];
}

@end