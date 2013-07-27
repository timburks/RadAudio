//
//  AppDelegate.m
//  sfxdemo
//
//  Created by Tim Burks on 7/26/13.
//
//

#import "AppDelegate.h"
#import "SFXViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];    
    self.window.rootViewController = [[SFXViewController alloc] init];
    return YES;
}

@end
