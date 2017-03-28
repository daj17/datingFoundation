//
//  EditSecondImageViewController.m
//  InterestMe
//
//  Created by Portanos on 7/22/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "EditSecondImageViewController.h"
#import <Parse/Parse.h>
#import "ColorSuperclass.h"
#import "SIAlertView.h"
#import "ColorSuperclass.h"
#import "MBProgressHUD.h"


@interface EditSecondImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *directionsTextView;
@property (nonatomic, strong) UIBarButtonItem *useImageBarButton;

@end

@implementation EditSecondImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    



    
    //NSLog(@"width of screen: %f",self.view.frame.size.width);
    //NSLog(@"width of imv: %f",self.imageView.frame.size.width);

    [self.imageView removeFromSuperview];
    
    // Added by djax to size the imageview correctly on different devices...
    CGFloat sizeFactor=.853;
    CGFloat sideLength=self.view.frame.size.width*sizeFactor;
    CGRect frameForImageView=CGRectMake(self.view.frame.size.width/2-sideLength/2, self.imageView.frame.origin.y, sideLength, sideLength);
    
    UIImageView * test=[[UIImageView alloc] initWithFrame:frameForImageView];
    [test setBackgroundColor:[UIColor cyanColor]];
    [self.view addSubview:test];
    
    [self.imageView setFrame:frameForImageView];
    self.imageView=test;
    

    
    
    [self showChooseImageOptions];
    [self setupUserImageBarButton];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showChooseImageOptions)];
    self.imageView.userInteractionEnabled=YES;
    [self.imageView addGestureRecognizer:tap];
//    [self.imageView setBackgroundColor:[ColorSuperclass returnMakeSecondAndThirdPictureBackground]];
    
    [self.imageView.layer setBorderColor:[ColorSuperclass returnMakeSecondAndThirdPictureBackground].CGColor];
    [self.imageView.layer setBorderWidth:2.0f];
    
    
    [self.imageView setBackgroundColor:[UIColor clearColor]];
    
    
    self.imageView.layer.cornerRadius=sideLength/2;
    [self.imageView.layer setMasksToBounds:YES];
    [self.directionsTextView setBackgroundColor:[UIColor clearColor]];
    self.directionsTextView.userInteractionEnabled=NO;
    // Do any additional setup after loading the view.
    

    

}

-(void)viewWillAppear:(BOOL)animated    {
    self.title=@"Photos";
    
    if (!self.image)  {
        self.useImageBarButton.enabled=NO;
    } else{
        self.useImageBarButton.enabled=YES;
        self.imageView.image=self.image;
        [self.imageView.layer setBorderColor:[UIColor clearColor].CGColor];

    }
    
    if (self.imageView.image)   {
        //        self.directionsTextView.text=@"Tap the circle to change the image";
    } else{
        //        self.directionsTextView.text=@"Tap the blue circle to add an image.";
        //        self.directionsTextView.text=@"";
    }

    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:[NSDictionary
                             dictionaryWithObjectsAndKeys:[ColorSuperclass returnNavBarTintInLive], UITextAttributeTextColor,nil]
     forState:UIControlStateNormal];
    
    [[self.navigationController.navigationBar.subviews lastObject] setTintColor:[ColorSuperclass returnNavBarTintInLive]];
    

}

-(void)viewWillDisappear:(BOOL)animated {
    //pass self.image to parent controller
    //    if (self.image) {
    //        createStoreTableController * cont=(createStoreTableController*)self.presentingViewController;
    //        cont.chosenImage=self.image;
    //    }
}

-(void)setupUserImageBarButton   {
    UIBarButtonItem *btnPrvw = [[UIBarButtonItem alloc]
                                initWithTitle:@"Use"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(useImage)];
    self.navigationItem.rightBarButtonItem=btnPrvw;
    self.useImageBarButton=btnPrvw;
}

BOOL SAVING_NEW_IMAGE=NO;
-(void)useImage {
    //transfer image to parent...
    if (self.image && !SAVING_NEW_IMAGE) {
        SAVING_NEW_IMAGE=YES;
        [self showProgressIndicator];
        
        NSData *compressedJPGData = UIImageJPEGRepresentation(self.image, .4);
        
        PFFile * pictureFile=[PFFile fileWithData:compressedJPGData];
        
        // Save the file, then save the current user.
        [pictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error)
            {
                NSLog(@"Uploaded profile image succesfully, about to save user");
                
                // Set up the basic structures of a user's attributes
                [PFUser currentUser][@"secondPicture"]=pictureFile;
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error)
                    {
                        // Save the image, then pop the controller
                        SAVING_NEW_IMAGE=NO;
                        [self hideProgressIndicator];
                        [self.navigationController popViewControllerAnimated:YES];                     }
                    else {
                        NSLog(@"error: %@",error);
                        SAVING_NEW_IMAGE=NO;
                        [self hideProgressIndicator];

                    }
                }];
            }
            else {
                NSLog(@"error: %@",error);
                SAVING_NEW_IMAGE=NO;
                [self hideProgressIndicator];

            }
        }];

        
        

    }
}

-(void)showProgressIndicator    {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)hideProgressIndicator    {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

//-(void)showFailedToSave {
//    
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showChooseImageOptions {
    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
    alertView.SHOULD_MOVE_ALERT_VIEW_DOWN=YES;
    [alertView addButtonWithTitle:@"Choose From Photos"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
                                      [self showLibrary];

                              
                          }];
    [alertView addButtonWithTitle:@"Take Photo"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                                      [self showCamera];

                              
                              
                          }];
    
    [alertView addButtonWithTitle:@"Cancel"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
                          }];

    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willDismissHandler", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
    };
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];

}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//UIIMAGEPICKERCONTROLLER CODE:
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imageView.image = image;
    self.image=image;
    self.useImageBarButton.enabled=YES;
    [self.imageView.layer setBorderColor:[UIColor clearColor].CGColor];

    self.directionsTextView.text=@"Tap the circle to change the image";
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    self.imageView.image = image;
    self.image=image;
    [self.imageView.layer setBorderColor:[UIColor clearColor].CGColor];

    self.useImageBarButton.enabled=YES;
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    self.directionsTextView.text=@"Tap the circle to change the image";
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.imageView.image)   {
        self.directionsTextView.text=@"Tap the circle to change the image";
    } else{
        self.directionsTextView.text=@"Tap the blue circle to choose or take an image";
        
        //[self.navigationController popViewControllerAnimated:YES];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)showCamera   {
    if (TARGET_IPHONE_SIMULATOR)    {
        //do nothing, the simulator cannot handle pressing the take photos...
    } else{ //check to make sure source type is available
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])    {
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        
    }
}

- (void)showLibrary { //check to make sure source type is available
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext; //this line is very important, because otherwise, the tab bar could go out of scope (a consequence of using modal segues and tab controllers!)
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}




@end
