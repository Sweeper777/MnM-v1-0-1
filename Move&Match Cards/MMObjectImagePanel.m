//
//  MMObjectImagePanel.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMObjectImagePanel.h"


@interface MMObjectImagePanel ()

-(IBAction)touchedTakeImage:(id)sender;
-(IBAction)touchedChooseImage:(id)sender;
-(IBAction)touchedDeleteImage:(id)sender;

@end

@implementation MMObjectImagePanel
@synthesize object = _object, delegate=_delegate;
@synthesize takeBut = _takeBut, chooseBut = _chooseBut, deleteBut = _deleteBut;

- (void)dealloc
{
    _object = nil;
    _delegate = nil;
    [super dealloc];
}

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

-(IBAction)touchedTakeImage:(id)sender
{
    [_delegate loadingImageFromCamera];
}

-(IBAction)touchedChooseImage:(id)sender
{
    [_delegate loadingImageFromAlbom];
}

-(IBAction)touchedDeleteImage:(id)sender
{
    if(![_object.imageView isHidden]){
        //cоздание записи
        [_delegate deleteImageFromObject:_object];
        
        [_object setImageForObject:nil];
    }
}

@end
