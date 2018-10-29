//
//  ViewController.m
//  MLPhotoPicker
//
//  Created by admin on 2018/10/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ViewController.h"
#import "CameraTool/MLImagePicker.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.button];
}

- (UIButton *)button{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor redColor];
        _button.frame = CGRectMake(0, 0, 300, 300*0.566);
        _button.center = self.view.center;
        [_button addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}


- (void)btnAction{
    
    [[MLImagePicker sharePicker] showPickerWith:self completeBlock:^(UIImage *image) {
        [self->_button setBackgroundImage:image forState:UIControlStateNormal];
    }];
}


@end
