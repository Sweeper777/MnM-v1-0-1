//
//  MMCheckView.m
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 26.07.12.
//
//

#import "MMCheckView.h"

@implementation MMCheckView

@synthesize selectImage = _selectIm, deselectImage = _deselectImage, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_imageView];
    }
    return self;
}

- (id)initWhithSelect:(UIImage *)_selectImage deselect:(UIImage *)_deselect
{
    self = [super init];
    if (self){
        _selectIm = _selectImage;
        _deselectImage = _deselect;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _check=!_check;
    if(_check==NO)
        [_imageView setImage:_deselectImage];
    else
        [_imageView setImage:_selectIm];
    [delegate checkViewDidSelect:self];
}

-(void)setCheckValue:(BOOL)_val
{
    _check = _val;
    if(_check==NO)
        [_imageView setImage:_deselectImage];
    else
        [_imageView setImage:_selectIm];
}

-(BOOL)getCheckValue
{
    return _check;
}

@end
