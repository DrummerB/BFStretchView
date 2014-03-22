//
//  BFStretchContentView.m
//  BFStretchView
//
//  Created by Balázs Faludi on 17.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFStretchContentView.h"

@implementation BFStretchContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//- (void)setTransform:(CGAffineTransform)transform {
//	
//	
////	transform.b = 0;
////	transform.d = 1;
//	
////	transform.a = 1;
////	transform.c = 0;
////	
//	[super setTransform:transform];
////
////	CGAffineTransform constrainedTransform = CGAffineTransformIdentity;
////	constrainedTransform.d = transform.d;
//////	constrainedTransform.a = transform.d;
//////	constrainedTransform.a = transform.a;
////	[super setTransform:constrainedTransform];
////	
//	CGFloat scaleX = sqrtf(transform.a * transform.a + transform.c * transform.c);
//	CGFloat scaleY = sqrtf(transform.b * transform.b + transform.d * transform.d);
//	
////	NSLog(@"TRANSFORM x: %f y: %f", scaleX, scaleY);
//}



@end
