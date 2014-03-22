//
//  BFStretchView.m
//  BFStretchView
//
//  Created by Balázs Faludi on 17.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFStretchView.h"
#import "BFStretchContentView.h"
#import "BFDebugView.h"
#import "UIGestureRecognizer+BFStretchView.h"

#define IsHorizontal (_stretchDirection == BFStretchViewDirectionHorizontal)
#define IsVertical (_stretchDirection == BFStretchViewDirectionVertical)
#define BoundsLength (IsHorizontal ? self.bounds.size.width : self.bounds.size.height)
#define BoundsHeight (IsHorizonal ? self.bounds.size.height : self.bounds.size.width)
#define ContentOffset (IsHorizontal ? self.contentOffset.x : self.contentOffset.y)

@implementation BFStretchView {
	BFStretchContentView *_contentView;
	
//	CGPoint startPointA;
//	CGPoint startPointB;
	CGFloat startCentroid;
	CGFloat startDistance;
	CGAffineTransform startTransform;
	CGFloat startOffset;
	
	CGFloat lastCentroid;
}

- (void)setup {
	_stretchDirection = BFStretchViewDirectionVertical;
	
	CGRect contentFrame = CGRectMake(0, 0, 320, 2000);
	_contentView = [[BFStretchContentView alloc] initWithFrame:contentFrame];
	[self addSubview:_contentView];
	
	self.contentSize = _contentView.frame.size;
	self.showsHorizontalScrollIndicator = YES;
	self.showsVerticalScrollIndicator = YES;
	self.alwaysBounceHorizontal = NO;
	self.alwaysBounceVertical = YES;
	self.delegate = self;
	
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self addGestureRecognizer:pinchRecognizer];
	
	BFDebugView *debugView = [[BFDebugView alloc] initWithFrame:contentFrame];
	debugView.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
	[_contentView addSubview:debugView];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchRecognizer {

	if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint startPointA = [pinchRecognizer bf_locationOfTouch:0 inScrollView:self];
		CGPoint startPointB = [pinchRecognizer bf_locationOfTouch:1 inScrollView:self];
		startCentroid = IsHorizontal ? (startPointA.x + startPointB.x) / 2 : (startPointA.y + startPointB.y) / 2;
		startDistance = IsHorizontal ? startPointA.x - startPointB.x : startPointA.y - startPointB.y;;
		startTransform = _contentView.transform;
		startOffset = self.contentOffset.y;
		return;
	}
	
	if (pinchRecognizer.state == UIGestureRecognizerStateEnded || pinchRecognizer.state == UIGestureRecognizerStateCancelled) {
		if (self.contentOffset.x < 0 || self.contentOffset.y < 0) {
			[self setContentOffset:CGPointMake(0, 0) animated:YES];
		}
		CGAffineTransform t = _contentView.transform;
		
		CGFloat *scaleValue = IsHorizontal ? &(t.a) : &(t.d);
		BOOL tooSmall = *scaleValue < self.minimumZoomScale;
		BOOL tooBig = *scaleValue > self.maximumZoomScale;
		if (tooSmall || tooBig) {
			CGFloat limitingZoomScale = tooSmall ? self.minimumZoomScale : self.maximumZoomScale;
			CGFloat contentOffset = (startOffset + startCentroid) * limitingZoomScale - startCentroid;
			if (tooSmall && contentOffset < 0) contentOffset = 0;
			*scaleValue = limitingZoomScale;
			[UIView animateWithDuration:0.3 animations:^{
				_contentView.transform = t;
				self.contentOffset = IsHorizontal ? CGPointMake(contentOffset, self.contentOffset.y)
												  : CGPointMake(self.contentOffset.x, contentOffset);
				self.contentSize = _contentView.frame.size;
				_contentView.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
			}];
		}
		return;
	}
	
	if (pinchRecognizer.numberOfTouches < 2) return;

	CGPoint pointA = [pinchRecognizer bf_locationOfTouch:0 inScrollView:self];
	CGPoint pointB = [pinchRecognizer bf_locationOfTouch:1 inScrollView:self];

	lastCentroid = IsHorizontal ? (pointA.x + pointB.x) / 2 : (pointA.y + pointB.y) / 2;
	CGFloat translation = (lastCentroid - startCentroid);
	
	CGFloat nowDist = IsHorizontal ? pointA.x - pointB.x : pointA.y - pointB.y;
	CGFloat scale = (nowDist / startDistance);

	CGFloat offsetDiff = startOffset + startCentroid;
	CGFloat scaledDiff = offsetDiff * scale;
	
	CGAffineTransform t = CGAffineTransformIdentity;
	t.d = startTransform.d * scale;
	_contentView.transform = t;
	
	self.contentSize = _contentView.frame.size;
	self.contentOffset = CGPointMake(self.contentOffset.x, scaledDiff - startCentroid - translation);
	
	_contentView.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);

}



@end
