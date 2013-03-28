//
//  PlayViewController.h
//  Game
//
//  Created by Raunak Rajpuria on 3/1/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Box2D/Box2D.h>
#import "Constants.h"
#import "GameWolf.h"
#import "GamePig.h"
#import "GameBlock.h"
#import "GameBreath.h"
#import "ModelDelegate.h"
#import "ObjectDelegate.h"
#import "BreathDelegate.h"
#import "CollisionDelegate.h"
#import "GameViewController.h"
#import "ContactListener.mm"

@interface PlayViewController : GameViewController 

@property b2World* world;
@property NSTimer* timer;
@property b2ContactListener* listener;
@property NSMutableArray *walls;
@property NSMutableArray* wolfLives;
@property UIImageView* staticHealthBar;
@property UIImageView* dynamicHealthBar;
@property NSMutableArray* score;
@property NSArray* numbers;
@property UIAlertView* startErrorAlert;
@property UIAlertView* gameOverAlert;
@property int currentScore;

-(void)load;
-(void)restart;
-(void)createPalette;
-(void)gameOverWinMessage;
-(void)gameOverLoseMessage;
-(void)reset;

@end
