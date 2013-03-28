//
//  GameViewController.h
//  Game
//
//  Created by Raunak Rajpuria on 3/1/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "GameModel.h"
#import "GameObject.h"
#import "GameWolf.h"
#import "GamePig.h"
#import "GameBlock.h"
#import "GameBreath.h"
#import "ModelDelegate.h"
#import "ObjectDelegate.h"

@interface GameViewController : UIViewController <ModelDelegate, ObjectDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIScrollView *gamearea;
@property (strong, nonatomic) IBOutlet UIView *paletteView;
@property NSMutableOrderedSet* savedFileNames;
@property UITableView* tableView;
@property UIAlertView* loadAlert;
@property GameObject* wolf;
@property GameObject* pig;
@property NSMutableDictionary* blocks;
@property GameBreath* wolfBreath;
@property UIImageView* defaultWolf;
@property UIImageView* defaultPig;
@property UIImageView* defaultBlock;
@property NSDictionary* images;
@property BOOL didLoad;
@property NSString* currentLevelName;

-(void)displayLoadScreen;
-(void)loadDirectlyFromFile:(NSString*)fileName;
-(void)loadObjectsFromFile:(NSString*)fileName;
-(BOOL)isDefaultLevel:(NSString*)fileName;
@end
