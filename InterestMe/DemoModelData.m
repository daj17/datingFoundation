//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DemoModelData.h"
#import "ColorSuperclass.h"
#import "NSUserDefaults+DemoSettings.h"


@implementation DemoModelData

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        self.messages = [NSMutableArray new];
  
    }
    
    return self;
}

-(void)doBasicSetup {
    
    
    
    /**
     *  Create avatar images once.
     *
     *  Be sure to create your avatars one time and reuse them for good performance.
     *
     *  If you are not using avatars, ignore this.
     */
    JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] initWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    JSQMessagesAvatarImage *jsqImage = [avatarFactory avatarImageWithUserInitials:@"Me"
                                                                  backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                        textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                             font:[UIFont systemFontOfSize:14.0f]];
    
    JSQMessagesAvatarImage *cookImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_cook"]];
    
    JSQMessagesAvatarImage *jobsImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_jobs"]];
    NSLog(@"image: %@",self.userImage);
    
    
    JSQMessagesAvatarImage *wozImage = [avatarFactory avatarImageWithImage:self.userImage];
    
    self.avatars = @{ kJSQDemoAvatarIdSquires : jsqImage,
                      kJSQDemoAvatarIdCook : cookImage,
                      kJSQDemoAvatarIdJobs : jobsImage,
                      kJSQDemoAvatarIdWoz : wozImage };
    
    
    self.users = @{ kJSQDemoAvatarIdJobs : kJSQDemoAvatarDisplayNameJobs,
                    kJSQDemoAvatarIdCook : kJSQDemoAvatarDisplayNameCook,
                    kJSQDemoAvatarIdWoz : kJSQDemoAvatarDisplayNameWoz,
                    kJSQDemoAvatarIdSquires : kJSQDemoAvatarDisplayNameSquires };
    
    
    /**
     *  Create message bubble images objects.
     *
     *  Be sure to create your bubble images one time and reuse them for good performance.
     *
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    UIColor * incomingColor=[ColorSuperclass returnIncomingMessagesColor];
    
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:incomingColor];
}

-(void)refreshTheMessages   {
    if ([NSUserDefaults emptyMessagesSetting]) {
        self.messages = [NSMutableArray new];
    }
    else {
        [self refreshMessagesForUser:self.user];
    }
}

-(void)addMessageUsingPFObject:(PFObject *)message  {
    JSQMessage * newMessage=[[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                               senderDisplayName:[PFUser currentUser][@"first_name"]
                                                            date:message[@"dateMade"]
                                                            text:NSLocalizedString(message[@"text"], nil)];
    [self.messages addObject:newMessage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeQuipsBecauseMessages"
                                                        object:self
                                                      userInfo:nil];

}

BOOL REFRESHING_MESSAGES=NO;
-(void)refreshMessagesForUser:(PFUser *)user  {
    if (!REFRESHING_MESSAGES)REFRESHING_MESSAGES=YES;
    NSLog(@"user: %@",self.user);
    NSString * username=user.username;
    PFQuery * query=[PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"whoSent" equalTo:username];
     [query whereKey:@"whoSentTo" equalTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *messagesTheySentMe, NSError *error) {
        if (!error) {
            
            PFQuery * query=[PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"whoSent" equalTo:[PFUser currentUser].username];
            [query whereKey:@"whoSentTo" equalTo:self.user.username];
            [query findObjectsInBackgroundWithBlock:^(NSArray *messagesISentThem, NSError *error) {
                if (!error) {
                    
                    NSArray * allMessages=[messagesTheySentMe arrayByAddingObjectsFromArray:messagesISentThem];
                    
                    NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                                        sortDescriptorWithKey:@"createdAt"
                                                        ascending:YES];
                    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
                    NSArray *sortedObjectsArray = [allMessages
                                                 sortedArrayUsingDescriptors:sortDescriptors];
                    
                    
                    NSMutableArray * messageObjectsCreated=[[NSMutableArray alloc] init];

                    for (int i=0;i<[sortedObjectsArray count];i++) { //for each mesage PFobject, we want to create local object
                        
                        PFObject * message=[sortedObjectsArray objectAtIndex:i];
                        
                        if ([message[@"whoSent"] isEqualToString:[PFUser currentUser].username])    {
                            JSQMessage * newMessage=[[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                                                       senderDisplayName:[PFUser currentUser][@"first_name"]
                                                                                    date:message[@"dateMade"]
                                                                                    text:NSLocalizedString(message[@"text"], nil)];
                            [messageObjectsCreated addObject:newMessage];
                        } else{
                            JSQMessage * newMessage=[[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdWoz
                                                                       senderDisplayName:@""//self.user[@"first_name"]
                                                                                    date:message[@"dateMade"]
                                                                                    text:NSLocalizedString(message[@"text"], nil)];
                            [messageObjectsCreated addObject:newMessage];
                           

                        }
                        
                    }
                    
                    self.messages=messageObjectsCreated; //switch pointer over
                    
                    if ([messageObjectsCreated count]==0)   {

                        
                        
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"showQuipsBecauseNoMessages"
                                                                            object:self
                                                                          userInfo:nil];

                    } else{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeQuipsBecauseMessages"
                                                                            object:self
                                                                          userInfo:nil];
                        
                    }
                    
                    

                    REFRESHING_MESSAGES=NO; // We're done
                    
                } else{
                    REFRESHING_MESSAGES=NO;
                    NSLog(@"Error: %@",error);
                    ;
                }
            }];
            
            
            
        } else{
            REFRESHING_MESSAGES=NO;
            NSLog(@"Error: %@",error);
            ;
        }
    }];
    
    
    
}

- (void)loadFakeMessages
{
    /**
     *  Load some fake messages for demo.
     *
     *  You should have a mutable array or orderedSet, or something.
     */
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                        senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                     date:[NSDate distantPast]
                                                     text:NSLocalizedString(@"Welcome to JSQMessages: A messaging UI framework for iOS.", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdWoz
                                        senderDisplayName:kJSQDemoAvatarDisplayNameWoz
                                                     date:[NSDate distantPast]
                                                     text:NSLocalizedString(@"It is simple, elegant, and easy to use. There are super sweet default settings, but you can customize like crazy.", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                        senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                     date:[NSDate distantPast]
                                                     text:NSLocalizedString(@"It even has data detectors. You can call me tonight. My cell number is 123-456-7890. My website is www.hexedbits.com.", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdJobs
                                        senderDisplayName:kJSQDemoAvatarDisplayNameJobs
                                                     date:[NSDate date]
                                                     text:NSLocalizedString(@"JSQMessagesViewController is nearly an exact replica of the iOS Messages App. And perhaps, better.", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdCook
                                        senderDisplayName:kJSQDemoAvatarDisplayNameCook
                                                     date:[NSDate date]
                                                     text:NSLocalizedString(@"It is unit-tested, free, open-source, and documented.", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                        senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                     date:[NSDate date]
                                                     text:NSLocalizedString(@"Now with media messages!", nil)],
                     nil];
    
//    [self addPhotoMediaMessage];
//    [self addAudioMediaMessage];
    
    /**
     *  Setting to load extra messages for testing/demo
     */
    if ([NSUserDefaults extraMessagesSetting]) {
        NSArray *copyOfMessages = [self.messages copy];
        for (NSUInteger i = 0; i < 4; i++) {
            [self.messages addObjectsFromArray:copyOfMessages];
        }
    }
    
    
    /**
     *  Setting to load REALLY long message for testing/demo
     *  You should see "END" twice
     */
    if ([NSUserDefaults longMessageSetting]) {
        JSQMessage *reallyLongMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                            displayName:kJSQDemoAvatarDisplayNameSquires
                                                                   text:@"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? END Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? END"];
        
        [self.messages addObject:reallyLongMessage];
    }
}

- (void)addAudioMediaMessage
{
    NSString * sample = [[NSBundle mainBundle] pathForResource:@"jsq_messages_sample" ofType:@"m4a"];
    NSData * audioData = [NSData dataWithContentsOfFile:sample];
    JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithData:audioData];
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:audioItem];
    [self.messages addObject:audioMessage];
}

- (void)addPhotoMediaMessage
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"goldengate"]];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    [self.messages addObject:photoMessage];
}

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                      displayName:kJSQDemoAvatarDisplayNameSquires
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

- (void)addVideoMediaMessage
{
    // don't have a real video, just pretending
    NSURL *videoURL = [NSURL URLWithString:@"file://"];
    
    JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

@end
