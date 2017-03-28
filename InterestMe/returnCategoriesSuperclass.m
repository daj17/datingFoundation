//  returnCategoriesSuperclass.m

// Builds up list of categories.

#import "returnCategoriesSuperclass.h"

@interface returnCategoriesSuperclass ()

@end

@implementation returnCategoriesSuperclass

//Build up the list of categories to show the user...
+ (NSDictionary *)returnCategoriesDict    {
    
    NSMutableArray * broadCategoriesList=[[NSMutableArray alloc] init];
    
    // Here we build list of broad categories

//    [broadCategoriesList addObject:@"Sports I Like To Watch"];
    [broadCategoriesList addObject:@"Sports And Outdoors"];
    [broadCategoriesList addObject:@"Music I Like"];
    [broadCategoriesList addObject:@"Important To Me"];
//    [broadCategoriesList addObject:@"My Favorite TV Shows"]; //not a zero sum if ur partner likes different ones...
    [broadCategoriesList addObject:@"Politics"];
    [broadCategoriesList addObject:@"Religion"];
//    [broadCategoriesList addObject:@"Interested In"];
//    [broadCategoriesList addObject:@"Intellectual Interests"]; //boring
//    [broadCategoriesList addObject:@"Nationality(?)Race"]; //Probably not a good idea to have race in here...
    
    
    
    // Now for each of these broad categories, we make a subarray of specific examples.
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    NSMutableArray * waysToStayFitArray=[[NSMutableArray alloc] init];
    [waysToStayFitArray addObject:@"Baseball ⚾"];
    [waysToStayFitArray addObject:@"Basketball 🏀"];
    [waysToStayFitArray addObject:@"Beachin' 🌊🌴"];
    [waysToStayFitArray addObject:@"Boxing"];
    [waysToStayFitArray addObject:@"Camping ⛺"];
    [waysToStayFitArray addObject:@"Canoeing"];
    [waysToStayFitArray addObject:@"Climbing"];
    [waysToStayFitArray addObject:@"Cricket 🏏"];
    [waysToStayFitArray addObject:@"Cross Country 🏃"];
    [waysToStayFitArray addObject:@"CrossFit"];
    [waysToStayFitArray addObject:@"Cycling 🚲"];
    [waysToStayFitArray addObject:@"Diving"];
    [waysToStayFitArray addObject:@"Fencing ⚔"];
    [waysToStayFitArray addObject:@"Fishing 🎣"];
    [waysToStayFitArray addObject:@"Football 🏈"];
    [waysToStayFitArray addObject:@"Hiking 🗻"];
    [waysToStayFitArray addObject:@"Hockey 🏒"];
    [waysToStayFitArray addObject:@"Hunting"];
    [waysToStayFitArray addObject:@"Kayaking"];
    [waysToStayFitArray addObject:@"Lacrosse"];
    [waysToStayFitArray addObject:@"Lifting Weights 🏋"];
    [waysToStayFitArray addObject:@"Mud Trucking"];
    [waysToStayFitArray addObject:@"Pilates"];
    [waysToStayFitArray addObject:@"Rafting"];
    [waysToStayFitArray addObject:@"Rowing 🚣"];
    [waysToStayFitArray addObject:@"Rugby 🏉"];
    [waysToStayFitArray addObject:@"Running 🏃"];
    [waysToStayFitArray addObject:@"Sailing ⛵"];
    [waysToStayFitArray addObject:@"Skiing 🎿"];
    [waysToStayFitArray addObject:@"Skydiving"];
    [waysToStayFitArray addObject:@"Slacklining"];
    [waysToStayFitArray addObject:@"Snowboarding 🏂"];
    [waysToStayFitArray addObject:@"Soccer ⚽"];
    [waysToStayFitArray addObject:@"Softball"];
    [waysToStayFitArray addObject:@"Squash 🍆"]; // lolol
    [waysToStayFitArray addObject:@"Surfing 🏄"];
    [waysToStayFitArray addObject:@"Swimming 🏊"];
    [waysToStayFitArray addObject:@"Tennis 🎾"];
    [waysToStayFitArray addObject:@"Track And Field"];
    [waysToStayFitArray addObject:@"Volleyball 🏐"];
    [waysToStayFitArray addObject:@"Water Polo"];
    [waysToStayFitArray addObject:@"Wrestling"];
    [waysToStayFitArray addObject:@"Yoga"];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    NSMutableArray * religionArray=[[NSMutableArray alloc] init];
    [religionArray addObject:@"Agnostic"];
    [religionArray addObject:@"Atheist"];
    [religionArray addObject:@"Buddhist"];
    [religionArray addObject:@"Christian"];
    [religionArray addObject:@"Hinduist"];
    [religionArray addObject:@"Judaist"];
    [religionArray addObject:@"Muslim"];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    NSMutableArray * politicsArray=[[NSMutableArray alloc] init];
    [politicsArray addObject:@"Democrat"];
    [politicsArray addObject:@"Green Party"];
    [politicsArray addObject:@"Independent"];
    [politicsArray addObject:@"Libertarian"];
    [politicsArray addObject:@"Republican"];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
//    NSMutableArray * sportsIWatchArray=[[NSMutableArray alloc] init];
//    [sportsIWatchArray addObject:@"Baseball ⚾"];
//    [sportsIWatchArray addObject:@"Basketball 🏀"];
//    [sportsIWatchArray addObject:@"Boxing"];
//    [sportsIWatchArray addObject:@"Cricket 🏏"];
////    [sportsIWatchArray addObject:@"Cross Country"]; // These commented out ones are IMO not big "watching" sports
////    [sportsIWatchArray addObject:@"Cycling 🚲"];
////    [sportsIWatchArray addObject:@"Diving"];
////    [sportsIWatchArray addObject:@"Fencing ⚔"];
//    [sportsIWatchArray addObject:@"Football 🏈"];
//    [sportsIWatchArray addObject:@"Hockey 🏒"];
//    [sportsIWatchArray addObject:@"Lacrosse"];
////    [sportsIWatchArray addObject:@"Lifting Weights 🏋"];
////    [sportsIWatchArray addObject:@"Pilates"];
////    [sportsIWatchArray addObject:@"Rowing 🚣"];
////    [sportsIWatchArray addObject:@"Rugby 🏉"];
////    [sportsIWatchArray addObject:@"Running 🏃"];
//    [sportsIWatchArray addObject:@"Soccer ⚽"];
//    [sportsIWatchArray addObject:@"Softball"];
////    [sportsIWatchArray addObject:@"Squash 🍆"]; // lolol
////    [sportsIWatchArray addObject:@"Swimming 🏊"];
//    [sportsIWatchArray addObject:@"Tennis 🎾"];
////    [sportsIWatchArray addObject:@"Track And Field"];
////    [sportsIWatchArray addObject:@"Volleyball 🏐"];
////    [sportsIWatchArray addObject:@"Water Polo"];
//    [sportsIWatchArray addObject:@"Wrestling"];
//    [sportsIWatchArray addObject:@"Yoga"];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    NSMutableArray * musicILike=[[NSMutableArray alloc] init];
    [musicILike addObject:@"Alternative Rock"];
    [musicILike addObject:@"Blues"];
    [musicILike addObject:@"Classical"];
    [musicILike addObject:@"Country"];
    [musicILike addObject:@"Dubstep"];
    [musicILike addObject:@"EDM"];
    [musicILike addObject:@"Funk"];
    [musicILike addObject:@"Hip hop"];
    [musicILike addObject:@"Indie"];
    [musicILike addObject:@"Jazz 🎷"];
    [musicILike addObject:@"K-Pop"];
    [musicILike addObject:@"Latin"];
    [musicILike addObject:@"Pop"];
    [musicILike addObject:@"Ragtime"];
    [musicILike addObject:@"Rap"];
    [musicILike addObject:@"Rock"];
    [musicILike addObject:@"Salsa"];
    [musicILike addObject:@"Soul"];
    [musicILike addObject:@"Techno"];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    NSMutableArray * importantToMeArray=[[NSMutableArray alloc] init];
    [importantToMeArray addObject:@"Eating Healthy 🍉🍞"];
    [importantToMeArray addObject:@"Learning 💡"];
    [importantToMeArray addObject:@"Musicianship 🎶"];
    [importantToMeArray addObject:@"Traveling"];
//    [importantToMeArray addObject:@"Brain"];
//    [importantToMeArray addObject:@"Looks"];
//    [importantToMeArray addObject:@"Personality"];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
//    NSMutableArray * outdoorAcivitiesILike=[[NSMutableArray alloc] init];
//    [outdoorAcivitiesILike addObject:@"Beachin' 🌊🌴"];
//    [outdoorAcivitiesILike addObject:@"Camping ⛺"];
//    [outdoorAcivitiesILike addObject:@"Canoeing"];
//    [outdoorAcivitiesILike addObject:@"Fishing 🎣"];
//    [outdoorAcivitiesILike addObject:@"Hiking 🗻"];
//    [outdoorAcivitiesILike addObject:@"Hunting"];
//    [outdoorAcivitiesILike addObject:@"Kayaking"];
//    [outdoorAcivitiesILike addObject:@"Mud Trucking"];
//    [outdoorAcivitiesILike addObject:@"Rafting"];
//    [outdoorAcivitiesILike addObject:@"Sailing ⛵"];
//    [outdoorAcivitiesILike addObject:@"Skiing 🎿"];
//    [outdoorAcivitiesILike addObject:@"Skydiving"];
//    [outdoorAcivitiesILike addObject:@"Slacklining"];
//    [outdoorAcivitiesILike addObject:@"Snowboarding 🏂"];
//    [outdoorAcivitiesILike addObject:@"Surfing 🏄"];

//  [outdoorAcivitiesILike addObject:@"Spearfishing"]; // Pretty similar to fishing
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
//    NSMutableArray * sexInterestArray=[[NSMutableArray alloc] init];
//    [sexInterestArray addObject:@"Men"];
//    [sexInterestArray addObject:@"Women"];
//    [sexInterestArray addObject:@"Other"];
    
    // Create the big dictionary that contains categories data
    NSMutableDictionary * categoriesDict=[[NSMutableDictionary alloc] initWithCapacity:[broadCategoriesList count]];
    
    //And now add them to the dictionary.
//    [categoriesDict setObject:sportsIWatchArray forKey:[broadCategoriesList objectAtIndex:0]];
    [categoriesDict setObject:waysToStayFitArray forKey:[broadCategoriesList objectAtIndex:0]];
    [categoriesDict setObject:musicILike forKey:[broadCategoriesList objectAtIndex:1]];
    [categoriesDict setObject:importantToMeArray forKey:[broadCategoriesList objectAtIndex:2]];
//    [categoriesDict setObject:outdoorAcivitiesILike forKey:[broadCategoriesList objectAtIndex:4]]; // condensed into fitness
    [categoriesDict setObject:politicsArray forKey:[broadCategoriesList objectAtIndex:3]];
    [categoriesDict setObject:religionArray forKey:[broadCategoriesList objectAtIndex:4]];
//    [categoriesDict setObject:sexInterestArray forKey:[broadCategoriesList objectAtIndex:7]]; //really not mutual intersts, I propse putting this on the profile page...
    
    return categoriesDict;

}

@end
