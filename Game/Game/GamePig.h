//
//  GamePig.h
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import "GameObject.h"
#import "GameModel.h"

@interface GamePig : GameObject

-(id)initWithOrigin:(CGPoint)o size:(CGSize)s state:(GameObjectState)st;
-(void)setDefaultPaletteState;
-(void)applyDamage:(CGFloat)impulse;
-(void)removePig;

@end
