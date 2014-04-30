//
//  GameAction.m
//  Fours
//
//  Created by Halko, Jaayden on 4/28/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GameAction.h"

@implementation GameAction

- (id) initWithGamepiece:(GamePiece*)gamePiece andAction:(SKAction*)action andPosition:(GridPosition*)position{
    if (self = [super init]) {
        self.gamePiece = gamePiece;
        self.action = action;
        self.position = position;
    }
    return self;
}

@end
