//
//  Block.h
//  Game
//
//  Created by Raunak Rajpuria on 1/29/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameModel.h"
#import "ModelDelegate.h"
#import "Constants.h"

@interface Block : GameModel

@property (readonly, nonatomic) BlockType type;
@property (readonly) int blockID;

-(id)initWithMass:(CGFloat)m origin:(CGPoint)o size:(CGSize)s rotation:(CGFloat)r scale:(CGFloat)sc state:(GameObjectState)st objectType:(GameObjectType)ot velocity:(Vector2D*)v angularVelocity:(CGFloat)av force:(Vector2D*)f torque:(CGFloat)t frictionCoeff:(CGFloat)fc restitutionCoeff:(CGFloat)rcf hasExpired:(BOOL)he shape:(GameObjectShape)sh blockType:(BlockType)t blockID:(int)i;
-(void)setType:(BlockType)t;
-(void)encodeWithCoder:(NSCoder*)encoder;
-(id)initWithCoder:(NSCoder*)decoder;

@end
