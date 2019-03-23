//
//  MMObjectColorPanel.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMObjectColorPanel.h"
#import "MMBorder.h"

@interface MMObjectColorPanel ()

-(IBAction)touchedColorButton:(id)sender;

@end

@implementation MMObjectColorPanel
@synthesize object=_object;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _colorsArray = [[NSMutableArray alloc] init];

    //[_colorsArray addObject:[UIColor colorWithRed:0.9725 green:1.0 blue:0.3255 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.9294 green:0.8549 blue:0.0117 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.447 green:1.0 blue:0.3529 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.0 green:0.8549 blue:1.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.0 green:0.5686 blue:1.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:1.0 green:0.5568 blue:0.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:1.0 green:0.847 blue:0.3843 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:1.0 green:0.3921 blue:1.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:1.0 green:0.0 blue:0.5843 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.9607 green:1.0 blue:0.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:1.0 green:0.4196 blue:0.447 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.596 green:0.4431 blue:1.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1]];
    [_colorsArray addObject:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(IBAction)touchedColorButton:(id)sender
{
    //Создание записи
    MMBorder *_bord =(MMBorder*) _object.superview;
    [_bord objectWasChange:_object];
    
    [_object.dashbord setBackgroundColor:[_colorsArray objectAtIndex:[(UIButton*)sender tag]-1]];
    _object.colorID = [(UIButton*)sender tag];
}

@end
