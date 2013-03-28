//
//  CollisionDelegate.h
//  Game
//
//  Created by Raunak Rajpuria on 2/28/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameModel.h"

@protocol CollisionDelegate <NSObject>
-(void)object:(GameModel*)a didCollideWith:(GameModel*)b withImpulse:(const b2ContactImpulse*)impulse;
@end
