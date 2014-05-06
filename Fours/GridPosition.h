//
//  GridPosition.h
//  Fours
//
//  Created by Halko, Jaayden on 4/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

@interface GridPosition : NSObject

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int column;
@property (nonatomic, assign) Direction direction;

- (id)initWithRow:(int)row andColumn:(int)column;

@end
