//
//  MMViewController.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 02.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MMViewController.h"


@interface MMViewController ()

-(void)configImagePickerControllers;
-(void)configToolbarPanels;
-(void)configToolbarTitle;

-(void)hidenLogoView;

-(void)setImageForObject:(UIImage*)_imageObj;

-(BOOL)checkSavingFile:(NSString*)_fileName;
-(void)savingDocumentInFile:(NSString*)_fileName;
-(void)savingDocumentInFile2:(NSString*)_fileName;
-(void)deleteDocumentInFile:(NSString*)_fileName;
-(void)loadingDocumentFromFile:(NSString*)_fileName;
-(void)createNewDocumentProject;

-(NSData*)createProjectFile;
-(UIImage*)createImage;
-(UIImage*)createImage2;
-(NSData*)createPDFDocument;
-(NSData*)createPDFDocument2;

-(void)startOperation:(SEL)_selector withObject:(id)obj;
-(void)endOperation;

-(void)openDocumentFromFile:(NSString*)docName;

@end



@implementation MMViewController
@synthesize borderView=_borderView;

- (void)dealloc
{
    [historyArray release];
    [_colorPopoverController release];
    [_sharePopoverController release];
    [_openPopoverController release];
    [_openController release];
    [_titleButton release];
    [_alertSave release];
    [_alertTitle release];
    [_alertResave release];
    [_titleField release];
    [_saveField release];
    [_documentName release];
    [_operations release];
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
    _borderView.isMakeMode = YES;
    _documentName = @"";
    _colorIndex = 1;
    isCreateButtonTouched=NO;
    isOpenDocumentTouched=NO;
    
    //Создание контролера за операциями
    _operations = [[NSOperationQueue alloc] init];
    //[_operations setMaxConcurrentOperationCount:2];
    
    //Установка делегата учета истории и 
    //создание массива хранения записей с индексироанием.
    _borderView.historyDelegate = self;
    historyArray = [[NSMutableArray alloc] init];
    historyIndex = [historyArray count]-1;
    
    [self configImagePickerControllers];
    [self configToolbarPanels];
    [self configToolbarTitle];
    
    //Задаем размер бордера и его контента
    CGSize content = CGSizeMake(_borderView.frame.size.width, _borderView.frame.size.height);
    [_borderView setContentSize:content];
    //[_borderView setContentOffset:CGPointMake((content.width-_borderView.frame.size.width)/2, (content.height-_borderView.frame.size.height)/2)];
    
    //анимация
    [_buttonUse setHidden:NO];
    [_buttonMake setHidden:NO];
    [UIView beginAnimations:@"show interfase" context:nil];
    [UIView setAnimationDuration:1.0];
    [_buttonMake setAlpha:1.0];
    [_buttonUse setAlpha:1.0];
    CGRect borderFrame = _borderView.frame;
    borderFrame = CGRectMake(borderFrame.origin.x,
                             borderFrame.origin.y+_toolBar.frame.size.height, 
                             borderFrame.size.width, 
                             borderFrame.size.height-_toolBar.frame.size.height);
    [_borderView setFrame:borderFrame];
    [UIView commitAnimations];
}

//отображение вида на экране(Загрузка интерфейса)
- (void)viewDidAppear:(BOOL)animated
{
//    [_buttonUse setHidden:NO];
//    [_buttonMake setHidden:NO];
//    [UIView beginAnimations:@"show interfase" context:nil];
//    [UIView setAnimationDuration:1.0];
//    [_buttonMake setAlpha:1.0];
//    [_buttonUse setAlpha:1.0];
//    CGRect borderFrame = _borderView.frame;
//    borderFrame = CGRectMake(borderFrame.origin.x,
//                             borderFrame.origin.y+_toolBar.frame.size.height, 
//                             borderFrame.size.width, 
//                             borderFrame.size.height-_toolBar.frame.size.height);
//    [_borderView setFrame:borderFrame];
//    [UIView commitAnimations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

#pragma mark - Private methods of class

//создание и настройка UIImagePickerControllers объектов
-(void)configImagePickerControllers
{
    //Создание ImagePickerController;
    //_objectImagePicker = [[UIImagePickerController alloc] init];
    _borderView.imagePanel.delegate = self;
    //[_objectImagePicker setDelegate:self];
    //_objectImagePopover = [[UIPopoverController alloc] init];
    //[_objectImagePopover setPopoverContentSize:_objectImagePicker.view.frame.size];
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = self;
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePopover = [[UIPopoverController alloc] initWithContentViewController:_imagePicker];
    //[_imagePopover setPopoverContentSize:_imagePicker.view.frame.size];
}

//конфигурация панелей тулбара (UIPopoverControllers)
-(void)configToolbarPanels
{
    //Создание панели выбора цвета стола
    MMColorViewController *colorContr = [[MMColorViewController alloc] initWithNibName:@"MMColorViewController" bundle:nil];
    colorContr.delegate=self;
    _colorPopoverController = [[UIPopoverController alloc] initWithContentViewController:colorContr];
    [_colorPopoverController setPopoverContentSize:colorContr.view.frame.size];
    [colorContr release];
    
    //Создание панели шаринга
    MMShareViewController *shareContr = [[MMShareViewController alloc] initWithNibName:@"MMShareViewController" bundle:nil];
    shareContr.delegate = self;
    _sharePopoverController = [[UIPopoverController alloc] initWithContentViewController:shareContr];
    [_sharePopoverController setPopoverContentSize:shareContr.view.frame.size];
    [shareContr release];
    
    //Создание панели загрузки файла
    _openController = [[MMOpenViewController alloc] initWithNibName:@"MMOpenViewController" bundle:nil];
    _openController.delegate = self;
    _openPopoverController = [[UIPopoverController alloc] initWithContentViewController:_openController];
    [_openPopoverController setPopoverContentSize:_openController.view.frame.size];
    
    //Создание панели алертов для изменения 
    //титула документа и сохранения документа
    _titleField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [_titleField setBackgroundColor:[UIColor whiteColor]];
    [_titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_titleField setText:_documentName];
    
    _saveField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [_saveField setBackgroundColor:[UIColor whiteColor]];
    [_saveField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_saveField setText:_documentName];
    
    _alertTitle = [[UIAlertView alloc] initWithTitle:@"Project Name" message:@"this gets covered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [_alertTitle addSubview:_titleField];
    _alertSave = [[UIAlertView alloc] initWithTitle:@"Save Project" message:@"this gets covered" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [_alertSave addSubview:_saveField];
    _alertResave = [[UIAlertView alloc] initWithTitle:@"" message:@"This file exists.\nReplace it?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    _alertNewProject = [[UIAlertView alloc] initWithTitle:@"Do you want to save changes?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",@"No", nil];
    _alertOpenProject = [[UIAlertView alloc] initWithTitle:@"Do you want to save changes?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",@"No", nil];
    _alertWarningResave = [[UIAlertView alloc] initWithTitle:@"All Recent changes will not be saved.\nDo you wish to continue?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    _alertWarningHome = [[UIAlertView alloc] initWithTitle:@"Would you like to exit the project?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    _alertError = [[UIAlertView alloc] initWithTitle:@"Please enter name of Project" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

//конфигурация титула тулбара
-(void)configToolbarTitle
{
    //Создание и настройка Заголовка    
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleButton.frame = CGRectMake(0, 11.0f, self.view.frame.size.width/2, 21);
    [_titleButton setTitle:_documentName forState:UIControlStateNormal];
    [_titleButton addTarget:self action:@selector(touchedTitle:) forControlEvents:UIControlEventTouchUpInside];
    
    //Добавление Заголовка в тулбар
    NSMutableArray *items = [[_toolBar items] mutableCopy];
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:_titleButton];
    [items insertObject:title atIndex:5];
    [title release];
    [_toolBar setItems:items animated:YES];
    [items release];
}

//Спрятать логотип и кнопки
-(void)hidenLogoView
{
    [UIView beginAnimations:@"hideLogo" context:nil];
    [UIView setAnimationDuration:0.5];
    [_logoView setAlpha:0];
    [_buttonMake setAlpha:0];
    [_buttonUse setAlpha:0];
    [_homeButton setAlpha:1];
    [_borderView setHidden:NO];
    [_toolBar setFrame:CGRectMake(_toolBar.frame.origin.x, 0, _toolBar.frame.size.width, _toolBar.frame.size.height)];
    [UIView commitAnimations];
}

//Установка изображения для объекта
-(void)setImageForObject:(UIImage *)_imageObj
{
    //создание записи в журнале истории
    NSMutableDictionary *_entry = [NSMutableDictionary dictionary];
    [_entry setObject:[_borderView.imagePanel.object getHistoryEntry] forKey:@"entry_body"];
    [_entry setObject:@"history_obj_change" forKey:@"entry_type"];
    [self border:_borderView withChanges:_entry];
    
    //установка нового изображения
    //[_borderView.imagePanel.object setImageForObject:_imageObj];
    [_borderView.imagePanel.object performSelectorOnMainThread:@selector(setImageForObject:) withObject:_imageObj waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(endOperation) withObject:nil waitUntilDone:YES];
}

//Проверка на наличиу существующего файла
-(BOOL)checkSavingFile:(NSString *)_fileName
{
    BOOL isFile = NO;
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_document];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MoveAndMatch",_fileName]];
    isFile = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return isFile;
}

//Сохранение документа
-(void)savingDocumentInFile:(NSString *)_fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_document];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_fileName];
    
    //Создание директории проекта
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //Формирование массива со значениями объектов
    NSMutableDictionary *savingData = [[NSMutableDictionary alloc] init];
    NSMutableArray *savingObjects = [[NSMutableArray alloc] init];
    for (int i=0; i<[_borderView.objectsArray count]; i++) {
        MMObject *item = [_borderView.objectsArray objectAtIndex:i];
        NSMutableDictionary *itemEntery = (NSMutableDictionary*)[item getHistoryEntry];
        NSString *imageName = [itemEntery objectForKey:@"obj_image"];
        if(![imageName isEqualToString:@"NULL"]){
            imageName = [imageName lastPathComponent];
            imageName = [filePath stringByAppendingPathComponent:imageName];
            [UIImagePNGRepresentation(item.imageView.image) writeToFile:imageName atomically:YES];
            [itemEntery setObject:imageName forKey:@"obj_image"];
        }
        [savingObjects addObject:itemEntery];
    }
    NSString *plistPath = [filePath stringByAppendingPathComponent:_fileName];
    plistPath = [plistPath stringByAppendingString:@".plist"];
    NSLog(@"%@",plistPath);
    //[fileManager createFileAtPath:plistPath contents:nil attributes:nil];
    
    [savingData setObject:savingObjects forKey:@"objects"];
    //сохранение бакграунда
    if(_colorIndex>0){
        [savingData setObject:[NSString stringWithFormat:@"%d",_colorIndex] forKey:@"background_color"];
    }else {
        [savingData setObject:[NSString stringWithFormat:@"%d",_colorIndex] forKey:@"background_color"];
        NSString *background_name = [_imageBackgraundName lastPathComponent];
        background_name = [filePath stringByAppendingPathComponent:background_name];
        [UIImagePNGRepresentation(_borderImageView.image) writeToFile:background_name atomically:YES];
        [savingData setObject:background_name forKey:@"background_name"];
    }

    [savingData writeToFile:plistPath atomically:YES];
    [self clearHistory];
    if(isCreateButtonTouched){
        isCreateButtonTouched = NO;
        [self performSelectorOnMainThread:@selector(createNewDocumentProject) withObject:nil waitUntilDone:YES];
    }else if (isOpenDocumentTouched) {
        isOpenDocumentTouched = NO;
        [self performSelectorOnMainThread:@selector(openDocumentFromFile:) withObject:_openDocumentName waitUntilDone:NO];
    }
    
    [self performSelectorOnMainThread:@selector(endOperation) withObject:nil waitUntilDone:YES];
}

-(void)savingDocumentInFile2:(NSString*)_fileName
{
    NSLog(@"%@",_fileName);
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_document];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MoveAndMatch",_fileName]];
    
    NSData *_fileData = [self createProjectFile];
    
    BOOL isFile = [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory];
    if(!isFile)
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSError *error;
    [_fileData writeToFile:filePath options:NSDataWritingAtomic error:&error];
//    if(error!=nil)
//        NSLog(@"%@",error);
    
    [self clearHistory];
    if(isCreateButtonTouched){
        isCreateButtonTouched = NO;
        [self performSelectorOnMainThread:@selector(createNewDocumentProject) withObject:nil waitUntilDone:YES];
    }else if (isOpenDocumentTouched) {
        isOpenDocumentTouched = NO;
        [self performSelectorOnMainThread:@selector(openDocumentFromFile:) withObject:_openDocumentName waitUntilDone:NO];
    }
    
    [self performSelectorOnMainThread:@selector(endOperation) withObject:nil waitUntilDone:YES];
}

//удаление документа
-(void)deleteDocumentInFile:(NSString*)_fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_document];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_fileName];
    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    for (NSString *file in files) {
        [fileManager removeItemAtPath: [filePath stringByAppendingPathComponent:file] error:nil];
    }
}

//Загрузка документа с файла
-(void)loadingDocumentFromFile:(NSString*)_fileName
{
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_document];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_fileName];
    
    NSString *plistPath = [filePath stringByAppendingPathComponent:_fileName];
    plistPath = [plistPath stringByAppendingString:@".plist"];
    
    //загрузка бэграунда
    NSDictionary *fileData = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    _colorIndex = [[fileData objectForKey:@"background_color"] intValue];
    if(_colorIndex>0){
        [_borderImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Background_Color%d.png",_colorIndex]]];
    }else {
        _imageBackgraundName = [fileData objectForKey:@"background_name"];
        UIImage *img = [UIImage imageWithContentsOfFile:_imageBackgraundName];
        [_borderImageView setImage:img];
    }
    
    //Загрузка объектов
    NSMutableArray *entryArray = [fileData objectForKey:@"objects"];
    for (NSDictionary *entry in entryArray) {
        MMObject *_obj = [_borderView createObjectInBoard];
        //[_obj configByEntry:entry];
        [_obj performSelectorOnMainThread:@selector(configByEntry:) withObject:entry waitUntilDone:YES];
        [_obj deselectObject];
    }
    
    if(!_borderView.isMakeMode){
        [self hidenLogoView];
        [_borderView setUserInteractionEnabled:YES];
        _documentName = _fileName;
        [_titleButton setTitle:_documentName forState:UIControlStateNormal];
        
        [_toolButton1 setEnabled:YES];
        [_toolButton4 setEnabled:YES];
        [_toolButton5 setEnabled:NO];
        [_toolButton6 setEnabled:YES];
        [_toolButton7 setEnabled:YES];
        [_toolButton8 setEnabled:YES];
        
        [_toolButton2 setEnabled:NO];
        [_toolButton3 setEnabled:NO];
    }
    
    [self performSelectorOnMainThread:@selector(endOperation) withObject:nil waitUntilDone:YES];
}

-(void)loadingDocumentFromFile2:(NSString*)_fileName
{
    [_openPopoverController dismissPopoverAnimated:YES];
    NSString *filePath = _fileName;
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:fileData];
    
    NSMutableArray *objcs = [unarchiver decodeObject];
    NSData *_bordImageData = [unarchiver decodeObject];
    [unarchiver finishDecoding];
    
    [_borderView deleteAllObjectsFromBorder];
    for (MMObject *item in objcs) {
        item.delegate = _borderView;
        [_borderView.objectsArray addObject:item];
        [_borderView addSubview:item];
    }
    UIImage* _bordImage = [UIImage imageWithData:_bordImageData];
    [_borderImageView setImage:_bordImage];
    
    if(!_borderView.isMakeMode){
        [self hidenLogoView];
        [_borderView setUserInteractionEnabled:YES];
        
        [_toolButton1 setEnabled:YES];
        [_toolButton4 setEnabled:YES];
        [_toolButton5 setEnabled:NO];
        [_toolButton6 setEnabled:YES];
        [_toolButton7 setEnabled:YES];
        [_toolButton8 setEnabled:YES];
        
        [_toolButton2 setEnabled:NO];
        [_toolButton3 setEnabled:NO];
    }
    
    [self performSelectorOnMainThread:@selector(endOperation) withObject:nil waitUntilDone:YES];
}

//Создание нового проекта
-(void)createNewDocumentProject
{
    //очистка от объектов и истории
    [self clearHistory];    
    [_borderView deleteAllObjectsFromBorder];
    
    //задаем новое название документа
    //_documentName = @"New Project";
    [_titleButton setTitle:_documentName forState:UIControlStateNormal];
    [_borderImageView setImage:[UIImage imageNamed:@"Background.png"]];
    
    [_titleField setText:_documentName];
    [_alertTitle show];
}

//Очистка истории и удаление папки Temp
-(void)clearHistory
{
    //удаление истории 
    [historyArray removeAllObjects];
    historyIndex = [historyArray count]-1;
    [_toolButton2 setEnabled:NO];
    [_toolButton3 setEnabled:NO];
    
    //очистка папки temp
    NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:path_tmp];
    [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
}

//создание файла архива(Для отправки по почте)
-(NSData*)createProjectFile
{
    //архивация массива объектов и изображения в данные
    NSMutableData *archiveData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiveData];
    //[archiver encodeRootObject:_borderView.objectsArray];
    [archiver performSelectorOnMainThread:@selector(encodeRootObject:) withObject:_borderView.objectsArray waitUntilDone:YES];
    [archiver encodeObject:UIImagePNGRepresentation(_borderImageView.image)];
    [archiver finishEncoding];
    [archiver release];
    
    return archiveData;
}

//Создание изображения
-(UIImage*)createImage
{
    UIImage *image = nil;
    CGFloat minX = _borderView.contentSize.width;
    CGFloat minY = _borderView.contentSize.height;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    CGFloat widthMAX = 0;
    CGFloat heightMAx = 0;
    
    UIView *_imView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, minX, minY)];
    UIImageView *_bordView = [[UIImageView alloc] initWithImage:_borderImageView.image];
    _bordView.frame = CGRectMake(0, 0, _borderView.frame.size.width, _borderView.frame.size.height);
    [_bordView setContentMode:UIViewContentModeScaleAspectFill];
    _bordView.tag = 22222;
    [_imView addSubview:_bordView];
    
    for (MMObject *item in _borderView.objectsArray) {
        if(item.frame.origin.x<minX)
            minX = item.frame.origin.x;
        if(item.frame.origin.y<minY)
            minY = item.frame.origin.y;
        if(item.frame.origin.x>maxX){
            maxX = item.frame.origin.x;
            widthMAX = item.frame.size.width;
        }
        if(item.frame.origin.y>maxY){
            maxY = item.frame.origin.y;
            heightMAx = item.frame.size.height;
        }
        [item setTag:11111];
        [_imView addSubview:item];
    }
    
    _imView.frame = CGRectMake(0, 0, (maxX-minX)+widthMAX+20, (maxY-minY)+heightMAx+20);
    [_imView setBackgroundColor:[UIColor clearColor]];
    
    for (UIView *obj in _imView.subviews) {
        if (obj.tag==11111) {
            NSLog(@"%@",NSStringFromCGRect(obj.frame));
            obj.frame =  CGRectMake(obj.frame.origin.x-minX+10, obj.frame.origin.y-minY+10, obj.frame.size.width, obj.frame.size.height);
        }
    }
    
    _bordView.frame = CGRectMake(_bordView.frame.origin.x-(minX-_borderView.contentOffset.x+10), 
                                 _bordView.frame.origin.y-(minY-_borderView.contentOffset.y+10), 
                                 _borderView.frame.size.width, _borderView.frame.size.height);
    
    UIGraphicsBeginImageContext(_imView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-(int)pt.x, -(int)pt.y));
    [_imView.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Возвращаем в нормальное положение!!!
    for (UIView *obj in _imView.subviews) {
        if (obj.tag==11111) {
            obj.frame =  CGRectMake(obj.frame.origin.x+minX-10, obj.frame.origin.y+minY-10, obj.frame.size.width, obj.frame.size.height);
            NSLog(@"%@",NSStringFromCGRect(obj.frame));
        }
    }
    
    [_imView release];    
    
    return image;
}

-(UIImage*)createImage2
{
    UIImage *image;
    CGSize contSize = CGSizeMake(_borderView.frame.size.height, _borderView.frame.size.width);
    
    UIGraphicsBeginImageContext(contSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_borderImageView.layer renderInContext:context];
    [_borderView.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(NSData*)createPDFDocument
{
    NSMutableData *pdfData = [NSMutableData data];
    CGFloat minX = _borderView.contentSize.width;
    CGFloat minY = _borderView.contentSize.height;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    CGFloat widthMAX = 0;
    CGFloat heightMAx = 0;
    
    UIView *_imView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, minX, minY)];
    UIImageView *_bordView = [[UIImageView alloc] initWithImage:_borderImageView.image];
    _bordView.frame = CGRectMake(0, 0, _borderView.frame.size.width, _borderView.frame.size.height);
    [_bordView setContentMode:UIViewContentModeScaleAspectFill];
    _bordView.tag = 22222;
    [_imView addSubview:_bordView];
    
    for (MMObject *item in _borderView.objectsArray) {
        if(item.frame.origin.x<minX)
            minX = item.frame.origin.x;
        if(item.frame.origin.y<minY)
            minY = item.frame.origin.y;
        if(item.frame.origin.x>maxX){
            maxX = item.frame.origin.x;
            widthMAX = item.frame.size.width;
        }
        if(item.frame.origin.y>maxY){
            maxY = item.frame.origin.y;
            heightMAx = item.frame.size.height;
        }
        [item setTag:11111];
        [_imView addSubview:item];
    }
    
    _imView.frame = CGRectMake(0, 0, (maxX-minX)+widthMAX+20, (maxY-minY)+heightMAx+20);
    [_imView setBackgroundColor:[UIColor clearColor]];
    
    for (UIView *obj in _imView.subviews) {
        if (obj.tag==11111) {
            NSLog(@"%@",NSStringFromCGRect(obj.frame));
            obj.frame =  CGRectMake(obj.frame.origin.x-minX+10, obj.frame.origin.y-minY+10, obj.frame.size.width, obj.frame.size.height);
        }
    }
    
    _bordView.frame = CGRectMake(_bordView.frame.origin.x-(minX-_borderView.contentOffset.x+10), 
                                 _bordView.frame.origin.y-(minY-_borderView.contentOffset.y+10), 
                                 _borderView.frame.size.width, _borderView.frame.size.height);
    
    UIGraphicsBeginPDFContextToData(pdfData, _imView.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    [_imView.layer renderInContext:pdfContext];
    UIGraphicsEndPDFContext();
    
    //Возвращаем в нормальное положение!!!
    for (UIView *obj in _imView.subviews) {
        if (obj.tag==11111) {
            obj.frame =  CGRectMake(obj.frame.origin.x+minX-10, obj.frame.origin.y+minY-10, obj.frame.size.width, obj.frame.size.height);
            NSLog(@"%@",NSStringFromCGRect(obj.frame));
        }
    }
    
    [_imView release];
    return pdfData;
}

-(NSData*)createPDFDocument2
{
    NSMutableData *pdfData = [NSMutableData data];
    CGRect pdfBounds = CGRectMake(0, 0, _borderView.frame.size.width, _borderView.frame.size.height);
    UIGraphicsBeginPDFContextToData(pdfData, pdfBounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    [_borderImageView.layer renderInContext:pdfContext];
    [_borderView.layer renderInContext:pdfContext];
    UIGraphicsEndPDFContext();
    return pdfData;
}

//Начало операции
-(void)startOperation:(SEL)_selector withObject:(id)obj
{
    [self.view setUserInteractionEnabled:NO];
    [_activity show];
    
    NSInvocationOperation *oper = [[NSInvocationOperation alloc] initWithTarget:self selector:_selector object:obj];
    [_operations addOperation:oper];
    [oper release];
}

//Конец операции
-(void)endOperation
{
    [self.view setUserInteractionEnabled:YES];
    [_activity hide];
}

#pragma mark - Public methods of class

//нажатие на кнопку Home
-(IBAction)touchedHome:(id)sender
{
    if ([historyArray count]>0) {
        [_alertWarningHome show];
    }else{
        [UIView beginAnimations:@"showMenu" context:nil];
        [UIView setAnimationDuration:0.5];
        [_logoView setAlpha:1];
        [_buttonMake setAlpha:1];
        [_buttonUse setAlpha:1];
        [_homeButton setAlpha:0];
        [_toolBar setFrame:CGRectMake(_toolBar.frame.origin.x, _toolBar.frame.origin.y-44, _toolBar.frame.size.width, _toolBar.frame.size.height)];
        [_borderImageView setImage:[UIImage imageNamed:@"Background.png"]];
        [_borderView setHidden:YES];
        [_borderView.colorPanel.view setHidden:YES];
        [_borderView.textPanel.view setHidden:YES];
        [_borderView.imagePanel.view setHidden:YES];
        [UIView commitAnimations];
    }
}

//нажатие на кнопку Make
-(IBAction)touchedMake:(id)sender
{
    _borderView.isMakeMode = YES;
    [self hidenLogoView];
    [_borderView setUserInteractionEnabled:YES];
    [self createNewDocumentProject];
    
    [_toolButton1 setEnabled:YES];
    [_toolButton4 setEnabled:YES];
    [_toolButton5 setEnabled:YES];
    [_toolButton6 setEnabled:YES];
    [_toolButton7 setEnabled:YES];
    [_toolButton8 setEnabled:YES];
    
    [_toolButton2 setEnabled:NO];
    [_toolButton3 setEnabled:NO];
}

//нажатие на кнопку Use
-(IBAction)touchedUse:(id)sender
{
    _borderView.isMakeMode = NO;
    [_borderView deleteAllObjectsFromBorder];
    [self clearHistory];
    [self tochedNavigButton1:_toolButton1];
}

//нажатие на титл проекта
-(void)touchedTitle:(id)sender
{
    [_titleField setText:_documentName];
    [_alertTitle show];
}

//Нажатие на 1 кнопку в навигации (Forlders)
-(IBAction)tochedNavigButton1:(id)sender
{
    for (MMObject *item in _borderView.objectsArray) {
        [item deselectObject];
    }
    
    [_openController loadingDocumentsArray];
    if([_openPopoverController isPopoverVisible])
        [_openPopoverController dismissPopoverAnimated:YES];
    else {
        CGRect openPopover = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        [_openPopoverController presentPopoverFromRect:openPopover inView:self.view permittedArrowDirections:0 animated:YES];
    }
}

//Нажатие на 2 кнопку в навигации (Undo)
-(IBAction)tochedNavigButton2:(id)sender
{
    for (MMObject *item in _borderView.objectsArray) {
        [item deselectObject];
    }
    
    NSMutableDictionary *history_entry = [historyArray objectAtIndex:historyIndex];
    NSString *history_type = [history_entry objectForKey:@"entry_type"];
    NSDictionary *history_body = [history_entry objectForKey:@"entry_body"];
    
    if([history_type isEqualToString:@"history_obj_change"])
    {
        //тип записи "изменение объекта"
        for (MMObject *item in _borderView.objectsArray) {
            if([item.UUID isEqualToString:[history_body objectForKey:@"obj_uuid"]])
            {
                NSDictionary *new_body = [item getHistoryEntry];
                [item configByEntry:history_body];
                [history_entry setObject:new_body forKey:@"entry_body"];
                [_toolButton3 setEnabled:YES];
            }
        }
    }
    
    else if ([history_type isEqualToString:@"history_obj_create"]) {
        //тип записи "создание объекта"
        for (MMObject *item in _borderView.objectsArray) {
            if([item.UUID isEqualToString:[history_body objectForKey:@"obj_uuid"]])
            {
                [_borderView deleteObjectFromBoard:item];
                [_toolButton3 setEnabled:YES];
            }
        }
    }
    
    else if ([history_type isEqualToString:@"history_obj_delete"]) {
        //тип записи "удаление объекта"
        MMObject *obj = [_borderView createObjectInBoard];
        [obj setUUID:[history_body objectForKey:@"obj_uuid"]];
        [obj configByEntry:history_body];
        [_toolButton3 setEnabled:YES];
    }
    
    else if ([history_type isEqualToString:@"history_backgroun"]) {
        //тип записи "изменение бакграунда"
        
        //Замена записи
        NSMutableDictionary *bodyEntry = [[NSMutableDictionary alloc] init];
        if(_colorIndex>0){
            [bodyEntry setObject:@"color" forKey:@"background_type"];
            [bodyEntry setObject:[NSString stringWithFormat:@"%d",_colorIndex] forKey:@"color_number"];
        }else {
            [bodyEntry setObject:@"image" forKey:@"background_type"];
            [bodyEntry setObject:_imageBackgraundName forKey:@"image_name"];
        }
        
        NSString *_type = [history_body objectForKey:@"background_type"];
        if([_type isEqualToString:@"color"]){
            _colorIndex = [[history_body objectForKey:@"color_number"] intValue];
            [_borderImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Background_Color%d.png",_colorIndex]]];
        }else if ([_type isEqualToString:@"image"]) {
            _colorIndex = -1;
            _imageBackgraundName = [history_body objectForKey:@"image_name"];
            UIImage *img = [UIImage imageWithContentsOfFile:_imageBackgraundName];
            [_borderImageView setImage:img];
        }
        
        [history_entry setObject:bodyEntry forKey:@"entry_body"];
        [bodyEntry release];
        [_toolButton3 setEnabled:YES];
    }
    
    historyIndex--;
    if(historyIndex<0)
        [_toolButton2 setEnabled:NO];
}

//Нажатие на 3 кнопку в навигации (Redo)
-(IBAction)tochedNavigButton3:(id)sender
{
    for (MMObject *item in _borderView.objectsArray) {
        [item deselectObject];
    }
    
    historyIndex++;
    if(historyIndex>=[historyArray count]-1){
        [_toolButton3 setEnabled:NO];
    }
    
    NSMutableDictionary *history_entry = [historyArray objectAtIndex:historyIndex];
    NSString *history_type = [history_entry objectForKey:@"entry_type"];
    NSDictionary *history_body = [history_entry objectForKey:@"entry_body"];
    
    if([history_type isEqualToString:@"history_obj_change"])
    {
        //тип записи "изменение объекта"
        for (MMObject *item in _borderView.objectsArray) {
            if([item.UUID isEqualToString:[history_body objectForKey:@"obj_uuid"]])
            {
                NSDictionary *old_body = [item getHistoryEntry];
                [item configByEntry:history_body];
                [history_entry setObject:old_body forKey:@"entry_body"];
                [_toolButton2 setEnabled:YES];
            }
        }
    }
    
    else if ([history_type isEqualToString:@"history_obj_create"]) {
        //тип записи "создание объекта"
        MMObject *obj = [_borderView createObjectInBoard];
        [obj setUUID:[history_body objectForKey:@"obj_uuid"]];
        [obj configByEntry:history_body];
        [_toolButton2 setEnabled:YES];
    }
    
    else if ([history_type isEqualToString:@"history_obj_delete"]) {
        //тип записи "удаление объекта"
        for (MMObject *item in _borderView.objectsArray) {
            if([item.UUID isEqualToString:[history_body objectForKey:@"obj_uuid"]])
            {
                [_borderView deleteObjectFromBoard:item];
                [_toolButton2 setEnabled:YES];
            }
        }
    }
    
    else if ([history_type isEqualToString:@"history_backgroun"]) {
        //тип записи "изменение бакграунда"
        //Замена записи
        NSMutableDictionary *bodyEntry = [[NSMutableDictionary alloc] init];
        if(_colorIndex>0){
            [bodyEntry setObject:@"color" forKey:@"background_type"];
            [bodyEntry setObject:[NSString stringWithFormat:@"%d",_colorIndex] forKey:@"color_number"];
        }else {
            [bodyEntry setObject:@"image" forKey:@"background_type"];
            [bodyEntry setObject:_imageBackgraundName forKey:@"image_name"];
        }
        
        NSString *_type = [history_body objectForKey:@"background_type"];
        if([_type isEqualToString:@"color"]){
            _colorIndex = [[history_body objectForKey:@"color_number"] intValue];
            [_borderImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Background_Color%d.png",_colorIndex]]];
        }else if ([_type isEqualToString:@"image"]) {
            _colorIndex = -1;
            _imageBackgraundName = [history_body objectForKey:@"image_name"];
            UIImage *img = [UIImage imageWithContentsOfFile:_imageBackgraundName];
            [_borderImageView setImage:img];
        }
        
        [history_entry setObject:bodyEntry forKey:@"entry_body"];
        [bodyEntry release];
        [_toolButton2 setEnabled:YES];
    }
}

//Нажатие на 4 кнопку в навигации (Изменение цвета)
-(IBAction)tochedNavigButton4:(id)sender
{
    for (MMObject *item in _borderView.objectsArray) {
        [item deselectObject];
    }
    
    if([_colorPopoverController isPopoverVisible]||[_imagePopover isPopoverVisible]){
        [_colorPopoverController dismissPopoverAnimated:YES];
        [_imagePopover dismissPopoverAnimated:YES];
    }
    else 
        [_colorPopoverController presentPopoverFromRect:[(UIButton*)sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        //[_colorPopoverController presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:0 animated:YES];
}

//Нажатие на 5 кнопку в навигации (Новый документ)
-(IBAction)tochedNavigButton5:(id)sender
{
    for (MMObject *item in _borderView.objectsArray) {
        [item deselectObject];
    }
    
    if([historyArray count]>0){
        isCreateButtonTouched=YES;
        [_alertNewProject show];
    }else {
        [self createNewDocumentProject];
    }
}

//Нажатие на 6 кнопку в навигации (Сохранение)
-(IBAction)tochedNavigButton6:(id)sender
{
    for (MMObject *item in _borderView.objectsArray) {
        [item deselectObject];
    }
    
    [_saveField setText:_documentName];
    [_alertSave show];
}

//Нажатие на 7 кнопку в навигации (Шаринг)
-(IBAction)tochedNavigButton7:(id)sender
{
    for (MMObject *item in _borderView.objectsArray) {
        [item deselectObject];
    }
    
    if([_sharePopoverController isPopoverVisible])
        [_sharePopoverController dismissPopoverAnimated:YES];
    else{
        [_sharePopoverController presentPopoverFromRect:[(UIButton*)sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }

}

//Нажатие на 8 кнопку в навигации (Info)
-(IBAction)tochedNavigButton8:(id)sender
{
    for (MMObject *item in _borderView.objectsArray) {
        [item deselectObject];
    }
}

#pragma mark - MMImagePanelDelegate methods
//нажатие на кнопку загрузки с альбома панели изображений объекта
- (void)loadingImageFromAlbom
{
    UIImagePickerController *contr = [[UIImagePickerController alloc] init];
    [contr setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    contr.delegate = self;
    if(_objectImagePopover==nil)
        _objectImagePopover = [[UIPopoverController alloc] initWithContentViewController:contr];
    else
        [_objectImagePopover setContentViewController:contr];
    [_objectImagePopover setPopoverContentSize:contr.view.frame.size];
    [_objectImagePopover presentPopoverFromRect:_borderView.imagePanel.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

//нажатие на кнопку загрузки с камеры панели изображений объекта
- (void)loadingImageFromCamera
{
    UIImagePickerController *contr = [[UIImagePickerController alloc] init];
    contr.delegate = self;
    [contr setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentModalViewController:contr animated:YES];
}

//нажатие на кнопку удаления изображения с картинки
- (void)deleteImageFromObject:(MMObject *)_obj
{
    NSMutableDictionary *_entry = [NSMutableDictionary dictionary];
    [_entry setObject:[_obj getHistoryEntry] forKey:@"entry_body"];
    [_entry setObject:@"history_obj_change" forKey:@"entry_type"];
    [self border:_borderView withChanges:_entry];
    [_borderView.imagePanel.chooseBut setEnabled:YES];
    [_borderView.imagePanel.takeBut setEnabled:YES];
    [_borderView.imagePanel.deleteBut setEnabled:NO];
}

#pragma mark - MMColorControllerDelegate methods

//Нажатие на кнопку получения изображения из библиотеки изображений для backgrounds
-(void)colorController:(UIViewController *)controller touchedPhotoButton:(UIButton *)sender
{
    [_colorPopoverController dismissPopoverAnimated:YES];
    
    [_imagePopover presentPopoverFromBarButtonItem:[[_toolBar items] objectAtIndex:3] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
//    [_imagePopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

//Нажатие на кнопки изменения backgraunds
-(void)colorController:(UIViewController *)controller touchedColorButton:(UIButton *)sender
{
    [_colorPopoverController dismissPopoverAnimated:YES];
    
    //Создание записи
    NSMutableDictionary *_entry = [[NSMutableDictionary alloc] init];
    [_entry setObject:@"history_backgroun" forKey:@"entry_type"];
    NSMutableDictionary *bodyEntry = [[NSMutableDictionary alloc] init];
    if(_colorIndex>0){
        [bodyEntry setObject:@"color" forKey:@"background_type"];
        [bodyEntry setObject:[NSString stringWithFormat:@"%d",_colorIndex] forKey:@"color_number"];
    }else {
        [bodyEntry setObject:@"image" forKey:@"background_type"];
        [bodyEntry setObject:_imageBackgraundName forKey:@"image_name"];
    }
    [_entry setObject:bodyEntry forKey:@"entry_body"];
    [bodyEntry release];
    [self border:_borderView withChanges:_entry];
    [_entry release];
    
    //Изменение поля
    _colorIndex = [sender tag];
    [_borderImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Background_Color%d.png",_colorIndex]]];
}

#pragma mark - UIAlertVieewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //обработка алерта Титула
    if (alertView==_alertTitle) {
        if(buttonIndex == 1)
        {
            _documentName = _titleField.text;
            if([_documentName isEqualToString:@""])
                [_alertError show];
            [_titleButton setTitle:_documentName forState:UIControlStateNormal];
        }else{
            if([_documentName isEqualToString:@""])
                [_alertError show];
        }
    }
    //обработка флерта Сохранения
    else if (alertView == _alertSave) {
        if(buttonIndex == 1)
        {
            //сохранение объекта
            if(![self checkSavingFile:_saveField.text]){
                _documentName = _saveField.text;
                [_titleButton setTitle:_documentName forState:UIControlStateNormal];
                
                [self startOperation:@selector(savingDocumentInFile2:) withObject:_saveField.text];
            }else {
                //есть такой фаил!!!
                if(_borderView.isMakeMode)
                    [_alertResave show];
                else{
                    UIAlertView *alarm = [[UIAlertView alloc] initWithTitle:@"This file already exists.\nYou can not overwrite it." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alarm show];
                }
            }
        }
    }
    //обработка алерта перезаписи
    else if (alertView == _alertResave) {
        if (buttonIndex==1) {
            //Пересохранение файла
            [self deleteDocumentInFile:_saveField.text];
            [self startOperation:@selector(savingDocumentInFile2:) withObject:_saveField.text];
        }
    }
    //обработка алерта создания нового документа
    else if (alertView == _alertNewProject) {
        if(buttonIndex==1){
            //сохранение данных перед созданием нового проекта
            [_saveField setText:_documentName];
            [_alertSave show];
        }else if(buttonIndex==2) {
            [_alertWarningResave show];
        }
    }
    //обработка алерта открытия документа
    else if (alertView == _alertOpenProject) {
        if(buttonIndex==1){
            //сохранение данных перед созданием нового проекта
            [_saveField setText:_documentName];
            [_alertSave show];
        }else if(buttonIndex==2) {
            [_alertWarningResave show];
        }
    }
    //обработка алерта о предупреждении продолжения действий
    else if (alertView == _alertWarningResave){
        if(buttonIndex==1){
            if(isCreateButtonTouched){
                isCreateButtonTouched = NO;
                [self createNewDocumentProject];
            }else{
                isOpenDocumentTouched = NO;
                NSString *strDoc = _openDocumentName;
                [self openDocumentFromFile:strDoc];
            }
        }
    }
    //обработка алерта о предупреждении закрытия проекта
    else if (alertView == _alertWarningHome){
        if (buttonIndex==1) {
            [UIView beginAnimations:@"showMenu" context:nil];
            [UIView setAnimationDuration:0.5];
            [_logoView setAlpha:1];
            [_buttonMake setAlpha:1];
            [_buttonUse setAlpha:1];
            [_homeButton setAlpha:0];
            [_toolBar setFrame:CGRectMake(_toolBar.frame.origin.x, _toolBar.frame.origin.y-44, _toolBar.frame.size.width, _toolBar.frame.size.height)];
            [_borderImageView setImage:[UIImage imageNamed:@"Background.png"]];
            [_borderView setHidden:YES];
            [_borderView.colorPanel.view setHidden:YES];
            [_borderView.textPanel.view setHidden:YES];
            [_borderView.imagePanel.view setHidden:YES];
            [UIView commitAnimations];
        }
    }
    else if (alertView == _alertError)
    {
        [_alertTitle show];
    }
    else {
        if(buttonIndex==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(picker == _imagePicker){
        //Создание записи
        NSMutableDictionary *_entry = [[NSMutableDictionary alloc] init];
        [_entry setObject:@"history_backgroun" forKey:@"entry_type"];
        NSMutableDictionary *bodyEntry = [[NSMutableDictionary alloc] init];
        if(_colorIndex>0){
            [bodyEntry setObject:@"color" forKey:@"background_type"];
            [bodyEntry setObject:[NSString stringWithFormat:@"%d",_colorIndex] forKey:@"color_number"];
        }else {
            [bodyEntry setObject:@"image" forKey:@"background_type"];
            [bodyEntry setObject:_imageBackgraundName forKey:@"image_name"];
        }
        [_entry setObject:bodyEntry forKey:@"entry_body"];
        [bodyEntry release];
        [self border:_borderView withChanges:_entry];
        [_entry release];
        
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //сохранение файла в темп
        _colorIndex = -1;
        _imageBackgraundName=[MMObject createUUID];
        _imageBackgraundName = [_imageBackgraundName stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:path_tmp];
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        _imageBackgraundName = [_imageBackgraundName stringByAppendingString:@".png"];
        _imageBackgraundName = [[documentsDirectory stringByAppendingPathComponent:_imageBackgraundName] retain];
        
        [UIImagePNGRepresentation(img) writeToFile:_imageBackgraundName atomically:YES];
        
        [_imagePopover dismissPopoverAnimated:YES];
        [_colorPopoverController dismissPopoverAnimated:YES];
        [_borderImageView setImage:img];
        
    }else {
        [_objectImagePopover dismissPopoverAnimated:YES];
        [self dismissModalViewControllerAnimated:YES];
        
        //установка нового изображения
        UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];      
                
        [_borderView.imagePanel.chooseBut setEnabled:NO];
        [_borderView.imagePanel.takeBut setEnabled:NO];
        [_borderView.imagePanel.deleteBut setEnabled:YES];
        
        [self startOperation:@selector(setImageForObject:) withObject:img];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
    [_sharePopoverController dismissPopoverAnimated:YES];
    
    for (MMObject* item in _borderView.objectsArray) {
        NSLog(@"%@",NSStringFromCGRect(item.frame));
        [item removeFromSuperview];
    }
    for (MMObject *item in _borderView.objectsArray) {
        [_borderView addSubview:item];
    }
}

#pragma mark - MMBorderDelegate methods

//Метод вызывается когда были произведены изменения в поле Border
- (void)border:(MMBorder *)border withChanges:(NSDictionary *)_changes
{
    //удаление записей после индекса
    for (int i=[historyArray count]-1; i>historyIndex; i--) {
        [historyArray removeObjectAtIndex:i];
    }
    
    //сохранение записи
    [historyArray addObject:_changes];
    historyIndex = [historyArray count]-1;
    
    //отображение кнопки Undo
    [_toolButton2 setEnabled:YES];
    [_toolButton3 setEnabled:NO];
}

#pragma mark - MMOpenFileControllerDelegate methods

- (void)openViewController:(MMOpenViewController *)controller didSelectDocument:(NSString *)docName
{
    _openDocumentName = [docName retain];
    if([historyArray count]>0){
        isOpenDocumentTouched=YES;
        [_alertOpenProject show];
    }else {
        [self openDocumentFromFile:_openDocumentName];
    }
}

- (void)openDocumentFromFile:(NSString*)docName
{
    [_borderView deleteAllObjectsFromBorder];
    [_openPopoverController dismissPopoverAnimated:YES];
    _documentName = [docName lastPathComponent];
    _documentName = [_documentName stringByReplacingOccurrencesOfString:@".MoveAndMatch" withString:@""];
    [_titleButton setTitle:_documentName forState:UIControlStateNormal];
    [self clearHistory];
    //[self startOperation:@selector(loadingDocumentFromFile2:) withObject:docName];
    [self loadingDocumentFromFile2:docName];
}

#pragma mark - MMShareControllerDelegate methods

- (void)shareController:(MMShareViewController *)controller willShare:(NSInteger)_index
{
    if(_borderView.objectsArray.count>0){
        if ([MFMailComposeViewController canSendMail]) {
            for (MMObject *item in _borderView.objectsArray) {
                [item deselectObject];
            }
            [_sharePopoverController dismissPopoverAnimated:YES];
            _shareIndex = _index;
            [self startOperation:@selector(SharingWithIndex:) withObject:nil];
        }else {
            [_sharePopoverController dismissPopoverAnimated:YES];
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Your device is not set up for the delivery of email." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }else {
        UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:@"Document is empty" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [_alert show];
        [_alert release];
    }
}

-(void)SharingWithIndex:(int)_index
{
    NSData *mailData = nil;
    switch (_shareIndex) {
        case 0:{
            //share file
            mailData = [self createProjectFile];
            break;
        }
        case 1:{
            //share jpg
            UIImage *image = [self createImage2];
            mailData = UIImageJPEGRepresentation(image, 3);
            break;
        }
        case 2:{
            //share png
            UIImage *image = [self createImage2];
            mailData = UIImagePNGRepresentation(image);
            break;
        }
        case 3:{
            //share pdf
            mailData = [self createPDFDocument2];
            break;
        }
    }
    [self performSelectorOnMainThread:@selector(SharingWithIndex2:) withObject:mailData waitUntilDone:NO];
}

-(void)SharingWithIndex2:(NSData*)_mailData
{
    [self.view setUserInteractionEnabled:YES];
    [_activity hide];
    
    MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@"Move & Match Cards"];
    [mailController setMessageBody:@"Move & Match Cards..." isHTML:NO];
    switch (_shareIndex) {
        case 0:     [mailController addAttachmentData:_mailData mimeType:@"file" fileName:[NSString stringWithFormat:@"%@.MoveAndMatch",_documentName]];   break;
        case 1:     [mailController addAttachmentData:_mailData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"%@.jpg",_documentName]];   break;
        case 2:     [mailController addAttachmentData:_mailData mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%@.png",_documentName]];   break;
        case 3:     [mailController addAttachmentData:_mailData mimeType:@"image/pdf" fileName:[NSString stringWithFormat:@"%@.pdf",_documentName]];   break;
    }
    [self presentModalViewController:mailController animated:YES];
}

@end
