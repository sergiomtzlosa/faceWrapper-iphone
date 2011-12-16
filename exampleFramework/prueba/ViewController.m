//
//  ViewController.m
//  prueba
//
//  Created by macpocket1 on 16/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [FWKeysHelper setFaceAPI:@""];
    [FWKeysHelper setFaceSecretAPI:@""];
    [FWKeysHelper setFacebookAppID:@""];
    [FWKeysHelper setTwitterConsumerKey:@""];
    [FWKeysHelper setTwitterConsumerSecret:@""];
    
    FWObject *object = [FWObject new];
    
    /*
     //REST
     NSMutableArray *urlImages = [NSMutableArray new];
     NSURL *urlImage = [NSURL URLWithString:@"http://images.wikia.com/powerrangers/images/f/fe/ActorJohnCho_John_Shea_55027822.jpg"];
     [urlImages addImageToArray:urlImage];
     [object setUrls:urlImages];
     
     object.isRESTObject = YES;
     //END REST
     */
    
    //POST
    UIImage *image = [UIImage imageNamed:@"girls.jpg"];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    FWImage *fwImage = [[FWImage alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)
                                           imageName:@"girls"
                                           extension:@"jpg"
                                         andFullPath:@""];
    fwImage.tag = 999;
    [images addImagePOSTToArray:fwImage];
    
    [object setPostImages:images];
    
    object.isRESTObject = NO;
    //END POST
    
    object.wantRecognition = NO;
    
    [object setDetector:DETECTOR_TYPE_DEFAULT];
    [object setFormat:FORMAT_TYPE_JSON];
    
    NSMutableArray *attr = [NSMutableArray new];
    [attr addAttributeToArray:ATTRIBUTE_GENDER];
    [attr addAttributeToArray:ATTRIBUTE_GLASSES];
    [attr addAttributeToArray:ATTRIBUTE_SMILING];
    
    [object setAttributes:attr];
    [object setCallback:@""];
    [object setCallback_url:nil];
    
    FWImageController *controller = [[FWImageController alloc] initWithNibName:@"FWImageController" bundle:nil];
    controller.objects = [NSArray arrayWithObjects:object, nil];
    controller.delegate = self;
    
    [self presentModalViewController:controller animated:YES];
}

#pragma -
#pragma FWImageControllerDelegate methods

- (void)controllerDidFindFaceItemWithObject:(NSDictionary *)faces postImageTag:(int)tag
{
    //tag = -1 means NO TAG, this tag is only in available to check POST images
    NSLog(@"DETECTED photo tag: %d, %@", tag, faces);
    
    if ([faces count] == 0)
    {
        NSLog(@"NO FACES DETECTED - %@", faces);
    }
    else
    {
        ParseObject *parsed = [[ParseObject alloc] initWithRawDictionary:faces];
        
        [parsed loopOverFaces:^(NSDictionary *face) {
            
            NSLog(@"FACE DETECTED: %@", face);
        }]; 
    }
}

- (void)controllerDidRecognizeFaceItemWithObject:(NSDictionary *)faces postImageTag:(int)tag
{
    //tag = -1 means NO TAG, this tag is only in available to check POST images
    NSLog(@"RECOGNIZED photo tag: %d", tag);
    
    if ([faces count] == 0)
    {
        NSLog(@"NO FACES RECOGNIZED - %@", faces);
    }
    else
    {
        NSLog(@"RECOGNIZED : %@", faces);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
