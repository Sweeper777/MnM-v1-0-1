//
//  MMObjectColorPanel.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMObject.h"

@interface MMObjectColorPanel : UIViewController{
    NSMutableArray *_colorsArray;
}

@property (assign)MMObject *object;

@end
