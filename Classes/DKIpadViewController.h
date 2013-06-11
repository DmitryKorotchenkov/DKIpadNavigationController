//
// Created by Dmitry Korotchenkov on 31.05.13.
// Copyright (c) 2013 Dmitry Korotchenkov. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface DKIpadViewController : UIViewController
@property(nonatomic) CGSize portraitSize;
@property(nonatomic) CGSize landscapeSize;

- (id)initWithPortraitSize:(CGSize)portrait landscapeSize:(CGSize)landscape;

- (void)configureWithPortraitSize:(CGSize)portrait landscapeSize:(CGSize)landscape;

- (void)setLeftPosition:(CGFloat)left;

- (CGFloat)widthForOrientation:(UIInterfaceOrientation)orientation;
@end