//
//  AppDelegate.m
//  Diary
//
//  Created by Ethan Neff on 6/9/14.
//  Copyright (c) 2014 Ethan Neff. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.backgroundColor = [UIColor whiteColor];
    [self setupAppearance];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)setupAppearance {
    UINavigationBar * navigationBarAppearance = [UINavigationBar appearance];
    navigationBarAppearance.barTintColor = [UIColor colorWithRed:77.0/255.0 green:164.0/255.0 blue:191.0/255.0 alpha:1.0f];
    navigationBarAppearance.tintColor = [UIColor whiteColor];
    navigationBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

@end
