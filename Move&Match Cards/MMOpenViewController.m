//
//  MMOpenViewController.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMOpenViewController.h"

@interface MMOpenViewController ()

@end

@implementation MMOpenViewController
@synthesize delegate = _delegate;
- (void)dealloc
{
    [_filesArray release];
    [_inboxArray release];
    [super dealloc];
}

#pragma mark - UIViewController methods

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
    
    [self loadingDocumentsArray];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadingDocumentsArray];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Public methods

-(void)loadingDocumentsArray
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_document];
    NSString *inboxDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_inbox];
    _filesArray = [(NSMutableArray*)[fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil] retain];
    _inboxArray = [(NSMutableArray*)[fileManager contentsOfDirectoryAtPath:inboxDirectory error:nil] retain];
    [_table reloadData];
}

#pragma mark - UITableViewDataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([_inboxArray count]>0)
        return 2;
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section==1)
        return @"Inbox files";
    else
        return @"Users files";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==1)
        return [_inboxArray count];
    return [_filesArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndetifire = @"OpenTableCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndetifire];
    if(cell==nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifire] autorelease];
    if(indexPath.section==0)
        cell.textLabel.text = [_filesArray objectAtIndex:indexPath.row];
    else
        cell.textLabel.text = [_inboxArray objectAtIndex:indexPath.row];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //удаление документа
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath;
        if(indexPath.section==0){
            NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_document];
            filePath = [documentsDirectory stringByAppendingPathComponent:[_filesArray objectAtIndex:indexPath.row]];
        }else{
            NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_inbox];
            filePath = [documentsDirectory stringByAppendingPathComponent:[_inboxArray objectAtIndex:indexPath.row]];
        }
        
        [fileManager removeItemAtPath:filePath error:nil];
        [self loadingDocumentsArray];
    }
}

#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *filePath;
    if(indexPath.section == 0){
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_document];
        filePath = [documentsDirectory stringByAppendingPathComponent:[_filesArray objectAtIndex:indexPath.row]];
    }else{
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_inbox];
        filePath = [documentsDirectory stringByAppendingPathComponent:[_inboxArray objectAtIndex:indexPath.row]];
    }
    [_delegate openViewController:self didSelectDocument:filePath];
}

@end
