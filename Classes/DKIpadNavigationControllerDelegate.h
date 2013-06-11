    //
// Created by Dmitry Korotchenkov on 31.05.13.
// Copyright (c) 2013 Dmitry Korotchenkov. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@protocol DKIpadNavigationControllerDelegate <NSObject>

- (CGRect)navigationViewFrameToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end