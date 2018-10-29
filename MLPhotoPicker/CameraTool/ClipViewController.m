//
//  ClipViewController.m
//  Camera
//
//  Created by wzh on 2017/6/6.
//  Copyright © 2017年 wzh. All rights reserved.
//

#import "ClipViewController.h"
#import "TKImageView.h"
#define SelfWidth [UIScreen mainScreen].bounds.size.width
#define SelfHeight  [UIScreen mainScreen].bounds.size.height
@interface ClipViewController ()

@property (nonatomic, assign) BOOL isClip;

@property (nonatomic, strong) TKImageView *tkImageView;

@end

@implementation ClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createdTkImageView];
    
    [self createdTool];
    
}

- (void)createdTkImageView
{
    _tkImageView = [[TKImageView alloc] initWithFrame:CGRectMake(0, 0, SelfWidth, SelfHeight)];
    [self.view addSubview:_tkImageView];
    //需要进行裁剪的图片对象
    _tkImageView.toCropImage = _image;
    //是否显示中间线
    _tkImageView.showMidLines = YES;
    //是否需要支持缩放裁剪
    _tkImageView.needScaleCrop = YES;
    //是否显示九宫格交叉线
    _tkImageView.showCrossLines = YES;
    _tkImageView.cornerBorderInImage = NO;
    _tkImageView.cropAreaCornerWidth = 44;
    _tkImageView.cropAreaCornerHeight = 44;
    _tkImageView.minSpace = 30;
    _tkImageView.cropAreaCornerLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaBorderLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCornerLineWidth = 6;
    _tkImageView.cropAreaBorderLineWidth = 1;
    _tkImageView.cropAreaMidLineWidth = 20;
    _tkImageView.cropAreaMidLineHeight = 6;
    _tkImageView.cropAreaMidLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCrossLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCrossLineWidth = 0.5;
    _tkImageView.initialScaleFactor = .8f;
    _tkImageView.cropAspectRatio = 0;
    _tkImageView.maskColor = [UIColor clearColor];
    
    self.isClip = NO;
}

- (void)createdTool
{
    UIView  *editorView = [[UIView alloc] initWithFrame:CGRectMake(0, SelfHeight - 60, SelfWidth, 60)];
    editorView.backgroundColor = [UIColor blackColor];
    editorView.alpha = 0.8;
    [self.view addSubview:editorView];
    CGFloat width = [UIScreen mainScreen].bounds.size.width/2;
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(0, 0, width, 60);
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [cancleBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [editorView addSubview:cancleBtn];
    
    UIButton *clipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clipBtn.frame = CGRectMake(width, 0, width, 60);
    [clipBtn setTitle:@"确认" forState:UIControlStateNormal];
    [clipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clipBtn addTarget:self action:@selector(clip:) forControlEvents:UIControlEventTouchUpInside];
    [editorView addSubview:clipBtn];
}

- (void)back{
    if (self.isClip == YES) {
        _tkImageView.toCropImage = _image;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)clip:(UIButton *)btn{
    UIImage *image = [_tkImageView currentCroppedImage];
    if (self.isTakePhoto) {
        //将图片存储到相册
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(clipPhoto:)]) {
        [self.delegate clipPhoto:image];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.picker dismissViewControllerAnimated:NO completion:nil];
    [self.controller dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
