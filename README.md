MirrorApp - iOS App. 

BackgroundImage: http://www.github.com/suhailrashidbhat/MirrorApp

Description: 
MirrorApp is an iOS app which takes users picture by using front camera of the device and he can share or save the picture taken. The app launches with the users camera open and display his/her face or where the front camera is pointing. Any tap on the screen pauses the live view on the screen and options show up to share or save the image or cancel it to retake.

Features: 
1.Using front facing camera of iOS device to view live preview of device capture. 
2.Tap on the preview anywhere to pause the preview. 
3.Displays options to Share or Save the image.
4.Share the image using Facebook, twitter, mail, messaging or copy it , etc.
5.Save the image by tapping on middle button in your photos library.
6.Display settings view to block ads or send feedback or review us (WIP).
7.Tap the cancel button to resume preview and do it again.

Usage:
It is very simple to run this project. Just run the project file in your Xcode and try building on an iOS device (not on simulator as it doesn't have camera). Run the app on your device with your developer certificates.

Technical Specifications: 
The project has three approaches of solving the particular problem 
1. Using UIImagePicker
2. AVFoundation
3.Screenshot
I have completed the project using former approach and later is in experimentation stage. There are two view-controllers for the same. At one time one ViewController will be inaccessible. The initial ViewController set on the storyboard is the one using UIImagePicker. By changing it we can change to AVFoundation. 

TODO::
1.Disable the shutter sound on tap of screen.
2.Complete AVFoundation approach which may help fix point 1.
3.Settings icon resource to be added instead named as “Edit”.
4.Adding UICollectionView in Settings View to display other apps.
5.Connect respective links from Block Ads, Review App or Feedback.
6.Add test case classes in XCTests. 
7.To create Technical Documentation. 
8.Adding screenshots, proper description and valid URLs in AppStore.
