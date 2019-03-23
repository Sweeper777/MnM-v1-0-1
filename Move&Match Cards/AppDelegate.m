//
//  AppDelegate.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 02.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MMViewController.h"
#import "MMBorder.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_viewController release];
    [_window release];
    [super dealloc];
}

//Запуск приложения
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[MMViewController alloc] initWithNibName:@"MMViewController" bundle:nil] autorelease];
    
    // Override point for customization after application launch.
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
    
    //Получение пути файла
    NSURL *fileURL = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if(fileURL){
        NSLog(@"%@",[fileURL absoluteString]);
        NSString *pathFile = [[[fileURL absoluteString] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *inboxDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_inbox];
        pathFile = [inboxDirectory stringByAppendingPathComponent:pathFile];
        
        MMViewController *controller =(MMViewController*) self.viewController;
        controller.borderView.isMakeMode = NO;
        [controller.borderView deleteAllObjectsFromBorder];
        [controller clearHistory];
        [controller loadingDocumentFromFile2:pathFile];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url isFileURL])
    {
        NSLog(@"%@",[url absoluteString]);
        NSString *pathFile = [[[url absoluteString] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *inboxDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_inbox];
        pathFile = [inboxDirectory stringByAppendingPathComponent:pathFile];
        
        MMViewController *controller =(MMViewController*) self.viewController;
        controller.borderView.isMakeMode = NO;
        [controller.borderView deleteAllObjectsFromBorder];
        [controller clearHistory];
        [controller loadingDocumentFromFile2:pathFile];
    }
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
    //очистка папки temp
    NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:path_tmp];
    [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
}

@end
