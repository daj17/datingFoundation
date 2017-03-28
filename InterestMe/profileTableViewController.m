//
//  profileTableViewController.m
//  InterestMe
//
//  Created by Portanos on 5/28/16.
//  Copyright © 2016 ChimpchatLLC. All rights reserved.
//

#import "profileTableViewController.h"
#import "ColorSuperclass.h"
#import "EditDescriptionCell.h"
#import "profileCell.h"
#import "BioHeaderCell.h"
#import "photosHeaderCell.h"
#import "EditInterestsHeaderCell.h"
#import "DiscoveryHeaderCell.h"
#import "EditThirdImageViewController.h"
#import "DiscoveryPrefsCell.h"
#import "AgeCalcSuperclass.h"
#import "versionCell.h"
#import "MainTabBarController.h"
#import "SIAlertView.h"
#import "EditSecondImageViewController.h"
#import "AgeRangeCell.h"
#import "addNewPhotoTableViewCell.h"
#import "OLFacebookImage.h"
#import "LogoutCell.h"
#import <Parse/Parse.h>
#import "ParseFacebookUtilsV4.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ParseFacebookUtilsV4.h"
#import "EditDescriptionCell.h"
#import "editInterestsAttemptCell.h"
#import "MBProgressHUD.h"

////////////////////////////////////////////////////////
// FACEBOOK ALBUMS PHOTOS FETCHING (FORKED FACEBOOK ALBUM PICKER)
#import "OLFacebookAlbumRequest.h"
#import "OLFacebookPhotosForAlbumRequest.h"
#import "OLFacebookAlbum.h"
#import "OLFacebookImage.h"
#import "OLFacebookImagePickerController.h"
/////////////////////////////////////////////////////////

@interface profileTableViewController () <MyTableCellProtocoll,DiscoveryRadiusProtocol,UINavigationControllerDelegate, OLFacebookImagePickerControllerDelegate>

//REFRESHING
@property (nonatomic, strong) UIView *refreshLoadingView;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;

//hacks, but they work! see S.O. for discussion of this stuff.
@property (nonatomic, strong) DiscoveryPrefsCell * hackCell;
@property (nonatomic, strong) AgeRangeCell * hackAgeCell;


//logout button/settings or low level logistics
@property (nonatomic) UIBarButtonItem *settingsButton;

@property (nonatomic, strong) UIImage * profileImage;
@property (nonatomic, strong) UIImage * secondProfileImage;
@property (nonatomic, strong) UIImage * thirdProfileImage;

@property NSInteger photoToChangeIndex;


//as a test:
//@property (nonatomic, strong) UIImageView *myProfileImageView;

@end

@implementation profileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollsToTop=NO;
    
//    self.navigationController.navigationBar.tintColor = [UIColor grayColor];

    
    [self registerNibs];
    [self setupRefreshControl];
    
//    [self.navigationController.navigationBar setTitleTextAttributes: @{UITextAttributeFont: [UIFont fontWithName:@"Helvetica" size:23.0f]}];
    
    
    

    
    self.navigationItem.title=@"My Profile";
    
    self.tableView.estimatedRowHeight = 204.0; //an estimate of how tall each cell is. Overridden in the first case because the profile cell has a designated height already
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

-(void)segueToChooseInterests   {
    [self performSegueWithIdentifier:@"editInterestsSegue" sender:self];
}

-(void)sliderValueChanged   {
    
}

-(void)viewWillAppear:(BOOL)animated    {
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:19]];
    [self refreshMyProfile];
    
    [self showTabBar];
    
//    [self.navigationController.navigationBar setBarTintColor:[ColorSuperclass returnNavBarTintInLive]];
//    [self.navigationController.navigationBar setTranslucent:NO];
    
}


-(void)registerNibs {
    
    
     [self.tableView registerNib:[UINib nibWithNibName:@"EditInterestsHeaderCell" bundle:nil] forCellReuseIdentifier:@"EditInterestsHeaderCell"];

   
        [self.tableView registerNib:[UINib nibWithNibName:@"editInterestsAttemptCell" bundle:nil] forCellReuseIdentifier:@"editInterestsAttemptCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"profileCell" bundle:nil] forCellReuseIdentifier:@"profileCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EditDescriptionCell" bundle:nil] forCellReuseIdentifier:@"EditDescriptionCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DiscoveryPrefsCell" bundle:nil] forCellReuseIdentifier:@"DiscoveryPrefsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LogoutCell" bundle:nil] forCellReuseIdentifier:@"LogoutCell"];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"versionCell" bundle:nil] forCellReuseIdentifier:@"versionCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AgeRangeCell" bundle:nil] forCellReuseIdentifier:@"AgeRangeCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DiscoveryHeaderCell" bundle:nil] forCellReuseIdentifier:@"DiscoveryHeaderCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BioHeaderCell" bundle:nil] forCellReuseIdentifier:@"BioHeaderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"photosHeaderCell" bundle:nil] forCellReuseIdentifier:@"photosHeaderCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"addNewPhotoTableViewCell" bundle:nil] forCellReuseIdentifier:@"addNewPhotoTableViewCell"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[ColorSuperclass returnInterestTableViewHeaderColor]];
    if (section==0) { //We're using custom cells, so if in the future we want to use non-custom (lol, why would we do that) you can use these title attributes...
        return @"";
    }
    if (section==1) {
        return @"";
    }
    if (section==2) {
        return @"";
    }
    if (section==3) {
        return @"";
    }
    if (section>4) { // lol, just a blank header.
        return @" ";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }
    
    if (section==1) {
        
        if (![PFUser currentUser][@"secondPicture"]) return 2;
        //        if ([PFUser currentUser][@"thirdPicture"]) return 3;
        
        return 3;
    }
    if (section==2) {
        return 2;
    }
    if (section==3) {
        return 2;
    }
    if (section==4) {
        return 3;
    }
    if (section==5) {
        return 1;
    }
    
    //    if (section==5) {
    //        return 2;
    //    }
    //    if (section==8) {
    //        return 1;
    //    }
    
    return 0;
}



BOOL PULLED_SAVED_SEARCH_RADIUS=NO; //the user's prefs are only from PFUser currentUser once (could be optimized for multi-device setup, but who does shit like that?).
BOOL PULLED_SAVED_AGE_RANGE=NO;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0)   {
        profileCell *cell = (profileCell *)[tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
        [cell.profileImageView.layer setCornerRadius:CGRectGetWidth(cell.profileImageView.bounds) / 2];
//        cell.profileImageView.layer.borderColor=[ColorSuperclass returnInterestTableViewHeaderColor].CGColor;
                cell.profileImageView.layer.borderColor=[UIColor lightGrayColor].CGColor;
        cell.profileImageView.layer.borderWidth=1.0f;
        
        if (self.profileImage)  {
            cell.profileImageView.image=self.profileImage;
        } else{
            //            [cell.profileImageView setBackgroundColor:[UIColor whiteColor]];
        }
        
        [cell.nameLabel setFont:[UIFont fontWithName:@"Avenir" size:20]];
//        [cell.descriptionLabel setFont:[UIFont fontWithName:@"Avenir" size:14]];
        
        [cell.descriptionLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
        
        
        cell.profileImageView.layer.masksToBounds=YES;
        cell.descriptionLabel.userInteractionEnabled=NO;
        if ([PFUser currentUser][@"bio"])   { // Check to make sure they have a bio.
            cell.descriptionLabel.text=[PFUser currentUser][@"bio"];
            [cell.descriptionLabel setTextColor:[UIColor lightGrayColor]];
        } else{
            [cell.descriptionLabel setTextColor:[ColorSuperclass returnHasntMadeBioYetColor]];
        }
        cell.nameLabel.userInteractionEnabled=NO;
        
        NSMutableString * nameAndAgeString=[[NSMutableString alloc] initWithString:@""];
        [nameAndAgeString appendString:[PFUser currentUser][@"first_name"]];
        [nameAndAgeString appendString:@" ("];
        
        
        NSInteger age= [AgeCalcSuperclass returnAgeUsingBirthDate:[PFUser currentUser][@"birthday"]];
        NSString * ageString=[NSString stringWithFormat:@"%ld",(long)age];
        [nameAndAgeString appendString:ageString];
        [nameAndAgeString appendString:@")"];
        
        
        cell.nameLabel.text=nameAndAgeString;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wantsToChangeProfPicChange)];
        [cell.profileImageView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tapp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToEditBio)];
        [cell.descriptionLabel addGestureRecognizer:tapp];
        cell.descriptionLabel.userInteractionEnabled=YES;
        
        [cell.profileImageView setUserInteractionEnabled:YES];
        
        //        self.myProfileImageView=cell.profileImageView;
        
        return cell;
        
    }
    
    if (indexPath.section==1)   {
        if (indexPath.row==0)   {
            photosHeaderCell * cell=(photosHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"photosHeaderCell" forIndexPath:indexPath];
            [cell.contentView setBackgroundColor:[ColorSuperclass colorFromHex:@"#F7F7F7"]];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        } else if (indexPath.row==1)    {
            
            addNewPhotoTableViewCell * cell=(addNewPhotoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"addNewPhotoTableViewCell" forIndexPath:indexPath];
            [cell.mainImageView.layer setCornerRadius:CGRectGetWidth(cell.mainImageView.bounds) / 2];
            [cell.mainImageView.layer setMasksToBounds:YES];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (![PFUser currentUser][@"secondPicture"])    {
                cell.mainTextView.text=@"Add another picture! 📷";
                [cell.mainTextView setTextColor:[ColorSuperclass returnHasntMadeSecondPicYetColor]];

                                            [cell.mainImageView.layer setBorderColor:[ColorSuperclass returnMakeSecondAndThirdPictureBackground].CGColor];


            } else{
                cell.mainImageView.image=self.secondProfileImage;
                cell.mainTextView.text=@"Update your second picture! 📷";
                [cell.mainTextView setTextColor:[UIColor lightGrayColor]];

                [cell.mainTextView setTextColor:[UIColor lightGrayColor]];
                [cell.mainImageView.layer setBorderColor:[UIColor clearColor].CGColor];
            }

            [cell.mainImageView.layer setCornerRadius:CGRectGetWidth(cell.mainImageView.bounds) / 2];

            [cell.mainImageView.layer setBorderWidth:2.0f];
            [cell.mainImageView setBackgroundColor:[UIColor clearColor]];
            [cell.mainTextView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
            cell.mainTextView.scrollEnabled=NO;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editSecondPhoto)];
            [cell addGestureRecognizer:tap];
            
            return cell;
            
        } else if (indexPath.row==2)    {
            
            addNewPhotoTableViewCell * cell=(addNewPhotoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"addNewPhotoTableViewCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            [cell.mainImageView.layer setCornerRadius:CGRectGetWidth(cell.mainImageView.bounds) / 2];
            [cell.mainImageView.layer setMasksToBounds:YES];

            [cell.mainImageView.layer setBorderWidth:2.0f];
            
            if (![PFUser currentUser][@"thirdPicture"])    {
                cell.mainTextView.text=@"Add a third picture! 📷";
                            [cell.mainImageView.layer setBorderColor:[ColorSuperclass returnMakeSecondAndThirdPictureBackground].CGColor];
            } else{
                cell.mainImageView.image=self.thirdProfileImage;
                [cell.mainImageView.layer setBorderColor:[UIColor clearColor].CGColor];

                cell.mainTextView.text=@"Update your third picture! 📷";
            }
            [cell.mainTextView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
            
            
            
            [cell.mainImageView setBackgroundColor:[UIColor clearColor]];
            [cell.mainTextView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
            [cell.mainTextView setTextColor:[UIColor lightGrayColor]];
            cell.mainTextView.scrollEnabled=NO;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editThirdPhoto)];
            [cell addGestureRecognizer:tap];

            
            return cell;
        }
    }
    if (indexPath.section==2)   {
        
        
        
        if (indexPath.row==0)   {
            BioHeaderCell * cell=(BioHeaderCell*)[tableView dequeueReusableCellWithIdentifier:@"BioHeaderCell" forIndexPath:indexPath];
            [cell.contentView setBackgroundColor:[ColorSuperclass colorFromHex:@"#F7F7F7"]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        if (indexPath.row==1)   {
            EditDescriptionCell * cell=(EditDescriptionCell*)[tableView dequeueReusableCellWithIdentifier:@"EditDescriptionCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToEditBio)];
            // setup gesture as needed
            [cell addGestureRecognizer:gesture];
            return cell;
        }
        
    }
    
    if (indexPath.section==3)   {
        
        if (indexPath.row==0)   {
            EditInterestsHeaderCell * editIntrstsHedaerCell=(EditInterestsHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"EditInterestsHeaderCell" forIndexPath:indexPath];
            editIntrstsHedaerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [editIntrstsHedaerCell.contentView setBackgroundColor:[ColorSuperclass colorFromHex:@"#F7F7F7"]];
            return editIntrstsHedaerCell;
        }
        
        if (indexPath.row==1)   {
            //Add the Edit Interests cell...
//            
//            EditInterestsHeaderCell * editIntrstsHedaerCell=(EditInterestsHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"EditInterestsHeaderCell" forIndexPath:indexPath];
//            editIntrstsHedaerCell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [editIntrstsHedaerCell.contentView setBackgroundColor:[ColorSuperclass colorFromHex:@"#F7F7F7"]];
//            return editIntrstsHedaerCell;

            
            editInterestsAttemptCell * edIntrstsCell=(editInterestsAttemptCell *)[tableView dequeueReusableCellWithIdentifier:@"editInterestsAttemptCell" forIndexPath:indexPath];
            edIntrstsCell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segueToChooseInterests)];
            [edIntrstsCell.contentView addGestureRecognizer:tap];
            return edIntrstsCell;
            
            
        }
    }
    
    if (indexPath.section==4 && indexPath.row==0)   {
        
        DiscoveryHeaderCell * discoveryCell=(DiscoveryHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"DiscoveryHeaderCell" forIndexPath:indexPath];
        discoveryCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [discoveryCell.contentView setBackgroundColor:[ColorSuperclass colorFromHex:@"#F7F7F7"]];
        
        return discoveryCell;
        
        
    }
    
    if (indexPath.section==4 && indexPath.row==1)   {
        
        DiscoveryPrefsCell * discoveryCell=(DiscoveryPrefsCell *)[tableView dequeueReusableCellWithIdentifier:@"DiscoveryPrefsCell" forIndexPath:indexPath];
        discoveryCell.selectionStyle = UITableViewCellSelectionStyleNone;
        discoveryCell.delegateListener=self;
        if (!PULLED_SAVED_SEARCH_RADIUS)    {
            PULLED_SAVED_AGE_RANGE=YES;
            [discoveryCell attemptSearchRadiusPresetWithValue:[PFUser currentUser][@"searchRadius"]];
        }
        [discoveryCell configureCell];
        self.hackCell=discoveryCell;
        
        
        [discoveryCell.radiusSlider addTarget:self
                                       action:@selector(radiusSliderChanged:)
                             forControlEvents:UIControlEventValueChanged];
        [discoveryCell.radiusSlider setTintColor:[ColorSuperclass returnProfSliderTints]];
        return discoveryCell;
        
    }
    else if (indexPath.section==4  && indexPath.row==2)   {
        
        AgeRangeCell * cell=(AgeRangeCell*)[tableView dequeueReusableCellWithIdentifier:@"AgeRangeCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //Forward compatibility
        //        every time the app boots up, you will want to pull the user's age preferences from their PFUser object. You'll want to think about, however, what happens if a user ages out of a agegroup (turns 18), how does you app handle this?
        
        NSInteger  upperSearchAge=[cell returnUpperAgeForNewSliderPosition];
        NSInteger  lowerSearchAge=[cell returnLowerAgeForNewSliderPosition];
        NSMutableString * ageRangeString=[[NSMutableString alloc] initWithString:@""];
        [ageRangeString appendString:[NSString stringWithFormat:@"%ld", (long)lowerSearchAge]];
        [ageRangeString appendString:@"-"];
        [ageRangeString appendString:[NSString stringWithFormat:@"%ld", (long)upperSearchAge]];
        cell.ageRangeLabel.text=ageRangeString;
        cell.tag=17258;
        self.hackAgeCell=cell;
        cell.delegateListener=self;
        
        [cell.ageSlider setTintColor:[ColorSuperclass returnProfSliderTints]];

        [cell.ageSlider addTarget:self
                           action:@selector(ageRangeSliderChanged:)
                 forControlEvents:UIControlEventValueChanged];
        
        return cell;
        
    }
    
    if (indexPath.section==5)   {
        //        if (indexPath.row==0)   {
        //            LogoutCell * cell=(LogoutCell*)[tableView dequeueReusableCellWithIdentifier:@"LogoutCell" forIndexPath:indexPath];
        //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLogoutCustomAlertView)];
        //
        //            [cell.contentView addGestureRecognizer:tap];
        //            return cell;
        //        }
        if (indexPath.row==0)   {
            versionCell * cell=(versionCell*)[tableView dequeueReusableCellWithIdentifier:@"versionCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            [cell.contentView setBackgroundColor:[ColorSuperclass colorFromHex:@"#F7F7F7"]];
            return cell;
        }
        
        
        
    }
    
    return nil;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

///////////////////   FACEBOOK PHOTOS FETCHING
-(void)editUserPhotoWithFacebookAtIndex:(NSInteger) index  { //as in show Facebook images and let them choose one

     [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error){
     
         if (!error)    {
             
             //Check permissions of current token...
             if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_photos"]) {
                 // We already have access to their photos
                 [self presentUserAlbumsToAllowProfilePictureChangeForPhotoIndex:index];
                 
             } else{
                 FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                 
                 [loginManager logInWithReadPermissions:@[@"public_profile",@"user_photos"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
                  {
                      
                      [self presentUserAlbumsToAllowProfilePictureChangeForPhotoIndex:index];
                      
                  }];
             }

         } else{

             NSLog(@"error: %@",error);
         }
     }];
}

-(void)presentUserAlbumsToAllowProfilePictureChangeForPhotoIndex:(NSInteger)index    {
    OLFacebookImagePickerController *picker = [[OLFacebookImagePickerController alloc] init];
    self.photoToChangeIndex=index;
//    picker.photoNum=index; // added by DJAX to let picker now which picture we're changing..
    picker.selected = @[];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];

}

//also need the did finish picking images one...

-(void)editFirstImageViaFacebook   { //as in show Facebook images and let them choose one
    
}

-(void)editSecondImageViaFacebook   { //as in show Facebook images and let them choose one
    
}

#pragma mark - OLFacebookImagePickerControllerDelegate methods

- (void)facebookImagePicker:(OLFacebookImagePickerController *)imagePicker didFailWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)facebookImagePicker:(OLFacebookImagePickerController *)imagePicker didFinishPickingImages:(NSArray/*<OLFacebookImage>*/ *)images {
    
    if ([images count]==0)  {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else{
        // Begin ignoring events
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [self showProgressIndicator];
        NSString *keyString=@"";
        if (self.photoToChangeIndex==0) {
            keyString=@"picture";
        } else if (self.photoToChangeIndex==1) {
            keyString=@"secondPicture";
        }else if (self.photoToChangeIndex==2) {
            keyString=@"thirdPicture";
        }
        

        UIImage *img = [images objectAtIndex:0];
        
        //now compress the image into data.
        
        NSData *compressedJPGData = UIImageJPEGRepresentation(img, .4);
        
        PFFile * pictureFile=[PFFile fileWithData:compressedJPGData];
        
        // Save the file, then save the current user.
        [pictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error)
            {
                // Set up the basic structures of a user's attributes
                [PFUser currentUser][keyString]=pictureFile;
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error)
                    {
                        
                        // Save the image, then pop the controller
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [self hideProgressIndicator];
                        //And now update the UI by refreshing...
                        // Stop ignoring events
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                        [self refreshMyProfile];
                    }
                    else {
                        [self hideProgressIndicator];
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                         [self dismissViewControllerAnimated:YES completion:nil];
                        
                    }
                }];
            }
            else {
                [self hideProgressIndicator];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];

                 [self dismissViewControllerAnimated:YES completion:nil];
                
            }
        }];


    }

}

-(void)showProgressIndicator    {
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"savingImageShowProgress"
//                                                        object:self
//                                                      userInfo:nil];

}

-(void)hideProgressIndicator    {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"doneSavingImageRemoveIndicator"
                                                        object:self
                                                      userInfo:nil];

}

///////////////////   END   FACEBOOK PHOTOS FETCHING

-(void)editSecondPhoto  {
    //give the user the options to choose between choosing from Facebook and the local library.

    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
    alertView.SHOULD_MOVE_ALERT_VIEW_DOWN=YES;
    [alertView addButtonWithTitle:@"Facebook"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
                              [self editUserPhotoWithFacebookAtIndex:1];
                              
                              
                          }];
    [alertView addButtonWithTitle:@"Take Or Choose"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self performSegueWithIdentifier:@"editSecondImageSegue" sender:self];
                              
                              
                              
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
-(void)editThirdPhoto  {
    //give the user the options to choose between choosing from Facebook and the local library.
    
    
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
    alertView.SHOULD_MOVE_ALERT_VIEW_DOWN=YES;
    [alertView addButtonWithTitle:@"Facebook"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              
                              [self editUserPhotoWithFacebookAtIndex:2];
                              
                              
                          }];
    
    [alertView addButtonWithTitle:@"Take Or Choose"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [self performSegueWithIdentifier:@"editThirdImageSegue" sender:self];

                              
                              
                              
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

-(void)showTabBar   {
    MainTabBarController * tabBarrController=(MainTabBarController *)self.navigationController.parentViewController;
    tabBarrController.tabBar.hidden=NO;
}

-(void)hideTabBar   {
    MainTabBarController * tabBarrController=(MainTabBarController *)self.navigationController.parentViewController;
    tabBarrController.tabBar.hidden=YES;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editSecondImageSegue"])  {
        EditSecondImageViewController * vc=(EditSecondImageViewController *)segue.destinationViewController;
        vc.image=self.secondProfileImage;
    }
    
    else if ([segue.identifier isEqualToString:@"editThirdImageSegue"])  {
        
        EditThirdImageViewController * vc=(EditThirdImageViewController *)segue.destinationViewController;
        vc.image=self.thirdProfileImage;
        
    }
}


//CUSTOM REFRESHING
- (void)setupRefreshControl
{
    // TODO: Programmatically inserting a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Setup the loading view, which will hold the moving graphics
    self.refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // Setup the color view, which will display the rainbowed background
    self.refreshColorView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshColorView.backgroundColor = [UIColor clearColor];
    self.refreshColorView.alpha = 0.30;
    
    // Create the graphic image views
    self.compass_background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass_background.png"]];
    self.compass_spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass_spinner.png"]];
    
    // Add the graphics to the loading view
    [self.refreshLoadingView addSubview:self.compass_background];
    [self.refreshLoadingView addSubview:self.compass_spinner];
    
    // Clip so the graphics don't stick out
    self.refreshLoadingView.clipsToBounds = YES;
    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    // Add the loading and colors views to our refresh control
    [self.refreshControl addSubview:self.refreshColorView];
    [self.refreshControl addSubview:self.refreshLoadingView];
    
    // Initalize flags
    self.isRefreshIconsOverlap = NO;
    self.isRefreshAnimating = NO;
    
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender{
    //    DLog(@"");
    
    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //        DLog(@"DONE");
        
        // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [self.refreshControl endRefreshing];
    });
    // -- FINISHED SOMETHING AWESOME, WOO! --
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    // Get the current size of the refresh controller
    CGRect refreshBounds = self.refreshControl.bounds;
    
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    
    // Half the width of the table
    CGFloat midX = self.tableView.frame.size.width / 2.0;
    
    // Calculate the width and height of our graphics
    CGFloat compassHeight = self.compass_background.bounds.size.height;
    CGFloat compassHeightHalf = compassHeight / 2.0;
    
    CGFloat compassWidth = self.compass_background.bounds.size.width;
    CGFloat compassWidthHalf = compassWidth / 2.0;
    
    CGFloat spinnerHeight = self.compass_spinner.bounds.size.height;
    CGFloat spinnerHeightHalf = spinnerHeight / 2.0;
    
    CGFloat spinnerWidth = self.compass_spinner.bounds.size.width;
    CGFloat spinnerWidthHalf = spinnerWidth / 2.0;
    
    // Calculate the pull ratio, between 0.0-1.0
    CGFloat pullRatio = MIN( MAX(pullDistance, 0.0), 100.0) / 100.0;
    
    // Set the Y coord of the graphics, based on pull distance
    CGFloat compassY = pullDistance / 2.0 - compassHeightHalf;
    CGFloat spinnerY = pullDistance / 2.0 - spinnerHeightHalf;
    
    // Calculate the X coord of the graphics, adjust based on pull ratio
    CGFloat compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio);
    CGFloat spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio);
    
    // When the compass and spinner overlap, keep them together
    if (fabsf(compassX - spinnerX) < 1.0) {
        self.isRefreshIconsOverlap = YES;
    }
    
    // If the graphics have overlapped or we are refreshing, keep them together
    if (self.isRefreshIconsOverlap || self.refreshControl.isRefreshing) {
        compassX = midX - compassWidthHalf;
        spinnerX = midX - spinnerWidthHalf;
    }
    
    // Set the graphic's frames
    CGRect compassFrame = self.compass_background.frame;
    compassFrame.origin.x = compassX;
    compassFrame.origin.y = compassY;
    
    CGRect spinnerFrame = self.compass_spinner.frame;
    spinnerFrame.origin.x = spinnerX;
    spinnerFrame.origin.y = spinnerY;
    
    self.compass_background.frame = compassFrame;
    self.compass_spinner.frame = spinnerFrame;
    
    // Set the encompassing view's frames
    refreshBounds.size.height = pullDistance;
    
    self.refreshColorView.frame = refreshBounds;
    self.refreshLoadingView.frame = refreshBounds;
    
    // If we're refreshing and the animation is not playing, then play the animation
    if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
        [self animateRefreshView];
    }
    
    //    DLog(@"pullDistance: %.1f, pullRatio: %.1f, midX: %.1f, isRefreshing: %i", pullDistance, pullRatio, midX, self.refreshControl.isRefreshing);
}

- (void)animateRefreshView
{
    // Background color to loop through for our color view
    NSArray *colorArray = @[[UIColor redColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor],[UIColor orangeColor],[UIColor magentaColor]];
    static int colorIndex = 0;
    
    // Flag that we are animating
    self.isRefreshAnimating = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.compass_spinner setTransform:CGAffineTransformRotate(self.compass_spinner.transform, M_PI_2)];
                         
                         // Change the background color
                         //                         UIColor * currentColor=[colorArray objectAtIndex:colorIndex];
                         
                         self.refreshColorView.backgroundColor = [colorArray objectAtIndex:colorIndex];
                         
                         //                         [self.myProfileImageView.layer setBorderColor:currentColor.CGColor];
                         
                         colorIndex = (colorIndex + 1) % colorArray.count;
                     }
                     completion:^(BOOL finished) {
                         // If still refreshing, keep spinning, else reset
                         if (self.refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         }else{
                             [self resetAnimation];
                         }
                     }];
}

- (void)resetAnimation
{
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.isRefreshIconsOverlap = NO;
    self.refreshColorView.backgroundColor = [UIColor clearColor];
}

BOOL REFRESHING_PROFILE_INFO=NO;
-(void)refreshMyProfile {
    if (REFRESHING_PROFILE_INFO) return;
    REFRESHING_PROFILE_INFO=YES;
    PFFile * myProfileImageFile=[PFUser currentUser][@"picture"];
    [myProfileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            UIImage * image =[UIImage imageWithData:data];
            self.profileImage=image;
            
            if ([PFUser currentUser][@"secondPicture"] && ![PFUser currentUser][@"thirdPicture"]){
                //fetch just the second one
                
                
                PFFile * myProfileImageFile=[PFUser currentUser][@"secondPicture"];
                [myProfileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        //they haven't put any more pics up....
                        REFRESHING_PROFILE_INFO=NO;
                        UIImage * image =[UIImage imageWithData:data];
                        self.secondProfileImage=image;
                        [self.tableView reloadData];
                    }
                    else{
                        REFRESHING_PROFILE_INFO=NO;
                    }
                }];
                
                
                
            } else if ([PFUser currentUser][@"thirdPicture"] && [PFUser currentUser][@"secondPicture"])    {
                //fetch em both
                
                
                PFFile * myProfileImageFile=[PFUser currentUser][@"secondPicture"];
                [myProfileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        UIImage * image =[UIImage imageWithData:data];
                        self.secondProfileImage=image;
                        
                        PFFile * myProfileImageFile=[PFUser currentUser][@"thirdPicture"];
                        [myProfileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if (!error) {
                                //they haven't put any more pics up....
                                REFRESHING_PROFILE_INFO=NO;
                                UIImage * image =[UIImage imageWithData:data];
                                self.thirdProfileImage=image;
                                [self.tableView reloadData];
                            }
                            else{
                                REFRESHING_PROFILE_INFO=NO;
                            }
                        }];
                    }
                    else{
                        REFRESHING_PROFILE_INFO=NO;
                    }
                }];
            } else{
                REFRESHING_PROFILE_INFO=NO;
                [self.tableView reloadData];
            }
            
            
        }
        else{
            //they haven't put any more pics up....
            REFRESHING_PROFILE_INFO=NO;
            UIImage * image =[UIImage imageWithData:data];
            self.profileImage=image;
            [self.tableView reloadData];        }
    }];
    
}

//show logout options:
- (void)showLogoutOptions:(id)sender {
    UIAlertController *settings = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        //        [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
        //            if (!error) {
        //                [[PFInstallation currentInstallation] removeObjectForKey:@"user"]; //so it doesn't crashes when saving PFOBJECT with nil
        //                //delete cached info
        //                AppDelegate * appDelegate=[[UIApplication sharedApplication] delegate];
        //                [CachedLoginInfo_Create deleteAllCurrentObjectsInContext:appDelegate.managedObjectContext];
        //                [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL success,NSError * error)   {
        //                    if (!error) {
        //                        NSLog(@"no error saving installation:");
        //                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup" bundle:nil];
        //                        UINavigationController *myVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"SignupNavigationController"];
        //                        EntranceViewController * presSignUpController=[myVC.childViewControllers objectAtIndex:0];
        //                        presSignUpController.DID_JUST_LOGOUT=YES;
        //                        [self presentViewController:myVC animated:NO completion:nil];
        //                    } else{
        //                        NSLog(@"error: %@",error);
        //                    }
        //                }];
        //
        //            } else  {
        //                NSLog(@"Error: %@",error);
        //            }
        //        }];
    }];
    [settings addAction:logoutAction];
    
    NSURL * termsUrl=[NSURL URLWithString:[@"http://chimpchat.com/terms.html" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *privacyUrl=[NSURL URLWithString:[@"http://chimpchat.com/privacy.html" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL * bugUrl=[NSURL URLWithString:[@"http://chimpchat.com/contact.html" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL * facebookUrl=[NSURL URLWithString:[@"https://www.facebook.com/Chimpchat?fref=ts" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL * twitterUrl=[NSURL URLWithString:[@"https://twitter.com/chimpchat" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    UIAlertAction *termsUseAction = [UIAlertAction actionWithTitle:@"Terms Of Use" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { [[UIApplication sharedApplication] openURL:termsUrl];}];
    
    UIAlertAction *fbAction = [UIAlertAction actionWithTitle:@"Facebook Page" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { [[UIApplication sharedApplication] openURL:facebookUrl];}];
    
    UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { [[UIApplication sharedApplication] openURL:twitterUrl];}];
    
    
    UIAlertAction *privacyPolicyAction = [UIAlertAction actionWithTitle:@"Privacy Policy" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { [[UIApplication sharedApplication] openURL:privacyUrl];}];
    
    UIAlertAction *bugReportNotContactAction = [UIAlertAction actionWithTitle:@"Report a Bug 🐛" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { [[UIApplication sharedApplication] openURL:bugUrl];}];
    UIAlertAction *reportBugAction = [UIAlertAction actionWithTitle:@"Contact" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { [[UIApplication sharedApplication] openURL:bugUrl];}];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }];
    
    //add the actions:
    
    [settings addAction:fbAction];
    //    [settings addAction:twitterAction];
    [settings addAction:termsUseAction];
    [settings addAction:privacyPolicyAction];
    
    [settings addAction:bugReportNotContactAction];
    [settings addAction:reportBugAction];
    
    
    [settings addAction:cancelAction];
    settings.view.tintColor=[ColorSuperclass returnLogoutOptionsColor];
    [self presentViewController:settings animated:YES completion:nil];
}

- (void)didPressButton:(AgeRangeCell *)theCell //use the release for knowing when to save.
{
    [PFUser currentUser][@"upperAgeLimit"]=[NSNumber numberWithInteger:[theCell returnUpperAgeForNewSliderPosition]];
    [PFUser currentUser][@"lowerAgeLimit"]=[NSNumber numberWithInteger:[theCell returnLowerAgeForNewSliderPosition]];
    [[PFUser currentUser] saveInBackground];
}

-(void)radiusSliderChanged:(UISlider * )sender  {
    [self.hackCell configureCell];
}

//called whenever age range slider is changed.
-(void)ageRangeSliderChanged:(UISlider * )sender  {
    
    NSMutableString * labelTextString=[[NSMutableString alloc] initWithString:@""];
    [labelTextString appendString:[NSString stringWithFormat:@"%d",[self.hackAgeCell returnLowerAgeForNewSliderPosition]]];
    [labelTextString appendString:@"-"];
    [labelTextString appendString:[NSString stringWithFormat:@"%d",[self.hackAgeCell returnUpperAgeForNewSliderPosition]]];
    
    self.hackAgeCell.ageRangeLabel.text=labelTextString;
    
    //TODO SAVE NEW PREFS IN BACKGROUND
    
}

- (void)didChangeDiscoveryPrefs:(DiscoveryPrefsCell *)theCell
{
    NSNumber * searchRadiusNum=[theCell returnSearchRadiusAsNSNumber];
    [PFUser currentUser][@"searchRadius"]=searchRadiusNum;
    [[PFUser currentUser] saveInBackground];
}

// When the user taps the cell to edit the bio, they transition to the edit bio controller.
-(void)segueToEditBio    {
    [self hideTabBar];
    [self performSegueWithIdentifier:@"editBioSegue" sender:self];
}

-(void)showLogoutCustomAlertView  {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"🤔" andMessage:@"Are you sure you want to logout? People nearby will still be able to match with you."];
    
    
    [alertView addButtonWithTitle:@"Yes"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              NSLog(@"User Requested logout");
                              [self attemptCurrentUserLogout];
                          }];
    //    [alertView addButtonWithTitle:@"No"
    //                             type:SIAlertViewButtonTypeDestructive
    //                          handler:^(SIAlertView *alert) {
    //                              NSLog(@"Button2 Clicked");
    //                          }];
    [alertView addButtonWithTitle:@"No"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              NSLog(@"User canceled logout");
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

-(void)wantsToChangeProfPicChange  {
    
    [self editUserPhotoWithFacebookAtIndex:0];
//    
//    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Guess what?" andMessage:@"Your main profile picture is automatically created using your Facebook profile. This keeps profiles authentic!"];
//    
//    
//    [alertView addButtonWithTitle:@"Got it!"
//                             type:SIAlertViewButtonTypeDefault
//                          handler:^(SIAlertView *alert) {
//                              
//                          }];
//    //    [alertView addButtonWithTitle:@"No"
//    //                             type:SIAlertViewButtonTypeDestructive
//    //                          handler:^(SIAlertView *alert) {
//    //                              NSLog(@"Button2 Clicked");
//    //                          }];
////    [alertView addButtonWithTitle:@"No"
////                             type:SIAlertViewButtonTypeCancel
////                          handler:^(SIAlertView *alert) {
////                              NSLog(@"User canceled logout");
////                          }];
//    
//    alertView.willShowHandler = ^(SIAlertView *alertView) {
//        NSLog(@"%@, willShowHandler", alertView);
//    };
//    alertView.didShowHandler = ^(SIAlertView *alertView) {
//        NSLog(@"%@, didShowHandler", alertView);
//    };
//    alertView.willDismissHandler = ^(SIAlertView *alertView) {
//        NSLog(@"%@, willDismissHandler", alertView);
//    };
//    alertView.didDismissHandler = ^(SIAlertView *alertView) {
//        NSLog(@"%@, didDismissHandler", alertView);
//    };
//    
//    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
//    
//    [alertView show];
}


-(void)attemptCurrentUserLogout {
    //TODO write.
}







@end
