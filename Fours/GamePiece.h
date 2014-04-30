//
//  GamePiece.h
//  Fours
//
//  Created by Halko, Jaayden on 4/12/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GamePiece : SKSpriteNode

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int column;
@property (nonatomic, assign) BOOL isPlayed;
@property (nonatomic, assign) int player;
@property (nonatomic, assign) CGPoint moveDestination;

- (id)initWithImageNamed:(NSString*)name;

@end
