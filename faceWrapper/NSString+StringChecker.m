//
//  StringChecker.m
//  faceWrapper
//
//  Created by Sergio on 07/12/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
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
