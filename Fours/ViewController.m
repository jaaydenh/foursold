/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <KoboldKit.h>
#import "ViewController.h"
#import "GameKitTurnBasedMatchHelper.h"
#import "HomeScene.h"
#import "GameScene.h"
#import "Flurry.h"
#import "GameKitHelper.h"
#import "AppDelegate.h"
#import "Match.h"

static NSString * kViewTransformChanged = @"view transform changed";

@interface ViewController()

@property(nonatomic, weak)UIView *clearContentView;
@property(nonatomic, strong)HomeScene *homeScene;
@property(nonatomic, strong) NSArray *matches;

@end

@implementation ViewController

UIScrollView *scrollView;

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController)
                                                 name:PresentAuthenticationViewController object:nil];
    
    [[GameKitTurnBasedMatchHelper sharedInstance] authenticateLocalPlayer];
    
    [GameKitTurnBasedMatchHelper sharedInstance].viewControllerDelegate = self;
    
    self.matches = [[NSArray alloc] init];
}

- (void)didFetchMatches:(NSArray*)matches
{
    NSLog(@"%@", matches);
    self.matches = matches;

    CGSize contentSize = self.kkView.frame.size;
    contentSize.height = self.matches.count * 100 + 100;
    contentSize.width *= 1.0;
    [self.homeScene setContentSize:contentSize];
    [self addScrollView:contentSize];
    
    [[GameKitTurnBasedMatchHelper sharedInstance] cachePlayerData:self];
}

- (void)onPlayerInfoReceived:(NSArray*)players
{
    [APP_DELEGATE.playerCache onPlayerInfoReceived:players];
    
    [self.homeScene displayMatchList:self.matches];
}

-(void)addScrollView:(CGSize)contentSize {
    
    //homeScene
    scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){.origin = CGPointMake(0.0, 110.0), .size = CGSizeMake(320, 568)}];
    [scrollView setContentSize:contentSize];
    scrollView.delegate = self;
    //scrollView.backgroundColor = [UIColor redColor];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    UIView *clearContentView = [[UIView alloc] initWithFrame:(CGRect){.origin = CGPointMake(0.0, 0.0), .size = contentSize}];
    [clearContentView setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:clearContentView];
    
    _clearContentView = clearContentView;
    
    [clearContentView addObserver:self
                       forKeyPath:@"transform"
                          options:NSKeyValueObservingOptionNew
                          context:&kViewTransformChanged];
    [self.kkView addSubview:scrollView];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:scrollView];
    
        for (SKNode *node in self.homeScene.spriteForScrollingGeometry.children) {
            if ([node isKindOfClass:[Match class]]) {
                Match *matchNode = (Match *)node;
                
                if ([matchNode containsPoint:touchPoint]) {
                    SKTransition *reveal = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:1];
                    [scrollView removeFromSuperview];
                    GameScene *gameScene = [GameScene sceneWithSize:self.view.bounds.size];
                    gameScene.scaleMode = SKSceneScaleModeAspectFill;
                    [self.kkView pushScene:gameScene transition:reveal];
                    [gameScene layoutMatch:matchNode.match];
                }
            }
        }
}

-(void)presentFirstScene
{
	// create and present first scene
    SKTransition *reveal = [SKTransition fadeWithDuration:3];
    
	self.homeScene = [HomeScene sceneWithSize:self.view.bounds.size];
	
    [self.kkView presentScene:self.homeScene transition:reveal];
}

- (void)showAuthenticationViewController
{
    [self presentViewController:[GameKitTurnBasedMatchHelper sharedInstance].authenticationViewController animated:YES completion:nil];
}

-(void)adjustContent:(UIScrollView *)scrollView
{
    CGPoint contentOffset = [scrollView contentOffset];
    [self.homeScene setContentOffset:contentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustContent:scrollView];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.clearContentView;
}

-(void)scrollViewDidTransform:(UIScrollView *)scrollView
{
    [self adjustContent:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale; // scale between minimum and maximum. called after any 'bounce' animations
{
    [self adjustContent:scrollView];
}
#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (context == &kViewTransformChanged)
    {
        [self scrollViewDidTransform:(id)[(UIView *)object superview]];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    @try {
        [self.clearContentView removeObserver:self forKeyPath:@"transform"];
    }
    @catch (NSException *exception) {    }
    @finally {    }
}

@end
