# MLPhotoPicker
自定义矩形裁剪框

1.使用方法
 [[MLImagePicker sharePicker] showPickerWith:self completeBlock:^(UIImage *image) {

//拿到裁剪后的图片

}];

2.自定义裁剪框高度和宽度

找到下面这个方法，直接修改height和width即可
- (void)resetCropAreaByAspectRatio {

    if(_imageAspectRatio == 0) return;

    CGFloat width, height;

    if(_cropAspectRatio == 0) {

        width = WIDTH(_imageView);

        height = width*0.566;

        if(_showMidLines) {

            [self createMidLines];

            [self resetMidLines];

        }

    }

    else {

        [self removeMidLines];

        if(_imageAspectRatio > _cropAspectRatio) {

            width = WIDTH(_imageView);

            height = width*0.566;

        }

        else {

            width = WIDTH(_imageView);

            height = width*0.566;

        }

    }

    _cropAreaView.frame = CGRectMake((WIDTH(_imageView) - width) / 2.0, (HEIGHT(_imageView) - height) / 2.0, width, height);

    [self resetCropTransparentArea];

    [self resetMinSpaceIfNeeded];

}
