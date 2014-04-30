//
//  GridPosition.h
//  Fours
//
//  Created by Halko, Jaayden on 4/14/14.
//  Copyright (c) 2014 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GridPosition : NSObject

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int column;

- (id)initWithRow:(int)row andColumn:(int)column;

@end
