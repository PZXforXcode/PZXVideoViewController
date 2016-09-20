//
//  ViewController.m
//  PZXVideoViewController
//
//  Created by pzx on 16/9/18.
//  Copyright © 2016年 pzx. All rights reserved.
//

#import "ViewController.h"
#import "PZXVideoViewController.h"

@interface ViewController ()<PZXVideoViewControllerDelegate>
- (IBAction)buttonPressed:(UIButton *)sender;
@property (nonatomic,strong)PZXVideoViewController *PZXVideoViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _PZXVideoViewController  = [[PZXVideoViewController alloc]init];
    _PZXVideoViewController.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)overlayViewController:(PZXVideoViewController *)overlayViewController finishWithURL:(NSURL *)URL{

    NSLog(@"over");
    
    
}
- (IBAction)buttonPressed:(UIButton *)sender {
    [self presentViewController:_PZXVideoViewController animated:YES completion:nil];
    
}
@end
