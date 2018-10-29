//
//  MLImagePicker.h
//  MLPhotoPicker
//
//  Created by admin on 2018/10/29.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLImagePicker : NSObject

+ (MLImagePicker *)sharePicker;
- (void)showPickerWith:(id)viewController completeBlock:(void (^)(id))image;
@end

