//
//  BFStretchView.m
//  BFStretchView
//
//  Created by Balázs Faludi on 17.03.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFStretchView.h"
#import "UIGestureRecognizer+BFStretchView.h"

#define IsHorizontal (_stretchDirection == BFStretchViewDirectionHorizontal)
#define IsVertical (_stretchDirection == BFStretchViewDirectionVertical)
#define BoundsLength (IsHorizontal ? self.bounds.size.width : self.bounds.size.height)
#define BoundsHeight (IsHorizonal ? self.bounds.size.height : self.bounds.size.width)
#define ContentOffset (IsHorizontal ? self.contentOffset.x : self.contentOffset.y)

@implementation BFStretchView {
	// These values are set when the pinch gesture is first recognized.
	CGFloat startCentroid;				// The point between the two fingers that initialted the pinch gesture. Used to get translation.
	CGFloat startDistance;				// The distance between the two fingers. Used to calculate scaling.
	CGAffineTransform startTransform;	// The transform that the _contentView had when the pinching started.
	CGFloat startContentOffset;			// The content offset of the scroll view.
	
	CGFloat lastCentroid;				// Temporary storage for the centroid from the last movement. Used when the gesture ends.
}

#pragma mark - Initialization & Destruction

- (void)setup {
	_stretchDirection = BFStretchViewDirectionVertical;
	
	_contentView = [[UIView alloc] initWithFrame:self.bounds];
	_contentView.backgroundColor = [UIColor redColor];
	[super addSubview:_contentView];
	
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self addGestureRecognizer:pinchRecognizer];
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

#pragma mark - Getters & Setters

- (void)setStretchDirection:(BFStretchViewDirection)stretchDirection {
	if (_stretchDirection != stretchDirection) {
		_stretchDirection = stretchDirection;
	}
}

- (void)setContentSize:(CGSize)contentSize {
	[super setContentSize:contentSize];
	_contentView.frame = (CGRect){_contentView.frame.origin, contentSize};
}

// Override addSubview to add any subviews to the contentView instead.
- (void)addSubview:(UIView *)view {
	[_contentView addSubview:view];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
	[_contentView insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
	[_contentView insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
	[_contentView insertSubview:view belowSubview:siblingSubview];
}

#pragma mark - Zooming

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchRecognizer {

	if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint startPointA = [pinchRecognizer bf_locationOfTouch:0 inScrollView:self];
		CGPoint startPointB = [pinchRecognizer bf_locationOfTouch:1 inScrollView:self];
		startCentroid = IsHorizontal ? (startPointA.x + startPointB.x) / 2 : (startPointA.y + startPointB.y) / 2;
		startDistance = IsHorizontal ? startPointA.x - startPointB.x : startPointA.y - startPointB.y;;
		startTransform = _contentView.transform;
		startContentOffset = self.contentOffset.y;
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

			CGFloat offset = (startContentOffset + startCentroid) * limitingZoomScale - startCentroid;
			if (tooSmall && offset < 0) offset = 0;
			CGPoint contentOffset = IsHorizontal ? CGPointMake(offset, self.contentOffset.y)
												 : CGPointMake(self.contentOffset.x, offset);
			
			
			*scaleValue = limitingZoomScale;
			[UIView animateWithDuration:0.3 animations:^{
				_contentView.transform = t;
				if (tooBig) {
					self.contentOffset = contentOffset;
				}
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

	if (!self.bouncesZoom) {
		scale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, scale));
	}
	
	CGFloat offsetDiff = startContentOffset + startCentroid;
	CGFloat scaledDiff = offsetDiff * scale;
	
	CGAffineTransform t = CGAffineTransformIdentity;
	t.d = startTransform.d * scale;
	_contentView.transform = t;
	
//	self.contentSize = _contentView.frame.size;
	self.contentOffset = CGPointMake(self.contentOffset.x, scaledDiff - startCentroid - translation);
	
	_contentView.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);

}

@end
