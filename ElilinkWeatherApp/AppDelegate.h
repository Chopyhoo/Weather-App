//
//  AppDelegate.h
//  ElilinkWeatherApp
//
//  Created by Alex Sobolevski on 3/13/17.
//  Copyright © 2017 Alex Sobolevski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

