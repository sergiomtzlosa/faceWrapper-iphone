//
//  ViewController.m
//  faceWrapper
//
//  Created by Sergio on 28/11/11.
//  Copyright (c) 2011 Sergio. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Images must be ALWAYS JPG

    //#error SETUP your keys 
    
    //if your compile this project as framework do NOT set your keys, do it into the project where you add the framework
    //Define your API from skybiometry.com --> https://www.skybiometry.com/Account
    
    [FWKeysHelper setFaceAPI:@"xxxxxxxxxxx"];
    [FWKeysHelper setFaceSecretAPI:@"xxxxxxxxxxxx"];
    
    //Define your Facebook Tokens at https://developers.facebook.com and set them in your skybiometry.com account

    [FWKeysHelper setFacebookAppID:@"xxxxxxxxx"];
    
    //Define your xAuth Tokens at developer.twitter.com and set them in your skybiometry.com account
    
    [FWKeysHelper setTwitterConsumerKey:@"xxxxxxxxxxxx"];
    [FWKeysHelper setTwitterConsumerSecret:@"xxxxxxxxxxx"];
    
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
    
    FWObject *recognition = [FWObject objectWithObject:object];
    recognition.wantRecognition = YES;
    recognition.accountNamespace = @"";
    recognition.useFacebook = YES;
    
    //recognition.twitter_username = @"";
    //recognition.twitter_password = @"";
    
    NSMutableArray *uidsArray = [NSMutableArray new];
    [uidsArray addUIDsToArray:@"friends@facebook.com"]; //only for facebook authentication
    //[uidsArray addUIDsToArray:@"xxxxx@twitter.com"]; //only for twitter authentication
    
    recognition.uids = uidsArray;
    
    FWImageController *controller = [[FWImageController alloc] initWithNibName:@"FWImageController" bundle:nil];
    controller.objects = [NSArray arrayWithObjects:object, recognition, nil];
    controller.delegate = self;
    
    [self presentModalViewController:controller animated:YES];
    
    //remove this return for more operations
    return;
    
    //FWObject *statusObject = [FWObject objectWithObject:recognition];

    //WARNING SLOW OPERATION!!!
    //if (!recognition.isRESTObject)
    //    [[FaceWrapper instance] statusFaceWithFWObject:statusObject delegate:self]; //POST ONLY
    
    //FWObject *trainObject = [FWObject objectWithObject:recognition];
    //trainObject.callback_url = [NSURL URLWithString:@"http://www.facebook.com/connect/login_success.html"]; //dummy callback URL
    
    //WARNING SLOW OPERATION!!!
    //[[FaceWrapper instance] trainFaceWithFWObject:trainObject delegate:self runInBackground:NO];
    
    FBGetterObject *fbObject = [[FBGetterObject alloc] initWithFWObject:recognition];

    uidsArray = [NSMutableArray new];
    [uidsArray addUIDsToArray:@"xxxxxxxx@facebook.com"];

    fbObject.uids = uidsArray;
    fbObject.format = FORMAT_TYPE_JSON;
    fbObject.limit = 10;
    fbObject.callback_url = nil;
    fbObject.attributes = [NSArray arrayWithObjects:[FBGetterManager objectFromFBAttribute:FBATTRIBUTE_GENDER_FEMALE], 
                           [FBGetterManager objectFromFBAttribute:FBATTRIBUTE_GLASSES_TRUE], 
                           [FBGetterManager objectFromFBAttribute:FBATTRIBUTE_PITCH_CENTER], 
                           [FBGetterManager objectFromFBAttribute:FBATTRIBUTE_ROLL_RANGE], 
                           [FBGetterManager objectFromFBAttribute:FBATTRIBUTE_YAW_CENTER], nil];
    
    fbObject.rollRange = CGPointMake(40.0, 150.0);
    
    [FBGetterManager requestForFacebookWithObject:fbObject completionBlock:^(NSDictionary *dictionary) {
        
        NSLog(@"FBDICTIONARY: %@", dictionary);
    }];
    
    return;
    
    //DOC URL: https://www.skybiometry.com/Documentation#tags/save
    
    FWObject *taggerObject = [FWObject objectWithObject:object];
    taggerObject.tagUID = @"YOUR_TAG_UID";
    taggerObject.tagLabel = @"YOUR_TAG_LABEL";
    taggerObject.tagUID = @"YOUR_TAG_UID";
    taggerObject.callback = @"";
    taggerObject.password = @"YOUR_PASSWORD"; //for use when saving tags is a privileged action in your client-side application (must be enabled in application settings)
    
    NSMutableArray *arrayTids = [NSMutableArray new];
    [arrayTids addTidToArray:@"0"]; //example how to add tid
    
    taggerObject.tids = arrayTids; //one or more tag ids to associate with the passed uid. The tag id is a reference field in the response of faces.detect and faces.recognize methods
    
    [[TaggerManager sharedInstance] actionTagWithObject:taggerObject
                                               doAction:TAG_ACTION_SAVE
                                        blockCompletion:^(NSDictionary *data) {
                                                   
        NSLog(@"%@", data);
    }];
    
    [[TaggerManager sharedInstance] actionTagWithObject:taggerObject 
                                               doAction:TAG_ACTION_REMOVE 
                                        blockCompletion:^(NSDictionary *data) {
        
        NSLog(@"%@", data);
    }];
    
    //DOC URL: https://www.skybiometry.com/Documentation#tags/add
    
    taggerObject.tagURL = @"YOUR_TAG_URL";
    taggerObject.tagX = 0;
    taggerObject.tagY = 0;
    taggerObject.tagWidth = 0;
    taggerObject.tagUID = @"YOUR_TAG_UID";
    taggerObject.taggerID = @"YOUR_TAGGER_ID";
    taggerObject.tagLabel = @"YOUR_LABEL";
    taggerObject.callback = @"";
    taggerObject.password = @"YOUR_PASSWORD";
    
    [[TaggerManager sharedInstance] addTagWithObject:object blockCompletion:^(NSDictionary *data) {
        
        NSLog(@"%@", data);
    }];
}

#pragma mark -
#pragma mark FaceWrapperDelegate methods

- (void)faceWrapperTrainFaceSuccess:(NSDictionary *)faceData photoTag:(int)tag
{
    NSLog(@"TRAIN: %@", faceData);
}

- (void)faceWrapperStatusFacing:(NSDictionary *)faceData photoTag:(int)tag
{
    NSLog(@"STATUS: %@", faceData);
}

#pragma -
#pragma FWImageControllerDelegate methods

- (void)controllerDidFindFaceItemWithObject:(NSDictionary *)faces postImageTag:(int)tag
{
    //tag = -1 means NO TAG, this tag is only in available to check POST images
    NSLog(@"DETECTED photo tag: %d", tag);
    
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end