//
//  ViewController.m
//  MirrorApp
//
//  Created by Suhail Bhat on 12/12/14.
//  Copyright (c) 2014 Suhail Bhat. All rights reserved.
//

#define CANCEL_BUTTON_HEIGHT_WIDTH 30
#define TOOLBAR_HEIGHT 40
#define PADDING 10
#define IMAGEVIEW_OFFSET 20

#import "ViewController.h"
#import "CameraOverlay.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureMovieFileOutput *mMovieFileOutput;
    NSTimer *mTimer;
}

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIView *cameraOverlay;
@property (strong, nonatomic) UIButton *clickButton;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIImageView *imageDisplayView;
@property (strong, nonatomic) UIButton *cancelImageButton;
@property (assign, nonatomic) BOOL imageTaken;
@property (nonatomic, strong) UIImage *screenShot;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) AVCaptureSession *capturedSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer  *previewLayer;
@property (nonatomic, retain) AVCaptureStillImageOutput	*capturedStillImageOutput;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self allocateViews];
    [self setUpViews];
    self.imageTaken = NO;
}

-(void)allocateViews {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imageDisplayView = [[UIImageView alloc] initWithFrame:CGRectMake(-IMAGEVIEW_OFFSET, 0, self.view.frame.size.width+2*IMAGEVIEW_OFFSET, self.view.frame.size.height)];
    self.cancelImageButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - CANCEL_BUTTON_HEIGHT_WIDTH +PADDING , self.view.frame.size.height - TOOLBAR_HEIGHT - CANCEL_BUTTON_HEIGHT_WIDTH - PADDING, CANCEL_BUTTON_HEIGHT_WIDTH, CANCEL_BUTTON_HEIGHT_WIDTH)];
    [self.cancelImageButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
}

-(void)setUpViews {
    self.cancelImageButton.backgroundColor = [UIColor clearColor];
    [self.cancelImageButton addTarget:self action:@selector(cancelImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.imageDisplayView.hidden = YES;
    self.imageDisplayView.userInteractionEnabled = YES;
    [self.imageDisplayView addSubview:self.cancelImageButton];
    [self.view addSubview:self.imageDisplayView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self checkForCamera] || self.imageTaken) {
        return;
    }
    [self setUpAndPresentUIPicker];
    // In Next View Controller now!  //

    //[self setupCaptureSessionG];
    //[self setupCaptureSession];
}

-(void)setUpAndPresentUIPicker {
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraOverlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.clickButton = [[UIButton alloc] initWithFrame:self.cameraOverlay.frame];
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.cameraOverlay.frame.size.height, self.cameraOverlay.frame.size.width, 44)];
    NSArray *buttons = [NSArray arrayWithObjects:
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePicture:)],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(savePicture:)],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(settingsView:)], nil];
    self.toolbar.items = buttons;
    [self.clickButton addTarget:self action:@selector(clicktapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraOverlay addSubview:self.clickButton];
    [self.cameraOverlay addSubview:self.imageDisplayView];
    [self.cameraOverlay addSubview:self.toolbar];
    [self.clickButton setBackgroundColor:[UIColor clearColor]];
    self.imagePicker.cameraOverlayView = self.cameraOverlay;
    self.imagePicker.showsCameraControls = NO;
    self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:self.imagePicker animated:NO completion:NULL];
}

-(BOOL)checkForCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device has no camera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [myAlertView show];
        return NO;
    }
    return YES;
}

-(void)clicktapped:(id)sender {
    // Capture the image and and put it on Image View.
    // Unhide the Image view. Animate the tool bar to visible.
    //[self screenshotWindow]; -- Not Working!
    //[self captureStillImage];
    //[self.capturedSession stopRunning];
    //self.imageDisplayView.image = self.screenShot;
    self.imageTaken = YES;
    [self.imagePicker takePicture];
    self.imageDisplayView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.toolbar.frame = CGRectMake(0, self.cameraOverlay.frame.size.height-44, self.cameraOverlay.frame.size.width, 44);
    }];
}
-(void)savePicture:(id)sender {
    // Play sound & Flash Screen.
    AudioServicesPlaySystemSound (1108);

    UIView *flashView = [[UIView alloc] initWithFrame:self.imageDisplayView.frame];
    flashView.backgroundColor = [UIColor whiteColor];
    [self.imageDisplayView addSubview:flashView];
    [UIView animateWithDuration:0.5 animations:^{
        flashView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [flashView removeFromSuperview];
    }];
    // Save picture to Gallery.
    UIImage *saveImage = [self invertImageToProperOrientation:self.screenShot];
    UIImageWriteToSavedPhotosAlbum(saveImage, nil, nil, nil);
}

-(void)sharePicture:(id)sender {
    // Open sharing options
    UIImage *shareImage = [self invertImageToProperOrientation:self.screenShot];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[shareImage] applicationActivities:nil];
    [self.imagePicker presentViewController:activityController animated:YES completion:nil];
}

-(void)settingsView:(id)sender {
    // Present Settings view.
}

-(void)cancelImageButtonTapped:(id)sender {
    // Hide the image view
    // present imageview.
    self.imageTaken = NO;
    //[self.capturedSession startRunning];
    self.imageDisplayView.hidden = YES;
    self.imageDisplayView.image = nil;
    [UIView animateWithDuration:0.5 animations:^{
        self.toolbar.frame = CGRectMake(0, self.cameraOverlay.frame.size.height, self.cameraOverlay.frame.size.width, 44);
    }];
}

-(UIImage*)invertImageToProperOrientation:(UIImage*)image {
    UIImage *temp = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
    return [UIImage imageWithCGImage:temp.CGImage scale:temp.scale orientation:UIImageOrientationRightMirrored];
}
#pragma mark UIImagePickerDelegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    UIImage *flippedImage = [UIImage imageWithCGImage:chosenImage.CGImage scale:chosenImage.scale orientation:UIImageOrientationLeftMirrored];
    self.imageDisplayView.image = flippedImage;
    self.screenShot = flippedImage;
    [self.imageDisplayView setHidden:NO];
}

// Better Idea.  -- Doesn't work on Camera Image !
-(void)takeScreenShot {
    UIGraphicsBeginImageContext(self.imagePicker.view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    // Set the Screenshot to image instance.
    self.screenShot = UIGraphicsGetImageFromCurrentImageContext();
    // To remove the current bitmap from Stack.
    UIGraphicsEndImageContext();
}


// Take screenShot of Window.-- Doesn't work on Camera Display !

- (void)screenshotWindow {
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);

            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];

            // Restore the context
            CGContextRestoreGState(context);
        }
    }

    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageDisplayView.image = image;
}


#pragma  mark AVFoundation Taking ScreenShot

- (void)captureStillImage {
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.capturedStillImageOutput connections]];

    if ([videoConnection isVideoOrientationSupported])
    {
        [videoConnection setVideoOrientation:[[UIDevice currentDevice] orientation]];
    }

    [self.capturedStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)  {

         if (imageDataSampleBuffer != NULL) {

             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             CGSize imageSize = [[UIScreen mainScreen] bounds].size;
             UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);

             CGContextRef context = UIGraphicsGetCurrentContext();
             UIGraphicsPushContext(context);
             [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
             UIGraphicsPopContext();

             UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
             self.screenShot = screenshot;

             // We're done with the image context, so close it out.
             //
             UIGraphicsEndImageContext();
         }
         else if (error)
         {
             NSLog(@"Some Problem!");
         }
     }];
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for ( AVCaptureConnection *connection in connections )
    {
        for ( AVCaptureInputPort *port in [connection inputPorts] )
        {
            if ( [[port mediaType] isEqual:mediaType] )
            {
                return connection;
            }
        }
    }
    return nil;
}


- (void)setupCaptureSession {
    NSError *error = nil;
    self.capturedSession = [[AVCaptureSession alloc] init];

    self.capturedSession.sessionPreset = AVCaptureSessionPreset640x480;

    AVCaptureDevice *device = [self getFrontCamera]; // To get Front Camera for out requirement.

    // Create a device input with the device and add it to the session.
    //
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input) {
        // Handling the error appropriately.
    } else {
        [self.capturedSession addInput:input];
    }

    // Create a AVCaputreStillImageOutput instance and add it to the session
    //
    self.capturedStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.capturedStillImageOutput setOutputSettings:outputSettings];


    [self.capturedSession addOutput:self.capturedStillImageOutput];

    // This is what actually gets the AVCaptureSession going
    //
    [self.capturedSession startRunning];
}

-(AVCaptureDevice*)getFrontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil; // If front camera not found.
}

#pragma mark Gist from grusha. 

- (void)setupCaptureSessionG
{
    NSError *error = nil;
    self.capturedSession = [[AVCaptureSession alloc] init];

    self.capturedSession.sessionPreset = AVCaptureSessionPresetMedium;

    AVCaptureDevice *device = [self getFrontCamera];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput
                                   deviceInputWithDevice:device
                                   error:&error];
    if (!input) {
        // Handling the error appropriately
    }
    [self.capturedSession addInput:input];

    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]
                                        init];
    [self.capturedSession addOutput:output];

    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];

    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    //output.minFrameDuration = CMTimeMake(1, 15);
    [self.capturedSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    self.screenShot = image;
    //< Add your code here that uses the image >

}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sample
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sample);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(baseAddress, width,
                                                 height, 8,
                                                 bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little |
                                                 kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = [UIImage imageWithCGImage:quartzImage];

    CGImageRelease(quartzImage);

    return (image);
}

@end
