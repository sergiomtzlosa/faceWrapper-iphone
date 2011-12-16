FaceWrapper for iPhone
===================

![FaceWrapper](https://github.com/sergiomtzlosa/faceWrapper-iphone/raw/master/faceWrapper-iphone.png)

Wrapper class to detect faces from http://face.com, you will need an API key and API Secret which you can get in developer.face.com.

This controller implements a custom object called FWObject where you can set properties to find in the image.

You can search faces using REST or POST service and you can receive JSON or XML response but you always get a NSDictionary with all data, you don't have to parse the raw response.

Dependencies: This projects uses FBGraph to connect Facebook and SBJSON

You can analyze images from the web or local images, but always as JPG files.

* Added multiple POST images, FWImage has a property tag returned on delegate method, tag property on failure or REST request has -1 value.
* Added recognition for images on REST/POST for Facebook accounts
* Added photo training
* Added Twitter/Facebook authentication
* Added status account management
* Added framework support (you MUST install https://github.com/kstenerud/iOS-Universal-Framework for framework templates)

<pre>

    //Define your API from faces.com --> http://developers.face.com/account/
    
    [FWKeysHelper setFaceAPI:@"YOUR_FACE_API_KEY"];
    [FWKeysHelper setFaceSecretAPI:@"YOUR_FACE_API_SECRET_KEY"];
    
    //Define your Facebook Tokens at https://developers.facebook.com and set them in your face.com account

    [FWKeysHelper setFacebookAppID:@"YOUR_FACEBOOK_APPLICATION_ID"];
    
    //Define your xAuth Tokens at developer.twitter.com and set them in your face.com account
    
    [FWKeysHelper setTwitterConsumerKey:@"YOUR_TWITTER_CONSUMER_KEY"];
    [FWKeysHelper setTwitterConsumerSecret:@"YOUR_TWITTER_CONSUMER_SECRET"];
    
    //Images must be ALWAYS JPG
    
    FWObject *object = [FWObject new];
    
    
    //REST
    NSMutableArray *urlImages = [NSMutableArray new];
    NSURL *urlImage = [NSURL URLWithString:@"http://images.wikia.com/powerrangers/images/f/fe/ActorJohnCho_John_Shea_55027822.jpg"];
    [urlImages addImageToArray:urlImage];
    [object setUrls:urlImages];
    
    object.isRESTObject = YES;
    //END REST
    
    /*
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
     */
    
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
    //[uidsArray addUIDsToArray:@"xxxx@twitter.com"]; //only for twitter authentication
    
    recognition.uids = uidsArray;
    
    FWImageController *controller = [[FWImageController alloc] initWithNibName:@"FWImageController" bundle:nil];
    controller.objects = [NSArray arrayWithObjects:object, recognition, nil];
    controller.delegate = self;
    
    [self presentModalViewController:controller animated:YES];
    
    FWObject *statusObject = [FWObject objectWithObject:recognition];

    //WARNING SLOW OPERATION!!!
    //if (!recognition.isRESTObject)
        [[FaceWrapper instance] statusFaceWithFWObject:statusObject delegate:self]; //POST ONLY
    
    //FWObject *trainObject = [FWObject objectWithObject:recognition];
    //trainObject.callback_url = [NSURL URLWithString:@"http://www.facebook.com/connect/login_success.html"]; //dummy callback URL
    
    //WARNING SLOW OPERATION!!!
    //[[FaceWrapper instance] trainFaceWithFWObject:trainObject delegate:self runInBackground:NO];

</pre>

On delegate method you will receive the response for detection or recognition:

<pre>

- (void)controllerDidFindFaceItemWithObject:(NSDictionary *)faces postImageTag:(int)tag
{
    ParseObject *parsed = [[ParseObject alloc] initWithRawDictionary:faces];
    
    [parsed loopOverFaces:^(NSDictionary *face) {
        
        NSLog(@"FACE: %@", face);
    }];
}

</pre>

Also, you should implement FaceWrapperDelegate to make train or status operations:

On training operations you MUST provide a callback URL due to slowness operation.

<pre>

//Train method
[[FaceWrapper instance] statusFaceWithFWObject:statusObject delegate:self]; //POST ONLY

//Status method
[[FaceWrapper instance] trainFaceWithFWObject:trainObject delegate:self runInBackground:NO];
</pre>

<pre>
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

</pre>

Use detection method just to place squares on photo's faces:

<pre>

[[FaceWrapper instance] detectFaceWithFWObject:object 
                               runInBackground:NO
                                completionData:^(NSDictionary *response, int tagImagePost) {

                    //Detection response and tag of the image
}];

</pre>

Facebook.get service how-to:

<pre>

FBGetterObject *fbObject = [[FBGetterObject alloc] initWithFWObject:recognition];

uidsArray = [NSMutableArray new];
[uidsArray addUIDsToArray:@"xxxxxxx@facebook.com"];

fbObject.uids = uidsArray;
fbObject.format = FORMAT_TYPE_JSON;
fbObject.limit = 10;
fbObject.callback_url = nil;
fbObject.attributes = [NSArray arrayWithObjects:[FBGetterManager objectFromFBAttribute:FBATTRIBUTE_GENDER_FEMALE], [FBGetterManager objectFromFBAttribute:FBATTRIBUTE_GLASSES_TRUE], [FBGetterManager objectFromFBAttribute:FBATTRIBUTE_PITCH_CENTER], [FBGetterManager objectFromFBAttribute:FBATTRIBUTE_ROLL_RANGE], [FBGetterManager objectFromFBAttribute:FBATTRIBUTE_YAW_CENTER], nil];
    
fbObject.rollRange = CGPointMake(40.0, 150.0);
    
[FBGetterManager requestForFacebookWithObject:fbObject completionBlock:^(NSDictionary *dictionary) {
        
    NSLog(@"FBDICTIONARY: %@", dictionary);
}];

</pre>

WrapperFace framework
---------------------

FaceWrapper project now turn to framework (but also single files support), the new framework tries to reach an easy way to integrate with face.com services.

Just drag WrapperFace.embeddedframework to your protect folder, select WrapperFace.framework from your project [BUILD PHASES] -> [LINK BINARY WITH LIBRARIES] -> [BUTTON "+"].

On your build setting into "Other linker Flags" add -ObjC and -all_load.

Import framework as:

<pre>
#import <WrapperFace/FWImageController.h>
#import <WrapperFace/FWKeysHelper.h>
</pre>

Wrapped services
----------------

- faces.detect
- faces.recognize
- faces.group
- faces.train
- faces.status
- account.users
- account.limits/.spaces
- facebook.get

Follow me on twitter : [http://twitter.com/#!/sergimtzlosa](@sergimtzlosa)