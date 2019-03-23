//
//  MMOpenViewController.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@protocol MMOpenFileControllerDelegate;

@interface MMOpenViewController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
    IBOutlet UITableView *_table;
    NSMutableArray *_filesArray;
    NSMutableArray *_inboxArray;
}

@property (nonatomic,assign)id<MMOpenFileControllerDelegate>delegate;

-(void)loadingDocumentsArray;

@end


@protocol MMOpenFileControllerDelegate <NSObject>

-(void)openViewController:(MMOpenViewController*)controller didSelectDocument:(NSString*)docName;

@end