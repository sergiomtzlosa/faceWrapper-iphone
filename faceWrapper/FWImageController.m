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
@synthesize object, delegate;

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
    
    if (([object.urls count] == 0) || ((id)object == nil))
    {
        [NSException exceptionWithName:@"URLs object" reason:@"URL image array is NULL" userInfo:nil];
    }
    
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
    
    if (object.isRESTObject)
    {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[object.urls objectAtIndex:0]]];
        imageView = [[UIImageView alloc] initWithImage:image];
    }
    else
    {
        UIImage *image = [UIImage imageWithData:[(FWImage *)[object.postImages objectAtIndex:0] data]];
        imageView = [[UIImageView alloc] initWithImage:image];
    }

    [self.view addSubview:imageView];
    [self.view addSubview:toolBar];
    [self findFaces];
}

- (void)findFaces
{    
    [[FaceWrapper instance] detectFaceWithFWObject:object runInBackground:NO completionData:^(NSDictionary *response) {

        //remark faces on image (remove it if you want)
        [self remarkFaces:response];
        
        NSString *stringSEL = NSStringFromSelector(@selector(controllerDidFindFaceItemWithObject:));
        
        [stringSEL selectorDidRespondInClass:self.delegate
                                     execute:^{
                                         
                                        [self.delegate controllerDidFindFaceItemWithObject:response];
                                     }];
    }];
}

#define degreesToRadians(x) (M_PI * x / 180.0)

- (void)remarkFaces:(NSDictionary *)dataFaces
{
    ParseObject *parsed = [[ParseObject alloc] initWithRawDictionary:dataFaces];

    [parsed loopOverFaces:^(NSDictionary *face) {
        
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