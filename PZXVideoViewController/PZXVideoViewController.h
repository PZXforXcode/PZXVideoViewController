//
//  PZXVideoViewController.h
//  PZXVideoViewController
//
//  Created by pzx on 16/9/18.
//  Copyright © 2016年 pzx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PZXVideoViewController.h"

//代理
@protocol PZXVideoViewControllerDelegate;


//controller的东西
@interface PZXVideoViewController : UIViewController

@property (nonatomic, assign) id<PZXVideoViewControllerDelegate>delegate;

@end


//代理的方法
@protocol PZXVideoViewControllerDelegate <NSObject>

- (void)overlayViewController:(PZXVideoViewController *)overlayViewController finishWithURL:(NSURL *)URL;


@end


