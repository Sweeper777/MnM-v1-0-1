//
//  MMActivityView.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 30.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMActivityView : UIView
{
    IBOutlet UIActivityIndicatorView *_activityIndicator;
}

-(void)show;
-(void)hide;

@end
