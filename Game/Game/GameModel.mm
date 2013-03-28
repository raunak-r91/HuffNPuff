//
//  GameModel.m
//  Game
//
//  Created by Raunak Rajpuria on 2/3/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
  This is a superclass which represents the Pig and Wolf objects completely.
  The attributes of this class's objects are used to store persistent data
  When changes are made to its attributes, this class notifies the ViewController to update the view through delegates
*/

#import "GameModel.h"

@interface GameModel ()
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat rotation;
@property (nonatomic) CGFloat scale;
@property (nonatomic) GameObjectState currentState;
@property CGRect box;
@property (nonatomic) Vector2D* velocity;
@property (nonatomic) CGFloat angularVelocity;
@property (nonatomic) Vector2D* force;
@property (nonatomic) CGFloat torque;
@property (nonatomic) BOOL canMove;
@property (nonatomic) CGFloat health;
@property (nonatomic) BOOL hasExpired;
@end

@implementation GameModel

-(id)initWithMass:(CGFloat)m origin:(CGPoint)o size:(CGSize)s rotation:(CGFloat)r scale:(CGFloat)sc state:(GameObjectState)st objectType:(GameObjectType)ot velocity:(Vector2D*)v angularVelocity:(CGFloat)av force:(Vector2D*)f torque:(CGFloat)t frictionCoeff:(CGFloat)fc restitutionCoeff:(CGFloat)rcf hasExpired:(BOOL)he shape:(GameObjectShape)sh {
    
    self = [super init];
    
    if(self) {
        _origin = o;
        _size = s;
        _rotation = r;
        _scale = sc;
        _currentState = st;
        _objectType = ot;
        _box = CGRectMake(o.x, o.y, s.width, s.height);
        _mass = m;
        _velocity = v;
        _angularVelocity = av;
        _force = f;
        _torque = t;
        _frictionCoeff = fc;
        _restitutionCoeff = rcf;
        _hasExpired = he;
        _shape = sh;
        _health = PIG_HEALTH;
    }
    return self;
}

-(void)setDelegate:(id<ModelDelegate>)delegate {
    self.selfDelegate = delegate;
}

-(void)setOrigin:(CGPoint)o {
    _origin = o;
    [self.selfDelegate objectDidMoveOfType:self.objectType];
}

-(void)setSize:(CGSize)s {
    _size = s;
    [self.selfDelegate objectDidResizeOfType:self.objectType];
}

-(void)setRotation:(CGFloat)finalRotation {
    _rotation = finalRotation;
}

-(void)setRotationStep:(CGFloat)rotationStep {
    [self.selfDelegate objectDidRotateBy:rotationStep OfType:self.objectType];
}

-(void)setDefaultRotation {
    _rotation = 0;
}

-(void)setScale:(CGFloat)finalScale {
    _scale = finalScale;
}

-(void)setScaleStep:(CGFloat)scaleStep {
    [self.selfDelegate objectDidScaleBy:scaleStep OfType:self.objectType];
}

-(void)setDefaultScale {
    _scale = 1;
}

-(void)setCurrentState:(GameObjectState)state {
    _currentState = state;
}

-(void)setVelocity:(Vector2D *)velocity {
    _velocity = velocity;
}

-(void)setAngularVelocity:(CGFloat)angularVelocity {
    _angularVelocity = angularVelocity;
}

-(void)setForce:(Vector2D *)force {
    _force = force;
}

-(void)setTorque:(CGFloat)torque {
    _torque = torque;
}

-(void)setHealth:(CGFloat)health {
    _health = health;
}

-(void)setHasExpired:(BOOL)hasExpired {
    _hasExpired = hasExpired;
}

-(CGPoint)getCenter {
     return CGPointMake(self.origin.x + self.size.width/2, self.origin.y + self.size.height/2);
}

-(void)setCenter:(CGPoint)c {
    self.origin = CGPointMake(c.x - self.size.width/2, c.y - self.size.height/2);
}

-(CGRect)getBoundingBox {
    return self.box;
}

-(void)setBoundingBox:(CGRect)boundingBox {
    self.box = boundingBox;
}

-(CGFloat)getInertia {
    return (self.size.width*self.size.width + self.size.height*self.size.height)*_mass/12;
}

-(CGSize)getScaledSize {
    return CGSizeMake(self.size.width*self.scale, self.size.height*self.scale);
}

//Conform to NSCoding protocol
-(void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeCGPoint:self.origin forKey:@"Origin"];
    [encoder encodeCGSize:self.size forKey:@"Size"];
    [encoder encodeFloat:self.rotation forKey:@"Rotation"];
    [encoder encodeFloat:self.scale forKey:@"Scale"];
    [encoder encodeInt:self.currentState forKey:@"State"];
}

-(id)initWithCoder:(NSCoder*)decoder {
    self.origin = [decoder decodeCGPointForKey:@"Origin"];
    self.size = [decoder decodeCGSizeForKey:@"Size"];
    self.rotation = [decoder decodeFloatForKey:@"Rotation"];
    self.scale = [decoder decodeFloatForKey:@"Scale"];
    self.currentState = (GameObjectState)[decoder decodeIntForKey:@"State"];
    return self;
}

@end
