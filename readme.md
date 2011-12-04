FaceWrapper for iPhone
===================

Wrapper class to detect faces from http://face.com, you will need an API key and API Secret which you can get in developer.face.com.

This controller implements a custom object called FWObject where you can set properties to find in the image.

You can search faces using REST or POST service and you can receive JSON or XML response but you always get a NSDictionary with all data, you don't have to parse the raw response.

You can analyze images from the web or local images, but always as JPG files.

* Added multiple POST images, FWImage has a property tag returned on delegate method, tag property on failure or REST request has -1 value.

<pre>

    FWObject *object = [FWObject new];
    
    /*
     
    //REST
    NSMutableArray *urlImages = [NSMutableArray new];
    NSURL *urlImage = [NSURL URLWithString:@"http://images.wikia.com/powerrangers/images/f/fe/ActorJohnCho_John_Shea_55027822.jpg"];
    [urlImages addImageToArray:urlImage];
    [object setUrls:urlImages];
     
    object.isRESTObject = YES;
     
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
    controller.object = object;
    controller.delegate = self;
    
    [self presentModalViewController:controller animated:YES];

</pre>

On delegate method you will receive the response:

<pre>

- (void)controllerDidFindFaceItemWithObject:(NSDictionary *)faces postImageTag:(int)tag
{
    ParseObject *parsed = [[ParseObject alloc] initWithRawDictionary:faces];
    
    [parsed loopOverFaces:^(NSDictionary *face) {
        
        NSLog(@"FACE: %@", face);
    }];
}

</pre>

Wrapped services
----------------

* faces.detect
* account.users
* account.limits
* account.namespaces

![FaceWrapper](https://github.com/sergiomtzlosa/faceWrapper-iphone/raw/master/faceWrapper-iphone.png)

Follow me on twitter : [http://twitter.com/#!/sergimtzlosa](@sergimtzlosa)

