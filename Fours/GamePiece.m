//
//  GamePiece.m
//  Fours
//
//  Created by Halko, Jaayden on 4/12/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import "GamePiece.h"

#define kPieceSize CGSizeMake(30, 30);

@interface GamePiece() {

}

@end

@implementation GamePiece

- (id)initWithImageNamed:(NSString *)name {
    self = [super initWithImageNamed:name];
    if (self) {
        self.anchorPoint = CGPointMake(0.0, 0.0);
        self.isPlayed = NO;
        self.size = CGSizeMake(30.0, 30.0);
    }
    return self;
}

@end
