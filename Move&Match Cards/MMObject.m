//
//  MMObject.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMObject.h"
#import "MMBorder.h"
#import "Defines.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>


@interface MMObject ()

- (void)createTextView;
- (void)touchedCloseButton:(id)sender;
- (void)touchedTextButton:(id)sender;
- (void)touchedColorButton:(id)sender;
- (void)touchedImageButton:(id)sender;
- (void)handleTap:(UITapGestureRecognizer*)recognizer;
- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer;
- (void)handlePan:(UIPanGestureRecognizer*)recognizer;
- (void)resizeObjectWhithPoint:(CGPoint)location andTagID:(int)tagID;
@end

@implementation MMObject
@synthesize UUID=_UUID,dashbord=_dashbord, isSelected=_isSelected, delegate=_delegate , textView = _textView, imageView = _imageView;
@synthesize colorButton = _colorButton, imageButton=_imageButton, textButton =_textButton, colorID=_colorID, toolView = _toolView;

#pragma mark - NSCoding methods

-(void) encodeWithCoder: (NSCoder *) coder
{
    [super encodeWithCoder:coder];
    [coder encodeCGRect:self.frame forKey:@"frame"];
    [coder encodeObject:_UUID forKey:@"UUID"];
    [coder encodeObject:_dashbord forKey:@"dashbord"];
    [coder encodeObject:_textView forKey:@"textView"];
    [coder encodeObject:_imageView forKey:@"imageView"];
    [coder encodeObject:_closeButton forKey:@"closeButton"];
    [coder encodeObject:_toolView forKey:@"toolView"];
    [coder encodeObject:_imageName forKey:@"imageName"];
    [coder encodeCGRect:frameTextView forKey:@"frameTextView"];
    [coder encodeBool:_isSelected forKey:@"isSelected"];
    [coder encodeBool:_isColorHide forKey:@"isColorHide"];
    [coder encodeBool:_isTextHide forKey:@"isTextHide"];
    [coder encodeBool:_isImageHide forKey:@"isImageHide"];
    //[coder encodeFloat:lastScale forKey:@"lastScale"];
    [coder encodeInteger:_colorID forKey:@"colorID"];
    [coder encodeObject:_colorButton forKey:@"colorButton"];
    [coder encodeObject:_textButton forKey:@"textButton"];
    [coder encodeObject:_imageButton forKey:@"imageButton"];
}

-(id) initWithCoder: (NSCoder *) decoder
{
    //[super performSelectorOnMainThread:@selector(initWithCoder:) withObject:decoder waitUntilDone:YES];
    self = [super initWithCoder:decoder];
    _UUID=[[decoder decodeObjectForKey:@"UUID"] retain];
    _dashbord=[[decoder decodeObjectForKey:@"dashbord"] retain];
    _textView=[[decoder decodeObjectForKey:@"textView"] retain];
    _imageView = [[decoder decodeObjectForKey:@"imageView"] retain];
    _closeButton = [[decoder decodeObjectForKey:@"closeButton"] retain];
    _toolView = [[decoder decodeObjectForKey:@"toolView"] retain];
    _imageName = [[decoder decodeObjectForKey:@"imageName"] retain];
    frameTextView = [decoder decodeCGRectForKey:@"frameTextView"];
    _isSelected = [decoder decodeBoolForKey:@"isSelected"];
    _isColorHide = [decoder decodeBoolForKey:@"isColorHide"];
    _isTextHide = [decoder decodeBoolForKey:@"isTextHide"];
    _isImageHide = [decoder decodeBoolForKey:@"isImageHide"];
    //lastScale = [decoder decodeFloatForKey:@"lastScale"];
    _colorID = [decoder decodeIntegerForKey:@"colorID"];
    _colorButton = [[decoder decodeObjectForKey:@"colorButton"] retain];
    _textButton = [[decoder decodeObjectForKey:@"textButton"] retain];
    _imageButton = [[decoder decodeObjectForKey:@"imageButton"] retain];
    
    _dashbord.layer.shadowOffset = CGSizeMake(0.0,3.0);
    _dashbord.layer.shadowOpacity = 0.7;
    _dashbord.layer.shadowColor = [UIColor blackColor].CGColor;
    
    lastScaleWidth = 0;
    lastScaleHeight = 0;
    curentOffsetY = 0;
    
    if(_imageView.image!=nil)
        [self setImageForObject:_imageView.image];
    
    //создание вьюшек для изменения вида размеров объекта
    _sizeButtons = [[NSMutableArray alloc] init];
    for (int i=0; i<7; i++) {
        CGRect sFrame;
        if(i==2)
            sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(7%3)-18,
                                _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(7/3)-18, 36, 36);
        else if (i==4)
            sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(8%3)-18,
                                _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(8/3)-18, 36, 36);
        else
            sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(i%3)-18,
                                _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(i/3)-18, 36, 36);
        UIView *sButton = [[UIView alloc] initWithFrame:sFrame];
        [sButton setBackgroundColor:[UIColor clearColor]];
        [sButton setTag:i];
        [sButton setHidden:NO];
        [sButton.layer setCornerRadius:18];
        //if(i==4){
        //[sButton setTag:0];
        [_sizeButtons addObject:sButton];
        [self addSubview:sButton];
        //}
    }
    
    //определения метода нажатия на вид и пинча
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    [tap release];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self addGestureRecognizer:pinch];
    [pinch release];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    [pan release];
    
    return self;
}

#pragma mark - UIView class methods

- (void)createTextView
{
    _textView = [[UITextView alloc] init];
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _textView.backgroundColor = [UIColor clearColor];
    [_textView setFont:[UIFont systemFontOfSize:16.0]];
    [_textView setTextAlignment:UITextAlignmentLeft];
    
    frameTextView = _dashbord.frame;
    _textView.frame = frameTextView;
    _textView.center = _dashbord.center;
    _textView.delegate = self;
    _textView.editable = NO;
    _textView.scrollEnabled = NO;
    [self addSubview:_textView];
}

- (id)initWithFrame:(CGRect)frame
{
    
    CGRect mainFrame = CGRectMake(0, 0, frame.size.width+36, frame.size.height+18+10+45);
    frame = CGRectMake(frame.origin.x+18, frame.origin.y+18, frame.size.width, frame.size.height);
    self = [super initWithFrame:mainFrame];
    if (self) {
        //Создание UUID для объекта
        _UUID = [MMObject createUUID];
        _colorID = 0;
        curentOffsetY = 0;
        
        //Установка основных флагов
        _imageName = @"NULL";
        _isSelected = NO;
        _isColorHide = YES;
        _isTextHide = YES;
        _isImageHide = YES;
        _isResizing = NO;
        resizeID = -1;
        lastScaleWidth = 0;
        lastScaleHeight = 0;
        
        //[self setBackgroundColor:[UIColor whiteColor]];
        
        //создание вида объекта 
        _dashbord = [[UIView alloc] initWithFrame:frame];
        _dashbord.backgroundColor = DEFAULT_OBJECT_COLOR;
        _dashbord.layer.shadowOffset = CGSizeMake(0.0,3.0);
        _dashbord.layer.shadowOpacity = 0.7;
        _dashbord.layer.shadowColor = [UIColor blackColor].CGColor;
        [self addSubview:_dashbord];
        
        //Создание поля изображений (Ресурс)
        _imageView = [[UIImageView alloc]initWithFrame:frame];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_textView setHidden:YES];
        [self addSubview:_imageView];
        
        //создание текстового поля (Ресурс)
        frameTextView = frame;
        //[self performSelectorOnMainThread:@selector(createTextView) withObject:nil waitUntilDone:YES];
        [self createTextView];
        
        //создание кнопки удаления
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"CloseButton.png"] forState:UIControlStateNormal];
        [_closeButton setFrame:CGRectMake(0, 0, 36, 36)];
        [_closeButton setCenter:CGPointMake(frame.size.width+frame.origin.x, frame.origin.y)];
        [_closeButton addTarget:self action:@selector(touchedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setHidden:YES];
        [self addSubview:_closeButton];
        
        //создание кнопки цвета (панель утилит)
        _colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_colorButton setImage:[UIImage imageNamed:@"ObjButton1.png"] forState:UIControlStateNormal];
        [_colorButton addTarget:self action:@selector(touchedColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [_colorButton setFrame:CGRectMake(0, 0, 55, 43)];
        
        //создание кнопки текста (панель утилит)
        _textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textButton setImage:[UIImage imageNamed:@"ObjButton2.png"] forState:UIControlStateNormal];
        [_textButton addTarget:self action:@selector(touchedTextButton:) forControlEvents:UIControlEventTouchUpInside];
        [_textButton setFrame:CGRectMake(_colorButton.frame.size.width, 0, 59, 43)];
        
        //создание кнопки изображения (панель утилит)
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageButton setImage:[UIImage imageNamed:@"ObjButton3.png"] forState:UIControlStateNormal];
        [_imageButton addTarget:self action:@selector(touchedImageButton:) forControlEvents:UIControlEventTouchUpInside];
        [_imageButton setFrame:CGRectMake(_colorButton.frame.size.width+_textButton.frame.size.width, 0, 55, 43)];
        
        //создание панели утилит
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0,0,_imageButton.frame.origin.x+_imageButton.frame.size.width,_imageButton.frame.size.height)];
        [_toolView addSubview:_colorButton];
        [_toolView addSubview:_textButton];
        [_toolView addSubview:_imageButton];
        [_toolView setCenter:CGPointMake(mainFrame.size.width/2, frame.origin.y+frame.size.height+_toolView.frame.size.height/2+10)];
        [_toolView setHidden:YES];
        [self addSubview:_toolView];
        
        //создание вьюшек для изменения вида размеров объекта
        _sizeButtons = [[NSMutableArray alloc] init];
        for (int i=0; i<7; i++) {
            CGRect sFrame;
            if(i==2)
                sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(7%3)-18, 
                                    _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(7/3)-18, 36, 36);
            else if (i==4)
                sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(8%3)-18, 
                                    _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(8/3)-18, 36, 36);
            else 
                sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(i%3)-18, 
                                       _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(i/3)-18, 36, 36);
            UIView *sButton = [[UIView alloc] initWithFrame:sFrame];
            [sButton setBackgroundColor:[UIColor clearColor]];
            [sButton setTag:i];
            [sButton setHidden:NO];
            [sButton.layer setCornerRadius:18];
            //if(i==4){
                //[sButton setTag:0];
                [_sizeButtons addObject:sButton];
                [self addSubview:sButton];
            //}
        }
        
        //определения метода нажатия на вид и пинча
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        [tap release];
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:pinch];
        [pinch release];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        [pan release];
    }
    return self;
}

-(void)dealloc
{
    [_sizeButtons release];
    [_UUID release];
    [_closeButton release];
    [_colorButton release];
    [_textButton release];
    [_imageButton release];
    [_toolView release];
    [_textView release];
    [_dashbord release];
    [super dealloc];
}

#pragma mark - Private methods

//Создание независимого UUID
+ (NSString*) createUUID 
{
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

//Нажатие на кнопку удаления
- (void)touchedCloseButton:(id)sender
{
    [_delegate objectWillDeleted:self];
    //[self removeFromSuperview];
}

//Нажатие на кнопку Текста в панеле ресурсов
- (void)touchedTextButton:(id)sender
{
    if(_textButton.enabled){
        if(_isTextHide){
            _isTextHide = NO;
            _isColorHide = YES;
            _isImageHide = YES;
            _textView.editable = YES;
            [_textView setHidden:NO];
            [_textView becomeFirstResponder];
        }else {
            _isTextHide = YES;
            [_textView resignFirstResponder];
        }
        [_delegate objectDidTouchTextPanel:(UIButton*)sender withHide:_isTextHide];
    }
}

//Нажатие на кнопку Цвета в панеле ресурсов
- (void)touchedColorButton:(id)sender
{
    if(_colorButton.enabled){
        if(_isColorHide){
            _isColorHide = NO;
            _isTextHide = YES;
            _isImageHide = YES;
        }else {
            _isColorHide = YES;
        }
        [_delegate objectDidTouchColorPanel:(UIButton*)sender withHide:_isColorHide];
    }
}

//Нажатие на кнопку Изображения в панеле ресурсов
- (void)touchedImageButton:(id)sender
{
    if(_imageButton.enabled){
        if(_isImageHide){
            _isImageHide = NO;
            _isTextHide = YES;
            _isColorHide = YES;
            [_textView resignFirstResponder];
        }else {
            _isImageHide = YES;
        }
        [_delegate objectDidTouchImagePanel:(UIButton*)sender withHide:_isImageHide];
    }
}

//Нажатие на вид
- (void)handleTap:(UITapGestureRecognizer*)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    //проверка выделения
    if(_isSelected==NO){
        //проверка нажатия на доске объекта
        if(!CGRectContainsPoint(_dashbord.frame, location)){
            [(MMBorder*)self.superview handleTap:recognizer];
            return;
        }
        [self selectObject];
    }else {
        //проверка нажатия на кнопке Close
        if(CGRectContainsPoint(_closeButton.frame, location))
            [self touchedCloseButton:_closeButton];
        else 
        {
            CGPoint locationTool = [recognizer locationInView:_toolView];
            if(CGRectContainsPoint(_textButton.frame, locationTool))
                [self touchedTextButton:_textButton];
            else if (CGRectContainsPoint(_colorButton.frame, locationTool))
                [self touchedColorButton:_colorButton];
            else if (CGRectContainsPoint(_imageButton.frame, locationTool))
                [self touchedImageButton:_imageButton];
        }
    }
}

//Событие Пинч
- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer
{
    if(!_isSelected)
        return;
    if(!_isColorHide||!_isTextHide||!_isImageHide)
        return;
    
    CGPoint firstPoint = CGPointZero;
    CGPoint secondPoint = CGPointZero;
    int countTouches = [recognizer numberOfTouches];
    NSLog(@"count %d",countTouches);
    if(countTouches>1){
        firstPoint = [recognizer locationOfTouch:0 inView:self.superview.superview];
        secondPoint = [recognizer locationOfTouch:1 inView:self.superview.superview];
    }else
        return;
    CGFloat scaleWidth = abs(firstPoint.x-secondPoint.x);
    CGFloat scaleHeight = abs(firstPoint.y-secondPoint.y);
    
    //проверка на начала pincha
    if([recognizer state] == UIGestureRecognizerStateBegan){
        lastScaleWidth = scaleWidth;
        lastScaleHeight = scaleHeight;
        [_delegate objectWasChange:self];
        return;
    }
    
    if([recognizer state] == UIGestureRecognizerStateEnded){
        lastScaleWidth = 0;
        lastScaleHeight = 0;
        return;
    }
    
    //изменение размеров
    CGFloat dexWidth = scaleWidth - lastScaleWidth;
    CGFloat dexHeight = scaleHeight - lastScaleHeight;
    
    CGSize  newSize = CGSizeMake(_dashbord.frame.size.width+dexWidth , _dashbord.frame.size.height+dexHeight);
    [self makeSize:newSize withCenter:self.center];
    lastScaleHeight = scaleHeight;
    lastScaleWidth = scaleWidth;
    
    _isColorHide=YES;
    _isImageHide = YES;
    _isTextHide = YES;
    //[_delegate objectWillPinch:self];
}

//Событие перемещение объекта
- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        CGPoint location = [recognizer locationInView:self];
        for (UIView*item in _sizeButtons) {
            if(CGRectContainsPoint(item.frame, location)){
                _isResizing = YES;
                resizeID = item.tag;
                break;
            }
        }
    }else if (recognizer.state == UIGestureRecognizerStateEnded) {
        _isResizing = NO;
        resizeID = -1;
        return;
    }
    
    if(_isSelected){
        if (_isResizing&_isColorHide&_isTextHide&_isImageHide) {
            //перемещение объектов изменения размеров
            
            CGPoint mainLocation = [recognizer locationInView:self.superview];
            [self resizeObjectWhithPoint:mainLocation andTagID:resizeID];
            
        }else if(_isColorHide&_isImageHide&_isTextHide){
            //проверка начала перемещения
            CGPoint mainLocation = [recognizer locationInView:self.superview];
            if(recognizer.state == UIGestureRecognizerStateBegan){
                panDexX = mainLocation.x-self.center.x;
                panDexY = mainLocation.y-self.center.y;
                [_delegate objectWasChange:self];
            }
            //перемещение объекта
            MMBorder *border = (MMBorder*)self.superview;
            _isColorHide = YES;
            _isImageHide = YES;
            _isTextHide = YES;
            [_delegate objectWillMove:self];
            [self setCenter:CGPointMake(mainLocation.x-panDexX, mainLocation.y-panDexY)];
            
            //проверка перемещения по ширине
            if (self.frame.origin.x<0)
                [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
            else if (self.frame.origin.x+self.frame.size.width>border.frame.size.width)
                [self setFrame:CGRectMake(border.frame.size.width-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
            
            //проверка перемещения по высоте
            if (self.frame.origin.y<0)
                [self setFrame:CGRectMake(self.frame.origin.x, 0, self.frame.size.width, self.frame.size.height)];
            else if (self.frame.origin.y+self.frame.size.height>border.frame.size.height)
                [self setFrame:CGRectMake(self.frame.origin.x, border.frame.size.height-self.frame.size.height, self.frame.size.width, self.frame.size.height)];
        }
    }
}

//Изменение размеров Обекта в зависимости от кнопки изменения размера
- (void)resizeObjectWhithPoint:(CGPoint)location andTagID:(int)tagID
{
    CGPoint objCenter = self.center;
    float dexX=abs(_dashbord.center.x+self.frame.origin.x - location.x);
    float dexY=abs(_dashbord.center.y+self.frame.origin.y - location.y);
    switch (tagID) {
        case 3:
        case 5:{
            [self makeSize:CGSizeMake(dexX*2, _dashbord.frame.size.height) withCenter:objCenter];
            break;
        }
        case 1:
        case 2:{
            [self makeSize:CGSizeMake(_dashbord.frame.size.width, dexY*2) withCenter:objCenter];
            break;
        }
        default:{
            [self makeSize:CGSizeMake(dexX*2, dexY*2) withCenter:objCenter];
            break;
        }
    }
}

//изменение объектов
- (void)makeSize:(CGSize)_dashSize withCenter:(CGPoint)centerPoint
{
    
    //изменение размеров коробки
    [_dashbord setFrame:CGRectMake(_dashbord.frame.origin.x, _dashbord.frame.origin.y, 
                                   _dashSize.width, _dashSize.height)];
    [_textView setFrame:CGRectMake(0, 0, _dashbord.frame.size.width, _dashbord.frame.size.height)];
    [_textView setCenter:_dashbord.center];
    
    [_imageView setFrame:_dashbord.frame];
    
    //изменени видов изменения размеров
    for (UIView *item in _sizeButtons) {
        CGRect sFrame;
        if(item.tag==2)
            sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(7%3)-18, 
                                _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(7/3)-18, 36, 36);
        else if (item.tag==4)
            sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(8%3)-18, 
                                _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(8/3)-18, 36, 36);
        else 
            sFrame = CGRectMake(_dashbord.frame.origin.x+(_dashbord.frame.size.width/2)*(item.tag%3)-18, 
                                _dashbord.frame.origin.y+(_dashbord.frame.size.height/2)*(item.tag/3)-18, 36, 36);
        [item setFrame:sFrame];
    }
    
    //Изменение размеров объекта;
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 
                              _dashbord.frame.size.width+36, _dashbord.frame.size.height+18+10+45)];
    [_closeButton setCenter:CGPointMake(_dashbord.frame.size.width+_dashbord.frame.origin.x, _dashbord.frame.origin.y)];
    [_toolView setCenter:CGPointMake(self.frame.size.width/2, _dashbord.frame.origin.y+_dashbord.frame.size.height+_toolView.frame.size.height/2+10)];
    [self setCenter:centerPoint];
    
    //проверка на размер контента
    if(_dashSize.height<_textView.contentSize.height)
        [self makeSize:CGSizeMake(_dashSize.width, _textView.contentSize.height) withCenter:self.center];
}

-(void)observeValueForKeyPath:(NSString *)keyPath   ofObject:(id)object   change:(NSDictionary *)change   context:(void *)context
{
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])  / 2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

#pragma mark - Public methods

//Метод определения выделения
-(void)selectObject
{
    [_delegate objectWillSelected:self];
    _isSelected = YES;
    [_closeButton setHidden:NO];
    [_toolView setHidden:NO];
    for (UIView* item in _sizeButtons)
        [item setHidden:NO];
    
    MMBorder *_border = (MMBorder*)self.superview;
    if(!_border.isMakeMode){
        [_toolView setHidden:YES];
        [_closeButton setHidden:YES];
        
        [_imageButton setEnabled:NO];
        [_textButton setEnabled:NO];
        [_colorButton setEnabled:NO];
    }
}

//Метод определения отмены выделения
-(void)deselectObject
{
    [_delegate objectWillDeselected:self];
    _isSelected = NO;
    _isColorHide = YES;
    _isTextHide = YES;
    _isImageHide = YES;
    [_closeButton setHidden:YES];
    [_toolView setHidden:YES];
    for (UIView* item in _sizeButtons)
        [item setHidden:YES];
    
    [_textView resignFirstResponder];
    _textView.editable = NO;
}

//создание записи для журнала историй
-(NSDictionary*)getHistoryEntry
{
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    [entry setObject:NSStringFromCGRect(self.frame) forKey:@"obj_frame"];

    //[entry setObject:_dashbord.backgroundColor forKey:@"obj_color"];
    [entry setObject:[NSString stringWithFormat:@"%d",_colorID] forKey:@"obj_color"];
    
    [entry setObject:_textView.text forKey:@"obj_text"];
    [entry setObject:[NSString stringWithFormat:@"%f",_textView.font.pointSize] forKey:@"obj_font"];
    [entry setObject:[NSString stringWithFormat:@"%d",_textView.textAlignment] forKey:@"obj_aligment"];
    [entry setObject:_UUID forKey:@"obj_uuid"];
    [entry setObject:_imageName forKey:@"obj_image"];
    return entry;
}

//настройка соответственно журналу историй
-(void)configByEntry:(NSDictionary*)entry
{
    //установка размеров объекта и конфигурация панелей управления
    CGRect mainFrame = CGRectFromString([entry objectForKey:@"obj_frame"]);
    CGRect dashFrame = CGRectMake(18, 
                                  18, 
                                  mainFrame.size.width-36, 
                                  mainFrame.size.height-18-10-45);
    [self setFrame:mainFrame];
    [_dashbord setFrame:dashFrame];
    [_textView setFrame:dashFrame];
    [_imageView setFrame:dashFrame];
    [_closeButton setCenter:CGPointMake(_dashbord.frame.size.width+_dashbord.frame.origin.x, _dashbord.frame.origin.y)];
    [_toolView setCenter:CGPointMake(self.frame.size.width/2, _dashbord.frame.origin.y+_dashbord.frame.size.height+_toolView.frame.size.height/2+10)];
    
    [_colorButton setEnabled:YES];
    [_imageButton setEnabled:YES];
    [_textButton setEnabled:YES];
    
    //установка параметров конфигурации
    _colorID = [[entry objectForKey:@"obj_color"] intValue];
    switch (_colorID) {
        case 0:     [_dashbord setBackgroundColor:DEFAULT_OBJECT_COLOR];        break;
        case 1:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1]];      break;
        case 2:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.447 green:1.0 blue:0.3529 alpha:1]];      break;
        case 3:     [_dashbord setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1]];      break;
        case 4:     [_dashbord setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1]];      break;
        case 5:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.9725 green:1.0 blue:0.3255 alpha:1]];      break;
        case 6:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.0 green:0.8549 blue:1.0 alpha:1]];      break;
        case 7:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.0 green:0.5686 blue:1.0 alpha:1]];      break;
        case 8:     [_dashbord setBackgroundColor:[UIColor colorWithRed:1.0 green:0.5568 blue:0.0 alpha:1]];      break;
        case 9:     [_dashbord setBackgroundColor:[UIColor colorWithRed:1.0 green:0.847 blue:0.3843 alpha:1]];      break;
        case 10:     [_dashbord setBackgroundColor:[UIColor colorWithRed:1.0 green:0.3921 blue:1.0 alpha:1]];      break;
        case 11:     [_dashbord setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.5843 alpha:1]];      break;
        case 12:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.9607 green:1.0 blue:0.0 alpha:1]];      break;
        case 13:     [_dashbord setBackgroundColor:[UIColor colorWithRed:1.0 green:0.4196 blue:0.447 alpha:1]];      break;
        case 14:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.596 green:0.4431 blue:1.0 alpha:1]];      break;
        case 15:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1]];      break;
        case 16:     [_dashbord setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1]];      break;
    }
    
    NSString *_textV = [entry objectForKey:@"obj_text"];
    
    [_textView setText:_textV];
    if([_textView.text isEqualToString:@""])
        [_textView setHidden:YES];
    else{
        [_textView setHidden:NO];
        [_imageButton setEnabled:NO];
    }
    
    CGFloat sizeFN = [[entry objectForKey:@"obj_font"] floatValue];
    [_textView setFont:[UIFont systemFontOfSize:sizeFN]];
    
    [_textView setTextAlignment:[[entry objectForKey:@"obj_aligment"] intValue]];
    [self setUUID:[entry objectForKey:@"obj_uuid"]];
    _imageName = [entry objectForKey:@"obj_image"];
    if([_imageName isEqualToString:@"NULL"]){
        [_imageView setHidden:YES];
        [_imageView setImage:nil];
    }
    else {
        [_imageView setHidden:NO];
        UIImage *_im = [UIImage imageWithContentsOfFile:_imageName];
        [_imageView setImage:_im];
        [_colorButton setEnabled:NO];
        [_textButton setEnabled:NO];
    }
}

//Установка Изображения
-(void)setImageForObject:(UIImage*)_image
{    
    //проверка на наличие изображения
    if(_image!=nil){
        [_imageView setImage:_image];
        [_imageView setHidden:NO];
        [_dashbord setBackgroundColor:DEFAULT_OBJECT_COLOR];
        [_textButton setEnabled:NO];
        [_colorButton setEnabled:NO];
        //[_textView setText:@""];
        [_textView setHidden:YES];
        
        
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_tmp];
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        _imageName = [[MMObject createUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        _imageName = [_imageName stringByAppendingString:@".png"];
        _imageName = [[documentsDirectory stringByAppendingPathComponent:_imageName] retain];
        
        [UIImagePNGRepresentation(_image) writeToFile:_imageName atomically:YES];
    }else {
        _imageName = @"NULL";
        [_imageView setHidden:YES];
        [_textButton setEnabled:YES];
        [_colorButton setEnabled:YES];
        [_textView setHidden:NO];
    }
}

//Задаем высоту оффсета при отображении клавиатуры(начальная позиция курсора)
-(void)setCurentOffsetY:(CGFloat)_offsetY
{
//    curentOffsetY = _offsetY;
//    CGPoint origionText = _textView.frame.origin;
//    NSString *head = _textView.text;
//    if ([head isEqualToString:@""])
//        head = @"A";
//    else{
//        head = [_textView.text substringToIndex:_textView.selectedRange.location];
//    }
//    CGSize initialSize = [head sizeWithFont:_textView.font constrainedToSize:_textView.contentSize];
//    curentOffsetY += origionText.y+initialSize.height;
}

#pragma mark - UITextViewDelegate methods

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *newText;
    if([text isEqualToString:@"\n"])
        text = [text stringByAppendingString:@"A"];
    newText = [_textView.text stringByReplacingCharactersInRange:range withString:text];
    MMBorder *board = (MMBorder*)self.superview;
    
    UITextView *tempView = [[UITextView alloc] init];
    tempView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    tempView.font = textView.font;
    tempView.textAlignment = textView.textAlignment;
    tempView.frame = textView.frame;
    CGSize textSize = tempView.contentSize;
    tempView.text = newText;
    [tempView sizeToFit];
    textSize = tempView.contentSize;
    
    //textSize.height+=16;
    
    CGSize contentSize = textView.contentSize;
    CGSize textFrame = textView.frame.size;
    if(textSize.height>textFrame.height){
        //если размер текста превышает размер контент сайза
        CGFloat widthBoard = board.frame.size.width-36;
        CGFloat fontSize = textView.font.pointSize;
        tempView.frame = CGRectMake(tempView.frame.origin.x, tempView.frame.origin.y, contentSize.width+fontSize, tempView.frame.size.height);
        [tempView sizeToFit];
        textSize = tempView.contentSize;
        if((textSize.height>textFrame.height)||(contentSize.width+fontSize>widthBoard)){
            //если  высота неизменна
            //если ширина превышает размер допустимый
            if(textSize.height>236){
                [tempView release];
                return NO;
            }else{
                [self makeSize:CGSizeMake(_dashbord.frame.size.width, textSize.height) withCenter:self.center];
                [board setContentOffset:CGPointMake(board.contentOffset.x, self.frame.origin.y-5)];
            }
        }else{
            [self makeSize:CGSizeMake(contentSize.width+fontSize, _dashbord.frame.size.height) withCenter:self.center];
        }
    }
    [tempView release];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [_delegate objectWasChange:self];
    [_toolView setHidden:YES];
    
    NSString *head = _textView.text;
    if ([head isEqualToString:@""])
        head = @"A";
    else{
        head = [_textView.text substringToIndex:_textView.selectedRange.location];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    if([_textView.text isEqualToString:@""]){
        [_imageButton setEnabled:YES];
        [_imageView setHidden:NO];
    }else{
        [_imageButton setEnabled:NO];
        [_imageView setHidden:YES];
        _imageName = @"NULL";
        [_imageView setImage:nil];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [_textView resignFirstResponder];
    _textView.editable = NO;
    _isTextHide = YES;
    [_delegate objectDidTouchTextPanel:_textButton withHide:_isTextHide];
    
    NSLog(@"%d",_imageButton.retainCount);
    
    if([textView.text isEqualToString:@""]){
        [_imageButton setEnabled:YES];
        [_imageView setHidden:NO];
    }else{
        
        [_imageButton setEnabled:NO];
        [_imageView setHidden:YES];
        _imageName = @"NULL";
        [_imageView setImage:nil];
    }
    if(_isSelected)
        [_toolView setHidden:NO];
}

@end
