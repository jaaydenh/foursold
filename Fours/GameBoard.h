//
//  GameBoard.h
//  Fours
//
//  Created by Halko, Jaayden on 4/27/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GamePiece.h"

@interface GameBoard : SKSpriteNode

@property int currentPlayer;
@property GamePiece *lastPiece;

- (id)initWithImageNamed:(NSString *)name;

@end
