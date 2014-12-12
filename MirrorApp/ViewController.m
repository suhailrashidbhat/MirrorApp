//
//  ViewController.m
//  MirrorApp
//
//  Created by Suhail Bhat on 12/12/14.
//  Copyright (c) 2014 Suhail Bhat. All rights reserved.
//

#define CANCEL_BUTTON_HEIGHT_WIDTH 40
#define TOOLBAR_HEIGHT 40


#import "ViewController.h"
#import "CameraOverlay.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIView *cameraOverlay;
@property (strong, nonatomic) UIButton *clickButton;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIImageView *imageDisplayView;
@property (strong, nonatomic) UIButton *cancelImageButton;
@property (assign, nonatomic) BOOL imageTaken;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.imageTaken = NO;
    [self allocateViews];
    [self setUpViews];
}

-(void)allocateViews {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imageDisplayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44)];
    self.cancelImageButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - CANCEL_BUTTON_HEIGHT_WIDTH , self.view.frame.size.height - TOOLBAR_HEIGHT - CANCEL_BUTTON_HEIGHT_WIDTH , CANCEL_BUTTON_HEIGHT_WIDTH, CANCEL_BUTTON_HEIGHT_WIDTH)];
}

-(void)setUpViews {
    self.cancelImageButton.backgroundColor = [UIColor purpleColor];
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
}

-(void)setUpAndPresentUIPicker {
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.cameraOverlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.clickButton = [[UIButton alloc] initWithFrame:self.cameraOverlay.frame];
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.cameraOverlay.frame.size.height - 44, self.cameraOverlay.frame.size.width, 44)];
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
    self.imageTaken = YES;
    [self.imagePicker takePicture];
    // Unhide the Image view. Animate the tool bar to visible.
}

-(void)savePicture:(id)sender {
    // Play sound
    // Save picture to Gallery.

}

-(void)sharePicture:(id)sender {
    // Open sharing options
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.imageDisplayView.image] applicationActivities:nil];
    [self.imagePicker presentViewController:activityController animated:YES completion:nil];
}

-(void)settingsView:(id)sender {
    // Present Settings view.
}

-(void)cancelImageButtonTapped:(id)sender {
    // Hide the image view
    // present imageview.
    self.imageTaken = NO;
    self.imageDisplayView.hidden = YES;
}

#pragma mark UIImagePickerDelegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    UIImage *flippedImage = [UIImage imageWithCGImage:chosenImage.CGImage scale:chosenImage.scale orientation:UIImageOrientationLeftMirrored];
    self.imageDisplayView.image = flippedImage;
    [self.imageDisplayView setHidden:NO];
}

@end
