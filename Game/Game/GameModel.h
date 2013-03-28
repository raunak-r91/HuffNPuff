//
//  GameModel.h
//  Game
//
//  Created by Raunak Rajpuria on 2/3/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelDelegate.h"
#import "Constants.h"
#import "Vector2D.h"

@interface GameModel : NSObject
@property (readonly, nonatomic) CGPoint origin;
@property (readonly, nonatomic) CGSize size;
@property (readonly, nonatomic) CGFloat rotation;
@property (readonly, nonatomic) CGFloat scale;
@property (readonly, nonatomic) GameObjectState currentState;
@property (readonly) GameObjectType objectType;
@property (readonly) CGFloat mass;
@property (readonly, nonatomic) Vector2D* velocity;
@property (readonly, nonatomic) CGFloat angularVelocity;
@property (readonly, nonatomic) Vector2D* force;
@property (readonly, nonatomic) CGFloat torque;
@property (readonly) CGFloat frictionCoeff;
@property (readonly) CGFloat restitutionCoeff;
@property (readonly, nonatomic) BOOL hasExpired;
@property (readonly) GameObjectShape shape;
@property (readonly, nonatomic) CGFloat health;
@property (weak) id<ModelDelegate> selfDelegate;

-(id)initWithMass:(CGFloat)m origin:(CGPoint)o size:(CGSize)s rotation:(CGFloat)r scale:(CGFloat)sc state:(GameObjectState)st objectType:(GameObjectType)ot velocity:(Vector2D*)v angularVelocity:(CGFloat)av force:(Vector2D*)f torque:(CGFloat)t frictionCoeff:(CGFloat)fc restitutionCoeff:(CGFloat)rcf hasExpired:(BOOL)he shape:(GameObjectShape)sh;
-(void)setDelegate:(id<ModelDelegate>)delegate;
-(void)encodeWithCoder:(NSCoder*)encoder;
-(id)initWithCoder:(NSCoder*)decoder;
-(void)setOrigin:(CGPoint)origin;
-(void)setSize:(CGSize)size;
-(void)setRotation:(CGFloat)finalRotation;
-(void)setRotationStep:(CGFloat)rotationStep;
-(void)setDefaultRotation;
-(void)setScale:(CGFloat)finalScale;
-(void)setScaleStep:(CGFloat)scaleStep;
-(void)setDefaultScale;
-(void)setCurrentState:(GameObjectState)state;
-(void)setVelocity:(Vector2D *)velocity;
-(void)setAngularVelocity:(CGFloat)angularVelocity;
-(void)setForce:(Vector2D *)force;
-(void)setTorque:(CGFloat)torque;
-(void)setHealth:(CGFloat)health;
-(void)setHasExpired:(BOOL)hasExpired;
-(CGPoint)getCenter;
-(void)setCenter:(CGPoint)c;
-(CGRect)getBoundingBox;
-(void)setBoundingBox:(CGRect)boundingBox;
-(CGFloat)getInertia;
-(CGSize)getScaledSize;

@end