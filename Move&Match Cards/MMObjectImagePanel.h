//
//  MMObjectImagePanel.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMObject.h"

@protocol MMImagePanelDelegate;

@interface MMObjectImagePanel : UIViewController

@property(nonatomic,assign)id<MMImagePanelDelegate>delegate;
@property(assign)MMObject *object;
@property(nonatomic,retain)IBOutlet UIButton *takeBut;
@property(nonatomic,retain)IBOutlet UIButton *chooseBut;
@property(nonatomic,retain)IBOutlet UIButton *deleteBut;

@end


@protocol MMImagePanelDelegate <NSObject>

-(void)loadingImageFromCamera;
-(void)loadingImageFromAlbom;
-(void)deleteImageFromObject:(MMObject*)_obj;

@end