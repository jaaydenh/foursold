//
//  GameBoard.m
//  Fours
//
//  Created by Halko, Jaayden on 4/27/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GameBoard.h"
#import "Utility.h"

@implementation GameBoard

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {

    }
    return self;
}

- (void)addGamePieceAt:(CGPoint)location andDestinationRow:(NSInteger)row andDestinationColumn:(NSInteger)column
{
    //SKSpriteNode *piece = [SKSpriteNode spriteNodeWithImageNamed:@"gamepiece3"];
    NSString *gamePieceImage;
    if (self.currentPlayer == Player1) {
        gamePieceImage = @"orangepiece";
    } else {
        gamePieceImage = @"bluepiece";
    }
    GamePiece *piece = [[GamePiece alloc] initWithImageNamed:gamePieceImage];
    
    piece.position = location;
    piece.name = kGamePieceName;
    piece.row = row;
    piece.column = column;
    self.lastPiece = piece;
    [self addChild:piece];
}

@end
