//
//  MMViewController.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 02.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMBorder.h"
#import "MMObjectImagePanel.h"
#import "MMColorViewController.h"
#import "MMOpenViewController.h"
#import "MMShareViewController.h"
#import "MMActivityView.h"
#import <MessageUI/MessageUI.h>

@interface MMViewController : UIViewController<MMImagePanelDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,MMColorControllerDelegate,MMBOrderDelegate,MMOpenFileControllerDelegate,MMShareControllerDelegate,MFMailComposeViewControllerDelegate>{
    IBOutlet UIToolbar *_toolBar;
    IBOutlet UIImageView *_borderImageView;
    IBOutlet UIImageView *_logoView;
    IBOutlet MMBorder *_borderView;
    IBOutlet MMActivityView *_activity;
    IBOutlet UIButton *_buttonMake;
    IBOutlet UIButton *_buttonUse;
    IBOutlet UIButton *_homeButton;
    
    IBOutlet UIButton *_toolButton1;
    IBOutlet UIButton *_toolButton2;
    IBOutlet UIButton *_toolButton3;
    IBOutlet UIButton *_toolButton4;
    IBOutlet UIButton *_toolButton5;
    IBOutlet UIButton *_toolButton6;
    IBOutlet UIButton *_toolButton7;
    IBOutlet UIButton *_toolButton8;
    
    BOOL isCreateButtonTouched;
    BOOL isOpenDocumentTouched;
    
    NSOperationQueue *_operations;
    
    UIButton *_titleButton;
    NSString *_documentName;
    NSString *_openDocumentName; 
    UIPopoverController *_colorPopoverController;
    UIPopoverController *_sharePopoverController;
    UIPopoverController *_openPopoverController;
    MMOpenViewController *_openController;
    
    UIImagePickerController *_imagePicker;
    UIPopoverController *_imagePopover;
    UIPopoverController *_objectImagePopover;
    
    UIAlertView *_alertTitle;
    UIAlertView *_alertSave;
    UIAlertView *_alertResave;
    UIAlertView *_alertNewProject;
    UIAlertView *_alertOpenProject;
    UIAlertView *_alertWarningResave;
    UIAlertView *_alertWarningHome;
    UIAlertView *_alertError;
    UITextField *_titleField;
    UITextField *_saveField;
    
    NSMutableArray *historyArray;
    NSInteger historyIndex;
    NSInteger _shareIndex;
    NSInteger _colorIndex;
    NSString *_imageBackgraundName;
}

@property(nonatomic, retain)MMBorder *borderView;

-(IBAction)touchedMake:(id)sender;
-(IBAction)touchedUse:(id)sender;
-(IBAction)touchedHome:(id)sender;
-(void)touchedTitle:(id)sender;
-(IBAction)tochedNavigButton1:(id)sender;
-(IBAction)tochedNavigButton2:(id)sender;
-(IBAction)tochedNavigButton3:(id)sender;
-(IBAction)tochedNavigButton4:(id)sender;
-(IBAction)tochedNavigButton5:(id)sender;
-(IBAction)tochedNavigButton6:(id)sender;
-(IBAction)tochedNavigButton7:(id)sender;
-(IBAction)tochedNavigButton8:(id)sender;

-(void)loadingDocumentFromFile2:(NSString*)_fileName;
-(void)clearHistory;

@end
