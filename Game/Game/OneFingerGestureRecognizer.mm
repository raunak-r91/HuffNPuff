
//
//  OneFingerGestureRecognizer.m
//  Game
//
//  Created by Raunak Rajpuria on 2/24/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//


#import "OneFingerGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation OneFingerGestureRecognizer

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    if ([[event touchesForGestureRecognizer:self] count] == 1) {
        [self setState:UIGestureRecognizerStateBegan];
    }
    else {
        [self setState:UIGestureRecognizerStateFailed];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateChanged];
    
    UITouch *touch = [touches anyObject];
    CGPoint center = CGPointMake(CGRectGetMidX([[self view] bounds]), CGRectGetMidY([[self view] bounds]));

    CGPoint currentPoint = [touch locationInView:[self view]];
    if (currentPoint.x < center.x) {
        return;
    }
    CGPoint previousPoint = [touch previousLocationInView:[self view]];
    
    CGFloat currentAngle = atan2f(currentPoint.y - center.y, currentPoint.x - center.x);
    CGFloat previousAngle  = atan2f(previousPoint.y - center.y, previousPoint.x - center.x);
    self.rotation = currentAngle - previousAngle;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self state] == UIGestureRecognizerStateChanged) {
        [self setState:UIGestureRecognizerStateEnded];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setState:UIGestureRecognizerStateFailed];
}

@end