/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKScene.h"
#import "GameKitTurnBasedMatchHelper.h"

// IMPORTANT: in Kobold Kit all scenes must inherit from KKScene.
@interface GameScene : KKScene <GameKitTurnBasedMatchHelperDelegate, UIGestureRecognizerDelegate>


@end
