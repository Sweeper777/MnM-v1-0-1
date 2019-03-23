//
//  MMBorder.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMObject.h"

#import "MMObjectColorPanel.h"
#import "MMObjectTextPanel.h"
#import "MMObjectImagePanel.h"

@protocol MMBOrderDelegate;

@interface MMBorder : UIScrollView <MMObjectDelegate>{
    NSMutableArray *objectsArray;
    
    BOOL isEditingTextBox;
    
    CGFloat firstX;
    CGFloat firstY;
}

@property(nonatomic,assign)id<MMBOrderDelegate>historyDelegate;

@property(strong,nonatomic)MMObjectColorPanel *colorPanel;
@property(strong,nonatomic)MMObjectTextPanel *textPanel;
@property(strong,nonatomic)MMObjectImagePanel *imagePanel;

@property(nonatomic,retain)NSMutableArray *objectsArray;
@property(assign)BOOL isMakeMode;

-(void)handleTap:(UITapGestureRecognizer*)recognizer;
-(MMObject*)createObjectInBoard;
-(void)deleteObjectFromBoard:(MMObject*)obj;
-(void)deleteAllObjectsFromBorder;

@end


@protocol MMBOrderDelegate <NSObject>

- (void)border:(MMBorder*)border withChanges:(NSDictionary*)_changes;

@end