//
//  MLImagePicker.m
//  MLPhotoPicker
//
//  Created by admin on 2018/10/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "MLImagePicker.h"
#import "AlbumViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ClipViewController.h"
@interface MLImagePicker ()<CameraDelegate,ClipPhotoDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    void (^ImageBlock)(UIImage *image);
    UIViewController *_viewController;
}
@property(nonatomic, strong) AlbumViewController *albumVC;
@property(nonatomic, strong) UIImagePickerController *imgPicker;
@end
@implementation MLImagePicker

static MLImagePicker* _picker;

+ (MLImagePicker *)sharePicker{
    if (!_picker) {
        _picker = [[MLImagePicker alloc]init];
    }
    return _picker;
}

- (AlbumViewController *)albumVC{
    if (!_albumVC) {
        _albumVC = [[AlbumViewController alloc] init];
        _albumVC.delegate = self;
    }
    return _albumVC;
}

#pragma mark - 选取照片的回调
- (void)CameraTakePhoto:(UIImage *)image{
    NSLog(@"-----%@",image);
    ImageBlock(image);
}


- (void)showPickerWith:(UIViewController *)viewController completeBlock:(void (^)(UIImage *image))image{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"拍一张", nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
    _viewController = viewController;
    ImageBlock = image;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    
    if (!isCamera) {
//        [THAlertActionView showWithType:AlertTypeNotButton title:@"您的手机没有拍照功能"];
        return;
    }
    if (buttonIndex < 2) {
        [self showPickerView:buttonIndex];
    }
}

- (void)showPickerView:(NSInteger)buttonIndex{
    //初始化图片选择控制器
    switch (buttonIndex) {
        case 0:{
            _imgPicker = [[UIImagePickerController alloc] init];
            _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            _imgPicker.delegate = self;
            _imgPicker.allowsEditing = NO;
            [_viewController presentViewController:_imgPicker animated:YES completion:nil];
        }
            break;
        case 1:{
            [_viewController presentViewController:self.albumVC animated:YES completion:nil];
            
        }
            break;
            
        default:
            break;
    }
}



#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate
// 选择照片之后
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [UIImage imageWithData:UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 0.1)];
    [self cropImage:image];
    
    
}

- (void)cropImage: (UIImage *)image {
    ClipViewController *viewController = [[ClipViewController alloc] init];
    viewController.image = image;
    viewController.picker = _imgPicker;
    viewController.controller = _viewController;
    viewController.delegate = self;
    viewController.isTakePhoto = NO;
    [_imgPicker presentViewController:viewController animated:NO completion:nil];
}



#pragma mark -- ClipPhotoDelegate
- (void)clipPhoto:(UIImage *)image
{
    [_viewController dismissViewControllerAnimated:NO completion:nil];
    ImageBlock(image);
}


@end
