/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "GameScene.h"
#import "RemoveSpaceshipBehavior.h"
#import "GamePiece.h"
#import "GridPosition.h"
#import "GameBoard.h"
#import "Utility.h"
#import "GameAction.h"

#pragma mark - Custom Type Definitions

typedef enum {
    None,
    Sticky,
    UpArrow,
    DownArrow,
    LeftArrow,
    RightArrow
} TokenType;

typedef enum {
    Top,
    Bottom,
    LeftSide,
    RightSide
} TapArea;

typedef enum {
    Up,
    Down,
    Left,
    Right
} Direction;

#define kColumnSize 30
#define kRowSize    30
#define kPieceSize  30
#define kGridXOffset 40.0
#define kGridYOffset 150.0
#define kTapAreaWidth 40
#define kBoardRows 8
#define kBoardColumns 8
#define kWinnerLabelName @"winnerLabel"


#pragma mark - Private GameScene Properties

@interface GameScene ()
@property BOOL contentCreated;
@property BOOL validMove;
@property SKSpriteNode *tapAreaLeft;
@property SKSpriteNode *tapAreaRight;
@property SKSpriteNode *tapAreaTop;
@property SKSpriteNode *tapAreaBottom;
@property SKSpriteNode *highlight;
@property int currentPlayer;
@property int boardColumns;
@property int boardRows;
@property (strong) NSMutableArray *winningPositions;
@property GamePiece *lastPiece;
@property GamePiece *currentPiece;
@property NSMutableArray *moveDestinations;
@property GameAction *action;
@end

@implementation GameScene

//GamePiece* test[8][8];
GamePiece *gameBoard[8][8];
int boardTokens[8][8];

-(void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

-(void)createContent
{
    self.boardRows = kBoardRows;
    self.boardColumns = kBoardColumns;
    self.moveDestinations = [[NSMutableArray alloc] init];
    self.action = nil;
    
    self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    [self setupTapAreas];
    [self setupBoard];
    
    self.currentPlayer = Player1;
    
    SKLabelNode *winnerLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    winnerLabel.fontSize = 26;
    winnerLabel.position = CGPointMake(self.frame.size.width/2 ,self.frame.size.height/2);
    winnerLabel.zPosition = 1.0;
    winnerLabel.hidden = YES;
    winnerLabel.name = kWinnerLabelName;
    [self addChild:winnerLabel];
    
    [self addMenuButton];
}

-(void)setupBoard
{
    //SKSpriteNode *grid = [SKSpriteNode spriteNodeWithImageNamed:@"grid8"];
    //grid.anchorPoint = CGPointMake(0.0, 0.0);
    //grid.position = CGPointMake(kGridXOffset, kGridYOffset);
    //[self addChild:grid];
    
    GameBoard *board  = [[GameBoard alloc] initWithImageNamed:@"grid8"];
    board.anchorPoint = CGPointMake(0.0, 0.0);
    board.position = CGPointMake(kGridXOffset, kGridYOffset);
    [self addChild:board];
    
    [self resetBoard];
    [self resetBoardTokens];
    [self generateBoardTokens];
}

-(void)setupTapAreas
{
    SKAction *fadeOut = [SKAction fadeAlphaTo:.4 duration:.1];
    //SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:.8];
    //SKAction *pulse = [SKAction sequence:@[fadeOut,fadeIn]];
    //SKAction *pulseForever = [SKAction repeatActionForever:pulse];
    
    self.tapAreaLeft = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area" ];
    self.tapAreaLeft.size = CGSizeMake(kTapAreaWidth, kRowSize * self.boardRows);
    self.tapAreaLeft.anchorPoint = CGPointMake(0.0, 0.0);
    self.tapAreaLeft.position = CGPointMake(0.0, 150.0);
    self.tapAreaLeft.name = @"tapAreaLeft";
    [self addChild:self.tapAreaLeft];
    [self.tapAreaLeft runAction:fadeOut];
    
    self.tapAreaRight = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area" ];
    self.tapAreaRight.size = CGSizeMake(kTapAreaWidth, kRowSize * self.boardRows);
    self.tapAreaRight.anchorPoint = CGPointMake(0.0, 0.0);
    self.tapAreaRight.position = CGPointMake(280.0, 150.0);
    self.tapAreaRight.name = @"tapAreaRight";
    [self addChild:self.tapAreaRight];
    [self.tapAreaRight runAction:fadeOut];
    
    self.tapAreaTop = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area" ];
    self.tapAreaTop.size = CGSizeMake(kColumnSize * self.boardColumns, kTapAreaWidth);
    self.tapAreaTop.anchorPoint = CGPointMake(0.0, 0.0);
    self.tapAreaTop.position = CGPointMake(40.0, 390.0);
    self.tapAreaTop.name = @"tapAreaTop";
    [self addChild:self.tapAreaTop];
    [self.tapAreaTop runAction:fadeOut];
    
    self.tapAreaBottom = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area" ];
    self.tapAreaBottom.size = CGSizeMake(kColumnSize * self.boardColumns, kTapAreaWidth);
    self.tapAreaBottom.anchorPoint = CGPointMake(0.0, 0.0);
    self.tapAreaBottom.position = CGPointMake(40.0, 110.0);
    self.tapAreaBottom.name = @"tapAreaBottom";
    [self addChild:self.tapAreaBottom];
    [self.tapAreaBottom runAction:fadeOut];
}

-(void)resetBoard {
    for (int col = 0; col < self.boardColumns; col++) {
		for (int row = 0; row < self.boardRows; row++) {
			gameBoard[col][row] = nil;
		}
	}
}

-(void)printBoard {
    NSLog(@" ");
    NSString *rowString = @"";
    for (int row = self.boardRows-1; row >= 0; row--) {
		for (int col = 0; col < self.boardColumns; col++) {
            if (gameBoard[row][col].player == Player1) {
                rowString = [rowString stringByAppendingString:@"1 "];
            } else if (gameBoard[row][col].player == Player2) {
                rowString = [rowString stringByAppendingString:@"2 "];
            } else {
                rowString = [rowString stringByAppendingString:@"0 "];
            }
		}
        NSLog(@"%@", rowString);
        rowString = @"";
	}
}

-(void)resetBoardTokens {
    for (int col = 0; col < self.boardColumns; col++) {
		for (int row = 0; row < self.boardRows; row++) {
			boardTokens[col][row] = None;
		}
	}
}

-(void)generateBoardTokens {
    boardTokens[1][1] = Sticky;
    boardTokens[2][2] = Sticky;
    boardTokens[5][5] = Sticky;
    boardTokens[6][6] = Sticky;
    [self addTokenAt:1 andColumn:1 andType:@"stickytoken"];
    [self addTokenAt:2 andColumn:2 andType:@"stickytoken"];
    [self addTokenAt:5 andColumn:5 andType:@"stickytoken"];
    [self addTokenAt:6 andColumn:6 andType:@"stickytoken"];
    
}

-(void)resetGame {
	[self enumerateChildNodesWithName:kGamePieceName usingBlock:^(SKNode* node, BOOL* stop) {
        [node removeFromParent];
	}];
    
    [self resetBoard];
    
    SKLabelNode *winner = (SKLabelNode*)[self childNodeWithName:kWinnerLabelName];
    winner.hidden = YES;
}

-(void) addMenuButton
{
    SKSpriteNode *menuButton = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(45.0, 45.0)];
    menuButton.anchorPoint = CGPointMake(0.0, 0.0);
    menuButton.position = CGPointMake(self.frame.size.width - menuButton.frame.size.width,
                                        self.frame.size.height - menuButton.frame.size.height);
	[self addChild:menuButton];
	
	// KKButtonBehavior turns any node into a button
	KKButtonBehavior* buttonBehavior = [KKButtonBehavior behavior];
	buttonBehavior.selectedScale = 1.2;
	[menuButton addBehavior:buttonBehavior];
	
	// observe button execute notification
	[self observeNotification:KKButtonDidExecuteNotification
					 selector:@selector(menuButtonDidExecute:)
					   object:menuButton];

	// preload the sound the button plays
	[[OALSimpleAudio sharedInstance] preloadEffect:@"die.wav"];
}

-(void) menuButtonDidExecute:(NSNotification*)notification
{
	[[OALSimpleAudio sharedInstance] playEffect:@"die.wav"];

    [self resetGame];
}

-(void)addTokenAt:(int)row andColumn:(int)column andType:(NSString*)tokenType {
    CGFloat x = column * kColumnSize + kGridXOffset;
    CGFloat y = row * kRowSize +  kGridYOffset;
    
    NSString *gamePieceImage = @"magnet";
    GamePiece *piece = [[GamePiece alloc] initWithImageNamed:gamePieceImage];
    piece.position = CGPointMake(x, y);
    piece.name = @"stickytoken";
    piece.row = row;
    piece.column = column;
    piece.size = CGSizeMake(22.0, 22.0);
    piece.position = CGPointMake(piece.position.x + 4, piece.position.y + 5);
    [self addChild:piece];
}

-(void)addGamePieceAt:(CGPoint)location
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
    piece.player = self.currentPlayer;
    self.lastPiece = piece;
    [self addChild:piece];
}

-(void)addGamePieceHighlightFrom:(TapArea)origin toRow:(NSInteger)row toColumn:(NSInteger)column {
    [self.highlight removeFromParent];
    self.highlight = [SKSpriteNode spriteNodeWithImageNamed:@"tap_area"];
    self.highlight.alpha = 0.3;
    self.highlight.anchorPoint = CGPointMake(0.0, 0.0);
    
    if (origin == Top) {
        self.highlight.size = CGSizeMake(kColumnSize, (self.boardRows - row) * kRowSize);
        self.highlight.position = CGPointMake(column * kColumnSize + kGridXOffset, kGridYOffset + (row *kRowSize));
    } else if (origin == Bottom) {
        self.highlight.size = CGSizeMake(kColumnSize, (row + 1) * kRowSize);
        self.highlight.position = CGPointMake(column * kColumnSize + kGridXOffset, kGridYOffset);
    } else if (origin == LeftSide) {
        self.highlight.size = CGSizeMake((column + 1) * kColumnSize, kRowSize);
        self.highlight.position = CGPointMake(kGridXOffset, row * kRowSize + kGridYOffset);
    } else if (origin == RightSide) {
        self.highlight.size = CGSizeMake((self.boardColumns - column) * kColumnSize, kRowSize);
        self.highlight.position = CGPointMake(kGridXOffset + (column * kColumnSize), row * kRowSize + kGridYOffset);
    }
    
    [self addChild:self.highlight];
}

- (void)calculateMove:(CGPoint)touchLocation {
    BOOL validMove = YES;
    Direction direction = -1;
    int startingRow = -1;
    int startingColumn = -1;
    int destinationRow = -1;
    int destinationColumn;
    int column = floor((touchLocation.x - kGridXOffset) / kColumnSize);
    int row = floor((touchLocation.y - kGridYOffset) / kRowSize);
    destinationColumn = column;
    CGPoint location = CGPointMake(0.0, 0.0);
    
    [self.moveDestinations removeAllObjects];
    
    if ([self.tapAreaTop containsPoint:touchLocation]) {
        startingRow = self.boardRows-1;
        startingColumn = column;
        direction = Down;
        location = CGPointMake(column * kColumnSize + kGridXOffset, kGridYOffset + kRowSize * self.boardRows + 5);
    } else if ([self.tapAreaBottom containsPoint:touchLocation]) {
        startingRow = 0;
        startingColumn = column;
        direction = Up;
        location = CGPointMake(column * kColumnSize + kGridXOffset, kGridYOffset - kRowSize - 5);
    } else if ([self.tapAreaRight containsPoint:touchLocation]) {
        startingRow = row;
        startingColumn = self.boardColumns-1;
        direction = Left;
        location = CGPointMake(self.boardColumns * kColumnSize + kGridXOffset + 5, row * kRowSize +  kGridYOffset);
    } else if ([self.tapAreaLeft containsPoint:touchLocation]) {
        startingRow = row;
        startingColumn = 0;
        direction = Right;
        location = CGPointMake(5, row * kRowSize + kGridYOffset);
    } else {
        return;
    }

    if (gameBoard[startingRow][startingColumn] != nil) {
        validMove = NO;
    } else {
        [self checkDirection:direction andStartingRow:startingRow andStartingColumn:column];
    }
    if (validMove) {
        //[self.moveDestinations removeAllObjects];
        //GridPosition *position = [[GridPosition alloc] initWithRow:destinationRow andColumn:destinationColumn];
        //[self.moveDestinations addObject:position];
        [self.lastPiece removeFromParent];
        [self addGamePieceAt:location];
        [self addGamePieceHighlightFrom:Top toRow:destinationRow toColumn:destinationColumn];
    }
}

- (void)checkDirection:(Direction)direction andStartingRow:(int)startingRow andStartingColumn:(int)startingColumn {
    GridPosition *position = [[GridPosition alloc] init];
    
    switch (direction) {
        case Down:
            position.row = 0;
            position.column = startingColumn;
            for (int row = self.boardRows-1; row >= 0;row--) {
                if (boardTokens[row][startingColumn] == Sticky) {
                    if (gameBoard[row][startingColumn] != nil) {
                        // continue checking in same direction to find destination of piece in sticky square
                        int x = row;
                        int y = startingColumn;
                        BOOL canMove = NO;
                        for (int i = row-1; i >= 0;i--) {
                            if (gameBoard[i][startingColumn] == nil) {
                                canMove = YES;
                                x = i;
                            } else {
                                break;
                            }
                        }
                        if (canMove) {
                            GamePiece *piece = gameBoard[row][startingColumn];
                            CGPoint moveLocation = CGPointMake(startingColumn * kColumnSize + kGridXOffset, x * kRowSize + kGridYOffset);
                            CGFloat distance = sqrtf((moveLocation.x-piece.position.x)*(moveLocation.x-piece.position.x)+
                                                     (moveLocation.y-piece.position.y)*(moveLocation.y-piece.position.y));
                            SKAction *move = [SKAction moveTo:moveLocation duration:distance/260.0];
                            GridPosition *newPosition = [[GridPosition alloc] initWithRow:x andColumn:startingColumn];
                            self.action = [[GameAction alloc] initWithGamepiece:piece andAction:move andPosition:newPosition];
                            //gameBoard[x][startingColumn] = piece;

                            position.row = row;
                            break;
                        } else {
                            position.row = row + 1;
                            break;
                        }
                    } else {
                        position.row = row;
                        break;
                    }
                } else if (gameBoard[row][startingColumn] != nil) {
                    position.row = row + 1;
                    break;
                } else if (boardTokens[row][startingColumn] == UpArrow) {
                    
                } else if (boardTokens[row][startingColumn] == DownArrow) {
                    
                } else if (boardTokens[row][startingColumn] == LeftArrow) {
                    
                } else if (boardTokens[row][startingColumn] == RightArrow) {
                    
                }
                position.row = row;
            }
            break;
        
        case Up:
            position.row = self.boardRows-1;
            position.column = startingColumn;
            for (int row = 1; row <= self.boardRows-1;row++) {
                if (boardTokens[row][startingColumn] == Sticky) {
                    if (gameBoard[row][startingColumn] != nil) {
                        // continue checking in same direction to find destination of piece in sticky square
                        int x = row;
                        int y = startingColumn;
                        BOOL canMove = NO;
                        for (int i = row+1; i <= self.boardRows-1;i++) {
                            if (gameBoard[i][startingColumn] == nil) {
                                canMove = YES;
                                x = i;
                            } else {
                                break;
                            }
                        }
                        if (canMove) {
                            GamePiece *piece = gameBoard[row][startingColumn];
                            CGPoint moveLocation = CGPointMake(startingColumn * kColumnSize + kGridXOffset, x * kRowSize + kGridYOffset);
                            CGFloat distance = sqrtf((moveLocation.x-piece.position.x)*(moveLocation.x-piece.position.x)+
                                                     (moveLocation.y-piece.position.y)*(moveLocation.y-piece.position.y));
                            SKAction *move = [SKAction moveTo:moveLocation duration:distance/260.0];
                            GridPosition *newPosition = [[GridPosition alloc] initWithRow:x andColumn:startingColumn];
                            self.action = [[GameAction alloc] initWithGamepiece:piece andAction:move andPosition:newPosition];
                            //gameBoard[x][startingColumn] = piece;
                            
                            position.row = row;
                            break;
                        } else {
                            position.row = row - 1;
                            break;
                        }
                    } else {
                        position.row = row;
                        break;
                    }
                } else if (gameBoard[row][startingColumn] != nil) {
                    position.row = row - 1;
                    break;
                } else if (boardTokens[row][startingColumn] == UpArrow) {
                    
                } else if (boardTokens[row][startingColumn] == DownArrow) {
                    
                } else if (boardTokens[row][startingColumn] == LeftArrow) {
                    
                } else if (boardTokens[row][startingColumn] == RightArrow) {
                    
                }
                
                position.row = row;
            }
            break;
            
        case Left:
            position.column = 0;
            position.row = startingRow;
            for (int column = self.boardColumns-1; column >= 0;column--) {
                if (boardTokens[startingRow][column] == Sticky) {
                    if (gameBoard[startingRow][column] != nil) {
                        // continue checking in same direction to find destination of piece in sticky square
                        int x = startingRow;
                        int y = startingColumn;
                        BOOL canMove = NO;
                        for (int i = column-1; i >= 0;i--) {
                            if (gameBoard[startingRow][i] == nil) {
                                canMove = YES;
                                y = i;
                            } else {
                                break;
                            }
                        }
                        if (canMove) {
                            GamePiece *piece = gameBoard[startingRow][column];
                            CGPoint moveLocation = CGPointMake(y * kColumnSize + kGridXOffset, startingRow * kRowSize + kGridYOffset);
                            CGFloat distance = sqrtf((moveLocation.x-piece.position.x)*(moveLocation.x-piece.position.x)+
                                                     (moveLocation.y-piece.position.y)*(moveLocation.y-piece.position.y));
                            SKAction *move = [SKAction moveTo:moveLocation duration:distance/260.0];
                            GridPosition *newPosition = [[GridPosition alloc] initWithRow:startingRow andColumn:y];
                            self.action = [[GameAction alloc] initWithGamepiece:piece andAction:move andPosition:newPosition];
                            //gameBoard[startingRow][y] = piece;
                            
                            position.column = column;
                            break;
                        } else {
                            position.column = column + 1;
                            break;
                        }
                    } else {
                        position.column = column;
                        break;
                    }
                } else if (gameBoard[startingRow][column] != nil) {
                    position.column = column + 1;
                    break;
                } else if (boardTokens[startingRow][column] == UpArrow) {
                    
                } else if (boardTokens[startingRow][column] == DownArrow) {
                    
                } else if (boardTokens[startingRow][column] == LeftArrow) {
                    
                } else if (boardTokens[startingRow][column] == RightArrow) {
                    
                }
                
                position.column = column;
            }
            break;
            
        case Right:
            position.column = self.boardColumns-1;
            position.row = startingRow;
            for (int column = 0; column <= self.boardColumns-1;column++) {
                if (boardTokens[startingRow][column] == Sticky) {
                    if (gameBoard[startingRow][column] != nil) {
                        // continue checking in same direction to find destination of piece in sticky square
                        int x = startingRow;
                        int y = startingColumn;
                        BOOL canMove = NO;
                        for (int i = column+1; i <= self.boardColumns-1;i++) {
                            if (gameBoard[startingRow][i] == nil) {
                                canMove = YES;
                                y = i;
                            } else {
                                break;
                            }
                        }
                        if (canMove) {
                            GamePiece *piece = gameBoard[startingRow][column];
                            CGPoint moveLocation = CGPointMake(y * kColumnSize + kGridXOffset, startingRow * kRowSize + kGridYOffset);
                            CGFloat distance = sqrtf((moveLocation.x-piece.position.x)*(moveLocation.x-piece.position.x)+
                                                     (moveLocation.y-piece.position.y)*(moveLocation.y-piece.position.y));
                            SKAction *move = [SKAction moveTo:moveLocation duration:distance/260.0];
                            GridPosition *newPosition = [[GridPosition alloc] initWithRow:startingRow andColumn:y];
                            self.action = [[GameAction alloc] initWithGamepiece:piece andAction:move andPosition:newPosition];
                            //gameBoard[startingRow][y] = piece;
                            
                            position.column = column;
                            break;
                        } else {
                            position.column = column - 1;
                            break;
                        }
                    } else {
                        position.column = column;
                        break;
                    }
                } else if (gameBoard[startingRow][column] != nil) {
                    position.column = column - 1;
                    break;
                } else if (boardTokens[startingRow][column] == UpArrow) {
                    
                } else if (boardTokens[startingRow][column] == DownArrow) {
                    
                } else if (boardTokens[startingRow][column] == LeftArrow) {
                    
                } else if (boardTokens[startingRow][column] == RightArrow) {
                    
                }
                
                position.column = column;
            }
            break;
        default:
            break;
    }
    
    [self.moveDestinations addObject:position];
    //return nil;
}


#if TARGET_OS_IPHONE // iOS
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.currentPiece hasActions]) {
        return;
    }
	NSArray *touchesArray = [touches allObjects];
    CGPoint touchLocation = [touchesArray[0] locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:[touchesArray[0] locationInNode:self]];

    for (SKNode *node in nodes) {
        //NSLog(@"%@",node.name);
        
        if ([node.name isEqualToString:kGamePieceName]) {
            if ([node isKindOfClass:[GamePiece class]]) {
                GamePiece *piece = (GamePiece *)node;
                if (!piece.isPlayed) {
                    int destinationRow = -1;
                    int destinationColumn = -1;
                    for (GridPosition *position in self.moveDestinations) {
                        destinationRow = position.row;
                        destinationColumn = position.column;
                        CGPoint moveLocation = CGPointMake(position.column * kColumnSize + kGridXOffset, position.row * kRowSize + kGridYOffset);
                        CGFloat distance = sqrtf((moveLocation.x-piece.position.x)*(moveLocation.x-piece.position.x)+
                                                 (moveLocation.y-piece.position.y)*(moveLocation.y-piece.position.y));
                        SKAction *move = [SKAction moveTo:moveLocation duration:distance/260.0];
                        [piece runAction:move];
                        piece.moveDestination = moveLocation;
                        
                        self.currentPiece = piece;
                    }
                    
//                    if (self.action != nil) {
//                        GamePiece *actionPiece = self.action.gamePiece;
//                        [actionPiece runAction:self.action.action];
//                        int x = self.action.position.row;
//                        int y = self.action.position.column;
//                        gameBoard[x][y] = actionPiece;
//                        self.action = nil;
//                    }
                    
                    if (destinationRow != -1 && destinationColumn != -1) {
                        piece.isPlayed = YES;
                        gameBoard[destinationRow][destinationColumn] = piece;
                        
                        [self printBoard];
                        
                        if (self.currentPlayer == Player1) {
                            self.currentPlayer = Player2;
                        } else {
                            self.currentPlayer = Player1;
                        }
                        [self.highlight removeFromParent];
                        self.lastPiece = nil;
                        
                        if (self.action != nil) {
                            GamePiece *actionPiece = self.action.gamePiece;
                            int x = self.action.position.row;
                            int y = self.action.position.column;
                            gameBoard[x][y] = actionPiece;
                            [self printBoard];
                            [self checkForWinnerAtRow:x andColumn:y];
                        }
                        
                        
                        [self checkForWinnerAtRow:destinationRow andColumn:destinationColumn];
                    }
                    

                    
                    return;
                }
            }
        }
    }

    [self calculateMove:touchLocation];
    
	// (optional) call super implementation to allow KKScene to dispatch touch events
	[super touchesBegan:touches withEvent:event];
}
#else // Mac OS X
-(void) mouseDown:(NSEvent *)event
{
	/* Called when a mouse click occurs */
	
	CGPoint location = [event locationInNode:self];
	[self addSpaceshipAt:location];

	// (optional) call super implementation to allow KKScene to dispatch mouse events
	[super mouseDown:event];
}
#endif


-(void) update:(CFTimeInterval)currentTime
{
	/* Called before each frame is rendered */
	if ([self.currentPiece hasActions]) {
        CGRect destinationRect = CGRectMake(self.currentPiece.moveDestination.x, self.currentPiece.moveDestination.y, kPieceSize, kPieceSize);
        if (CGRectIntersectsRect(destinationRect, self.currentPiece.frame)) {
            if (self.action != nil) {
                GamePiece *actionPiece = self.action.gamePiece;
                [actionPiece runAction:self.action.action];
                self.action = nil;
            }
        }
        
    }
	// (optional) call super implementation to allow KKScene to dispatch update events
	[super update:currentTime];
}

-(void)checkForWinnerAtRow:(int)row andColumn:(int)column {
    PieceType winner = Empty;
    self.winningPositions = [[NSMutableArray alloc] init];
    NSString *winMethod = @"";
    
    winner = [self checkForWinnerInRow:row];
    if (winner != Empty) {
        winMethod = @"row";
    }
    if (winner == Empty) {
        winner = [self checkForWinnerInColumn:column];
        if (winner != Empty) {
            winMethod = @"column";
        }
    }
    if (winner == Empty) {
        winner = [self checkDiagonalForWinnerAtRow:row andColumn:column];
        if (winner != Empty) {
            winMethod = @"diagonal";
        }
    }
    
    SKLabelNode *winnerLabel = (SKLabelNode*)[self childNodeWithName:kWinnerLabelName];
    if (winner == Player1) {
        winnerLabel.text =  [NSString stringWithFormat:@"%@ - %@", @"Player 1 Wins!", winMethod];
        winnerLabel.hidden = NO;
    } else if (winner == Player2) {
        winnerLabel.text = [NSString stringWithFormat:@"%@ - %@", @"Player 2 Wins!", winMethod];
        winnerLabel.hidden = NO;
    }
}

-(int)updateWinCounterWithRow:(int)row andColumn:(int)column andPlayer:(PieceType)player andWinCounter:(int)winCounter {
    if (gameBoard[row][column] != nil) {
        if (gameBoard[row][column].player == player) {
            winCounter++;
        } else {
            winCounter = 0;
        }
    } else {
        winCounter = 0;
    }
    
    return winCounter;
}

-(int)checkForWinnerInRow:(int)row {
    PieceType currentPiece;
    int winCounter = 0;
    
    for (int column = 0; column < self.boardRows; column++) {
        if (column > 0 && gameBoard[row][column].player != gameBoard[row][column-1].player) {
            winCounter = 0;
            self.winningPositions = nil;
        }
        currentPiece = gameBoard[row][column].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            self.winningPositions = nil;
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    return 0;
}

-(int)checkForWinnerInColumn:(int)column {
    PieceType currentPiece;
    int winCounter = 0;
    
    for (int row = 0; row < self.boardRows; row++) {
        if (row > 0 && gameBoard[row][column].player != gameBoard[row-1][column].player) {
            winCounter = 0;
            self.winningPositions = nil;
        }
        currentPiece = gameBoard[row][column].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            self.winningPositions = nil;
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    return 0;
}

-(int)checkDiagonalForWinnerAtRow:(int)currentRow andColumn:(int)currentColumn {
    PieceType currentPiece;
    int winCounter = 0;
    int startingRow;
    int startingColumn;
    int row, column;
    
    for (row = currentRow, column = currentColumn; row >= 0 && column >= 0;row--,column--) {
        startingRow = row;
        startingColumn = column;
    }
    
    for (row = startingRow, column = startingColumn; row < self.boardRows && column < self.boardColumns; row++,column++) {
        if (row > startingRow && column > startingColumn && gameBoard[row][column].player != gameBoard[row-1][column-1].player) {
            winCounter = 0;
            self.winningPositions = nil;
        }
        currentPiece = gameBoard[row][column].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            self.winningPositions = nil;
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    for (row = currentRow, column = currentColumn; row < self.boardRows && column >= 0;row++,column--) {
        startingRow = row;
        startingColumn = column;
    }
    
    for (row = startingRow, column = startingColumn; row >= 0 && column < self.boardColumns;row--,column++) {
        if (row < startingRow && column > startingColumn && gameBoard[row][column].player != gameBoard[row+1][column-1].player) {
            winCounter = 0;
            self.winningPositions = nil;
        }
        currentPiece = gameBoard[row][column].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            self.winningPositions = nil;
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    return 0;
}

@end
