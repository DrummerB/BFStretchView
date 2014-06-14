//
//  BFStretchView2.m
//  BFStretchView
//
//  Created by Balázs Faludi on 13.06.14.
//  Copyright (c) 2014 Balazs Faludi. All rights reserved.
//

#import "BFStretchView.h"
#import <objc/runtime.h>

@implementation BFStretchView {
	id<UIScrollViewDelegate> _realDelegate;
	UIView *_zoomedView;
	UIView *_zoomProxyView;
	BOOL _observingProxyView;
	
//	CGPoint initialPinchCentroid;
//	CGPoint initialCenter;
	CGPoint initialContentOffset;
	BOOL pinching;
	CGSize realContentSize;
}

#pragma mark - Initialization & Destruction

- (void)setup {
	super.delegate = self;
	_observingProxyView = NO;
	pinching = NO;
	_zoomProxyView = [[UIView alloc] initWithFrame:CGRectZero];
//	_zoomProxyView.hidden = YES;
	_zoomProxyView.backgroundColor = [UIColor redColor];
	[self addSubview:_zoomProxyView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Delegate swapping

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
    _realDelegate = delegate;
}

- (BOOL)selectorIsScrollViewDelegateMethod:(SEL)selector {
    Protocol *protocol = @protocol(UIScrollViewDelegate);
    struct objc_method_description description = protocol_getMethodDescription(protocol, selector, NO, YES);
    return (description.name != NULL);
}

- (BOOL)respondsToSelector:(SEL)selector {
    if ([self selectorIsScrollViewDelegateMethod:selector]) {
        return [_realDelegate respondsToSelector:selector] || [super respondsToSelector:selector];
    }
    return [super respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    if ([self selectorIsScrollViewDelegateMethod:selector]) {
        return _realDelegate;
    }
    return [super forwardingTargetForSelector:selector];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	static BOOL first = YES;
	if ([_realDelegate respondsToSelector:_cmd]) {
		UIView *view = [_realDelegate viewForZoomingInScrollView:scrollView];
		_zoomedView = view;
		if (_zoomedView) {
			[self stopObservingZoomProxyView];
			if (first) {
				_zoomProxyView.frame = _zoomedView.frame;
				first = NO;
			}
			[self startObservingZoomProxyView];
			return _zoomProxyView;
		}
	}
	return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	[self startObservingZoomProxyView];
//	initialPinchCentroid = [self.pinchGestureRecognizer locationInView:self.superview];
//	initialCenter = [self.superview convertPoint:_zoomedView.center fromView:self];
//	initialPinchCentroid = [_zoomedView convertPoint:initialPinchCentroid fromView:self];
//	NSLog(@"initial: %@", NSStringFromCGPoint(initialPinchCentroid));
	initialContentOffset = self.contentOffset;
	pinching = YES;
	if ([_realDelegate respondsToSelector:_cmd]) {
		[_realDelegate scrollViewWillBeginZooming:scrollView withView:view];
	}
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	[self stopObservingZoomProxyView];
	pinching = NO;
	if ([_realDelegate respondsToSelector:_cmd]) {
		[_realDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
//	NSLog(@"offset: %@", NSStringFromCGPoint(self.contentOffset));
	if ([_realDelegate respondsToSelector:_cmd]) {
		[_realDelegate scrollViewDidScroll:scrollView];
	}
}

#pragma mark - Observing

- (void)startObservingZoomProxyView {
	if (_observingProxyView) return;
	[_zoomProxyView addObserver:self forKeyPath:@"transform" options:0 context:nil];
	[_zoomProxyView addObserver:self forKeyPath:@"frame" options:0 context:nil];
	_observingProxyView = YES;
}

- (void)stopObservingZoomProxyView {
	if (!_observingProxyView) return;
	[_zoomProxyView removeObserver:self forKeyPath:@"transform"];
	[_zoomProxyView removeObserver:self forKeyPath:@"frame"];
	_observingProxyView = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {

//	if (!pinching) return;
	
	CGSize contentSize = CGSizeMake(realContentSize.width, realContentSize.height / self.zoomScale);
	[super setContentSize:contentSize];
	
//	CGPoint centroid = [self.pinchGestureRecognizer locationInView:self.superview];
//	CGPoint diff = CGPointMake(initialPinchCentroid.x - centroid.x, initialPinchCentroid.y - centroid.y);
	
//	CGPoint center = CGPointMake(initialCenter.x - diff.x, initialCenter.y - diff.y);
//	center = [self.superview convertPoint:center toView:self];

	CGAffineTransform transform = CGAffineTransformMakeScale(self.zoomScale, 1);
	_zoomedView.transform = transform;
	
	CGFloat offset = (_zoomProxyView.frame.size.height - _zoomedView.frame.size.height) / 4;
	
	CGPoint center = _zoomedView.center;
	center.x = _zoomProxyView.center.x;
	center.y = _zoomedView.frame.size.height / 2;//-self.contentOffset.y / 8+ _zoomedView.frame.size.height / 2;
	_zoomedView.center = center;
	
	CGPoint contentOffset = self.contentOffset;
	if (self.pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || self.pinchGestureRecognizer.state == UIGestureRecognizerStateChanged || self.pinchGestureRecognizer.state == UIGestureRecognizerStateCancelled || self.pinchGestureRecognizer.state == UIGestureRecognizerStateEnded)
		contentOffset.y = initialContentOffset.y;
	self.contentOffset = contentOffset;
	
//	CGRect frame = _zoomedView.frame;
//	frame.origin.x = _zoomProxyView.frame.origin.x;
//	frame.origin.y = 0;
//	_zoomedView.frame = frame;
	
//	NSLog(@"diff: %@", NSStringFromCGPoint(diff));
	
//	center.y = centroid.y - initialPinchCentroid.y + roundf(_zoomedView.frame.size.height / 2;
    // self.contentOffset.y + _zoomedView.bounds.size.height / 2;
	
//	CGAffineTransform transform = _zoomProxyView.transform;
//	transform.d = 1.0;
//	_zoomedView.transform = transform;
//	_zoomedView.frame = _zoomProxyView.frame;
}

- (void)setContentSize:(CGSize)contentSize {
	[super setContentSize:contentSize];
	realContentSize = contentSize;
}

@end
