//
//  GameBreath.m
//  Game
//
//  Created by Raunak Rajpuria on 2/26/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
 Deals with specific functionalities for Wolf's Breath
 */
#import "GameBreath.h"

@interface GameBreath ()
@property NSMutableArray* trajectory;
@property GameModel* modelObject;

@end

@implementation GameBreath

-(id)initWithOrigin:(CGPoint)o size:(CGSize)s velocity:(Vector2D*)v {
    self = [super init];
    if (self) {
        _modelObject = [[GameModel alloc] initWithMass:BREATH_MASS
                                                origin:o
                                                  size:s
                                              rotation:0
                                                 scale:1
                                                 state:kInGameArea
                                            objectType:kGameObjectBreath
                                              velocity:v
                                       angularVelocity:0
                                                 force:[Vector2D vectorWith:0 y:0]
                                                torque:0
                                         frictionCoeff:BREATH_FRICTION
                                      restitutionCoeff:BREATH_RESTITUTION
                                            hasExpired:NO
                                                 shape:kCircle];
        
        self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:BREATH_IMAGE]];
        self.view.frame = CGRectMake(o.x, o.y, s.width, s.height);
        self.trajectory = [NSMutableArray array];
    }
    return self;
}

//Display Trajectory as Breath moves
-(void)addTrajectoryTracer {
    UIImageView* newTrace = [self getTraceImageAtPosition:self.view.center];
    //If no traces already added, add current trace
    if ([self.trajectory count] == 0) {
        [self.view.superview addSubview:newTrace];
        [self.trajectory addObject:newTrace];
    }
    else {
        //Calculate distance between last trace and current position of breath
        Vector2D *previousBreath = [Vector2D vectorWith:((UIImageView*)[self.trajectory lastObject]).center.x y:((UIImageView*)[self.trajectory lastObject]).center.y];
        Vector2D *currentBreath = [Vector2D vectorWith:self.view.center.x y:self.view.center.y];
        Vector2D *breathDistance = [currentBreath subtract:previousBreath];
        
        //If distance greater than TRACE_DISTANCE, add it to screen
        if ([breathDistance length] > TRACE_DISTANCE) {
            [self.view.superview addSubview:newTrace];
            [self.trajectory addObject:newTrace];
        }
    }
}

//Remove Previous Trajectory from Screen
-(void)removeTrajectoryTracer {
    for (UIImageView* trace in self.trajectory) {
        [trace removeFromSuperview];
    }
    [self.trajectory removeAllObjects];
}

-(UIImageView*)getTraceImageAtPosition:(CGPoint)pos {
    UIImageView* newTrace = [[UIImageView alloc] initWithImage:[UIImage imageNamed:BREATH_IMAGE]];
    newTrace.frame = CGRectMake(0, 0, TRACE_WIDTH, TRACE_HEIGHT);
    newTrace.center = pos;
    return newTrace;
}


//Animate destruction of breath
-(void)removeBreath {
    NSArray* windDisperse = [self getFramesForImage:[UIImage imageNamed:WIND_DISPERSE] withRows:5 andColumns:2];
    UIImageView* windDisperseView = [[UIImageView alloc] initWithImage:windDisperse[0]];
    windDisperseView.frame = CGRectMake(0, 0, windDisperseView.image.size.width, windDisperseView.image.size.height);
    windDisperseView.center = self.view.center;
    [self.view.superview addSubview:windDisperseView];
    [self.view removeFromSuperview];
    [windDisperseView setAnimationImages:windDisperse];
    [windDisperseView setAnimationDuration:0.5];
    [windDisperseView setAnimationRepeatCount:1];
    [windDisperseView startAnimating];
    [self performSelector:@selector(completedDisperseAnimation:) withObject:windDisperseView afterDelay:0.5];
}


//Remove from screen after animation completes
-(void)completedDisperseAnimation:(UIImageView*)windDisperseView {
    [windDisperseView removeFromSuperview];
    windDisperseView = nil;
}

//Helper Method to divide animation sprite into individual images
-(NSArray*)getFramesForImage:(UIImage*)img withRows:(int)rows andColumns:(int)columns {
    NSArray* imageFrames = [NSMutableArray array];
    CGFloat widthPerFrame = img.size.width/rows;
    CGFloat heightPerFrame = img.size.height/columns;
    
    for (int i = 0; i < rows*columns; i++) {
        CGFloat originX = widthPerFrame * (i % rows);
        CGFloat originY = heightPerFrame * (i / rows);
        
        CGRect imageBox = CGRectMake(originX, originY, widthPerFrame, heightPerFrame);
        [(NSMutableArray*)imageFrames addObject:[UIImage imageWithCGImage:CGImageCreateWithImageInRect([img CGImage], imageBox)]];
    }
    return imageFrames;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidUnload {
    self.modelObject = nil;
    self.trajectory = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
