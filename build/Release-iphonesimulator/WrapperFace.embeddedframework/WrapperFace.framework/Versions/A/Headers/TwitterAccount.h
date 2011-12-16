//
//  TwitterAccount.h
//  faceWrapper
//
//  Created by sid on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterAccount : NSObject
{
@private
    NSMutableData *responseData;
    NSURLConnection *connection;
}

+ (TwitterAccount *)sharedInstance;
- (void)reverseInfoFromUsername:(NSString *)twitterScreenName infoCompletion:(void (^)(NSDictionary *))infoUsername;
- (void)handleError:(NSError *)error;

@end
