//
//  FWImageController.m
//  faceWrapper
//
//  Created by Sergio on 30/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "FWImageController.h"

@interface FWImageController (Private)

- (void)findFaces;
- (void)remarkFaces:(NSDictionary *)dataFaces;

@end

@implementation FWImageController
@synthesize objects, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    toolBar.frame = CGRectMake(0, 420, 320, 40);
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                   target:nil 
                                                                                   action:nil];

    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(dismissControll)];
    
    [toolBar setItems:[NSArray arrayWithObjects:flexibleSpace, dismissButton,nil]];
    
    
    [self.view addSubview:toolBar];
    [self findFaces];
}

- (void)findFaces
{    
    for (FWObject *object in objects)
    {
        if (object.isRESTObject)
        {
            ([object.urls count] == 0) ? [FaceWrapper throwExceptionWithName:@"URL array items exception" 
                                                                      reason:@"URL array cannot be null"] : nil;
            
            (![object.urls arrayIsTypeOf:[NSURL class]]) ? [FaceWrapper throwExceptionWithName:@"URL array type exception" 
                                                                                        reason:@"Array object is not an NSURL object, addURLsToArray: from NSMutableArray"]: nil;
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[object.urls objectAtIndex:0]]];
            if (imageView == nil)
                imageView = [[UIImageView alloc] initWithImage:image];
        }
        else
        {
            UIImage *image = [UIImage imageWithData:[(FWImage *)[object.postImages objectAtIndex:0] data]];
            if (imageView == nil)
                imageView = [[UIImageView alloc] initWithImage:image];
        }

        imageView.tag = 123;
        
        if ([self.view viewWithTag:imageView.tag] == nil)
            [self.view addSubview:imageView];
        
        [[FaceWrapper instance] detectFaceWithFWObject:object 
                                       runInBackground:NO
                                        completionData:^(NSDictionary *response, int tagImagePost) 
        {
                    
            if (!object.wantRecognition) 
            {
                //remark faces on image (remove it if you want)
                [self remarkFaces:response];
                
                NSString *stringSEL = NSStringFromSelector(@selector(controllerDidFindFaceItemWithObject:postImageTag:));
                
                [stringSEL selectorDidRespondInClass:self.delegate
                                             execute:^{
                                                 
                                                 [self.delegate controllerDidFindFaceItemWithObject:response 
                                                                                       postImageTag:tagImagePost];
                                             }];
                
            }
            else
            {
                NSString *stringSEL = NSStringFromSelector(@selector(controllerDidRecognizeFaceItemWithObject:postImageTag:));
                
                [stringSEL selectorDidRespondInClass:self.delegate
                                             execute:^{
                                                 
                                                 [self.delegate controllerDidRecognizeFaceItemWithObject:response 
                                                                                            postImageTag:tagImagePost];
                                             }];
            }
        }];
    }
}

#define degreesToRadians(x) (M_PI * x / 180.0)

- (void)remarkFaces:(NSDictionary *)dataFaces
{
    ParseObject *parsed = [[ParseObject alloc] initWithRawDictionary:dataFaces];
    
    [parsed loopOverFaces:^(NSDictionary *face) {
        
        //NSLog(@"%@", face);
        CGFloat width = ([[face objectForKey:@"width"] floatValue] * imageView.frame.size.width) / 100;
        CGFloat height = ([[face objectForKey:@"height"] floatValue] * imageView.frame.size.height) / 100;
        CGFloat x = ([[(NSDictionary *)[face objectForKey:@"center"] objectForKey:@"x"] floatValue] * imageView.frame.size.width) / 100;
        CGFloat y = ([[(NSDictionary *)[face objectForKey:@"center"] objectForKey:@"y"] floatValue] * imageView.frame.size.height) / 100;

        CGFloat roll = [[face objectForKey:@"roll"] floatValue];
        
        UIView *square = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        square.backgroundColor = [UIColor clearColor];
        square.layer.borderColor = [UIColor redColor].CGColor;
        square.layer.borderWidth = 1.0;
        square.center = CGPointMake(x, y);
        [square setTransform:CGAffineTransformMakeRotation(degreesToRadians(roll))];
        
        [imageView addSubview:square];
    }];
}

- (void)dismissControll
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end