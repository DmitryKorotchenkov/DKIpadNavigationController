//
// Created by Dmitry Korotchenkov on 31.05.13.
// Copyright (c) 2013 Dmitry Korotchenkov. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DKIpadNavigationController.h"
#import "DKIpadNavigationControllerDelegate.h"
#import "DKIpadViewController.h"
#import "UIView+DKViewAdditions.h"


@interface DKIpadNavigationController ()
@property(nonatomic) CGFloat panBeganLeftPosition;
@end

@implementation DKIpadNavigationController

- (UIPanGestureRecognizer *)panGestureRecognizer {
    static UIPanGestureRecognizer *recognizer = nil;
    if (!recognizer) {
        recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecogniserHandler:)];
    }
    return recognizer;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setDefaultSettings];
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setDefaultSettings];
}


- (void)setDefaultSettings {
    self.controllersAlignment = DKIpadNavigationAlignmentCenter;
    self.landscapeSpacing = 0.0;
    self.portraitSpacing = 0.0;
}

- (id)initWithDelegate:(id <DKIpadNavigationControllerDelegate>)delegate {
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }

    return self;
}

- (void)setViewControllers:(NSArray *)controllers {
    for (DKIpadViewController *controller in controllers) {
        [self addViewController:controller];
    }
}

- (void)addViewController:(DKIpadViewController *)controller {
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
}

- (void)removeViewController:(DKIpadViewController *)controller {
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (void)commitConfiguring {
    if (self.childViewControllers.count > 0) {
        [self.lastViewController.view addGestureRecognizer:self.panGestureRecognizer];
    }
    [self updateViewControllersPositionsToInterfaceOrientation:DK_INTERFACE_ORIENTATION];
}

- (void)loadView {
    [super loadView];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    CGRect frame = CGRectZero;
    if (self.delegate) {
        frame = [self.delegate navigationViewFrameToInterfaceOrientation:DK_INTERFACE_ORIENTATION];
    }
    [self.view setFrame:frame];
}

- (void)pushViewController:(DKIpadViewController *)controller {
    UIInterfaceOrientation orientation = DK_INTERFACE_ORIENTATION;
    if (self.childViewControllers && self.childViewControllers.count > 0) {
        controller.view.left = [self widthForInterfaceOrientation:orientation];
        [self.lastViewController.view removeGestureRecognizer:self.panGestureRecognizer];
    } else {
        controller.view.left = self.view.innerCenterX;
    }
    [controller.view addGestureRecognizer:self.panGestureRecognizer];
    [self addViewController:controller];
    [UIView animateFromCurrentStateWithDuration:kIpadNavigationDuration animations:^{
        [self updateViewControllersPositionsToInterfaceOrientation:orientation];
    }];
}

- (void)panGestureRecogniserHandler:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.panBeganLeftPosition = gestureRecognizer.view.left;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat translationX = [gestureRecognizer translationInView:self.view].x;
        if (translationX < 0) {
            translationX = translationX / 2;
        }
        CGFloat left = self.panBeganLeftPosition + translationX;
        gestureRecognizer.view.left = left;
        [self updateViewControllersForInterfaceOrientation:DK_INTERFACE_ORIENTATION andLastControllerPosition:left];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
            gestureRecognizer.state == UIGestureRecognizerStateEnded ||
            gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        if (gestureRecognizer.view.centerX > self.view.right) {
            [self popViewController];
        } else {
            [UIView animateFromCurrentStateWithDuration:kIpadNavigationDuration animations:^{
                [self updateViewControllersPositionsToInterfaceOrientation:DK_INTERFACE_ORIENTATION];
            }];
        }

    }
}

- (void)popViewController {
    [([self lastViewController]).view removeGestureRecognizer:self.panGestureRecognizer];
    [UIView animateFromCurrentStateWithDuration:kIpadNavigationDuration
                                     animations:^{
                                         [self updateViewControllersForInterfaceOrientation:DK_INTERFACE_ORIENTATION andLastControllerPosition:[self widthForInterfaceOrientation:DK_INTERFACE_ORIENTATION]];
                                     }
                                     completion:^(BOOL finished) {
                                         [self removeViewController:[self lastViewController]];
                                         if (self.lastViewController) {
                                             [self.lastViewController.view addGestureRecognizer:self.panGestureRecognizer];
                                         }
                                     }];
}

- (DKIpadViewController *)lastViewController {
    return self.childViewControllers.lastObject;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [UIView animateFromCurrentStateWithDuration:duration animations:^{
        [self updateViewControllersPositionsToInterfaceOrientation:toInterfaceOrientation];
        [self.view setFrame:[self.delegate navigationViewFrameToInterfaceOrientation:toInterfaceOrientation]];
    }];
}

- (void)updateViewControllersForInterfaceOrientation:(UIInterfaceOrientation)orientation andLastControllerPosition:(CGFloat)position {
    if (!self.childViewControllers || self.childViewControllers.count < 1)
        return;
    NSUInteger controllersCount = self.childViewControllers.count;
    CGFloat widthOfViews[controllersCount - 1];
    for (NSUInteger i = 0; i < controllersCount - 1; i++) {
        DKIpadViewController *controller = [self.childViewControllers objectAtIndex:i];
        widthOfViews[i] = [controller widthForOrientation:orientation];
    }

    CGFloat maxWidth = position;

    CGFloat *controllersPositions = [self calculatePositionsForWidths:widthOfViews maxWidth:maxWidth count:controllersCount - 1 orientation:orientation];

    for (NSUInteger i = 0; i < controllersCount - 1; i++) {
        DKIpadViewController *controller = [self.childViewControllers objectAtIndex:i];
        [controller setLeftPosition:controllersPositions[i]];
    }
    DKIpadViewController *lastController = [self.childViewControllers objectAtIndex:controllersCount - 1];
    [lastController setLeftPosition:position];
    free(controllersPositions);
}

- (void)updateViewControllersPositionsToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (!self.childViewControllers || self.childViewControllers.count < 1)
        return;

    NSUInteger controllersCount = self.childViewControllers.count;
    CGFloat widthOfViews[controllersCount];
    for (NSUInteger i = 0; i < controllersCount; i++) {
        DKIpadViewController *controller = [self.childViewControllers objectAtIndex:i];
        widthOfViews[i] = [controller widthForOrientation:orientation];
    }

    CGFloat maxWidth = [self widthForInterfaceOrientation:orientation];

    CGFloat *controllersPositions = [self calculatePositionsForWidths:widthOfViews maxWidth:maxWidth count:controllersCount orientation:orientation];

    for (NSUInteger i = 0; i < controllersCount; i++) {
        DKIpadViewController *controller = [self.childViewControllers objectAtIndex:i];
        [controller setLeftPosition:controllersPositions[i]];
    }
    free(controllersPositions);
}

- (CGFloat *)calculatePositionsForWidths:(CGFloat[])widths maxWidth:(float)maxWidth count:(NSUInteger)count orientation:(UIInterfaceOrientation)orientation {

    CGFloat spacing = UIInterfaceOrientationIsPortrait(orientation) ? self.portraitSpacing : self.landscapeSpacing;

    CGFloat *positions = malloc(count * sizeof 1.0);

    if (spacing * count > maxWidth) {
        NSInteger maxControllers = (int) (maxWidth / spacing);
        NSUInteger firstVisibleController = count - maxControllers;
        for (NSUInteger i = 0; i < count; i++) {
            if (i >= firstVisibleController) {
                positions[i] = spacing * (i - firstVisibleController);
            } else {
                positions[i] = 0;
            }
        }
    } else {

        CGFloat widthsSum = 0;

        for (NSUInteger i = 0; i < count; i++) {
            positions[i] = spacing * i;
            widthsSum += widths[i];
        }

        CGFloat leftPosition = maxWidth;
        if (widthsSum < maxWidth) {
            if (self.controllersAlignment == DKIpadNavigationAlignmentLeft) {
                leftPosition = maxWidth - widthsSum;
            } else if (self.controllersAlignment == DKIpadNavigationAlignmentCenter &&
                    (maxWidth - widthsSum / 2) > [self widthForInterfaceOrientation:orientation] / 2) {
                leftPosition = [self widthForInterfaceOrientation:orientation] / 2 + widthsSum / 2;
            }
        }

        for (NSInteger i = count - 1; i >= 0; i--) {
            if (positions[i] >= leftPosition - widths[i]) {
                break;
            } else {
                positions[i] = leftPosition - widths[i];
                leftPosition = positions[i];
            }
        }


    }
    return positions;
}


- (CGFloat)widthForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (self.delegate) {
        return [self.delegate navigationViewFrameToInterfaceOrientation:orientation].size.width;
    } else {
        return 0;
    }

}

@end