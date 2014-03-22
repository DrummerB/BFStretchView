//
//  UIGestureRecognizer+BFStretchView.m
//  BFStretchView
//
//  Created by Balázs Faludi on 22.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "UIGestureRecognizer+BFStretchView.h"

@implementation UIGestureRecognizer (BFStretchView)

- (CGPoint)bf_locationOfTouch:(NSInteger)touchIndex inScrollView:(UIView *)view {
	CGPoint location = [self locationOfTouch:touchIndex inView:view];
	return CGPointMake(location.x - view.bounds.origin.x, location.y - view.bounds.origin.y);
}


@end
