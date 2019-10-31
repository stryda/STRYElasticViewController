//
//  AppDelegate.m
//  STRYElasticViewController
//
//  Created by Terry Lewis on 31/10/19.
//  Copyright © 2019 Terry Lewis. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Classes/STRYNavigationControllerDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *rootNavigationController;
@property (nonatomic, strong) ViewController *firstViewController;
@property (nonatomic, strong) STRYNavigationControllerDelegate *rootNavigationControllerDelegate;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  self.firstViewController = [[ViewController alloc] initWithDepth: 1];
  
  self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController: self.firstViewController];
  self.rootNavigationControllerDelegate = [[STRYNavigationControllerDelegate alloc] init];
  self.rootNavigationController.delegate = self.rootNavigationControllerDelegate;
  
  self.window.rootViewController = self.rootNavigationController;
  [self.window makeKeyAndVisible];
  
  return YES;
}


@end
