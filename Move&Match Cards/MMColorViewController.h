//
//  MMColorViewController.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMColorControllerDelegate;

@interface MMColorViewController : UIViewController

@property(nonatomic,assign)id<MMColorControllerDelegate>delegate;

@end

@protocol MMColorControllerDelegate <NSObject>

-(void)colorController:(UIViewController*)controller touchedColorButton:(UIButton*)sender;
-(void)colorController:(UIViewController*)controller touchedPhotoButton:(UIButton*)sender;

@end
