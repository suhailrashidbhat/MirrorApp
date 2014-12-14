//
//  SecondViewController.m
//  MirrorApp
//
//  Created by Suhail Bhat on 13/12/14.
//  Copyright (c) 2014 Suhail Bhat. All rights reserved.
//

#import "SecondViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@interface SecondViewController ()

@property (strong, nonatomic) IBOutlet UIView *container;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) IBOutlet UIImageView *imageDisplayView;
@property (strong, nonatomic) IBOutlet UIButton *takePictureButton;


@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageDisplayView.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [cancelButton addTarget:self action:@selector(cancelImageDisplay:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(self.container.frame.size.width - 40, self.container.frame.size.height - 80, 40, 40);
    [self.imageDisplayView addSubview:cancelButton];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;

    CALayer *viewLayer = self.container.layer;
    NSLog(@"viewLayer = %@", viewLayer);
    self.container.layer.bounds = [[UIScreen mainScreen] bounds];
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];

    captureVideoPreviewLayer.frame = [[UIScreen mainScreen] bounds];
    [self.container.layer addSublayer:captureVideoPreviewLayer];
    AVCaptureDevice *device = [self getFrontCamera];

    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:self.stillImageOutput];
    [session startRunning];
}

- (IBAction)captureNow:(id)sender {
    self.imageDisplayView.hidden = NO;
    self.takePictureButton.hidden = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }

    NSLog(@"about to request a capture from: %@", self.stillImageOutput);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
         }
         else
             NSLog(@"no attachments");

         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         UIImage *flippedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
         self.imageDisplayView.image = flippedImage;
     }];
}

-(void)cancelImageDisplay:(id)sender {
    self.imageDisplayView.hidden = YES;
    self.takePictureButton.hidden = NO;
}

#pragma mark - Utilities 

-(AVCaptureDevice*)getFrontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil; // If front camera not found.
}

@end
