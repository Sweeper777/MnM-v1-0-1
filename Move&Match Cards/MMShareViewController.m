//
//  MMShareViewController.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMShareViewController.h"

@interface MMShareViewController ()

@end

@implementation MMShareViewController
@synthesize delegate=_delegate;

-(void)dealloc
{
    _delegate = nil;
    [super dealloc];
}

#pragma mark - ViewController methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [_table setScrollEnabled:NO];
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

#pragma mark - TableView Data Source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    [cell.textLabel setTextAlignment:UITextAlignmentCenter];
    switch (indexPath.row) {
        case 0:     [cell.textLabel setText:@"Email File"];    break;
        case 1:     [cell.textLabel setText:@"Email as JPG"];    break;
        case 2:     [cell.textLabel setText:@"Email as PNG"];    break;
        case 3:     [cell.textLabel setText:@"Email as PDF"];    break;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    return cell;
}

#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate shareController:self willShare:indexPath.row];
}

@end
