//
//  DesignViewControllerExtension.m
//  Game
//
//  Created by Raunak Rajpuria on 2/2/13.
//  Copyright (c) 2013 Raunak Rajpuria. All rights reserved.
//
/*
    DesignViewControllerExtension extends the DesignViewController class to implement the save, load and reset functionalities
*/
#import "DesignViewControllerExtension.h"

@interface DesignViewController ()
@end


@implementation DesignViewController (DesignViewControllerExtension)

- (IBAction)buttonPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSString *buttonName = [button titleForState:UIControlStateNormal];
    if ([buttonName isEqual:@"Save"]) {
        [self save];
    }
    else if ([buttonName isEqual:@"Load"]) {
        [self load];
    }
    else if ([buttonName isEqual:@"Reset"]) {
        [self reset];
    }
    else if ([buttonName isEqual:@"Back"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)save {
    // REQUIRES: game in designer mode
    // EFFECTS: game objects are saved
    [self.saveAlert show];
}

//Implementing UIAlertViewDelegate protocol method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!([alertView isEqual:self.saveAlert])) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    else {
        if (buttonIndex == 1){
            return; //If cancel then return
        }
        if (buttonIndex == 0) {
            if ([alertView isEqual:self.saveAlert]) {
                [self saveToFile:[[alertView textFieldAtIndex:0] text]];
                [self.saveAlert textFieldAtIndex:0].text = nil;
            }
        }
    }
}

-(void)saveToFile:(NSString*)fileName {
    if ([super isDefaultLevel:fileName]) {
        UIAlertView *errorSave = [[UIAlertView alloc] initWithTitle:@"Error" message:@"File Name Cannot Be Same As A Default Level" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [errorSave show];
    }
    else {
        NSString *documentsPath = [self getPathToDocumentsDirectory];
        
        //Save objects to file
        NSMutableData *data  = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        [archiver encodeObject:self.wolf.modelObject forKey:@"Wolf Object"];
        [archiver encodeObject:self.pig.modelObject forKey:@"Pig Object"];
        [archiver encodeObject:self.blocks forKey:@"Block Objects"];
        [archiver finishEncoding];
        
        BOOL success = [data writeToFile:[NSString stringWithFormat:@"%@/%@", documentsPath, fileName] atomically:YES];
        if(!success) {
            UIAlertView *errorSave = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to Save File" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [errorSave show];
        }
        else {
            UIAlertView *saveSuccess = [[UIAlertView alloc] initWithTitle:@"Success" message:@"File Saved Successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            self.currentLevelName = fileName;
            [saveSuccess show];
        }
    }
}

-(void)load {
    // MODIFIES: self (game objects)
    // REQUIRES: game in designer mode
    // EFFECTS: game objects are loaded
    [super displayLoadScreen];
}

//Implementing UITableView Delegate method to deal with selection of cell by user
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString* fileName = [self.savedFileNames objectAtIndex:indexPath.row];
    self.currentLevelName = fileName;
    [self reset];
    [super loadObjectsFromFile:fileName];
}

-(NSString*)getPathToDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return documentsPath;
}

-(void)reset {
    // MODIFIES: self (game objects)
    // REQUIRES: game in designer mode
    // EFFECTS: current game objects are deleted and palette contains all objects
    [self resetWolfObject];
    [self resetPigObject];
    [self resetBlockObjects];
}

-(void)resetWolfObject {
    if (self.wolf.modelObject.currentState == kInGameArea) {
        [(GameWolf*)self.wolf setDefaultPaletteState];
        [self.wolf setAllGestures];
        [(GameWolf*)self.wolf resetStartMode];
        [self.defaultWolf setAlpha:OPAQUE];
    }
}

-(void)resetPigObject {
    if (self.pig.modelObject.currentState == kInGameArea) {
        [(GamePig*)self.pig setDefaultPaletteState];
        [self.defaultPig setAlpha:OPAQUE];
    }
}

-(void)resetBlockObjects {
    NSMutableArray *deletedBlocks = [NSMutableArray array];
    
    for (NSString* key in self.blocks) {
        //Foreach block, add the blockID to the array
        GameBlock* gb = [self.blocks objectForKey:key];
        [gb.view removeFromSuperview];
        [deletedBlocks addObject:[NSNumber numberWithInt:((Block*)gb.modelObject).blockID]];
    }
    
    //Delete all blocks found above
    for (NSNumber* key in deletedBlocks) {
        [self.blocks removeObjectForKey:key];
    }
    
    //Create new default block for palette area
    [self newBlockAdded];
}

@end
