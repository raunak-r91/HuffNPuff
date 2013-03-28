//
//  Collision.m
//  FallingBricks
//
//  Created by Raunak Rajpuria on 2/15/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
 This class is used to represent a single collision which occurs in the physics engine.
 This class checks if two objects are colliding, then finds the contact points and applies the appropriate impulses to the objects
 */
#import "Collision.h"

@interface Collision () {
    Vector2D *hA, *hB;
    Vector2D *pA, *pB;
    Vector2D *d, *dA, *dB;
    CGFloat fAB[4];
    Matrix2D *Ra, *Rb;
    
    Vector2D *n, *nf, *ns;
    CGFloat Df, Ds, Dneg, Dpos;
    
    Vector2D *v1, *v2;
    
    CGFloat separation[2];
    Vector2D *contact[2];
    Vector2D *t;
}

@property GameModel* objectA;
@property GameModel* objectB;
@property CGFloat timeStep;

@end

@implementation Collision

#define K 0.01
#define E 0.05
#define DAMPENING_MULTIPLIER 30

//Constructor. Set up variables needed to simulate collision.
-(id)initWithObjectA:(GameModel*)a objectB:(GameModel*)b timeStep:(CGFloat)ts {
    self = [super init];
    if (self) {
        _objectA = a;
        _objectB = b;
        _timeStep = ts;
        
        hA = [Vector2D vectorWith:[self.objectA getScaledSize].width/2 y:[self.objectA getScaledSize].height/2];
        hB = [Vector2D vectorWith:[self.objectB getScaledSize].width/2 y:[self.objectB getScaledSize].height/2];
        
        Ra = [Matrix2D initRotationMatrix:self.objectA.rotation];
        Rb = [Matrix2D initRotationMatrix:self.objectB.rotation];
        
        pA = [Vector2D vectorWith:[self.objectA getCenter].x y:[self.objectA getCenter].y];
        pB = [Vector2D vectorWith:[self.objectB getCenter].x y:[self.objectB getCenter].y];
        
        d = [pB subtract:pA];
        dA = [[Ra transpose] multiplyVector:d];
        dB = [[Rb transpose] multiplyVector:d];
        
        Matrix2D *C = [[Ra transpose] multiply:Rb];
        Vector2D *fA = [[[dA abs] subtract:hA] subtract:[[C abs] multiplyVector:hB]];
        Vector2D *fB = [[[dB abs] subtract:hB] subtract:[[[C transpose] abs] multiplyVector:hA]];
        
        fAB[0] = fA.x;
        fAB[1] = fA.y;
        fAB[2] = fB.x;
        fAB[3] = fB.y;
    }
    return self;
}

//Simulate collision between two objects
-(BOOL)collideObjects {

    if (![self checkCollision]) {
        return NO;
    }
    if (![self findContactPoints]) {
        return NO;
    }
    [self applyImpulse];
    return YES;
}

//Check if the objects are intersecting
-(BOOL)checkCollision {
     for (int i = 0; i < 4; i++) {
        if (fAB[i] >= 0) {
            return NO;
        }
    }
    return YES;
}

-(BOOL)findContactPoints {
    [self pickReferenceEdge];
    if (![self pickIncidentEdge]) {
        return NO;
    }
    [self pickContactPoints];
    return YES;
}

//Apply appropriate impulses to the objects
-(void)applyImpulse {
    Vector2D *rAContact, *rBContact, *uA, *uB, *u, *pN, *pT;
    CGFloat uT, uN, mN, mT, dPT, e, pTMax, bias;
    
    for (int j = 0; j < 2; j++) {
        for (int i = 0; i < 2; i++) {
            if (separation[i]>=0) {
                continue; //If either separation is positive, that point should be skipped
            }
            rAContact = [contact[i] subtract:pA];
            rBContact = [contact[i] subtract:pB];
            
            uA = [self.objectA.velocity add:[rAContact crossZ:-self.objectA.angularVelocity]];
            uB = [self.objectB.velocity add:[rBContact crossZ:-self.objectB.angularVelocity]];
            u = [uB subtract:uA];
            
            uN = [u dot:n];
            uT = [u dot:t];
            
            mN = 1.0/self.objectA.mass + 1.0/self.objectB.mass
                + (([rAContact dot:rAContact] - [rAContact dot:n]*[rAContact dot:n])/[self.objectA getInertia])
                + (([rBContact dot:rBContact] - [rBContact dot:n]*[rBContact dot:n])/[self.objectB getInertia]);
            mN = 1.0/mN;
            
            mT = 1.0/self.objectA.mass + 1.0/self.objectB.mass
                + (([rAContact dot:rAContact] - [rAContact dot:t]*[rAContact dot:t])/[self.objectA getInertia])
                + (([rBContact dot:rBContact] - [rBContact dot:t]*[rBContact dot:t])/[self.objectB getInertia]);
            mT = 1.0/mT;
            
            e = sqrt(self.objectA.restitutionCoeff*self.objectB.restitutionCoeff);
            bias = fabs(E/self.timeStep*(K+separation[i]));
            pN = [n multiply:MIN(0, mN*((1+e)*uN)-bias)];
            
            dPT = mT*uT;
            pTMax = sqrt([pN dot:pN])*self.objectA.frictionCoeff*self.objectB.frictionCoeff;
            dPT = MAX(-pTMax, MIN(dPT, pTMax));
            pT = [t multiply:dPT];
            
            [self updateVelocities:[pN add:pT] contactA:rAContact contactB:rBContact];
        }
    }
}

//Updates the velocities of the objects based on calculated impulse
-(void)updateVelocities:(Vector2D*)p contactA:(Vector2D*)rAContact contactB:(Vector2D*)rBContact {
    if (self.objectA.canMove) {
        self.objectA.impulse += [p length];
        self.objectA.velocity = [self.objectA.velocity add:[p multiply:1.0/self.objectA.mass]];
        
        //Apply dampening to prevent blocks from sliding due to small values of velocity
        if (fabs(self.objectA.velocity.x) < DAMPENING_MULTIPLIER*self.timeStep && fabs(self.objectA.velocity.y) < DAMPENING_MULTIPLIER*self.timeStep) {
            self.objectA.velocity = [Vector2D vectorWith:0.0 y:0.0];
        }
        self.objectA.angularVelocity  = self.objectA.angularVelocity + [[rAContact multiply:1.0/[self.objectA getInertia]] cross:p];
    }
    if (self.objectB.canMove) {
        self.objectB.impulse += [p length];
        self.objectB.velocity = [self.objectB.velocity subtract:[p multiply:1.0/self.objectB.mass]];
        
        //Apply dampening to prevent blocks from sliding due to small values of velocity
        if (fabs(self.objectB.velocity.x) < DAMPENING_MULTIPLIER*self.timeStep && fabs(self.objectB.velocity.y) < DAMPENING_MULTIPLIER*self.timeStep) {
            self.objectB.velocity = [Vector2D vectorWith:0.0 y:0.0];
        }
        self.objectB.angularVelocity = self.objectB.angularVelocity - [[rBContact multiply:1.0/[self.objectB getInertia]] cross:p];
    }
}

//Helper method to get the index of fi with the smallest magnitude
-(int)getSmallestMagnitudeIndex {
    int smallestMagnitudeIndex = 0;
    CGFloat smallestMagnitude = fabs(fAB[0]);
    for (int i = 1;i < 4; i++) {
        if (fabs(fAB[i]) < smallestMagnitude) {
            smallestMagnitudeIndex = i;
            smallestMagnitude = fabs(fAB[i]);
        }
    }
    return smallestMagnitudeIndex;
}

-(void)pickReferenceEdge {
    int smallestMagnitudeIndex = [self getSmallestMagnitudeIndex];
    switch (smallestMagnitudeIndex) {
        case 0:
            n = (dA.x > 0) ? Ra.col1 :[Ra.col1 negate];
            nf = n;
            Df = [pA dot:nf] + hA.x;
            ns = Ra.col2;
            Ds = [pA dot:ns];
            Dneg = hA.y - Ds;
            Dpos = hA.y + Ds;
            break;
            
        case 1:
            n = (dA.y > 0) ? Ra.col2 : [Ra.col2 negate];
            nf = n;
            Df = [pA dot:nf] + hA.y;
            ns = Ra.col1;
            Ds = [pA dot:ns];
            Dneg = hA.x - Ds;
            Dpos = hA.x + Ds;
            break;
            
        case 2:
            n = (dB.x > 0) ? Rb.col1 : [Rb.col1 negate];
            nf = [n negate];
            Df = [pB dot:nf] + hB.x;
            ns = Rb.col2;
            Ds = [pB dot:ns];
            Dneg = hB.y - Ds;
            Dpos = hB.y + Ds;
            break;
            
        case 3:
            n = (dB.y > 0) ? Rb.col2 : [Rb.col2 negate];
            nf = [n negate];
            Df = [pB dot:nf] + hB.y;
            ns = Rb.col1;
            Ds = [pB dot:ns];
            Dneg = hB.x - Ds;
            Dpos = hB.x + Ds;
            break;
            
        default:
            break;
    }
}

-(BOOL)clipIncidentPointsinDirection:(Vector2D*)clipDirection distance:(CGFloat)distance {
    CGFloat dist1, dist2;
    Vector2D *v1Prime, *v2Prime;
    
    dist1 = [clipDirection dot:v1] - distance;
    dist2 = [clipDirection dot:v2] - distance;
    
    if (dist1 < 0 && dist2 < 0) {
        v1Prime = v1;
        v2Prime = v2;
    }
    else if (dist1 < 0 && dist2 >= 0) {
        v1Prime  = v1;
        v2Prime = [v1 add:[[v2 subtract:v1] multiply:(dist1/(dist1 - dist2))]];
    }
    else if (dist1 >= 0 && dist2 < 0) {
        v1Prime = v2;
        v2Prime = [v1 add:[[v2 subtract:v1] multiply:(dist1/(dist1 - dist2))]];
    }
    else if (dist1 >= 0 && dist2 >= 0)
        return NO;
    
    v1 = v1Prime;
    v2 = v2Prime;
    return YES;
}

-(BOOL)pickIncidentEdge {
    Vector2D *ni, *p, *h;
    Matrix2D *R;
    
    int smallestMagnitudeIndex = [self getSmallestMagnitudeIndex];
    switch (smallestMagnitudeIndex) {
        case 0:
        case 1:
            ni = [[[Rb transpose] multiplyVector:nf] negate];
            p = pB;
            R = Rb;
            h = hB;
            break;
            
        case 2:
        case 3:
            ni = [[[Ra transpose] multiplyVector:nf] negate];
            p = pA;
            R = Ra;
            h = hA;
            
        default:
            break;
    }
    
    if ([ni abs].x > [ni abs].y) {
        if (ni.x > 0) {
            v1 = [p add:[R multiplyVector:[Vector2D vectorWith:h.x y:-h.y]]];
            v2 = [p add:[R multiplyVector:h]];
        }
        else {
            v1 = [p add:[R multiplyVector:[Vector2D vectorWith:-h.x y:h.y]]];
            v2 = [p add:[R multiplyVector:[h negate]]];
        }
    }
    else {
        if (ni.y > 0) {
            v1 = [p add:[R multiplyVector:h]];
            v2 = [p add:[R multiplyVector:[Vector2D vectorWith:-h.x y:h.y]]];
        }
        else {
            v1 = [p add:[R multiplyVector:[h negate]]];
            v2 = [p add:[R multiplyVector:[Vector2D vectorWith:h.x y:-h.y]]];
        }
    }
    //Clip points
    if (![self clipIncidentPointsinDirection:[ns negate] distance:Dneg] || ![self clipIncidentPointsinDirection:ns distance:Dpos]) {
        return NO; //If both dist1 and dist2 are positive, then objects do not collide
    }
    else {
        return YES;
    }
}

-(void)pickContactPoints {
    separation[0] = [nf dot:v1] - Df;
    contact[0] = [v1 subtract:[nf multiply:separation[0]]];
    
    separation[1] = [nf dot:v2] - Df;
    contact[1] = [v2 subtract:[nf multiply:separation[1]]];
    
    t = [n crossZ:1];
}

@end
