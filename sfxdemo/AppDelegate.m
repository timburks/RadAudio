//
//  AppDelegate.m
//  sfxdemo
//
//  Created by Tim Burks on 7/26/13.
//
//

#import "AppDelegate.h"
#import "RadAudioGraph.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    RadAudioGraph *player = [[RadAudioGraph alloc] init];
    [player openGraph];
    
    RadAudioFilePlayerUnit *filePlayerNode = [player addFilePlayerNode];
    RadAudioReverbUnit *reverbNode = [player addReverbNode];
    RadAudioUnit *outputNode = [player addOutputNode];
    RadAudioMixerUnit *mixerNode = [player addMixerNode];
    
    RadAudioToneGeneratorUnit *toneGeneratorNode1 = [player addToneGeneratorNode];
    toneGeneratorNode1.frequency = 440;
    
    RadAudioSFXRUnit *sfxrNode = [player addSFXRNode];
    RadAudioSFXRUnit *sfxrNode2 = [player addSFXRNode];
    
    [player connectOutputOfNode:filePlayerNode channel:0 toInputOfNode:mixerNode channel:0];
    [player connectOutputOfNode:toneGeneratorNode1 channel:0 toInputOfNode:mixerNode channel:1];
    [player connectOutputOfNode:sfxrNode channel:0 toInputOfNode:mixerNode channel:2];
    [player connectOutputOfNode:sfxrNode2 channel:0 toInputOfNode:mixerNode channel:3];
    [player connectOutputOfNode:mixerNode toInputOfNode:outputNode];
    
    [player initializeGraph];
    
    [mixerNode setNumberOfInputs:4];
    [mixerNode setVolume:1.0 forInput:0];
    [mixerNode setVolume:1.0 forInput:1];
    [mixerNode setVolume:1.0 forInput:2];
    [mixerNode setVolume:1.0 forInput:3];
    [mixerNode setOutputVolume:1.0];
    
    [reverbNode setReverbRoomType:kReverbRoomType_Plate];
    
    int playTime;
    if (filePlayerNode) {
        [filePlayerNode prepareWithFile:[[NSBundle mainBundle] pathForResource:@"money" ofType:@"m4a"]];
        playTime = [filePlayerNode duration];
    } else {
        playTime = 10;
    }
    
    [sfxrNode jump];
    [sfxrNode2 explosion];
    
    [player start];
    
 

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
 //   [player stop];
    
 //   [filePlayerNode closeFile];
}

@end
