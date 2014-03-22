//
//  UIGestureRecognizer+BFStretchView.h
//  BFStretchView
//
//  Created by Balázs Faludi on 22.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (BFStretchView)

- (CGPoint)bf_locationOfTouch:(NSInteger)touchIndex inScrollView:(UIView *)view;

@end
