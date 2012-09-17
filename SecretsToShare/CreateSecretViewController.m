//
//  CreateSecretViewController.m
//  SecretsToShare
//
//  Created by Ran Tao on 8.30.12.
//  Copyright (c) 2012 Ran Tao. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "CreateSecretViewController.h"
#import "SecretStore.h"
#import "Secret.h"

@interface CreateSecretViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSData* imageData;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation CreateSecretViewController
@synthesize secretTextView;
@synthesize shareButton;
@synthesize userImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *addImage = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(pushAddImage)];
    self.navigationItem.rightBarButtonItem=addImage;
    self.scrollView = (UIScrollView*)self.view;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - 43);
    //UIScrollView * scrollView = (UIScrollView*)self.view;
//    self.scrollView = (UIScrollView*)self.view;
//    self.scrollView.contentSize = self.view.frame.size;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.scrollView addGestureRecognizer:tapGesture];
    
}
//
//-(void) viewWillAppear:(BOOL)animated {
//    self.scrollView = (UIScrollView*)self.view;
//
//    if (!self.userImage) {
//        NSLog(@"user image is not hidden");
//        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + self.userImage.image.size.height);
//
//        //self.scrollView.contentSize = self.view.bounds.size;
//    }
//    else {
//        NSLog(@"user image is hidden");
//        self.scrollView.contentSize = self.view.frame.size;
//    }
////    self.scrollView = (UIScrollView*)self.view;
////    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2) ;
//}


- (void)viewDidUnload
{
    [self setSecretTextView:nil];
    [self setUserImage:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)hideKeyboard
{
    [self.secretTextView resignFirstResponder];
}

-(void) pushAddImage{
    //push a new image view controller and save the camera or user's library
    UIImagePickerController *ipc = [UIImagePickerController new];
    ipc.delegate = self;
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.mediaTypes = [NSArray arrayWithObject:(NSString*) kUTTypeImage];
    ipc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:ipc animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageData = UIImageJPEGRepresentation(image, 1.0);
    self.userImage.image = image;
    self.userImage.hidden = NO;
    NSLog(@"did finish picking media");
    //self.secretTextView.frame.origin = CGPointMake(self.secretTextView.frame.origin.x, self.secretTextView.frame.origin.y + self.userImage.bounds.size.height);
    self.secretTextView.frame = CGRectOffset(self.secretTextView.frame, 0, self.userImage.frame.size.height + 30.0);
    self.shareButton.frame = CGRectOffset(self.shareButton.frame, 0, self.userImage.frame.size.height + 30.0);
//    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + self.userImage.image.size.height);
//    self.scrollView.contentSize = self.view.frame.size;
    self.scrollView = (UIScrollView*)self.view;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + self.userImage.image.size.height);
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.view setNeedsDisplay];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.secretTextView resignFirstResponder];
}



- (IBAction)shareSecretButtonPressed:(UIButton *)sender {
    NSString *secretText = self.secretTextView.text;
    if (![secretText isEqualToString:@""]) {
        Secret *secret  = [SecretStore createSecret];
        secret.entry = secretText;
        secret.date =  [NSDate date];
        secret.imageData = self.imageData;
        [SecretStore save];
    }
    self.secretTextView.text = @"";
    self.userImage.hidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}


- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int animatedDistance;
    int moveUpValue = textField.frame.origin.y+ (textField.frame.size.height)+60;
    NSLog(@"%d", moveUpValue);
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        
        animatedDistance = 216-(460-moveUpValue-5);
    }
    else
    {
        animatedDistance = 162-(320-moveUpValue-5);
    }
    
    if(animatedDistance>0)
    {
        const int movementDistance = animatedDistance;
        const float movementDuration = 0.3f;
        int movement = (up ? -movementDistance : movementDistance);
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    }
}

@end
