//
//  MMObjectTextPanel.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMObject.h"
#import "MMCheckView.h"

@interface MMObjectTextPanel : UIViewController<MMCheckViewDelegate>{
    IBOutlet UISegmentedControl *_aligmentSegment;
    IBOutlet UISegmentedControl *_sizeSegment;
    
    IBOutlet UIView *_aligmView;
    IBOutlet UIView *_sizeView;
    
    NSMutableArray *aligmentChek;
    NSMutableArray *sizeChek;
}

@property(assign)MMObject *object;

-(void)analizeObject;

@end
