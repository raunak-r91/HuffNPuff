//
//  BreathDelegate.h
//  Game
//
//  Created by Raunak Rajpuria on 2/28/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"

@protocol BreathDelegate <NSObject>

-(void)createBreathWithVelocity:(Vector2D*)velocity;

@end
