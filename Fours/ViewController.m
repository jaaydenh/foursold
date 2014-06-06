/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <KoboldKit.h>
#import "ViewController.h"
#import "GameScene.h"
#import "GameKitHelper.h"

@implementation ViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController)
                                                 name:PresentAuthenticationViewController object:nil];
    
    //[[GameKitTurnBasedMatchHelper sharedInstance] authenticateLocalPlayer];
    
    //[[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

//- (void)playerAuthenticated {
    //[[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:self];
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) presentFirstScene
{
	// create and present first scene
	GameScene* myScene = [GameScene sceneWithSize:self.view.bounds.size];
	[self.kkView presentScene:myScene];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
      //                                          name:LocalPlayerIsAuthenticated object:nil];
}

- (void)showAuthenticationViewController
{
    //[[GameKitTurnBasedMatchHelper sharedInstance] authenticateLocalPlayer];
    //GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
     [self presentViewController:[GameKitTurnBasedMatchHelper sharedInstance].authenticationViewController animated:YES completion:nil];
   // [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}

@end
