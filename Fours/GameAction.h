//
//  GameAction.h
//  Fours
//
//  Created by Halko, Jaayden on 4/28/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GamePiece.h"
#import "GridPosition.h"
@interface GameAction : NSObject

@property SKAction *action;
@property GamePiece *gamePiece;
@property GridPosition *position;

- (id) initWithGamepiece:(GamePiece*)gamePiece andAction:(SKAction*)action andPosition:(GridPosition*)position;

@end
