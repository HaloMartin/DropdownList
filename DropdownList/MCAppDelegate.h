//
//  AppDelegate.h
//  DropdownList
//
//  Created by 朱进林 on 9/3/16.
//  Copyright © 2016 Martin Choo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(MCAppDelegate*)sharedAppDelegate;
+(UINavigationController*)getRootViewController;


@end

