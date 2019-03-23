//
//  MMCheckView.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 26.07.12.
//
//

#import <UIKit/UIKit.h>

@protocol MMCheckViewDelegate;

@interface MMCheckView : UIView{
    id<MMCheckViewDelegate>delegate;
    BOOL _check;
    UIImageView *_imageView;
    UIImage *_selectIm;
    UIImage *deselect;
}

@property(nonatomic,assign)id<MMCheckViewDelegate>delegate;
@property(nonatomic,retain)UIImage* selectImage;
@property(nonatomic,retain)UIImage* deselectImage;

-(id)initWhithSelect:(UIImage*)_selectImage deselect:(UIImage*)_deselect;
-(void)setCheckValue:(BOOL)_val;
-(BOOL)getCheckValue;

@end

@protocol MMCheckViewDelegate

-(void)checkViewDidSelect:(MMCheckView*)_view;

@end
