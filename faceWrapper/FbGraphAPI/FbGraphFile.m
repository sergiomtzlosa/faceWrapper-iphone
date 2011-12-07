/*
 * Copyright (c) 2010, Dominic DiMarco (dominic@ReallyLongAddress.com)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * -Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 
 * -Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * -Neither the name of the author nor the
 * names of its contributors may be used to endorse or promote products
 * derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

//
//  FbGraphFile.m
//  oAuth2Test
//
//  Created by dominic dimarco (ddimarco@room214.com @dominicdimarco) on 6/9/10.
//

#import "FbGraphFile.h"


@implementation FbGraphFile

@synthesize uploadImage;

- (id)initWithImage:(UIImage *)upload_image {
	
	if (self = [super init]) {
		self.uploadImage = upload_image;
	}
	return self;
}

/**
 * this way the class is easily extensible to other file
 * types as FB allows us to upload them into the graph...
 * with little if any modification to the code 
**/
- (void)appendDataToBody:(NSMutableData *)body {
	
	/**
	 * Facebook Graph API only support images at the moment, surely videos must occur soon.
	 **/
	
	NSData *picture_data = UIImagePNGRepresentation(uploadImage);
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media\";\r\nfilename=\"media.png\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:picture_data];
	
}

-(void) dealloc {
	
	if (uploadImage != nil) {
		[uploadImage release];
	}
	
    [super dealloc];
}

@end
