//
//  ViewController.m
//  MFSpringViewDemo
//
//  Created by Lyman Li on 2018/11/25.
//  Copyright © 2018年 Lyman Li. All rights reserved.
//

#import "MFSpringView.h"

#import "ViewController.h"

@interface ViewController () <MFSpringViewDelegate>

@property (weak, nonatomic) IBOutlet MFSpringView *springView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineSpace;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, assign) CGFloat currentTop;  // 上方横线距离纹理顶部的高度
@property (nonatomic, assign) CGFloat currentBottom;    // 下方横线距离纹理顶部的高度

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupButtons];
    self.springView.springDelegate = self;
    [self.springView updateImage:[UIImage imageNamed:@"girl.jpg"]];
    
    self.topLineSpace.constant = 200;
    self.bottomLineSpace.constant = 300;
    self.currentTop = [self stretchAreaYWithLineSpace:self.topLineSpace.constant];
    self.currentBottom = [self stretchAreaYWithLineSpace:self.bottomLineSpace.constant];
}

#pragma mark - Private

- (void)setupButtons {
    self.topButton.layer.borderWidth = 1;
    self.topButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.topButton addGestureRecognizer:[[UIPanGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(actionPanTop:)]];
    
    self.bottomButton.layer.borderWidth = 1;
    self.bottomButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.bottomButton addGestureRecognizer:[[UIPanGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(actionPanBottom:)]];
}

- (CGFloat)stretchAreaYWithLineSpace:(CGFloat)lineSpace {
    return (lineSpace / self.springView.bounds.size.height - self.springView.textureTopY) / self.springView.textureHeight;
}

#pragma mark - Action

- (void)actionPanTop:(UIPanGestureRecognizer *)pan {
    if ([self.springView hasChange]) {
        [self.springView updateTexture];
        self.slider.value = 0.5f; // 重置滑杆位置
    }
    
    CGPoint translation = [pan translationInView:self.view];
    self.topLineSpace.constant = MIN(self.topLineSpace.constant + translation.y,
                                     self.bottomLineSpace.constant);
    CGFloat textureTop = self.springView.bounds.size.height * self.springView.textureTopY;
    self.topLineSpace.constant = MAX(self.topLineSpace.constant, textureTop);
    [pan setTranslation:CGPointZero inView:self.view];
    
    self.currentTop = [self stretchAreaYWithLineSpace:self.topLineSpace.constant];
}

- (void)actionPanBottom:(UIPanGestureRecognizer *)pan {
    if ([self.springView hasChange]) {
        [self.springView updateTexture];
        self.slider.value = 0.5f; // 重置滑杆位置
    }
    
    CGPoint translation = [pan translationInView:self.view];
    self.bottomLineSpace.constant = MAX(self.bottomLineSpace.constant + translation.y,
                                        self.topLineSpace.constant);
    CGFloat textureBottom = self.springView.bounds.size.height * self.springView.textureBottomY;
    self.bottomLineSpace.constant = MIN(self.bottomLineSpace.constant, textureBottom);
    [pan setTranslation:CGPointZero inView:self.view];
    
    self.currentBottom = [self stretchAreaYWithLineSpace:self.bottomLineSpace.constant];
}

#pragma mark - IBAction

- (IBAction)sliderValueDidChanged:(UISlider *)sender {
    CGFloat newHeight = (self.currentBottom - self.currentTop) * ((sender.value) + 0.5);
    [self.springView stretchingFromStartY:self.currentTop
                                   toEndY:self.currentBottom
                            withNewHeight:newHeight];
}

#pragma mark - MFSpringViewDelegate

- (void)springViewStretchAreaDidChanged:(MFSpringView *)springView {
    CGFloat topY = self.springView.bounds.size.height * self.springView.stretchAreaTopY;
    CGFloat bottomY = self.springView.bounds.size.height * self.springView.stretchAreaBottomY;
    self.topLineSpace.constant = topY;
    self.bottomLineSpace.constant = bottomY;
}

@end
