//
//  AlbumViewController.h
//  XunMap
//
//  Created by admin on 2018/10/26.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraDelegate <NSObject>

- (void)CameraTakePhoto:(UIImage *)image;

@end

@interface AlbumViewController : UIViewController

@property (nonatomic, weak)id<CameraDelegate> delegate;
@end

