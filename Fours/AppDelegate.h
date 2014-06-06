/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKAppDelegate.h"
#import "PlayerCache.h"

@interface AppDelegate : KKAppDelegate

@property (strong, nonatomic) PlayerCache *playerCache;

@end

#define APP_DELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)