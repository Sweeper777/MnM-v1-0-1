//
//  MMActivityView.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 30.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMActivityView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MMActivityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:10.0];
}

-(void)show
{
    [self setHidden:NO];
    [_activityIndicator startAnimating];
}

-(void)hide
{
    [_activityIndicator stopAnimating];
    [self setHidden:YES];
}

@end
