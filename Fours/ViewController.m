/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <KoboldKit.h>
#import "ViewController.h"
#import "GameScene.h"

@implementation ViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

-(void) presentFirstScene
{
	// create and present first scene
	GameScene* myScene = [GameScene sceneWithSize:self.view.bounds.size];
	[self.kkView presentScene:myScene];
}

@end
