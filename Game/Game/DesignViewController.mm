//
//  ViewController.m
//  Game
//
//  Created by Raunak Rajpuria on 1/27/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//

/*
    DesignViewController is responsible for setting up and updating the objects in the Design view which are displayed to the user. It only deals with the Design Mode. 
    This class is notified by the model objects when they are changed, and then it appropriately updates the view.
*/

#import "DesignViewController.h"

@interface DesignViewController ()
@end

@implementation DesignViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
    [self loadDefaultView];
}

-(void)setUp {
    UIImage *wolfImage = [UIImage imageNamed:WOLF_IMAGE];
    UIImage *pigImage = [UIImage imageNamed:PIG_IMAGE];
    UIImage *strawImage = [UIImage imageNamed:STRAW_IMAGE];
    
    //Create default image views which are displayed in the palette
    self.defaultWolf = [[UIImageView alloc] initWithImage:wolfImage];
    self.defaultWolf.frame = CGRectMake(PALETTE_WOLF_ORIGIN_X, PALETTE_WOLF_ORIGIN_Y, PALETTE_WOLF_SIZE_WIDTH, PALETTE_WOLF_SIZE_HEIGHT);
    self.defaultPig = [[UIImageView alloc] initWithImage:pigImage];
    self.defaultPig.frame = CGRectMake(PALETTE_PIG_ORIGIN_X, PALETTE_PIG_ORIGIN_Y, PALETTE_PIG_SIZE_WIDTH, PALETTE_PIG_SIZE_HEIGHT);
    self.defaultBlock = [[UIImageView alloc] initWithImage:strawImage];
    self.defaultBlock.frame = CGRectMake(PALETTE_BLOCK_ORIGIN_X, PALETTE_BLOCK_ORIGIN_Y, PALETTE_BLOCK_SIZE_WIDTH, PALETTE_BLOCK_SIZE_HEIGHT);
    self.blockCount = 1; //used to generate the block ID which is used to identify individual blocks
    
    //Initialize game objects
    self.wolf = [[GameWolf alloc] initWithOrigin:CGPointMake(PALETTE_WOLF_ORIGIN_X, PALETTE_WOLF_ORIGIN_Y)
                                            size:CGSizeMake(PALETTE_WOLF_SIZE_WIDTH, PALETTE_WOLF_SIZE_HEIGHT)
                                           state:kInPalette];
    
    self.pig = [[GamePig alloc] initWithOrigin:CGPointMake(PALETTE_PIG_ORIGIN_X, PALETTE_PIG_ORIGIN_Y)
                                          size:CGSizeMake(PALETTE_PIG_SIZE_WIDTH, PALETTE_PIG_SIZE_HEIGHT)
                                         state:kInPalette];
    
    GameObject* firstBlock = [[GameBlock alloc] initWithOrigin:CGPointMake(PALETTE_BLOCK_ORIGIN_X, PALETTE_BLOCK_ORIGIN_Y)
                                                          size:CGSizeMake(PALETTE_BLOCK_SIZE_WIDTH, PALETTE_BLOCK_SIZE_HEIGHT)
                                                         state:kInPalette
                                                     blockType:kStrawBlock
                                                       blockID:self.blockCount];
    
    [self.blocks setObject:firstBlock forKey:[NSNumber numberWithInt:((Block*)firstBlock.modelObject).blockID]];
    
//    [self removeContentOfDocumentsDirectory];
    
    //Set gestures and delegates
    [self.wolf setAllGestures];
    [self.pig setAllGestures];
    [firstBlock setAllGestures];
    
    [self.wolf.modelObject setDelegate:self];
    [self.pig.modelObject setDelegate:self];
    [firstBlock.modelObject setDelegate:self];
    [self.wolf setDelegate:self];
    [self.pig setDelegate:self];
    [firstBlock setDelegate:self];

    [self setUpSaveAlert];
}

-(void)setUpSaveAlert {
    self.saveAlert = [[UIAlertView alloc] initWithTitle:@"Save Level" message:@"Enter File Name" delegate:self cancelButtonTitle:@"Save" otherButtonTitles:@"Cancel",nil];
    self.saveAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [self.saveAlert textFieldAtIndex:0];
    alertTextField.placeholder = @"Enter File Name";
}

//Used to clear all the files stored in the Documents directory.
-(void)removeContentOfDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsPath error:NULL];
    for (NSString *path in directoryContents) {
        NSString *fullPath = [documentsPath stringByAppendingPathComponent:path];
        [fileMgr removeItemAtPath:fullPath error:NULL];
    }
}

-(void)createPalette {
    [self.paletteView addSubview:self.defaultWolf];
    [self.paletteView addSubview:self.defaultPig];
    [self.paletteView addSubview:self.defaultBlock];
    
    [self.paletteView addSubview:self.wolf.view];
    [self.paletteView addSubview:self.pig.view];    
    [self.paletteView addSubview:((GameBlock*)[self.blocks objectForKey:[NSNumber numberWithInt:1]]).view];
}

//Implementing Delegate Protocol Methods
-(void)objectDidResizeOfType:(GameObjectType)type {
    //REQUIRES: type = wolf or pig
    //EFFECTS: Sets the frame property of the image view of appropriate object type
    if (type == kGameObjectWolf) {
        self.wolf.view.frame = CGRectMake(self.wolf.modelObject.origin.x, self.wolf.modelObject.origin.y, self.wolf.modelObject.size.width, self.wolf.modelObject.size.height);
        [self.wolf.modelObject setBoundingBox:self.wolf.view.frame];
    }
    else if (type == kGameObjectPig) {
        self.pig.view.frame = CGRectMake(self.pig.modelObject.origin.x, self.pig.modelObject.origin.y, self.pig.modelObject.size.width, self.pig.modelObject.size.height);
        [self.pig.modelObject setBoundingBox:self.pig.view.frame];
    }
}

-(void)objectDidScaleBy:(CGFloat)scaleStep OfType:(GameObjectType)type {
    //REQUIRES: type = wolf or pig
    //EFFECTS: Sets the transform property of the image view of appropriate object type
    if (type == kGameObjectWolf) {
        [self.wolf.view setTransform:CGAffineTransformScale(self.wolf.view.transform, scaleStep, scaleStep)];
        [self.wolf.modelObject setBoundingBox:self.wolf.view.frame];
    }
    else if (type == kGameObjectPig) {
        [self.pig.view setTransform:CGAffineTransformScale(self.pig.view.transform, scaleStep, scaleStep)];
        [self.pig.modelObject setBoundingBox:self.pig.view.frame];
    }
}

-(void)blockDidResize:(int)blockID {
    //REQUIRES: blockID is a valid ID of a non-deleted block
    //EFFECTS: Sets the frame property of the image view of the corresponding block
    GameBlock* block = [self.blocks objectForKey:[NSNumber numberWithInt:blockID]];
    block.view.frame = CGRectMake(block.modelObject.origin.x, block.modelObject.origin.y, block.modelObject.size.width, block.modelObject.size.height);
    [block.modelObject setBoundingBox:block.view.frame];
}

-(void)blockDidScale:(int)blockID By:(CGFloat)scaleStep {
    //REQUIRES: blockID is a valid ID of a non-deleted block
    //EFFECTS: Sets the transform property of the image view of the corresponding block
    GameBlock* block = [self.blocks objectForKey:[NSNumber numberWithInt:blockID]];
    [block.view setTransform:CGAffineTransformScale(block.view.transform, scaleStep, scaleStep)];
    [block.modelObject setBoundingBox:block.view.frame];
}

-(void)blockDidChangeType:(int)blockID {
    //REQUIRES: blockID is a valid ID of a non-deleted block
    //EFFECTS: Sets the image property of the image view of the corresponding block
    GameBlock* block = [self.blocks objectForKey:[NSNumber numberWithInt:blockID]];
    [(UIImageView*)block.view setImage:[self.images objectForKey:[NSNumber numberWithInt:((Block*)block.modelObject).type]]];
}

-(void)objectMovedToGameAreaOfType:(GameObjectType)type {
    //REQUIRES: type = wolf or pig
    //EFFECTS: Sets the alpha property of the image view of default image in the palette
    if (type == kGameObjectWolf) {
        [self.defaultWolf setAlpha:FADED];
    }
    else if (type == kGameObjectPig) {
        [self.defaultPig setAlpha:FADED];
    }
}

-(void)objectMovedToPaletteOfType:(GameObjectType)type {
    //REQUIRES: type = wolf or pig
    //EFFECTS: Sets the alpha property of the image view of default image in the palette
    if (type == kGameObjectWolf) {
        [self.defaultWolf setAlpha:OPAQUE];
    }
    else if (type == kGameObjectPig) {
        [self.defaultPig setAlpha:OPAQUE];
    }
}

-(void)newBlockAdded {
    //EFFECTS: Adds a new block to the palette
    self.blockCount++;
    GameObject* newBlock = [[GameBlock alloc] initWithOrigin:CGPointMake(PALETTE_BLOCK_ORIGIN_X, PALETTE_BLOCK_ORIGIN_Y)
                                                          size:CGSizeMake(PALETTE_BLOCK_SIZE_WIDTH, PALETTE_BLOCK_SIZE_HEIGHT)
                                                         state:kInPalette
                                                     blockType:kStrawBlock
                                                       blockID:self.blockCount];
    
    [self.blocks setObject:newBlock forKey:[NSNumber numberWithInt:((Block*)newBlock.modelObject).blockID]];
    [newBlock setAllGestures];
    [newBlock.modelObject setDelegate:self];
    [newBlock setDelegate:self];
    [self.paletteView addSubview:newBlock.view];
}

-(void)blockDeleted:(int)blockID {
    //EFFECTS: Removes the block object from the array
    [self.blocks removeObjectForKey:[NSNumber numberWithInt:blockID]];
}


-(void)loadDefaultView {
    [self createPalette];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    self.saveAlert = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

// Override to allow orientations other than the default portrait orientation.
// Rotation for v. 5.1.1
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    else
        return NO;
}

@end
