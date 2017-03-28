//
//  MainTabBarController.m


#import "MainTabBarController.h"
#import "ColorSuperclass.h"

#define TAB_SWIPING 0
#define TAB_INTERESTS 1
#define TAB_PROFILE 2

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearance] setBarTintColor:[ColorSuperclass returnTabbarBackgroundTintColor]];
    self.tabBar.tintColor=[ColorSuperclass returnTabbarTextTintColor];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated    {
    
    [[self.tabBar.items objectAtIndex:TAB_SWIPING] setTitle:@"People"];
    [[self.tabBar.items objectAtIndex:TAB_INTERESTS] setTitle:@"Interests"];
    [[self.tabBar.items objectAtIndex:TAB_PROFILE] setTitle:@"Me"];
    
//    self.tabBar.tintColor=[ColorSuperclass returnTabbarTintColor];
    
//    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
