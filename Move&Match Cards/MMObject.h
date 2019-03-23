//
//  MMObject.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HPGrowingTextView.h"

@protocol MMObjectDelegate;


@interface MMObject : UIView <UITextViewDelegate,NSCoding> {
    UIButton *_closeButton;
    NSMutableArray *_sizeButtons;
    NSString *_imageName;
    
    CGRect frameTextView;
    
    BOOL _isSelected;
    BOOL _isColorHide;
    BOOL _isTextHide;
    BOOL _isImageHide;
    BOOL _isResizing;
    int resizeID;
    
    CGFloat lastScaleWidth;
    CGFloat lastScaleHeight;
    
    CGFloat panDexX;
    CGFloat panDexY;
    
    CGFloat curentOffsetY;
}

@property(strong,nonatomic)NSString *UUID;
@property(nonatomic,assign)id<MMObjectDelegate>delegate;
@property(strong,nonatomic)UIView *dashbord;
@property(nonatomic,retain)UITextView *textView;
@property(strong,nonatomic)UIImageView *imageView;
@property(strong,nonatomic)UIView *toolView;
@property(nonatomic,assign)BOOL isSelected;
@property(nonatomic,assign)NSInteger colorID;

@property(nonatomic,retain)UIButton *colorButton;
@property(nonatomic,retain)UIButton *textButton;
@property(nonatomic,retain)UIButton *imageButton;

+(NSString*) createUUID;

-(void)selectObject;
-(void)deselectObject;

-(NSDictionary*)getHistoryEntry;
-(void)configByEntry:(NSDictionary*)entry;
-(void)setImageForObject:(UIImage*)_image;
-(void)setCurentOffsetY:(CGFloat)_offsetY;
-(void)makeSize:(CGSize)_dashSize withCenter:(CGPoint)centerPoint;

@end

@protocol MMObjectDelegate 
@required
- (void)objectWillDeleted:(MMObject*)obj;
- (void)objectWillMove:(MMObject *)obj;
@optional
- (void)objectWillSelected:(MMObject*)obj;
- (void)objectWillDeselected:(MMObject*)obj;
- (void)objectDidTouchColorPanel:(UIButton*)sender withHide:(BOOL)isHide;
- (void)objectDidTouchTextPanel:(UIButton*)sender withHide:(BOOL)isHide;
- (void)objectDidTouchImagePanel:(UIButton*)sender withHide:(BOOL)isHide;
- (void)objectWillPinch:(MMObject*)obj;

- (void)objectWasChange:(MMObject*)obj;
@end
