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
@property NSMutableArray *currentPieces;

@end

@implementation GameScene

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
    self.currentPieces = [[NSMutableArray alloc] init];
    
    self.boardRows = kBoardRows;
    self.boardColumns = kBoardColumns;
    
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
    GameBoard *board  = [[GameBoard alloc] initWithImageNamed:@"grid8"];
    board.anchorPoint = CGPointMake(0.0, 0.0);
    board.position = CGPointMake(kGridXOffset, kGridYOffset);
    [self addChild:board];
    
    [self setupBoardCorners];
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

- (void)setupBoardCorners {
    SKSpriteNode *corner1 = [SKSpriteNode spriteNodeWithImageNamed:@"board_corner" ];
    corner1.size = CGSizeMake(kTapAreaWidth, kTapAreaWidth);
    corner1.anchorPoint = CGPointMake(0.0, 0.0);
    corner1.position = CGPointMake(0.0, kGridYOffset + (kBoardRows * kRowSize));
    corner1.alpha = 0.5;
    [self addChild:corner1];
    
    SKSpriteNode *corner2 = [SKSpriteNode spriteNodeWithImageNamed:@"board_corner" ];
    corner2.size = CGSizeMake(kTapAreaWidth, kTapAreaWidth);
    corner2.anchorPoint = CGPointMake(0.0, 0.0);
    corner2.position = CGPointMake(kGridXOffset + (kBoardColumns * kColumnSize), kGridYOffset + (kBoardRows * kRowSize));
    corner2.alpha = 0.5;
    [self addChild:corner2];
    
    SKSpriteNode *corner3 = [SKSpriteNode spriteNodeWithImageNamed:@"board_corner" ];
    corner3.size = CGSizeMake(kTapAreaWidth, kTapAreaWidth);
    corner3.anchorPoint = CGPointMake(0.0, 0.0);
    corner3.position = CGPointMake(kGridXOffset + (kBoardColumns * kColumnSize), kGridYOffset - kTapAreaWidth);
    corner3.alpha = 0.5;
    [self addChild:corner3];
    
    SKSpriteNode *corner4 = [SKSpriteNode spriteNodeWithImageNamed:@"board_corner" ];
    corner4.size = CGSizeMake(kTapAreaWidth, kTapAreaWidth);
    corner4.anchorPoint = CGPointMake(0.0, 0.0);
    corner4.position = CGPointMake(0.0, kGridYOffset - kTapAreaWidth);
    corner4.alpha = 0.5;
    [self addChild:corner4];
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
    boardTokens[2][2] = Sticky;
    boardTokens[2][5] = Sticky;
    boardTokens[5][2] = Sticky;
    boardTokens[5][5] = Sticky;
    boardTokens[6][5] = LeftArrow;
    boardTokens[1][2] = RightArrow;
    boardTokens[5][1] = DownArrow;
    boardTokens[2][6] = UpArrow;
    boardTokens[7][0] = Blocker;
    boardTokens[0][7] = Blocker;
    [self addTokenAt:2 andColumn:2 andType:Sticky];
    [self addTokenAt:2 andColumn:5 andType:Sticky];
    [self addTokenAt:5 andColumn:2 andType:Sticky];
    [self addTokenAt:5 andColumn:5 andType:Sticky];
    [self addTokenAt:6 andColumn:5 andType:LeftArrow];
    [self addTokenAt:1 andColumn:2 andType:RightArrow];
    [self addTokenAt:5 andColumn:1 andType:DownArrow];
    [self addTokenAt:2 andColumn:6 andType:UpArrow];
    [self addTokenAt:7 andColumn:0 andType:Blocker];
    [self addTokenAt:0 andColumn:7 andType:Blocker];
}

-(void)resetGame {
	[self enumerateChildNodesWithName:kGamePieceName usingBlock:^(SKNode* node, BOOL* stop) {
        [node removeFromParent];
	}];
    
    [self resetBoard];
    
    SKLabelNode *winner = (SKLabelNode*)[self childNodeWithName:kWinnerLabelName];
    winner.hidden = YES;
    
    self.currentPlayer = Player1;
}

-(void) addMenuButton
{
    //SKSpriteNode *menuButton = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(45.0, 45.0)];
    SKSpriteNode *menuButton = [[SKSpriteNode alloc] initWithImageNamed:@"menu_button"];
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

-(void)addTokenAt:(int)row andColumn:(int)column andType:(TokenType)tokenType {
    CGFloat x = column * kColumnSize + kGridXOffset;
    CGFloat y = row * kRowSize +  kGridYOffset;
    NSString *gamePieceImage = @"magnet";
    
    if (tokenType == Sticky) {
        gamePieceImage = @"sticky_token";
    } else if (tokenType == UpArrow) {
        gamePieceImage = @"up_arrow_token";
    } else if (tokenType == DownArrow) {
        gamePieceImage = @"down_arrow_token";
    } else if (tokenType == LeftArrow) {
        gamePieceImage = @"left_arrow_token";
    } else if (tokenType == RightArrow) {
        gamePieceImage = @"right_arrow_token";
    } else if (tokenType == Blocker) {
        gamePieceImage = @"blocker_token";
    } 

    GamePiece *piece = [[GamePiece alloc] initWithImageNamed:gamePieceImage];
    piece.position = CGPointMake(x, y);
    piece.row = row;
    piece.column = column;
    piece.size = CGSizeMake(30.0, 30.0);
    piece.position = CGPointMake(piece.position.x, piece.position.y);
    [self addChild:piece];
}

- (void)addGamePieceAt:(CGPoint)location
{
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

    [self addChild:piece];
}

- (void)removeHighlights {
    for (SKNode *node in self.children) {
        if ([node.name  isEqual: @"highlight"]) {
            [node removeFromParent];
        }
    }
}

- (void)addGamePieceHighlightFrom:(Direction)direction {

    [self removeHighlights];
    
    for (GamePiece *piece in self.currentPieces) {
        
        int startColumn = floor((piece.position.x - kGridXOffset) / kColumnSize);
        int startRow = floor((piece.position.y - kGridYOffset) / kRowSize);
        
        if (startRow  < 0) {
            startRow = 0;
        }
        
        if (startColumn < 0) {
            startColumn = 0;
        }
        
        for (GridPosition *position in [piece.moveDestinations reverseObjectEnumerator]) {
            SKSpriteNode *highlight = [SKSpriteNode spriteNodeWithImageNamed:@"highlight"];
            highlight.alpha = 0.2;
            if (piece.player == Player1) {
                highlight.color = [UIColor orangeColor];
                highlight.colorBlendFactor = 0.9;
            } else if (piece.player == Player2) {
                highlight.color = [UIColor blueColor];
                highlight.colorBlendFactor = 0.5;
            }

            highlight.anchorPoint = CGPointMake(0.0, 0.0);
            highlight.name = @"highlight";
            
            if (position.direction == Down) {
                highlight.size = CGSizeMake(kColumnSize, (startRow - position.row) * kRowSize);
                highlight.position = CGPointMake(position.column * kColumnSize + kGridXOffset, kGridYOffset + (position.row * kRowSize));
            } else if (position.direction == Up) {
                highlight.size = CGSizeMake(kColumnSize, (position.row - startRow + 1) * kRowSize);
                highlight.position = CGPointMake(position.column * kColumnSize + kGridXOffset, (startRow * kRowSize) + kGridYOffset);
            } else if (position.direction == Right) {
                highlight.size = CGSizeMake((position.column - startColumn + 1) * kColumnSize, kRowSize);
                highlight.position = CGPointMake((startColumn * kColumnSize) + kGridXOffset, position.row * kRowSize + kGridYOffset);
            } else if (position.direction == Left) {
                highlight.size = CGSizeMake((startColumn - position.column) * kColumnSize, kRowSize);
                highlight.position = CGPointMake(kGridXOffset + (position.column * kColumnSize), position.row * kRowSize + kGridYOffset);
            }

            startRow = position.row;
            startColumn = position.column;
            
            [self addChild:highlight];
        }
    }
}

- (void)endGameWithWinner:(PieceType)pieceType {
    SKLabelNode *winnerLabel = (SKLabelNode*)[self childNodeWithName:kWinnerLabelName];
    if (pieceType == Player1) {
        winnerLabel.text =  [NSString stringWithFormat:@"%@", @"Player 1 Wins!"];
        winnerLabel.hidden = NO;
    } else if (pieceType == Player2) {
        winnerLabel.text = [NSString stringWithFormat:@"%@", @"Player 2 Wins!"];
        winnerLabel.hidden = NO;
    } else if (pieceType == Tie) {
        winnerLabel.text = [NSString stringWithFormat:@"%@", @"Tie!"];
        winnerLabel.hidden = NO;
    }
}

#if TARGET_OS_IPHONE // iOS
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.currentPiece hasActions]) {
        return;
    }
    
	NSArray *touchesArray = [touches allObjects];
    CGPoint touchLocation = [touchesArray[0] locationInNode:self];
    NSMutableArray *winners = [[NSMutableArray alloc] init];
    PieceType winner = Empty;
    
    if ([self.currentPieces count] > 0 && [self.currentPieces[0] containsPoint:touchLocation]) {
        
        for (GamePiece *piece in self.currentPieces) {
            [piece generateActions];
        }
        
        GamePiece *piece = self.currentPieces[0];
        [self.currentPieces removeObjectAtIndex:0];
        self.currentPiece = piece;
        
        SKAction *sequence = [SKAction sequence:piece.actions];
        [piece runAction:sequence];
        
        // update gameboard model with destination of gamepiece
        GridPosition *desinationPosition = piece.moveDestinations[0];
        gameBoard[desinationPosition.row][desinationPosition.column] = piece;

        if (self.currentPlayer == Player1) {
            self.currentPlayer = Player2;
        } else {
            self.currentPlayer = Player1;
        }
        
        [self removeHighlights];
        
        winner = [self checkForWinnerAtRow:desinationPosition.row andColumn:desinationPosition.column];
        if (winner != Empty) {
            [winners addObject:[NSNumber numberWithInt:winner]];
        }
        
        for (GamePiece *currentPiece in self.currentPieces) {
            GridPosition *position = currentPiece.moveDestinations[0];
            gameBoard[position.row][position.column] = currentPiece;
            
            winner = [self checkForWinnerAtRow:position.row andColumn:position.column];
            if (winner != Empty) {
                [winners addObject:[NSNumber numberWithInt:winner]];
            }
        }
        
        [self printBoard];
        
        if (winners.count > 0) {
            int player1Wins = 0;
            int player2Wins = 0;
            for (NSNumber *pieceType in winners) {
                if (pieceType == [NSNumber numberWithInt:Player1]) {
                    player1Wins++;
                } else if (pieceType == [NSNumber numberWithInt:Player2]) {
                    player2Wins++;
                }
            }
            if (player1Wins > 0 && player2Wins > 0) {
                [self endGameWithWinner:Tie];
            } else if (player1Wins > 0) {
                [self endGameWithWinner:Player1];
            } else if (player2Wins > 0) {
                [self endGameWithWinner:Player2];
            }

        }
        
        //TODO: Tie if no more possible moves

        return;
    }
    
    [self calculateMoveFromLocation:touchLocation];
    
	// (optional) call super implementation to allow KKScene to dispatch touch events
	[super touchesBegan:touches withEvent:event];
}
#else // Mac OS X
-(void) mouseDown:(NSEvent *)event
{
	CGPoint location = [event locationInNode:self];
	[self addSpaceshipAt:location];
    
	// (optional) call super implementation to allow KKScene to dispatch mouse events
	[super mouseDown:event];
}
#endif

- (void)calculateMoveFromLocation:(CGPoint)touchLocation {
    BOOL validMove = YES;
    Direction direction = -1;
    int startingRow = -1;
    int startingColumn = -1;
    int column = floor((touchLocation.x - kGridXOffset) / kColumnSize);
    int row = floor((touchLocation.y - kGridYOffset) / kRowSize);
    
    if ([self.currentPieces count] > 0) {
        [self.currentPieces[0] removeFromParent];
    }
    
    [self removeHighlights];
    [self.currentPieces removeAllObjects];
    
    CGPoint location = CGPointMake(0.0, 0.0);
    
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
        NSString *gamePieceImage;
        if (self.currentPlayer == Player1) {
            gamePieceImage = @"orangepiece";
        } else {
            gamePieceImage = @"bluepiece";
        }
        
        GamePiece *gamePiece = [[GamePiece alloc] initWithImageNamed:gamePieceImage];
        gamePiece.position = location;
        gamePiece.name = kGamePieceName;
        gamePiece.player = self.currentPlayer;
        [self.currentPieces addObject:gamePiece];
        [self getDestinationForDirection:direction withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:startingColumn];
        
        [self addChild:gamePiece];
        
        [self addGamePieceHighlightFrom:direction];
    }
}

// assumption: only call this method with a valid row and column that is within the bounds of the board and does not contain a piece
- (void)getDestinationForDirection:(Direction)direction withGamePiece:(GamePiece*)gamePiece andStartingRow:(int)startingRow andStartingColumn:(int)startingColumn {
    GridPosition *position = [[GridPosition alloc] init];
    
    switch (direction) {
        case Down:
            position.row = 0;
            position.column = startingColumn;
            position.direction = Down;
            
            for (int row = startingRow; row >= 0;row--) {
                if (boardTokens[row][startingColumn] == Sticky) {
                    if (gameBoard[row][startingColumn] != nil) {
                        // If the piece in the sticky square can move
                        if (row - 1 >= 0 && gameBoard[row-1][startingColumn] == nil){
                            GamePiece *stuckPiece = gameBoard[row][startingColumn];
                            [stuckPiece resetMovement];
                            [self getDestinationForDirection:Down withGamePiece:stuckPiece andStartingRow:row - 1 andStartingColumn:startingColumn];
                            [self.currentPieces addObject:stuckPiece];
                            
                            position.row = row;
                            break;
                        } else {
                            // piece in sticky square cannot move
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
                    position.row = row;
                    [self getDestinationForDirection:Up withGamePiece:gamePiece andStartingRow:row + 1 andStartingColumn:startingColumn];
                    break;
                } else if (boardTokens[row][startingColumn] == DownArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Down withGamePiece:gamePiece andStartingRow:row - 1 andStartingColumn:startingColumn];
                    break;
                } else if (boardTokens[row][startingColumn] == LeftArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Left withGamePiece:gamePiece andStartingRow:row andStartingColumn:startingColumn - 1];
                    break;
                } else if (boardTokens[row][startingColumn] == RightArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Right withGamePiece:gamePiece andStartingRow:row andStartingColumn:startingColumn + 1];
                    break;
                } else if (boardTokens[row][startingColumn] == Blocker) {
                    position.row = row + 1;
                    break;
                }
                
                position.row = row;
            }
            break;
        
        case Up:
            position.row = self.boardRows-1;
            position.column = startingColumn;
            position.direction = Up;
            
            for (int row = startingRow; row <= self.boardRows-1;row++) {
                if (boardTokens[row][startingColumn] == Sticky) {
                    if (gameBoard[row][startingColumn] != nil) {
                        // If the piece in the sticky square can move
                        if (row + 1 < kBoardRows && gameBoard[row+1][startingColumn] == nil){
                            GamePiece *stuckPiece = gameBoard[row][startingColumn];
                            [stuckPiece resetMovement];
                            [self getDestinationForDirection:Up withGamePiece:stuckPiece andStartingRow:row + 1 andStartingColumn:startingColumn];
                            [self.currentPieces addObject:stuckPiece];
                            
                            position.row = row;
                            break;
                        } else {
                            // piece in sticky square cannot move
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
                    position.row = row;
                    [self getDestinationForDirection:Up withGamePiece:gamePiece andStartingRow:row + 1 andStartingColumn:startingColumn];
                    break;
                } else if (boardTokens[row][startingColumn] == DownArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Down withGamePiece:gamePiece andStartingRow:row - 1 andStartingColumn:startingColumn];
                    break;
                } else if (boardTokens[row][startingColumn] == LeftArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Left withGamePiece:gamePiece andStartingRow:row andStartingColumn:startingColumn - 1];
                    break;
                } else if (boardTokens[row][startingColumn] == RightArrow) {
                    position.row = row;
                    [self getDestinationForDirection:Right withGamePiece:gamePiece andStartingRow:row andStartingColumn:startingColumn + 1];
                    break;
                } else if (boardTokens[row][startingColumn] == Blocker) {
                    position.row = row - 1;
                    break;
                }
                
                position.row = row;
            }
            break;
            
        case Left:
            position.column = 0;
            position.row = startingRow;
            position.direction = Left;
            
            for (int column = startingColumn; column >= 0;column--) {
                if (boardTokens[startingRow][column] == Sticky) {
                    if (gameBoard[startingRow][column] != nil) {
                        // If the piece in the sticky square can move
                        if (column - 1 >= 0 && gameBoard[startingRow][column-1] == nil){
                            GamePiece *stuckPiece = gameBoard[startingRow][column];
                            [stuckPiece resetMovement];
                            [self getDestinationForDirection:Left withGamePiece:stuckPiece andStartingRow:startingRow andStartingColumn:column - 1];
                            [self.currentPieces addObject:stuckPiece];
                            
                            position.column = column;
                            break;
                        } else {
                            // piece in sticky square cannot move
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
                    position.column = column;
                    [self getDestinationForDirection:Up withGamePiece:gamePiece andStartingRow:startingRow + 1 andStartingColumn:column];
                    break;
                } else if (boardTokens[startingRow][column] == DownArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Down withGamePiece:gamePiece andStartingRow:startingRow - 1 andStartingColumn:column];
                    break;
                } else if (boardTokens[startingRow][column] == LeftArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Left withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:column - 1];
                    break;
                } else if (boardTokens[startingRow][column] == RightArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Right withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:column + 1];
                    break;
                } else if (boardTokens[startingRow][column] == Blocker) {
                    position.column = column + 1;
                    break;
                }
                
                position.column = column;
            }
            break;
            
        case Right:
            position.column = self.boardColumns-1;
            position.row = startingRow;
            position.direction = Right;
            
            for (int column = startingColumn; column <= self.boardColumns-1;column++) {
                if (boardTokens[startingRow][column] == Sticky) {
                    if (gameBoard[startingRow][column] != nil) {
                        // If the piece in the sticky square can move
                        if (column + 1 < kBoardColumns && gameBoard[startingRow][column+1] == nil){
                            GamePiece *stuckPiece = gameBoard[startingRow][column];
                            [stuckPiece resetMovement];
                            [self getDestinationForDirection:Right withGamePiece:stuckPiece andStartingRow:startingRow andStartingColumn:column + 1];
                            [self.currentPieces addObject:stuckPiece];
                            
                            position.column = column;
                            break;
                        } else {
                            // piece in sticky square cannot move
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
                    position.column = column;
                    [self getDestinationForDirection:Up withGamePiece:gamePiece andStartingRow:startingRow + 1 andStartingColumn:column];
                    break;
                } else if (boardTokens[startingRow][column] == DownArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Down withGamePiece:gamePiece andStartingRow:startingRow - 1 andStartingColumn:column];
                    break;
                } else if (boardTokens[startingRow][column] == LeftArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Left withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:column - 1];
                    break;
                } else if (boardTokens[startingRow][column] == RightArrow) {
                    position.column = column;
                    [self getDestinationForDirection:Right withGamePiece:gamePiece andStartingRow:startingRow andStartingColumn:column + 1];
                    break;
                } else if (boardTokens[startingRow][column] == Blocker) {
                    position.column = column - 1;
                    break;
                }
                
                position.column = column;
            }
            break;
        default:
            break;
    }
    
    [gamePiece.moveDestinations addObject:position];
}

- (void)update:(CFTimeInterval)currentTime
{
	/* Called before each frame is rendered */
	if ([self.currentPiece hasActions]) {
        CGRect destinationRect = CGRectMake(self.currentPiece.moveDestination.x, self.currentPiece.moveDestination.y, kPieceSize, kPieceSize);
        if (CGRectIntersectsRect(destinationRect, self.currentPiece.frame)) {
            if (self.currentPieces.count > 0) {
                self.currentPiece = self.currentPieces[self.currentPieces.count-1];
                [self.currentPieces removeObjectAtIndex:self.currentPieces.count-1];
                SKAction *sequence = [SKAction sequence:self.currentPiece.actions];
                [self.currentPiece runAction:sequence];
            }
        }
    }
	// (optional) call super implementation to allow KKScene to dispatch update events
	[super update:currentTime];
}

- (PieceType)checkForWinnerAtRow:(int)row andColumn:(int)column {
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
    
    return winner;
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
            [self.winningPositions removeAllObjects];
        }
        currentPiece = gameBoard[row][column].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            [self.winningPositions removeAllObjects];
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
            [self.winningPositions removeAllObjects];
        }
        currentPiece = gameBoard[row][column].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            [self.winningPositions removeAllObjects];
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
            [self.winningPositions removeAllObjects];
        }
        currentPiece = gameBoard[row][column].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            [self.winningPositions removeAllObjects];
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    winCounter = 0;
    
    for (row = currentRow, column = currentColumn; row < self.boardRows && column >= 0;row++,column--) {
        startingRow = row;
        startingColumn = column;
    }
    
    for (row = startingRow, column = startingColumn; row >= 0 && column < self.boardColumns;row--,column++) {
        if (row < startingRow && column > startingColumn && gameBoard[row][column].player != gameBoard[row+1][column-1].player) {
            winCounter = 0;
            [self.winningPositions removeAllObjects];
        }
        currentPiece = gameBoard[row][column].player;
        winCounter = [self updateWinCounterWithRow:row andColumn:column andPlayer:currentPiece andWinCounter:winCounter];
        
        if (winCounter > 0) {
            GridPosition *gridPosition = [[GridPosition alloc] initWithRow:row andColumn:column];
            [self.winningPositions addObject:gridPosition];
        } else {
            [self.winningPositions removeAllObjects];
        }
        
        if (winCounter >= 4) {
            return currentPiece;
        }
    }
    
    return 0;
}

@end
