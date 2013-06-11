//
// Created by Dmitry Korotchenkov on 31.05.13.
// Copyright (c) 2013 Dmitry Korotchenkov. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DKIpadViewController.h"
#import "DKIpadNavigationController.h"
#import "UIView+DKViewAdditions.h"


@implementation DKIpadViewController

- (id)initWithPortraitSize:(CGSize)portrait landscapeSize:(CGSize)landscape {
    self = [super init];
    if (self) {
        [self configureWithPortraitSize:portrait landscapeSize:landscape];
    }
    return self;
}

- (void)configureWithPortraitSize:(CGSize)portrait landscapeSize:(CGSize)landscape {
    self.portraitSize = portrait;
    self.landscapeSize = landscape;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.top = 0;
    self.view.autoresizingMask = UIViewAutoresizingNone;
    [self updateViewSizeToOrientation:DK_INTERFACE_ORIENTATION];
}


- (void)setLeftPosition:(CGFloat)left {
    self.view.left = left;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView animateFromCurrentStateWithDuration:duration animations:^{
        [self updateViewSizeToOrientation:toInterfaceOrientation];
    }];
}


- (void)updateViewSizeToOrientation:(UIInterfaceOrientation)orientation {
    CGFloat viewWidth = UIInterfaceOrientationIsLandscape(orientation) ? self.landscapeSize.width : self.portraitSize.width;
    CGFloat viewHeight = UIInterfaceOrientationIsLandscape(orientation) ? self.landscapeSize.height : self.portraitSize.height;
    self.view.width = viewWidth;
    self.view.height = viewHeight;
}

- (CGFloat)widthForOrientation:(UIInterfaceOrientation)orientation {
    if (UIDeviceOrientationIsPortrait(orientation))
        return self.portraitSize.width;
    else
        return self.landscapeSize.width;
}

@end