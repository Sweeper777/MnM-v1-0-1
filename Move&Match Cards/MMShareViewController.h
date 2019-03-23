//
//  MMShareViewController.h
//  Move&Match Cards
//
//  Created by Mark Voskresenskiy on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMShareControllerDelegate;

@interface MMShareViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *_table;
}

@property (assign,nonatomic)id<MMShareControllerDelegate>delegate;

@end


@protocol MMShareControllerDelegate <NSObject>

- (void)shareController:(MMShareViewController*)controller willShare:(NSInteger)_index;

@end