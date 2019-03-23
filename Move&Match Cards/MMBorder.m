//
//  MMBorder.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMBorder.h"
#import "Defines.h"


@interface MMBorder ()

-(void)handleDoubleTap:(UITapGestureRecognizer*)recognizer;
-(void)handlePan:(UIPanGestureRecognizer*)recognizer;

@end

@implementation MMBorder
@synthesize imagePanel = _imagePanel, historyDelegate=_historyDelegate, isMakeMode=_isMakeMode;
@synthesize colorPanel = _colorPanel, textPanel = _textPanel;
@synthesize objectsArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    _historyDelegate=nil;
    [objectsArray release];
    [super dealloc];
}

//Загрузка вида с Nib-файла
- (void)awakeFromNib
{
    _isMakeMode = YES;
    isEditingTextBox = NO;
    //Создание массива объектов
    objectsArray = [[NSMutableArray alloc] init];
    
    //Регистрирование события прикасания
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTap];
    [doubleTap release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tap setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tap];
    [tap release];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];
    [pan release];
    
    //Создание выскакивающих панелей
    _colorPanel = [[MMObjectColorPanel alloc] initWithNibName:@"MMObjectColorPanel" bundle:nil];
    [_colorPanel.view setHidden:YES];
    [self.superview addSubview:_colorPanel.view];
    
    _textPanel = [[MMObjectTextPanel alloc] initWithNibName:@"MMObjectTextPanel" bundle:nil];
    [_textPanel.view setHidden:YES];
    
    
    _textPanel.view.frame = CGRectMake(self.frame.size.width-self.contentOffset.x-_textPanel.view.frame.size.width, 
                                       self.frame.size.height-self.contentOffset.y-_textPanel.view.frame.size.height, 
                                       _textPanel.view.frame.size.width, _textPanel.view.frame.size.height);
    [self.superview addSubview:_textPanel.view];
    
    _imagePanel = [[MMObjectImagePanel alloc] initWithNibName:@"MMObjectImagePanel" bundle:nil];
    [_imagePanel.view setHidden:YES];
    [self.superview addSubview:_imagePanel.view];
    
    //Регистрация уведомлений отображения и скрытия клавиатуры
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Отображение клавиатуры
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if(isEditingTextBox){
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
        CGRect newRec = CGRectMake(_textPanel.view.frame.origin.x,
                                   _textPanel.view.frame.origin.y-kbSize.width+44,
                                   _textPanel.view.frame.size.width,
                                   _textPanel.view.frame.size.height); 
    
        _textPanel.view.frame = newRec;
        [_textPanel.view setHidden:NO];
    }
//    CGRect fr = self.frame;
//    CGFloat heightVisible = fr.size.height - kbSize.width;
//    self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y-heightVisible);
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    
}

//Нажатие пальцем на экране вида
-(void)handleTap:(UITapGestureRecognizer*)recognizer
{
    for (MMObject *item in objectsArray)
            [item deselectObject];
    [self setContentOffset:CGPointMake(0, 0)];
}

//Двойное нажатие пальцем на экране вида
- (void)handleDoubleTap:(UITapGestureRecognizer*)recognizer
{
    //определение нажатия на объекте или нет
    CGPoint position = [recognizer locationOfTouch:0 inView:self];
    BOOL isObjectPosition = NO;
    for (MMObject *obj in objectsArray) {
        CGRect objFrame = obj.dashbord.frame;
        objFrame.origin.x += obj.frame.origin.x;
        objFrame.origin.y += obj.frame.origin.y;
        if(CGRectContainsPoint(objFrame, position)){
            isObjectPosition = YES;
            break;
        }
    }
    
    if((_isMakeMode==YES)&(isObjectPosition==NO)){
        //Добавление объекта
        MMObject *obj = [self createObjectInBoard];
        obj.center = position;
    
        //создание записи
        NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
        [entry setObject:[obj getHistoryEntry] forKey:@"entry_body"];
        [entry setObject:@"history_obj_create" forKey:@"entry_type"];
        [_historyDelegate border:self withChanges:entry];
        [entry release];
    }
}

//Перемещение пальцем по доске
-(void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    //Деселект всех объектов
    for (MMObject* item in objectsArray) {
        [item deselectObject];
    }
    
//    CGPoint location = [recognizer translationInView:self];
//    if([recognizer state] == UIGestureRecognizerStateBegan){
//        firstX = location.x;
//        firstY = location.y;
//    } 
//    CGFloat distX = (location.x-firstX);
//    CGFloat distY = (location.y-firstY);
//    [self setContentOffset:CGPointMake(self.contentOffset.x-distX, self.contentOffset.y-distY)];
//        
//    firstX = location.x;
//    firstY = location.y;
//    
//    if(![_colorPanel.view isHidden]){
//        [_colorPanel.view setCenter:CGPointMake(_colorPanel.view.center.x+distX, _colorPanel.view.center.y+distY)];
//    }
//    if(![_textPanel.view isHidden]){
//        [_textPanel.view setCenter:CGPointMake(_textPanel.view.center.x+distX, _textPanel.view.center.y+distY)];
//    }
//    if(![_imagePanel.view isHidden]){
//        [_imagePanel.view setCenter:CGPointMake(_imagePanel.view.center.x+distX, _imagePanel.view.center.y+distY)];
//    }
}

//Создание объекта
-(MMObject*)createObjectInBoard
{
    //Добавление объекта
    MMObject *obj = [[MMObject alloc] initWithFrame:CGRectMake(0, 0, obj_width, obj_height)];
    obj.tag = 1111;
    obj.delegate = self;
    [self addSubview:obj];
    [obj selectObject];
    [objectsArray addObject:obj];
    return obj;
}

//Удаление объекта
-(void)deleteObjectFromBoard:(MMObject*)obj
{
    //удаление объекта
    [obj removeFromSuperview];
    [objectsArray removeObject:obj];
    
    //Скрытие панелей
    [_colorPanel.view setHidden:YES];
    [_imagePanel.view setHidden:YES];
    [_textPanel.view setHidden:YES];
}

//Удаление всех объектов
-(void)deleteAllObjectsFromBorder
{
    for (MMObject *item in objectsArray) {
        [item removeFromSuperview];
    }
    [objectsArray removeAllObjects];
    
    //Скрытие панелей
    [_colorPanel.view setHidden:YES];
    [_imagePanel.view setHidden:YES];
    [_textPanel.view setHidden:YES];
}

#pragma mark - MMObjectDelegate methods

//Событие удаления объекта
-(void)objectWillDeleted:(MMObject *)obj
{
    if(_isMakeMode==YES){
        //создание записи
        NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
        [entry setObject:[obj getHistoryEntry] forKey:@"entry_body"];
        [entry setObject:@"history_obj_delete" forKey:@"entry_type"];
        [_historyDelegate border:self withChanges:entry];
        [entry release];
    
        [self deleteObjectFromBoard:obj];
    }
}

//Событие выделение объекта
-(void)objectWillSelected:(MMObject *)obj
{
    for (MMObject *item in objectsArray) {
        if(item != obj)
            [item deselectObject];
    }
    [self bringSubviewToFront:obj];
    [_colorPanel setObject:obj];
    [_textPanel setObject:obj];
    [_textPanel analizeObject];
    [_imagePanel setObject:obj];
}

//Событие отмены выделения объекта
-(void)objectWillDeselected:(MMObject *)obj
{
    [_colorPanel.view setHidden:YES];
    [_imagePanel.view setHidden:YES];
    [_textPanel.view setHidden:YES];
    [_colorPanel setObject:nil];
    [_textPanel setObject:nil];
    [_imagePanel setObject:nil];
}

//Событие перемещения объекта
-(void)objectWillMove:(MMObject *)obj
{
    [_textPanel.view setHidden:YES];
    [_colorPanel.view setHidden:YES];
    [_imagePanel.view setHidden:YES];
}

//Событие нажатия на кнопку цвета (панель утилит)
-(void)objectDidTouchColorPanel:(UIButton *)sender withHide:(BOOL)isHide
{
    if(!isHide){
        CGRect obj_panel_frame = sender.superview.frame;
        CGRect obj_frame = sender.superview.superview.frame;
        CGPoint bord_offset = self.contentOffset;
        CGRect button_popUp_frame = CGRectMake(obj_frame.origin.x+obj_panel_frame.origin.x+sender.frame.origin.x-bord_offset.x, 
                                           obj_frame.origin.y+obj_panel_frame.origin.y+sender.frame.origin.y-bord_offset.y+self.frame.origin.y, 
                                           sender.frame.size.width, sender.frame.size.height);
        
        [_colorPanel.view setCenter:CGPointMake(button_popUp_frame.origin.x+button_popUp_frame.size.width/2, 
                                                button_popUp_frame.origin.y+button_popUp_frame.size.height+_colorPanel.view.frame.size.height/2)];
        
        CGRect colorPanelFrame = _colorPanel.view.frame;
        CGFloat dexVY = (colorPanelFrame.origin.y+colorPanelFrame.size.height)-self.frame.size.height-44;
        if(dexVY>0){
            self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y+dexVY);
            [_colorPanel.view setCenter:CGPointMake(_colorPanel.view.center.x, _colorPanel.view.center.y-dexVY)];
        }
        if(colorPanelFrame.origin.x<0){
            self.contentOffset = CGPointMake(self.contentOffset.x+colorPanelFrame.origin.x, self.contentOffset.y);
            [_colorPanel.view setCenter:CGPointMake(_colorPanel.view.center.x-colorPanelFrame.origin.x, _colorPanel.view.center.y)];
        }
        
        [_textPanel.view setHidden:YES];
        [_imagePanel.view setHidden:YES];
    }else{
            [self setContentOffset:CGPointMake(0, 0)];
    }
    [_colorPanel.view setHidden:isHide];
}

//Событие нажатия на кнопку текста (панель утилит)
-(void)objectDidTouchTextPanel:(UIButton *)sender withHide:(BOOL)isHide
{
    if(!isHide){
        MMObject *object = (MMObject*)sender.superview.superview;
        CGFloat offsetX = object.frame.origin.x;
        CGFloat offsetY = object.frame.origin.y;
        
        //нахождение X
        offsetX=offsetX-(self.frame.size.width-object.frame.size.width)/2;
        
        //нахождение Y
        offsetY=offsetY-5;
        
        //установка offset
        [self setContentOffset:CGPointMake(offsetX, offsetY)];
        [object setCurentOffsetY:offsetY];
        
        //перемещение и скрытие панелей изменений
        NSLog(@"%@",NSStringFromCGPoint([self contentOffset]));
        CGRect newRect = CGRectMake(self.frame.size.width-_textPanel.view.frame.size.width, 
                                    self.frame.size.height-_textPanel.view.frame.size.height, 
                                    _textPanel.view.frame.size.width, _textPanel.view.frame.size.height);
        _textPanel.view.frame = newRect;
        [_colorPanel.view setHidden:YES];
        [_imagePanel.view setHidden:YES];
        isEditingTextBox = YES;
    }else{
        [_textPanel.view setHidden:isHide];
        isEditingTextBox = NO;
        [self setContentOffset:CGPointMake(0, 0)];
    }
}

//Событие нажатия на кнопку изображения (панель утилит)
-(void)objectDidTouchImagePanel:(UIButton *)sender withHide:(BOOL)isHide
{
    if(!isHide){
        CGRect obj_panel_frame = sender.superview.frame;
        CGRect obj_frame = sender.superview.superview.frame;
        CGPoint bord_offset = self.contentOffset;
        CGRect button_popUp_frame = CGRectMake(obj_frame.origin.x+obj_panel_frame.origin.x+sender.frame.origin.x-bord_offset.x, 
                                               obj_frame.origin.y+obj_panel_frame.origin.y+sender.frame.origin.y-bord_offset.y+self.frame.origin.y, 
                                               sender.frame.size.width, sender.frame.size.height);
        
        [_imagePanel.view setCenter:CGPointMake(button_popUp_frame.origin.x+button_popUp_frame.size.width/2, 
                                               button_popUp_frame.origin.y+button_popUp_frame.size.height+_imagePanel.view.frame.size.height/2)];
        
        CGRect colorPanelFrame = _imagePanel.view.frame;
        CGFloat dexVY = (colorPanelFrame.origin.y+colorPanelFrame.size.height)-self.frame.size.height-44;
        if(dexVY>0){
            self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y+dexVY);
            [_imagePanel.view setCenter:CGPointMake(_imagePanel.view.center.x, _imagePanel.view.center.y-dexVY)];
        }
        
        CGFloat dexVX = (colorPanelFrame.origin.x+colorPanelFrame.size.width)-self.frame.size.width;
        if(colorPanelFrame.origin.x<0){
            self.contentOffset = CGPointMake(self.contentOffset.x+colorPanelFrame.origin.x, self.contentOffset.y);
            [_imagePanel.view setCenter:CGPointMake(_imagePanel.view.center.x-colorPanelFrame.origin.x, _imagePanel.view.center.y)];
        }else if(dexVX>0){
            self.contentOffset = CGPointMake(self.contentOffset.x+dexVX, self.contentOffset.y);
            [_imagePanel.view setCenter:CGPointMake(_imagePanel.view.center.x-dexVX, _imagePanel.view.center.y)];
        }
        
        [_colorPanel.view setHidden:YES];
        [_textPanel.view setHidden:YES];
    }else{
        [self setContentOffset:CGPointMake(0, 0)];
    }
    MMObject *obj = (MMObject*)sender.superview.superview;
    if(!(obj.imageView.image==nil)){
        [_imagePanel.chooseBut setEnabled:NO];
        [_imagePanel.takeBut setEnabled:NO];
        [_imagePanel.deleteBut setEnabled:YES];
    }else {
        [_imagePanel.chooseBut setEnabled:YES];
        [_imagePanel.takeBut setEnabled:YES];
        [_imagePanel.deleteBut setEnabled:NO];
    }
    [_imagePanel.view setHidden:isHide];
}

//Событие Pinch с объектом
- (void)objectWillPinch:(MMObject *)obj
{
    [_colorPanel.view setHidden:YES];
    [_textPanel.view setHidden:YES];
    [_imagePanel.view setHidden:YES];
}

//Объект был изменен
- (void)objectWasChange:(MMObject *)obj
{
    //Создание записи в список истории
    NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
    [entry setObject:[obj getHistoryEntry] forKey:@"entry_body"];
    [entry setObject:@"history_obj_change" forKey:@"entry_type"];
    [_historyDelegate border:self withChanges:entry];
    [entry release];
}

@end
