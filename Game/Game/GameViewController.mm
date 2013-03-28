//
//  GameViewController.m
//  Game
//
//  Created by Raunak Rajpuria on 3/1/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

/*
    This is a superclass of the PlayViewController and DesignViewController classes. This class contains all the common methods and properties which are to be used by both the views during the game. 
 */
#import "GameViewController.h"

@interface GameViewController ()
@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpGameArea];
    [self setUpPaletteView];
    [self createBackground];
    [self setUpObjects];
}

#pragma mark setup

-(void)setUpGameArea {
    self.gamearea = [[UIScrollView alloc] initWithFrame:CGRectMake(GAMEAREA_ORIGIN_X, GAMEAREA_ORIGIN_Y, GAMEAREA_SIZE_WIDTH, GAMEAREA_SIZE_HEIGHT)];
    [self.gamearea setBackgroundColor:[UIColor colorWithRed:GAMEAREA_RED green:GAMEAREA_GREEN blue:GAMEAREA_BLUE alpha:1]];
    [self.gamearea setBounces:NO];
    [self.gamearea setShowsHorizontalScrollIndicator:NO];
    [self.gamearea setShowsVerticalScrollIndicator:NO];
    self.gamearea.tag = 1;
    [self.view addSubview:self.gamearea];
}

-(void)setUpPaletteView {
    self.paletteView = [[UIView alloc] initWithFrame:CGRectMake(PALETTE_ORIGIN_X, PALETTE_ORIGIN_Y, PALETTE_SIZE_WIDTH, PALETTE_SIZE_HEIGHT)];
    [self.paletteView setBackgroundColor:[UIColor colorWithRed:PALETTE_RED green:PALETTE_GREEN blue:PALETTE_BLUE alpha:1]];
    self.paletteView.tag = 5;
    [self.view addSubview:self.paletteView];
}

-(void)createBackground {
    UIImage *bgImage = [UIImage imageNamed:BACKGROUND_IMAGE];
    UIImage *groundImage = [UIImage imageNamed:GROUND_IMAGE];
    UIImage *cloud1Image = [UIImage imageNamed:@"cloud1.png"];
    UIImage *cloud2Image = [UIImage imageNamed:@"cloud2.png"];
    UIImage *cloud3Image = [UIImage imageNamed:@"cloud3.png"];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:bgImage];
    background.tag = 6;
    UIImageView *ground = [[UIImageView alloc] initWithImage:groundImage];
    ground.tag = 7;
    
    CGFloat backgroundWidth = bgImage.size.width;
    CGFloat backgroundHeight = bgImage.size.height;
    CGFloat groundWidth = groundImage.size.width;
    CGFloat groundHeight = groundImage.size.height;
    
    CGFloat groundY = self.gamearea.frame.size.height - groundHeight;
    CGFloat backgroundY = groundY - backgroundHeight;
    
    background.frame = CGRectMake(0, backgroundY, backgroundWidth, backgroundHeight);
    ground.frame = CGRectMake(0, groundY, groundWidth, groundHeight);
    
    UIImageView* cloud1 = [[UIImageView alloc] initWithImage:cloud1Image];
    cloud1.frame = CGRectMake(CLOUD1_ORIGIN_X, CLOUD1_ORIGIN_Y, cloud1Image.size.width, cloud1Image.size.height);
    UIImageView* cloud2 = [[UIImageView alloc] initWithImage:cloud2Image];
    cloud2.frame = CGRectMake(CLOUD2_ORIGIN_X, CLOUD2_ORIGIN_Y, cloud2Image.size.width/2, cloud2Image.size.height/2);
    UIImageView* cloud3 = [[UIImageView alloc] initWithImage:cloud3Image];
    cloud3.frame = CGRectMake(CLOUD3_ORIGIN_X, CLOUD3_ORIGIN_Y, cloud3Image.size.width, cloud3Image.size.height);
                                    
    [self.gamearea addSubview:background];
    [self.gamearea addSubview:ground];
    [self.gamearea insertSubview:cloud1 aboveSubview:background];
    [self.gamearea insertSubview:cloud2 aboveSubview:background];
    [self.gamearea insertSubview:cloud3 aboveSubview:background];
    
    CGFloat gameareaHeight = backgroundHeight + groundHeight;
    CGFloat gameareaWidth = backgroundWidth;
    [self.gamearea setContentSize:CGSizeMake(gameareaWidth, gameareaHeight)];
}

-(void)setUpObjects {
    self.didLoad = NO; //Used to specify if file loading has completed
    
    UIImage *strawImage = [UIImage imageNamed:STRAW_IMAGE];
    UIImage *woodImage = [UIImage imageNamed:WOOD_IMAGE];
    UIImage *stoneImage = [UIImage imageNamed:STONE_IMAGE];
    UIImage *ironImage = [UIImage imageNamed:IRON_IMAGE];
    
    NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:kStrawBlock], [NSNumber numberWithInt:kWoodBlock], [NSNumber numberWithInt:kStoneBlock], [NSNumber numberWithInt:kIronBlock], nil];
    NSArray *values = [NSArray arrayWithObjects:strawImage, woodImage, stoneImage, ironImage, nil];
    self.images = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    self.blocks = [NSMutableDictionary dictionary];
    [self readDefaultLevels];
    [self setUpTable];
    [self setUpAlerts];
}

-(void)readDefaultLevels {
    self.savedFileNames = [[NSMutableOrderedSet alloc] initWithObjects:LEVEL1, LEVEL2, LEVEL3, LEVEL4, LEVEL5, LEVEL6, nil];
}

//Table to be displayed in Load Menu
-(void)setUpTable {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(LOAD_TABLEVIEW_ORIGIN_X, LOAD_TABLEVIEW_ORIGIN_Y, LOAD_TABLEVIEW_SIZE_WIDTH, LOAD_TABLEVIEW_SIZE_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.layer.cornerRadius = LOAD_TABLEVIEW_CORNER_RADIUS;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = (NSInteger)[self.savedFileNames count];
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = [self.savedFileNames objectAtIndex:indexPath.row];
    return cell;
}

//Create UIAlertViews to notify the user during save/load operations
-(void)setUpAlerts {
    self.loadAlert = [[UIAlertView alloc] initWithTitle:@"Load Level" message:@"\n\n\n\n\n\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [self.loadAlert addSubview:self.tableView];
}

#pragma mark load

-(void)displayLoadScreen {
    [self readDocumentsDirectory];
    //Update tableView with saved files
    [self.tableView reloadData];
    [self.loadAlert show];
}

-(void)readDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    [self.savedFileNames addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL]];
}

-(NSString*)getPathToDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return documentsPath;
}

-(void)loadObjectsFromFile:(NSString*)fileName {
    [self loadDirectlyFromFile:fileName];
    [self.loadAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.didLoad = YES;
}

-(BOOL)isDefaultLevel:(NSString*)fileName {
    if ([fileName isEqualToString:LEVEL1] ||
        [fileName isEqualToString:LEVEL2] ||
        [fileName isEqualToString:LEVEL3] ||
        [fileName isEqualToString:LEVEL4] ||
        [fileName isEqualToString:LEVEL5] ||
        [fileName isEqualToString:LEVEL6] ) {
        
        return YES;
    }
    else {
        return NO;
    }
}

//Used to load data stored in the given file name
-(void)loadDirectlyFromFile:(NSString*)fileName {
    NSString* documentsPath;
    NSData* data;
    if ([self isDefaultLevel:fileName]) {
        documentsPath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        data = [NSData dataWithContentsOfFile:documentsPath];
    }
    else {
        //Get Path of Documents Directory
        documentsPath = [self getPathToDocumentsDirectory];
        data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentsPath, fileName]];
    }
    
    //Read objects from file
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    GameModel* tempWolf = (GameModel*)[unarchiver decodeObjectForKey:@"Wolf Object"];
    GameModel* tempPig = (GameModel*)[unarchiver decodeObjectForKey:@"Pig Object"];
    NSMutableDictionary* tempBlocks = (NSMutableDictionary*)[unarchiver decodeObjectForKey:@"Block Objects"];
    [unarchiver finishDecoding];
    [self loadWolfObject:(GameModel*)tempWolf];
    [self loadPigObject:(GameModel*)tempPig];
    [self loadBlockObjects:(NSMutableDictionary*)tempBlocks];
}

-(void)loadWolfObject:(GameModel*)tempWolf {
    [self.wolf.view removeFromSuperview];
    
    //Create new GameWolf object
    self.wolf = [[GameWolf alloc] initWithOrigin:tempWolf.origin
                                            size:tempWolf.size
                                           state:tempWolf.currentState];
    [self.wolf.modelObject setRotation:tempWolf.rotation];
    [self.wolf.modelObject setScale:tempWolf.scale];
    [self.wolf setAllGestures];
    [self.wolf.modelObject setDelegate:self];
    [self.wolf setDelegate:self];
    
    //Add GameWolf object to appropriate position
    if (self.wolf.modelObject.currentState == kInGameArea) {
        [self.wolf.view setTransform:CGAffineTransformRotate(self.wolf.view.transform, tempWolf.rotation)];
        [self.wolf.view setTransform:CGAffineTransformScale(self.wolf.view.transform, tempWolf.scale, tempWolf.scale)];
        [self.gamearea addSubview:self.wolf.view];
        [self.defaultWolf setAlpha:FADED];
    }
    else {
        [self.paletteView addSubview:self.wolf.view];
        [self.defaultWolf setAlpha:OPAQUE];
    }
}

-(void)loadPigObject:(GameModel*)tempPig {
    [self.pig.view removeFromSuperview];
    
    //Create new GamePig object
    self.pig = [[GamePig alloc] initWithOrigin:tempPig.origin
                                          size:tempPig.size
                                         state:tempPig.currentState];
    [self.wolf.modelObject setRotation:tempPig.rotation];
    [self.wolf.modelObject setScale:tempPig.scale];
    [self.pig setAllGestures];
    [self.pig.modelObject setDelegate:self];
    [self.pig setDelegate:self];
    
    //Add GamePig object to appropriate position
    if (self.pig.modelObject.currentState == kInGameArea) {
        [self.pig.view setTransform:CGAffineTransformRotate(self.pig.view.transform, tempPig.rotation)];
        [self.pig.view setTransform:CGAffineTransformScale(self.pig.view.transform, tempPig.scale, tempPig.scale)];
        [self.gamearea addSubview:self.pig.view];
        [self.defaultPig setAlpha:FADED];
    }
    else {
        [self.paletteView addSubview:self.pig.view];
        [self.defaultPig setAlpha:OPAQUE];
    }
}

-(void)loadBlockObjects:(NSMutableDictionary*)tempBlocks {
    [self.blocks removeAllObjects];
    
    for (NSNumber* key in tempBlocks) {
        //For each block stored, created new GameBlock object
        GameBlock* gb = [tempBlocks objectForKey:key];
        GameBlock* newBlock = [[GameBlock alloc] initWithOrigin:gb.modelObject.origin
                                                           size:gb.modelObject.size
                                                          state:gb.modelObject.currentState
                                                      blockType:((Block*)gb.modelObject).type
                                                        blockID:((Block*)gb.modelObject).blockID];
        
        [(UIImageView*)newBlock.view setImage:[self.images objectForKey:[NSNumber numberWithInt:((Block*)gb.modelObject).type]]];
        [newBlock.modelObject setRotation:gb.modelObject.rotation];
        [newBlock.modelObject setScale:gb.modelObject.scale];
        [self.blocks setObject:newBlock forKey:[NSNumber numberWithInt:((Block*)newBlock.modelObject).blockID]];
        [newBlock setAllGestures];
        [newBlock.modelObject setDelegate:self];
        [newBlock setDelegate:self];
        
        //Add GameBlock object to appropriate position
        if (newBlock.modelObject.currentState == kInGameArea) {
            [newBlock.view setTransform:CGAffineTransformRotate(newBlock.view.transform, gb.modelObject.rotation)];
            [newBlock.view setTransform:CGAffineTransformScale(newBlock.view.transform, gb.modelObject.scale, gb.modelObject.scale)];
            [self.gamearea addSubview:newBlock.view];
        }
        else {
            [self.paletteView addSubview:newBlock.view];
        }
    }
}

#pragma mark delegates

//Implementing Delegate Protocol Methods
-(void)objectDidMoveOfType:(GameObjectType)type {
    //REQUIRES: type = wolf or pig
    //EFFECTS: Sets the center property of the image view of appropriate object type
    if (type == kGameObjectWolf) {
        self.wolf.view.center = [self.wolf.modelObject getCenter];
        [self.wolf.modelObject setBoundingBox:self.wolf.view.frame];
    }
    else if (type == kGameObjectBreath) {
        self.wolfBreath.view.center = [self.wolfBreath.modelObject getCenter];
        [self.wolfBreath.modelObject setBoundingBox:self.wolfBreath.view.frame];
        [self breathScroll];
        [self.wolfBreath addTrajectoryTracer];
    }
    else if (type == kGameObjectPig) {
        self.pig.view.center = [self.pig.modelObject getCenter];
        [self.pig.modelObject setBoundingBox:self.pig.view.frame];
    }
}

-(void)objectDidRotateBy:(CGFloat)rotationStep OfType:(GameObjectType)type {
    //REQUIRES: type = wolf or pig
    //EFFECTS: Sets the transform property of the image view of appropriate object type
    if (type == kGameObjectWolf) {
        [self.wolf.view setTransform:CGAffineTransformRotate(self.wolf.view.transform, rotationStep)];
        [self.wolf.modelObject setBoundingBox:self.wolf.view.frame];
    }
    else if (type == kGameObjectBreath) {
        [self.wolfBreath.view setTransform:CGAffineTransformRotate(self.wolfBreath.view.transform, rotationStep)];
        [self.wolfBreath.modelObject setBoundingBox:self.wolfBreath.view.frame];
    }
    else if (type == kGameObjectPig) {
        [self.pig.view setTransform:CGAffineTransformRotate(self.pig.view.transform, rotationStep)];
        [self.pig.modelObject setBoundingBox:self.pig.view.frame];
    }
}

-(void)blockDidMove:(int)blockID {
    //REQUIRES: blockID is a valid ID of a non-deleted block
    //EFFECTS: Sets the center property of the image view of the corresponding block
    GameBlock* block = [self.blocks objectForKey:[NSNumber numberWithInt:blockID]];
    block.view.center = [block.modelObject getCenter];
    [block.modelObject setBoundingBox:block.view.frame];
}

-(void)blockDidRotate:(int)blockID By:(CGFloat)rotationStep {
    //REQUIRES: blockID is a valid ID of a non-deleted block
    //EFFECTS: Sets the transform property of the image view of the corresponding block
    GameBlock* block = [self.blocks objectForKey:[NSNumber numberWithInt:blockID]];
    [block.view setTransform:CGAffineTransformRotate(block.view.transform, rotationStep)];
    [block.modelObject setBoundingBox:block.view.frame];
}

//Used to scroll gamearea scrollview automatically if breath moves out of the screen edge
-(void)breathScroll {
    CGFloat breathLeftEdge = self.wolfBreath.view.frame.origin.x;
    CGFloat breathRightEdge = self.wolfBreath.view.frame.origin.x+self.wolfBreath.view.frame.size.width;
    CGFloat frameLeftEdge = self.gamearea.contentOffset.x;
    CGFloat frameRightEdge = self.gamearea.contentOffset.x + GAMEAREA_SIZE_WIDTH;
    
    if (breathRightEdge > frameRightEdge && breathRightEdge < RIGHT_EDGE_X) {
        CGPoint currentOffset = self.gamearea.contentOffset;
        CGPoint newOffset = CGPointMake(currentOffset.x + (breathRightEdge - frameRightEdge), 0);
        [self.gamearea setContentOffset:newOffset animated:NO];
    }
    else if (breathLeftEdge < frameLeftEdge && breathLeftEdge > LEFT_EDGE_X) {
        CGPoint currentOffset = self.gamearea.contentOffset;
        CGPoint newOffset = CGPointMake(currentOffset.x - (frameLeftEdge - breathLeftEdge), 0);
        [self.gamearea setContentOffset:newOffset animated:NO];
    }
}

-(void)newBlockAdded {}
-(void)blockDeleted:(int)ID {}
-(void)objectMovedToGameAreaOfType:(GameObjectType)type {}
-(void)objectMovedToPaletteOfType:(GameObjectType)type {}
-(void)blockDidResize:(int)blockID {}
-(void)blockDidScale:(int)blockID By:(CGFloat)s {}
-(void)blockDidChangeType:(int)blockID {}
-(void)objectDidResizeOfType:(GameObjectType)type {}
-(void)objectDidScaleBy:(CGFloat)s OfType:(GameObjectType)type {}

- (void)viewWillDisappear:(BOOL)animated {
    self.savedFileNames = nil;
    self.tableView = nil;
    self.loadAlert = nil;
    self.wolf = nil;
    self.pig = nil;
    self.blocks = nil;
    self.wolfBreath = nil;
    self.defaultWolf = nil;
    self.defaultPig = nil;
    self.defaultBlock = nil;
    self.images = nil;
    self.currentLevelName = nil;
}

-(void)viewDidUnload {
    self.gamearea = nil;
    self.paletteView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
