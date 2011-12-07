//
//  StringChecker.m
//  faceWrapper
//
//  Created by macpocket1 on 07/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+StringChecker.h"

@implementation NSString (StringChecker)

- (BOOL)containsString:(NSString *)aString
{
	NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
	
	if (range.location != NSNotFound) 
	{
		return YES;
	}
	else 
	{
		return NO;
	}
}

@end
