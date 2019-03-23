//
//  MMColorViewController.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMColorViewController.h"

@interface MMColorViewController ()

-(IBAction)touchedColorButton:(id)sender;
-(IBAction)touchedPhotoButton:(id)sender;

@end

@implementation MMColorViewController
@synthesize delegate=_delegate;

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
    // Do any additional setup after loading the view from its nib.
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
    [_delegate colorController:self touchedColorButton:(UIButton*)sender];
}

-(IBAction)touchedPhotoButton:(id)sender
{
    [_delegate colorController:self touchedPhotoButton:(UIButton*)sender];
}

@end
