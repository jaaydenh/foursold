//
//  GamePiece.h
//  Fours
//
//  Created by Halko, Jaayden on 4/12/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Utility.h"

@interface GamePiece : SKSpriteNode

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int column;
@property (nonatomic, assign) BOOL isPlayed;
@property (nonatomic, assign) int player;
@property (nonatomic, assign) CGPoint moveDestination;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSMutableArray *moveDestinations;

- (id)initWithImageNamed:(NSString*)name;
- (void)generateActions;
- (void)resetMovement;

@end
