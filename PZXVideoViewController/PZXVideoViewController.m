//
//  PZXVideoViewController.m
//  PZXVideoViewController
//
//  Created by pzx on 16/9/18.
//  Copyright © 2016年 pzx. All rights reserved.
//


//define最大视频录制时间
#define MAXTIME 11.0
//需要import视频相关的东西
#import <AVFoundation/AVFoundation.h>

#import <MobileCoreServices/UTCoreTypes.h>
//----------
#import "PZXVideoViewController.h"


//进度条View代理
@protocol PZXCameraProgressViewDelegate;


//进度条View的interface
@interface PZXCameraProgressView : UIView{
    BOOL isChangeTintColor;
}

@property (nonatomic, assign) id<PZXCameraProgressViewDelegate>delegate;

//左右的slider
@property (nonatomic, strong) UISlider *leftSliderView;
@property (nonatomic, strong) UISlider *rightSliderView;

//进度条移动的timer
@property (nonatomic, strong) NSTimer *timer;

//进度条最大值
@property (nonatomic, assign) float maxValue;

//进度条每次移动间隔时间
@property (nonatomic, assign) float repeatTime;



- (void)changeProgressTint:(BOOL)isChange color:(UIColor *)color;

//开始进度条移动
- (void)start;
//结束进度条移动
- (void)stop;
@end

//进度条代理
@protocol PZXCameraProgressViewDelegate <NSObject>
@required
- (void)cameraProgressView:(PZXCameraProgressView *)progressView didProgressMaxValue:(float)maxValue;

@end

//进度条View实现
@implementation PZXCameraProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        isChangeTintColor = NO;
        self.repeatTime = 0.1;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews{
    
    //设置进度条View界面
    self.clipsToBounds = YES;
    self.rightSliderView = [[UISlider alloc] initWithFrame:CGRectMake(self.frame.size.width/2-2, 0, self.frame.size.width/2+4, self.frame.size.height)];
    [self.rightSliderView setThumbImage:[UIImage imageNamed:@"sliderthumb.png"] forState:UIControlStateNormal];
    self.rightSliderView.maximumValue = CGRectGetWidth(self.rightSliderView.frame);
    [self.rightSliderView setMinimumTrackTintColor:[UIColor greenColor]];
    [self.rightSliderView setMaximumTrackTintColor:[UIColor clearColor]];
    [self addSubview:self.rightSliderView];
    
    self.leftSliderView = [[UISlider alloc] initWithFrame:CGRectMake(0-2, 0, self.frame.size.width/2+4, self.frame.size.height)];
    [self.leftSliderView setThumbImage:[UIImage imageNamed:@"sliderthumb.png"] forState:UIControlStateNormal];
    self.leftSliderView.maximumValue = CGRectGetWidth(self.leftSliderView.frame);
    [self.leftSliderView setMinimumTrackTintColor:[UIColor greenColor]];
    [self.leftSliderView setMaximumTrackTintColor:[UIColor clearColor]];
    [self.leftSliderView setTransform:CGAffineTransformRotate(self.leftSliderView.transform, M_PI)];
    [self addSubview:self.leftSliderView];

    

}

- (void)setMaxValue:(float)maxValue{
    _maxValue = maxValue;
}

//开始进度条
- (void)start{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.repeatTime target:self selector:@selector(startProgressAction:) userInfo:nil repeats:YES];
}
//停止进度条
- (void)stop{
    self.rightSliderView.value = 0;
    self.leftSliderView.value = 0;
    if(isChangeTintColor){
        self.leftSliderView.minimumTrackTintColor = [UIColor greenColor];
        self.rightSliderView.minimumTrackTintColor = [UIColor greenColor];
    }
    [self.timer invalidate];
    self.timer = nil;
}


//进度条动作
- (void)startProgressAction:(NSTimer *)timer{
    float width = self.leftSliderView.frame.size.width;
    self.leftSliderView.value += (width/(self.maxValue/self.repeatTime));
    self.rightSliderView.value += (width/(self.maxValue/self.repeatTime));
    if(self.leftSliderView.value>=self.leftSliderView.maximumValue || self.rightSliderView.value>=self.rightSliderView.maximumValue){
        [self stop];
        if(self.delegate && [self.delegate respondsToSelector:@selector(cameraProgressView:didProgressMaxValue:)]){
            [self.delegate cameraProgressView:self didProgressMaxValue:self.maxValue];
        }
    }
}

//变色
- (void)changeProgressTint:(BOOL)isChange color:(UIColor *)color{
    if(isChange){
        self.leftSliderView.minimumTrackTintColor = color;
        self.rightSliderView.minimumTrackTintColor = color;
    }else{
        self.leftSliderView.minimumTrackTintColor = [UIColor greenColor];
        self.rightSliderView.minimumTrackTintColor = [UIColor greenColor];
    }
    isChangeTintColor = isChange;
}

@end













@interface PZXVideoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,PZXCameraProgressViewDelegate>


@property (nonatomic, strong) UIImagePickerController *imagePickerController;



@property (nonatomic, strong) UIView *overlayView;

@property (nonatomic, strong) UIButton *playButton;


@property (nonatomic, strong) UIButton *backButton;

//progress
@property (nonatomic, strong) PZXCameraProgressView *progressView;
@property (nonatomic, strong) NSDate *startDate;

//是否完成拍摄 并 保存
@property (nonatomic, assign) BOOL isSave;
//是否取消视频录制
@property (nonatomic, assign) BOOL isCannel;

//用于显示拍摄的事件进度条view


//提示向上移动可以删除
@property (nonatomic, strong) UIButton *cannelAlertView;

//提示可以松开 删除
@property (nonatomic, strong) UIButton *cannleView;

@end

@implementation PZXVideoViewController

//不隐藏statusBar
- (BOOL)prefersStatusBarHidden{
    return NO;
}
//屏幕旋转代码
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
    
}

//初始化方法
- (instancetype)init{
    self = [super init];
    if(self){
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    //初始化拍摄控制器
    [self initImagePickerController];


}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.imagePickerController) {
        [self.view addSubview:self.imagePickerController.view];
        [self.view sendSubviewToBack:self.imagePickerController.view];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.imagePickerController) {
        [self.imagePickerController.view removeFromSuperview];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)dealloc{
    NSLog(@"拍摄控制器销毁了");
}

#pragma mark - init
//使用自带的imagePickerController
- (void)initImagePickerController{//初始化pickerController
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        //设置 拍摄模式为 摄像
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //设置拍照时的下方的工具栏是否显示，如果需要自定义拍摄界面，则可把该工具栏隐藏
        self.imagePickerController.showsCameraControls = NO;
        
        //只摄像
        self.imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)  kUTTypeMovie,nil];
        
        //self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        //设置后置摄像头
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        //闪光灯
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        //
        //self.imagePickerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
        //self.imagePickerController.cameraOverlayView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
        //        [self.view addSubview:self.imagePickerController.view];
        //设置拍摄最大时间
        //self.imagePickerController.videoMaximumDuration = MAXTIME;
        //设置拍摄质量 zhongdegn
        self.imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
        
        //在摄像头可用的情况下 初始化 拍摄 视图
        [self initViews];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此设备摄像头不可用" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)initViews{//定制拍摄控键
    
    self.isSave = NO;
    self.isCannel = NO;
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.overlayView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.overlayView];
    
    //长按拍摄
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(self.overlayView.frame.size.width/2-50, self.overlayView.frame.size.height-140, 100, 100)];
    [self.playButton setTitle:@"按住拍" forState:UIControlStateNormal];
    [self.playButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    //添加长按事件
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touchDownButton:)];
    [self.playButton addGestureRecognizer:longPress];
    self.playButton.layer.cornerRadius = 50;
    self.playButton.layer.borderWidth = 1;
    self.playButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.playButton.backgroundColor = [UIColor clearColor];
    [self.overlayView addSubview:self.playButton];
    
    
    //加进度条
    self.progressView = [[PZXCameraProgressView alloc] initWithFrame:CGRectMake(0, 50, self.overlayView.frame.size.width, 20)];
    self.progressView.delegate = self;
    self.progressView.maxValue = MAXTIME;
    [self.overlayView addSubview:self.progressView];
    
    
    //返回按钮
    //.imageEdgeInsets = UIEdgeInsetsMake(14, 18, 14, 18); 14 27
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 50, 44)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
//    [backButton setImage:[UIImage imageNamed:@"fanhui"] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(14, 18+3, 14, 18+3);
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView addSubview:backButton];
    [self initCannelAlertView];
    [self initCannelView];
    
}

//创建 向上移动删除视图
- (void)initCannelAlertView{
    self.cannelAlertView = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.playButton.frame)-40, self.overlayView.frame.size.width, 30)];
    [self.cannelAlertView setTitle:@"向上移动取消拍摄" forState:UIControlStateNormal];
    [self.cannelAlertView setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    self.cannelAlertView.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.cannelAlertView.enabled = NO;
    [self.overlayView addSubview:self.cannelAlertView];
    self.cannelAlertView.hidden = YES;
}

//创建删除视图
- (void)initCannelView{
    self.cannleView = [[UIButton alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.overlayView.frame)-CGRectGetMinX(self.playButton.frame))/2-15, self.overlayView.frame.size.width, 30)];
    [self.cannleView setTitle:@"取消拍摄" forState:UIControlStateNormal];
    [self.cannleView setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.cannleView.enabled = NO;
    self.cannleView.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.overlayView addSubview:self.cannleView];
    self.cannleView.hidden = YES;
}

- (void)changeCannelViewCannel:(BOOL)isCannel{
    if(isCannel){
        self.cannelAlertView.hidden = YES;
        self.cannleView.hidden = NO;
    }else{
        self.cannleView.hidden = YES;
        self.cannelAlertView.hidden = NO;
    }
}
- (void)hideCannelView{
    [self.cannelAlertView setHidden:YES];
    self.cannleView.hidden = YES;
}
- (void)showCannelView{
    self.cannleView.hidden = YES;
    self.cannelAlertView.hidden = NO;
}

//按下拍摄
- (void)touchDownButton:(UILongPressGestureRecognizer *)longPress{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {//开始捕捉视频
            self.startDate = [NSDate date];
            [self.imagePickerController startVideoCapture];
            [self.progressView start];
            [self showCannelView];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {//进行取消拍摄
            CGPoint p = [longPress locationInView:self.overlayView];
            if(p.y<self.playButton.frame.origin.y){//取消拍摄
                [self.progressView changeProgressTint:YES color:[UIColor redColor]];
                self.isCannel = YES;
            }else{//拍摄
                [self.progressView changeProgressTint:NO color:nil];
                self.isCannel = NO;
            }
            [self changeCannelViewCannel:self.isCannel];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if(!self.isCannel){
                if(-[self.startDate timeIntervalSinceDate:[NSDate date]]<=2){
                    self.startDate = nil;
                }else{
                    self.isSave = YES;
                    self.startDate = nil;
                }
            }
            self.isCannel = NO;
            [self hideCannelView];
            //停止捕捉视频
            [self.imagePickerController stopVideoCapture];
            [self.progressView stop];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {//如果进了这个case 表示拍摄的最大时间到了
            
        }
            break;
        default:{
            NSLog(@"new %ld",longPress.state);
        }break;
    }
    
}

#pragma mark - progress delegate
- (void)cameraProgressView:(PZXCameraProgressView *)progressView didProgressMaxValue:(float)maxValue{
    self.isSave = YES;
    [self.imagePickerController stopVideoCapture];
}



#pragma mark - imagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        //[picker dismissViewControllerAnimated:YES completion:nil];
        NSURL *mp4;
        if(self.isSave){
            mp4 = [self convertToMp4:videoURL];
        }
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }else{
                NSLog(@"已经删除拍摄原视频");
            }
        }
        if(self.isSave){
            if(self.delegate && [self.delegate respondsToSelector:@selector(overlayViewController:finishWithURL:)]){
                [self.delegate overlayViewController:self finishWithURL:mp4];
            }
            [self overlayBack];
        }
    }
}


//视频转换压缩 拍摄出来是mov 格式的 转成mp4
- (NSURL *)convertToMp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetMediumQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        int timeout = (int)dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    return mp4Url;
}


#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self overlayBack];
}

- (void)overlayBack{
    //    [self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)backButtonAction{
    [self overlayBack];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
