//
//  GameWolf.h
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import "GameObject.h"
#import "GameModel.h"
#import "BreathDelegate.h"
#import "OneFingerGestureRecognizer.h"

@interface GameWolf : GameObject
@property (weak, nonatomic) id<BreathDelegate> breathDelegate;
-(id)initWithOrigin:(CGPoint)o size:(CGSize)s state:(GameObjectState)st;
-(void)setDefaultPaletteState;
-(void)setStartMode;
-(void)resetStartMode;
-(void)wolfDie;

@end
