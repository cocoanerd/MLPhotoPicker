//
//  TKImageView.m
//  TKImageDemo
//
//  Created by yinyu on 16/7/10.
//  Copyright © 2016年 yinyu. All rights reserved.
//

#import "TKImageView.h"
#define WIDTH(_view) CGRectGetWidth(_view.bounds)
#define HEIGHT(_view) CGRectGetHeight(_view.bounds)
#define MAXX(_view) CGRectGetMaxX(_view.frame)
#define MAXY(_view) CGRectGetMaxY(_view.frame)
#define MINX(_view) CGRectGetMinX(_view.frame)
#define MINY(_view) CGRectGetMinY(_view.frame)
#define MID_LINE_INTERACT_WIDTH 44
#define MID_LINE_INTERACT_HEIGHT 44
typedef NS_ENUM(NSInteger, TKCropAreaCornerPosition) {
    TKCropAreaCornerPositionTopLeft,
    TKCropAreaCornerPositionTopRight,
    TKCropAreaCornerPositionBottomLeft,
    TKCropAreaCornerPositionBottomRight
};
typedef NS_ENUM(NSInteger, TKMidLineType) {
    
    TKMidLineTypeTop,
    TKMidLineTypeBottom,
    TKMidLineTypeLeft,
    TKMidLineTypeRight
    
};
@interface UIImage(Handler)
@end
@implementation UIImage(Handler)
//Fix image's rotation
- (UIImage *)fixOrientation {
    
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}
- (UIImage *)imageAtRect:(CGRect)rect
{
    
    UIImage *fixedImage = [self fixOrientation];
    CGImageRef imageRef = CGImageCreateWithImageInRect([fixedImage CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}
@end
@interface CornerView: UIView

@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) TKCropAreaCornerPosition cornerPosition;
@property (assign, nonatomic) CornerView *relativeViewX;
@property (assign, nonatomic) CornerView *relativeViewY;
@property (strong, nonatomic) CAShapeLayer *cornerShapeLayer;

- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height;
@end
@implementation CornerView
- (instancetype)initWithFrame:(CGRect)frame lineColor: (UIColor *)lineColor lineWidth: (CGFloat)lineWidth {
    
    self = [super initWithFrame: frame];
    if(self) {
        self.lineColor = lineColor;
        self.lineWidth = lineWidth;
    }
    return self;
}
- (void)setCornerPosition:(TKCropAreaCornerPosition)cornerPosition {
    
    _cornerPosition = cornerPosition;
    [self drawCornerLines];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self drawCornerLines];
    
}
- (void)drawCornerLines {
    
    if(_cornerShapeLayer && _cornerShapeLayer.superlayer) {
        [_cornerShapeLayer removeFromSuperlayer];
    }
    _cornerShapeLayer = [CAShapeLayer layer];
    _cornerShapeLayer.lineWidth = _lineWidth;
    _cornerShapeLayer.strokeColor = _lineColor.CGColor;
    _cornerShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPath];
    CGFloat paddingX = _lineWidth / 2.0f;
    CGFloat paddingY = _lineWidth / 2.0f;
    switch (_cornerPosition) {
        case TKCropAreaCornerPositionTopLeft: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self), paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self))];
            break;
        }
        case TKCropAreaCornerPositionTopRight: {
            [cornerPath moveToPoint:CGPointMake(0, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self))];
            break;
        }
        case TKCropAreaCornerPositionBottomLeft: {
            [cornerPath moveToPoint:CGPointMake(paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self), HEIGHT(self) - paddingY)];
            break;
        }
        case TKCropAreaCornerPositionBottomRight: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self) - paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(0, HEIGHT(self) - paddingY)];
            break;
        }
        default:
            break;
    }
    _cornerShapeLayer.path = cornerPath.CGPath;
    [self.layer addSublayer: _cornerShapeLayer];
    
}
- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height {
    
    switch (_cornerPosition) {
        case TKCropAreaCornerPositionTopLeft: {
            self.frame = CGRectMake(MINX(self), MINY(self), width, height);
            break;
        }
        case TKCropAreaCornerPositionTopRight: {
            self.frame = CGRectMake(MAXX(self) - width, MINY(self), width, height);
            break;
        }
        case TKCropAreaCornerPositionBottomLeft: {
            self.frame = CGRectMake(MINX(self), MAXY(self) - height, width, height);
            break;
        }
        case TKCropAreaCornerPositionBottomRight: {
            self.frame = CGRectMake(MAXX(self) - width, MAXY(self) - height, width, height);
            break;
        }
        default:
            break;
    }
    [self drawCornerLines];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _cornerShapeLayer.strokeColor = lineColor.CGColor;
    
}
@end

@interface MidLineView : UIView
@property (strong, nonatomic) CAShapeLayer *lineLayer;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat lineHeight;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) TKMidLineType type;
@end
@implementation MidLineView
- (instancetype)initWithLineWidth: (CGFloat)lineWidth lineHeight: (CGFloat)lineHeight lineColor: (UIColor *)lineColor {
    
    self = [super initWithFrame: CGRectMake(0, 0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT)];
    if(self) {
        self.lineWidth = lineWidth;
        self.lineHeight = lineHeight;
        self.lineColor = lineColor;
    }
    return self;
    
}
- (void)setType:(TKMidLineType)type {
    
    _type = type;
    [self drawMidLine];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self drawMidLine];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _lineLayer.strokeColor = lineColor.CGColor;
    
}
- (void)setLineHeight:(CGFloat)lineHeight {
    
    _lineHeight = lineHeight;
    _lineLayer.lineWidth = lineHeight;
    
}
- (void)drawMidLine {
    
    if(_lineLayer && _lineLayer.superlayer) {
        [_lineLayer removeFromSuperlayer];
    }
    _lineLayer = [CAShapeLayer layer];
    _lineLayer.strokeColor = _lineColor.CGColor;
    _lineLayer.lineWidth = _lineHeight;
    _lineLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *midLinePath = [UIBezierPath bezierPath];
    switch (_type) {
        case TKMidLineTypeTop:
        case TKMidLineTypeBottom: {
            [midLinePath moveToPoint:CGPointMake((WIDTH(self) - _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake((WIDTH(self) + _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            break;
        }
        case TKMidLineTypeRight:
        case TKMidLineTypeLeft: {
            [midLinePath moveToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) - _lineWidth) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) + _lineWidth) / 2.0)];
            break;
        }
        default:
            break;
    }
    _lineLayer.path = midLinePath.CGPath;
    [self.layer addSublayer: _lineLayer];
    
}
@end

@interface CropAreaView : UIView
@property (strong, nonatomic) CAShapeLayer *crossLineLayer;
@property (assign, nonatomic) CGFloat crossLineWidth;
@property (strong, nonatomic) UIColor *crossLineColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (assign, nonatomic) BOOL showCrossLines;
@end
@implementation CropAreaView

- (instancetype)init {
    
    self = [super init];
    if(self) {
        [self createBorderLayer];
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    if(_showCrossLines) {
        [self showCrossLineLayer];
    }
    [self resetBorderLayerPath];
    
}
- (void)setBounds:(CGRect)bounds {
    
    [super setBounds:bounds];
    if(_showCrossLines) {
        [self showCrossLineLayer];
    }
    [self resetBorderLayerPath];
    
}
- (void)showCrossLineLayer {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(WIDTH(self) / 3.0, 0)];
    [path addLineToPoint: CGPointMake(WIDTH(self) / 3.0, HEIGHT(self))];
    [path moveToPoint:CGPointMake(WIDTH(self) / 3.0 * 2.0, 0)];
    [path addLineToPoint: CGPointMake(WIDTH(self) / 3.0 * 2.0, HEIGHT(self))];
    [path moveToPoint:CGPointMake(0, HEIGHT(self) / 3.0)];
    [path addLineToPoint: CGPointMake(WIDTH(self), HEIGHT(self) / 3.0)];
    [path moveToPoint:CGPointMake(0, HEIGHT(self) / 3.0 * 2.0)];
    [path addLineToPoint: CGPointMake(WIDTH(self), HEIGHT(self) / 3.0 * 2.0)];
    if(!_crossLineLayer) {
        _crossLineLayer = [CAShapeLayer layer];
        [self.layer addSublayer: _crossLineLayer];
    }
    _crossLineLayer.lineWidth = _crossLineWidth;
    _crossLineLayer.strokeColor = _crossLineColor.CGColor;
    _crossLineLayer.path = path.CGPath;
    
}
- (void)setCrossLineWidth:(CGFloat)crossLineWidth {
    
    _crossLineWidth = crossLineWidth;
    _crossLineLayer.lineWidth = crossLineWidth;
    
}
- (void)setCrossLineColor:(UIColor *)crossLineColor {
    
    _crossLineColor = crossLineColor;
    _crossLineLayer.strokeColor = crossLineColor.CGColor;
    
}
- (void)setShowCrossLines:(BOOL)showCrossLines {
    
    if(_showCrossLines && !showCrossLines) {
        [_crossLineLayer removeFromSuperlayer];
        _crossLineLayer = nil;
    }
    else if(!_showCrossLines && showCrossLines) {
        [self showCrossLineLayer];
    }
    _showCrossLines = showCrossLines;
    
}
- (void)createBorderLayer {
    
    if(_borderLayer && _borderLayer.superlayer) {
        [_borderLayer removeFromSuperlayer];
    }
    _borderLayer = [CAShapeLayer layer];
    [self.layer addSublayer: _borderLayer];
    
}
- (void)resetBorderLayerPath {
    
    UIBezierPath *layerPath = [UIBezierPath bezierPathWithRect: CGRectMake(_borderWidth / 2.0f, _borderWidth / 2.0f, WIDTH(self) - _borderWidth, HEIGHT(self) - _borderWidth)];
    _borderLayer.lineWidth = _borderWidth;
    _borderLayer.fillColor = nil;
    _borderLayer.path = layerPath.CGPath;
    
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    
    _borderWidth = borderWidth;
    [self resetBorderLayerPath];
    
}
- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    _borderLayer.strokeColor = borderColor.CGColor;
    
}
- (UIView *) hitTest:(CGPoint) point withEvent:(UIEvent *)event {
    
    for(UIView *subView in self.subviews) {
        if(CGRectContainsPoint(subView.frame, point)) {
            return subView;
        }
    }
    if(CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return nil;
    
}
@end
@interface TKImageView() {
    
    CGFloat currentMinSpace;
    
}
@property (strong, nonatomic) UIView *cropMaskView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) CropAreaView *cropAreaView;
@property (strong, nonatomic) UIPanGestureRecognizer *cropAreaPan;
@property (strong, nonatomic) UIPinchGestureRecognizer *cropAreaPinch;
@property (assign, nonatomic) CGSize pinchOriSize;
@property (assign, nonatomic) CGPoint cropAreaOriCenter;
@property (assign, nonatomic) CGRect cropAreaOriFrame;
@property (strong, nonatomic) MidLineView *topMidLine;
@property (strong, nonatomic) MidLineView *leftMidLine;
@property (strong, nonatomic) MidLineView *bottomMidLine;
@property (strong, nonatomic) MidLineView *rightMidLine;
@property (assign, nonatomic) CGFloat paddingLeftRight;
@property (assign, nonatomic) CGFloat paddingTopBottom;
@property (assign, nonatomic) CGFloat imageAspectRatio;
@property (assign, nonatomic, readonly) CGFloat cornerMargin;
@end
@implementation TKImageView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder: aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (void)commonInit {
    
    [self setUp];
    [self bindPanGestures];
    
}
- (void)dealloc {
    
    [_cropAreaView removeObserver: self forKeyPath: @"frame"];
    [_cropAreaView removeObserver: self forKeyPath: @"center"];
    [_imageView removeObserver: self forKeyPath: @"frame"];
    
}
- (void)setUp {
    
    _imageView = [[UIImageView alloc]initWithFrame: self.bounds];
    _imageView.contentMode = UIViewContentModeScaleToFill;
    _imageView.userInteractionEnabled = YES;
    _imageAspectRatio = 0;
    [self addSubview: _imageView];
    
    _cropMaskView = [[UIView alloc]initWithFrame: _imageView.bounds];
    _cropMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _cropMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_imageView addSubview: _cropMaskView];
    
    UIColor *defaultColor = [UIColor colorWithWhite: 1 alpha: 0.8];
    _cropAreaBorderLineColor = defaultColor;
    _cropAreaCornerLineColor = [UIColor whiteColor];
    _cropAreaBorderLineWidth = 2;
    _cropAreaCornerLineWidth = 4;
    _cropAreaCornerWidth = 20;
    _cropAreaCornerHeight = 20;
    _cropAspectRatio = 0;
    _minSpace = 10;
    currentMinSpace = _minSpace;
    _cropAreaCrossLineWidth = 2;
    _cropAreaCrossLineColor = defaultColor;
    _cropAreaMidLineWidth = 20;
    _cropAreaMidLineHeight = 4;
    _cropAreaMidLineColor = defaultColor;
    
    _cropAreaView = [[CropAreaView alloc] init];
    _cropAreaView.borderWidth = _cropAreaBorderLineWidth;
    _cropAreaView.borderColor = _cropAreaBorderLineColor;
    _cropAreaView.crossLineColor = _cropAreaCrossLineColor;
    _cropAreaView.crossLineWidth = _cropAreaCrossLineWidth;
//    _cropAreaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_imageView addSubview: _cropAreaView];
    
    [_cropAreaView addObserver: self
                    forKeyPath: @"frame"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    [_cropAreaView addObserver: self
                    forKeyPath: @"center"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    [_imageView addObserver: self
                    forKeyPath: @"frame"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    
}
#pragma mark - PanGesture Bind
- (void)bindPanGestures {
    _cropAreaPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCropAreaPan:)];
    [_cropAreaView addGestureRecognizer: _cropAreaPan];
    
}
#pragma mark - PinchGesture CallBack
- (void)handleCropAreaPinch: (UIPinchGestureRecognizer *)pinchGesture {
    
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _pinchOriSize = _cropAreaView.frame.size;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self resetCropAreaByScaleFactor: pinchGesture.scale];
            break;
        }
        default:
            break;
    }
    
}
#pragma mark - PanGesture CallBack
- (void)handleCropAreaPan: (UIPanGestureRecognizer *)panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriCenter = _cropAreaView.center;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: _imageView];
            CGPoint willCenter = CGPointMake(_cropAreaOriCenter.x + translation.x, _cropAreaOriCenter.y + translation.y);
            CGFloat centerMinX = WIDTH(_cropAreaView) / 2.0f + self.cornerMargin * _cornerBorderInImage ;
            CGFloat centerMaxX = WIDTH(_imageView) - WIDTH(_cropAreaView) / 2.0f - self.cornerMargin * _cornerBorderInImage;
            CGFloat centerMinY = HEIGHT(_cropAreaView) / 2.0f + self.cornerMargin * _cornerBorderInImage;
            CGFloat centerMaxY = HEIGHT(_imageView) - HEIGHT(_cropAreaView) / 2.0f - self.cornerMargin * _cornerBorderInImage;
            _cropAreaView.center = CGPointMake(MIN(MAX(centerMinX, willCenter.x), centerMaxX), MIN(MAX(centerMinY, willCenter.y), centerMaxY));
            break;
        }
        default:
            break;
    }
    
}

- (void)resetMinSpaceIfNeeded {
    
    CGFloat willMinSpace = MIN(WIDTH(_cropAreaView) - _cropAreaCornerWidth * 2 + self.cornerMargin * 2, HEIGHT(_cropAreaView) - _cropAreaCornerHeight * 2 + self.cornerMargin * 2);
    currentMinSpace = MIN(willMinSpace, _minSpace);
    
}
- (void)resetCropTransparentArea {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect: _imageView.bounds];
    UIBezierPath *clearPath = [[UIBezierPath bezierPathWithRect: _cropAreaView.frame] bezierPathByReversingPath];
    [path appendPath: clearPath];
    CAShapeLayer *shapeLayer = (CAShapeLayer *)_cropMaskView.layer.mask;
    if(!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
        [_cropMaskView.layer setMask: shapeLayer];
    }
    shapeLayer.path = path.CGPath;
    
}


- (void)createMidLines {
    
    if(_topMidLine && _bottomMidLine && _leftMidLine && _rightMidLine) return;
    _topMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _topMidLine.type = TKMidLineTypeTop;
    
    _bottomMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _bottomMidLine.type = TKMidLineTypeBottom;
    
    _leftMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _leftMidLine.type = TKMidLineTypeLeft;
    
    _rightMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _rightMidLine.type = TKMidLineTypeRight;
    
}
- (void)removeMidLines {
    
    [_topMidLine removeFromSuperview];
    [_bottomMidLine removeFromSuperview];
    [_leftMidLine removeFromSuperview];
    [_rightMidLine removeFromSuperview];
    
    _topMidLine = nil;
    _bottomMidLine = nil;
    _leftMidLine = nil;
    _rightMidLine = nil;
    
}
- (void)resetMidLines {
    
    CGFloat lineMargin = _cropAreaMidLineHeight / 2.0 - _cropAreaBorderLineWidth;
    _topMidLine.frame = CGRectMake((WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH) / 2.0, - MID_LINE_INTERACT_HEIGHT / 2.0 - lineMargin, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _bottomMidLine.frame = CGRectMake((WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH) / 2.0, HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT / 2.0 + lineMargin, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _leftMidLine.frame = CGRectMake(- MID_LINE_INTERACT_WIDTH / 2.0 - lineMargin, (HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT) / 2.0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    _rightMidLine.frame = CGRectMake(WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH / 2.0 + lineMargin, (HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT) / 2.0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT);
    
}
- (void)resetImageView {
    
    CGFloat selfAspectRatio = WIDTH(self) / HEIGHT(self);
    if(_imageAspectRatio > selfAspectRatio) {
        _paddingLeftRight = 0;
        _paddingTopBottom = floor((HEIGHT(self) - WIDTH(self) / _imageAspectRatio) / 2.0);
        _imageView.frame = CGRectMake(0, _paddingTopBottom, WIDTH(self), floor(WIDTH(self) / _imageAspectRatio));
    }
    else {
        _paddingTopBottom = 0;
        _paddingLeftRight = floor((WIDTH(self) - HEIGHT(self) * _imageAspectRatio) / 2.0);
        _imageView.frame = CGRectMake(_paddingLeftRight, 0, floor(HEIGHT(self) * _imageAspectRatio), HEIGHT(self));
    }
    
}
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
- (void)resetCropAreaByScaleFactor: (CGFloat)scaleFactor {
    
    CGPoint center = _cropAreaView.center;
    CGFloat tmpCornerMargin = self.cornerMargin * _cornerBorderInImage;
    CGFloat width = _pinchOriSize.width * scaleFactor;
    CGFloat height = _pinchOriSize.height * scaleFactor;
    CGFloat widthMax = MIN(WIDTH(_imageView) - center.x - tmpCornerMargin, center.x - tmpCornerMargin) * 2;
    CGFloat widthMin = currentMinSpace + _cropAreaCornerWidth * 2.0 - tmpCornerMargin * 2.0;
    CGFloat heightMax = MIN(HEIGHT(_imageView) - center.y - tmpCornerMargin, center.y - tmpCornerMargin) * 2;
    CGFloat heightMin = currentMinSpace + _cropAreaCornerWidth * 2.0 - tmpCornerMargin * 2;
    
    BOOL isMinimum = NO;
    if(_cropAspectRatio > 1) {
        if(height <= heightMin) {
            height = heightMin;
            width = height * _cropAspectRatio;
            isMinimum = YES;
        }
    }
    else {
        if(width <= widthMin) {
            width = widthMin;
            height = width / (_cropAspectRatio == 0 ? 1 : _cropAspectRatio);
            isMinimum = YES;
        }
    }
    if(!isMinimum) {
        if(_cropAspectRatio == 0) {
            if(width >= widthMax) {
                width = MIN(width, WIDTH(_imageView) - 2 * tmpCornerMargin);
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
            if(height > heightMax) {
                height = MIN(height, HEIGHT(_imageView) - 2 * tmpCornerMargin);
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
            
        }
        else if(_imageAspectRatio > _cropAspectRatio) {
            if(height >= heightMax) {
                height = MIN(height, HEIGHT(_imageView) - 2 * tmpCornerMargin);
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
            width = height * _cropAspectRatio;
            if(width > widthMax) {
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
        }
        else {
            if(width >= widthMax) {
                width = MIN(width, WIDTH(_imageView) - 2 * tmpCornerMargin);
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
            height = width / _cropAspectRatio;
            if(height > heightMax) {
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
        }
    }
    _cropAreaView.bounds = CGRectMake(0, 0, width, height);
    _cropAreaView.center = center;
    
}
#pragma mark - Setter & Getters
- (void)setInitialScaleFactor:(CGFloat)initialScaleFactor {
    
    _initialScaleFactor = MIN(1.0f, initialScaleFactor);
    
}
- (CGFloat)cornerMargin {
    
    return _cropAreaCornerLineWidth - _cropAreaBorderLineWidth;
    
}
- (void)setMaskColor:(UIColor *)maskColor {
    
    _maskColor = maskColor;
    _cropMaskView.backgroundColor = maskColor;
    
}
- (void)setMinSpace:(CGFloat)minSpace {
    
    _minSpace = minSpace;
    currentMinSpace = minSpace;
    
}
- (void)setToCropImage:(UIImage *)toCropImage {
    
    _toCropImage = toCropImage;
    _imageAspectRatio = toCropImage.size.width / toCropImage.size.height;
    _imageView.image = toCropImage;
    [self resetImageView];
    [self resetCropAreaByAspectRatio];
    
}
- (void)setNeedScaleCrop:(BOOL)needScaleCrop {
    
    if(!_needScaleCrop && needScaleCrop) {
        _cropAreaPinch = [[UIPinchGestureRecognizer alloc]initWithTarget: self action:@selector(handleCropAreaPinch:)];
        [_cropAreaView addGestureRecognizer: _cropAreaPinch];
    }
    else if(_needScaleCrop && !needScaleCrop){
        [_cropAreaView removeGestureRecognizer: _cropAreaPinch];
        _cropAreaPinch = nil;
    }
    _needScaleCrop = needScaleCrop;
    
}
- (void)setCropAreaCrossLineWidth:(CGFloat)cropAreaCrossLineWidth {
    
    _cropAreaCrossLineWidth = cropAreaCrossLineWidth;
    _cropAreaView.crossLineWidth = cropAreaCrossLineWidth;
    
}
- (void)setCropAreaCrossLineColor:(UIColor *)cropAreaCrossLineColor {
    
    _cropAreaCrossLineColor = cropAreaCrossLineColor;
    _cropAreaView.crossLineColor = cropAreaCrossLineColor;
    
}
- (void)setCropAreaMidLineWidth:(CGFloat)cropAreaMidLineWidth {
    
    _cropAreaMidLineWidth = cropAreaMidLineWidth;
    _topMidLine.lineWidth = cropAreaMidLineWidth;
    _bottomMidLine.lineWidth = cropAreaMidLineWidth;
    _leftMidLine.lineWidth = cropAreaMidLineWidth;
    _rightMidLine.lineWidth = cropAreaMidLineWidth;
    if(_showMidLines) {
        [self resetMidLines];
    }
    
}
- (void)setCropAreaMidLineHeight:(CGFloat)cropAreaMidLineHeight {
    
    _cropAreaMidLineHeight = cropAreaMidLineHeight;
    _topMidLine.lineHeight = cropAreaMidLineHeight;
    _bottomMidLine.lineHeight = cropAreaMidLineHeight;
    _leftMidLine.lineHeight = cropAreaMidLineHeight;
    _rightMidLine.lineHeight = cropAreaMidLineHeight;
    if(_showMidLines) {
        [self resetMidLines];
    }
    
}
- (void)setCropAreaMidLineColor:(UIColor *)cropAreaMidLineColor {
    
    _cropAreaMidLineColor = cropAreaMidLineColor;
    _topMidLine.lineColor = cropAreaMidLineColor;
    _bottomMidLine.lineColor = cropAreaMidLineColor;
    _leftMidLine.lineColor = cropAreaMidLineColor;
    _rightMidLine.lineColor = cropAreaMidLineColor;
    
}
- (void)setCropAreaBorderLineWidth:(CGFloat)cropAreaBorderLineWidth {
    
    _cropAreaBorderLineWidth = cropAreaBorderLineWidth;
    _cropAreaView.borderWidth = cropAreaBorderLineWidth;
    
}
- (void)setCropAreaBorderLineColor:(UIColor *)cropAreaBorderLineColor {
    
    _cropAreaBorderLineColor = cropAreaBorderLineColor;
    _cropAreaView.borderColor = cropAreaBorderLineColor;
    
}
- (void)setCropAreaCornerLineColor:(UIColor *)cropAreaCornerLineColor {
    
    _cropAreaCrossLineColor = cropAreaCornerLineColor;
    
}
- (void)setCropAreaCornerLineWidth:(CGFloat)cropAreaCornerLineWidth {
    
    _cropAreaCornerLineWidth = cropAreaCornerLineWidth;
    [self resetCropAreaByAspectRatio];
    
}
- (void)setCropAreaCornerWidth:(CGFloat)cropAreaCornerWidth {
    
    _cropAreaCornerWidth = cropAreaCornerWidth;
    
}
- (void)setCropAreaCornerHeight:(CGFloat)cropAreaCornerHeight {
    
    _cropAreaCornerHeight = cropAreaCornerHeight;
    
}
- (void)setCropAspectRatio:(CGFloat)cropAspectRatio {
    
    _cropAspectRatio = MAX(cropAspectRatio, 0);
    [self resetCropAreaByAspectRatio];
    
}
- (void)setShowMidLines:(BOOL)showMidLines {
    
    if(_cropAspectRatio == 0) {
        if(!_showMidLines && showMidLines) {
            [self createMidLines];
            [self resetMidLines];
        }
        else if(_showMidLines && !showMidLines) {
            [self removeMidLines];
        }
    }
    _showMidLines = showMidLines;
    
}
- (void)setShowCrossLines:(BOOL)showCrossLines {
    
    _showCrossLines = showCrossLines;
    _cropAreaView.showCrossLines = _showCrossLines;
    
}
- (void)setCornerBorderInImage:(BOOL)cornerBorderInImage {
    
    _cornerBorderInImage = cornerBorderInImage;
    [self resetCropAreaByAspectRatio];
    
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    [self resetImageView];
    
}
- (void)setCenter:(CGPoint)center {
    
    [super setCenter: center];
    [self resetImageView];
    
}
#pragma mark - KVO CallBack
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if([object isEqual: _cropAreaView]) {
        if(_showMidLines){
            [self resetMidLines];
        }
        [self resetCropTransparentArea];
        return;
    }
    if([object isEqual: _imageView]) {
        [self resetCropAreaByAspectRatio];
    }
    
}
#pragma Instance Methods
- (UIImage *)currentCroppedImage {
    
    CGFloat scaleFactor = WIDTH(_imageView) / _toCropImage.size.width;
    return [_toCropImage imageAtRect: CGRectMake((MINX(_cropAreaView) + _cropAreaBorderLineWidth) / scaleFactor, (MINY(_cropAreaView) + _cropAreaBorderLineWidth) / scaleFactor, (WIDTH(_cropAreaView) - 2 * _cropAreaBorderLineWidth) / scaleFactor, (HEIGHT(_cropAreaView) - 2 * _cropAreaBorderLineWidth) / scaleFactor)];
    
}
@end


