//
// Created by Dmitry Korotchenkov on 31.05.13.
// Copyright (c) 2013 Dmitry Korotchenkov. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#define DK_INTERFACE_ORIENTATION [[UIApplication sharedApplication] statusBarOrientation]

@protocol DKIpadNavigationControllerDelegate;
@class DKIpadViewController;

static const float kIpadNavigationDuration = 0.375;
typedef enum {
    DKIpadNavigationAlignmentCenter,
    DKIpadNavigationAlignmentLeft,
    DKIpadNavigationAlignmentRight,
} DKIpadNavigationAlignment;

@interface DKIpadNavigationController : UIViewController

@property(nonatomic, weak) id <DKIpadNavigationControllerDelegate> delegate;

@property(nonatomic) DKIpadNavigationAlignment controllersAlignment;

@property(nonatomic) float landscapeSpacing;

@property(nonatomic) float portraitSpacing;

- (id)initWithDelegate:(id <DKIpadNavigationControllerDelegate>)delegate;

- (void)setViewControllers:(NSArray *)controllers;

- (void)commitConfiguring;

- (void)pushViewController:(DKIpadViewController *)controller;

- (void)popViewController;
@end