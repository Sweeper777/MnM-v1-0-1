//
//  MMObjectTextPanel.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMObjectTextPanel.h"
#import "MMBorder.h"


@interface MMObjectTextPanel ()

- (IBAction)changeTextAligment:(id)sender;
- (IBAction)changeTextSize:(id)sender;

@end

@implementation MMObjectTextPanel
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
    
    //init aligmentChek
    aligmentChek = [[NSMutableArray alloc] init];
    CGFloat _width1=0;
    for (int i = 0; i<3; i++) {
        CGRect frame;
        switch (i) {
            case 0:     frame = CGRectMake(0, 0, 88, 39);     break;
            case 1:     frame = CGRectMake(0, 0, 86, 39);     break;
            case 2:     frame = CGRectMake(0, 0, 88, 39);     break;
        }
        MMCheckView *item = [[MMCheckView alloc] initWithFrame:frame];
        [item setSelectImage:[UIImage imageNamed:[NSString stringWithFormat:@"Seg1_%d_select.png",i+1]]];
        [item setDeselectImage:[UIImage imageNamed:[NSString stringWithFormat:@"Seg1_%d.png",i+1]]];
        [item setCheckValue:NO];
        [item setTag:1];
        [item setDelegate:self];
        [item setCenter:CGPointMake(_width1+item.frame.size.width/2, item.frame.size.height/2)];
        [_aligmView addSubview:item];
        _width1+=item.frame.size.width;
        [aligmentChek addObject:item];
    }
    
    //init aligmentChek
    sizeChek = [[NSMutableArray alloc] init];
    CGFloat _width2=0;
    for (int i = 0; i<6; i++) {
        CGRect frame;
        switch (i) {
            case 5:     frame = CGRectMake(0, 0, 45, 39);       break;
            default:    frame = CGRectMake(0, 0, 43, 39);       break;
        }
        MMCheckView *item = [[MMCheckView alloc] initWithFrame:frame];
        [item setSelectImage:[UIImage imageNamed:[NSString stringWithFormat:@"Seg2_%d_select.png",i+1]]];
        [item setDeselectImage:[UIImage imageNamed:[NSString stringWithFormat:@"Seg2_%d.png",i+1]]];
        [item setCheckValue:NO];
        [item setTag:2];
        [item setDelegate:self];
        [item setCenter:CGPointMake(_width2+item.frame.size.width/2, item.frame.size.height/2)];
        [_sizeView addSubview:item];
        _width2+=item.frame.size.width;
        [sizeChek addObject:item];
    }
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

-(void)analizeObject
{
    for (MMCheckView* it in aligmentChek) {
        [it setCheckValue:NO];
    }
    
    for (MMCheckView* it in sizeChek) {
        [it setCheckValue:NO];
    }
    
    int alID = 0;
    switch (_object.textView.textAlignment) {
        case UITextAlignmentLeft:       alID = 0;   break;
        case UITextAlignmentCenter:     alID = 1;   break;
        case UITextAlignmentRight:      alID = 2;   break;
    }
    
    MMCheckView *item = [aligmentChek objectAtIndex:alID];
    [item setCheckValue:YES];
    
    int sizeID = 0;
    int text_size = [[_object.textView font] pointSize];
    switch (text_size) {
        case 16:    sizeID = 0;   break;
        case 34:    sizeID = 1;   break;
        case 50:    sizeID = 2;   break;
        case 80:    sizeID = 3;   break;
        case 110:    sizeID = 4;   break;
        case 150:    sizeID = 5;   break;
        default:    sizeID = 0;   break;
    }
    MMCheckView *item2 = [sizeChek objectAtIndex:sizeID];
    [item2 setCheckValue:YES];
}

- (IBAction)changeTextAligment:(id)sender
{
    //Создание записи
    MMBorder *bord =(MMBorder*)_object.superview;
    [bord objectWasChange:_object];
    
    NSLog(@"%@",NSStringFromRange(_object.textView.selectedRange));
    
    UISegmentedControl *segm = (UISegmentedControl*)sender;
    switch ([segm selectedSegmentIndex]) {
        case 0:     [_object.textView setTextAlignment:UITextAlignmentLeft];        break;
        case 1:     [_object.textView setTextAlignment:UITextAlignmentCenter];      break;
        case 2:     [_object.textView setTextAlignment:UITextAlignmentRight];       break;
    }
    
    CGPoint scrollPoint = _object.textView.contentOffset;
    scrollPoint.y= scrollPoint.y+1; 
    [_object.textView setContentOffset:scrollPoint animated:YES];
}

- (IBAction)changeTextSize:(id)sender
{
    //Создание записи
    MMBorder *bord =(MMBorder*)_object.superview;
    [bord objectWasChange:_object];
    
    UISegmentedControl *segm = (UISegmentedControl*)sender;
    switch ([segm selectedSegmentIndex]) {
        case 0:     [_object.textView setFont:[UIFont systemFontOfSize:10.0]];        break;
        case 1:     [_object.textView setFont:[UIFont systemFontOfSize:14.0]];      break;
        case 2:     [_object.textView setFont:[UIFont systemFontOfSize:18.0]];       break;
        case 3:     [_object.textView setFont:[UIFont systemFontOfSize:22.0]];       break;
        case 4:     [_object.textView setFont:[UIFont systemFontOfSize:27.0]];       break;
        case 5:     [_object.textView setFont:[UIFont systemFontOfSize:33.0]];       break;
    }
    [_object reloadInputViews];
}

-(void)checkViewDidSelect:(MMCheckView *)_checkview
{
    if(_checkview.tag==1){
        //Text Aligment
        BOOL value = [_checkview getCheckValue];
        int _indexCheck = [aligmentChek indexOfObject:_checkview];
        if(value == YES){
            for (MMCheckView* it in aligmentChek) {
                [it setCheckValue:NO];
            }
            [_checkview setCheckValue:YES];
        }else{
            [_checkview setCheckValue:YES];
        }
        
        switch (_indexCheck) {
            case 0:     [_object.textView setTextAlignment:UITextAlignmentLeft];        break;
            case 1:     [_object.textView setTextAlignment:UITextAlignmentCenter];      break;
            case 2:     [_object.textView setTextAlignment:UITextAlignmentRight];       break;
        }
        
        CGPoint scrollPoint = _object.textView.contentOffset;
        scrollPoint.y= scrollPoint.y+1;
        [_object.textView setContentOffset:scrollPoint animated:YES];
        
    }
    else if(_checkview.tag==2){
        //Text Size
        BOOL value = [_checkview getCheckValue];
        int _indexCheck = [sizeChek indexOfObject:_checkview];
        if(value == YES){
            for (MMCheckView* it in sizeChek) {
                [it setCheckValue:NO];
            }
            [_checkview setCheckValue:YES];
        }else{
            [_checkview setCheckValue:YES];
        }
        
        switch (_indexCheck) {
            case 0:     [_object.textView setFont:[UIFont systemFontOfSize:16.0]];       break;
            case 1:     [_object.textView setFont:[UIFont systemFontOfSize:34.0]];       break;
            case 2:     [_object.textView setFont:[UIFont systemFontOfSize:50.0]];       break;
            case 3:     [_object.textView setFont:[UIFont boldSystemFontOfSize:80.0]];       break;
            case 4:     [_object.textView setFont:[UIFont boldSystemFontOfSize:110.0]];       break;
            case 5:     [_object.textView setFont:[UIFont boldSystemFontOfSize:150.0]];       break;
        }
        //установка размеров
        CGFloat newSizeH = _object.textView.contentSize.height;
        //проверка размеров объекта
        if((_object.dashbord.frame.size.height<newSizeH)&(newSizeH<=236)){
            //если объект вписывается в допустимые размеры
            CGSize newObjSize = CGSizeMake(_object.dashbord.frame.size.width, newSizeH);
            [_object makeSize:newObjSize withCenter:_object.center];
        }else if(_object.dashbord.frame.size.height<newSizeH){
            
        }
    }
}

@end
